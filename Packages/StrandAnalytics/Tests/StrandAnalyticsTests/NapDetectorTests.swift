import XCTest
@testable import StrandAnalytics
import WhoopProtocol

/// Pins the Swift `NapDetector`, the twin of Android's `NapDetector.kt`: a quiet run of 20 to 90 minutes with a
/// settled heart rate is a NAP to ask about, never written by itself. The oracle at the end runs a generator both
/// languages share (an MMIX LCG) and is asserted with the same literals by Kotlin `NapDetectorOracleTest`.
final class NapDetectorTests: XCTestCase {

    /// Two hours at 30-second gravity samples: moving, then still for `quietMinutes`, then moving; heart rate
    /// every minute, `quietHr` while still and 95 while moving.
    private func napFixture(quietMinutes: Int, quietHr: Int, start: Int = 1_800_000_000)
        -> ([GravitySample], [HRSample]) {
        var grav: [GravitySample] = []
        var hr: [HRSample] = []
        let quietFrom = start + 20 * 60, quietTo = quietFrom + quietMinutes * 60
        for i in 0..<(240) {
            let ts = start + i * 30
            let still = ts >= quietFrom && ts < quietTo
            grav.append(GravitySample(ts: ts, x: still ? 0 : (i % 2 == 0 ? 0.6 : -0.6), y: 0, z: 1))
        }
        for i in 0..<120 {
            let ts = start + i * 60
            hr.append(HRSample(ts: ts, bpm: (ts >= quietFrom && ts < quietTo) ? quietHr : 95))
        }
        return (grav, hr)
    }

    func testAQuietRunWithASettledHeartRateIsANapToAskAbout() {
        let (g, h) = napFixture(quietMinutes: 35, quietHr: 58)
        let d = NapDetector.evaluate(gravity: g, hr: h, restingHr: 55, config: NapConfig())
        XCTAssertEqual(d.verdict, .nap)
        XCTAssertNotNil(d.candidate)
        XCTAssertGreaterThanOrEqual(d.candidate!.durationS, 20 * 60)
    }

    func testStillButAwakeIsNotANap() {
        let (g, h) = napFixture(quietMinutes: 35, quietHr: 75)
        XCTAssertEqual(NapDetector.evaluate(gravity: g, hr: h, restingHr: 55, config: NapConfig()).verdict, .none)
    }

    func testTooShortTooLongOffAndSparse() {
        let (short, h1) = napFixture(quietMinutes: 12, quietHr: 56)
        XCTAssertEqual(NapDetector.evaluate(gravity: short, hr: h1, restingHr: 55, config: NapConfig()).verdict, .none)
        let (long, h2) = napFixture(quietMinutes: 96, quietHr: 56)
        XCTAssertEqual(NapDetector.evaluate(gravity: long, hr: h2, restingHr: 55, config: NapConfig()).verdict,
                       .inconclusive, "longer than 90 minutes may be main sleep")
        let (g, h) = napFixture(quietMinutes: 35, quietHr: 56)
        XCTAssertEqual(NapDetector.evaluate(gravity: g, hr: h, restingHr: 55,
                                            config: NapConfig(enabled: false)).verdict, .inconclusive)
        let sparse = Array(g.enumerated().filter { $0.offset % 8 == 0 }.map(\.element))
        XCTAssertEqual(NapDetector.evaluate(gravity: sparse, hr: h, restingHr: 55, config: NapConfig()).verdict,
                       .inconclusive)
    }

    // MARK: - The oracle (shared with Kotlin)

    private var napLcg: UInt64 = 0x5851F42D4C957F2D

    private func napNext(_ n: Int) -> Int {
        napLcg = napLcg &* 6364136223846793005 &+ 1442695040888963407
        return Int((napLcg >> 33) % UInt64(n))
    }

    func testMatchesTheKotlinOracle() {
        var h: UInt64 = 0xcbf29ce484222325
        var first: [String] = []
        for i in 0..<300 {
            let start = 1_800_000_000 + napNext(10_000) * 30
            let quiet = 5 + napNext(110)
            let quietFrom = start + (5 + napNext(30)) * 60
            let resting: Int? = napNext(5) == 0 ? nil : 45 + napNext(20)
            let hrOffset = napNext(25) - 5
            let step = [30, 30, 60, 120][napNext(4)]
            var grav: [GravitySample] = []
            var hr: [HRSample] = []
            for k in 0..<(9000 / step) {
                let ts = start + k * step
                let still = ts >= quietFrom && ts < quietFrom + quiet * 60
                let jitter = Double(napNext(7) - 3) / 1000.0
                grav.append(GravitySample(ts: ts, x: still ? jitter : (k % 2 == 0 ? 0.5 : -0.5) + jitter, y: 0.1, z: 0.98))
            }
            for k in 0..<150 {
                let ts = start + k * 60
                let still = ts >= quietFrom && ts < quietFrom + quiet * 60
                hr.append(HRSample(ts: ts, bpm: still ? (resting ?? 60) + hrOffset : 90 + napNext(20)))
            }
            let d = NapDetector.evaluate(gravity: grav, hr: hr, restingHr: resting, config: NapConfig())
            let c = d.candidate
            let line = "\(d.verdict.rawValue)|\(c?.start ?? -1)|\(c?.end ?? -1)|\(c?.meanHr ?? -1)|"
                + String(c?.confidence.bitPattern ?? 0, radix: 16)
            for b in line.utf8 { h ^= UInt64(b); h = h &* 0x100000001b3 }
            h ^= 0x0A; h = h &* 0x100000001b3
            if i < 3 { first.append(line) }
        }
        XCTAssertEqual(first[1], "NAP|1800201060|1800204660|57|3fe9d41d41d41d42")
        XCTAssertEqual(String(format: "%016llx", h), "88d66a6214fd4b33")
    }
}
