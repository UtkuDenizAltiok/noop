import XCTest
@testable import Strand

/// Pins the iPhone step calibration's rules (`StepCalibration`): only windows where both the phone and the strap
/// saw real walking count, two hours of them are needed, the divisor is their median ticks-per-step rounded to
/// hundredths, and an implausible or inconsistent set changes nothing.
final class StepCalibrationTests: XCTestCase {

    private func calPair(_ phone: Int, _ ticks: Int, _ i: Int = 0) -> StepCalibration.Pair {
        StepCalibration.Pair(start: 1_800_000_000 + i * 900, phoneSteps: phone, strapTicks: ticks)
    }

    func testTheMedianOfWalkingWindowsBecomesTheDivisor() {
        // Eight walks at 1.10 to 1.30 ticks per step, plus windows that must not count.
        let walks = [(1000, 1100), (1200, 1380), (900, 1035), (1500, 1800), (1100, 1265), (800, 920), (1300, 1560), (1000, 1170)]
            .enumerated().map { calPair($0.element.0, $0.element.1, $0.offset) }
        let ignored = [calPair(300, 900, 20), calPair(1200, 50, 21)]   // phone barely walking; strap not counting
        let result = StepCalibration.calibrate(walks + ignored, now: 7)
        XCTAssertEqual(result?.windows, 8)
        XCTAssertEqual(result?.ticksPerStep, 1.15)   // sorted 1.10 1.15 1.15 1.15 [1.15] 1.17 1.20 1.20
        XCTAssertEqual(result?.phoneSteps, walks.reduce(0) { $0 + $1.phoneSteps })
        XCTAssertEqual(result?.at, 7)
    }

    func testTwoHoursOfWalkingAreNeeded() {
        let seven = (0..<7).map { calPair(1000, 1200, $0) }
        XCTAssertNil(StepCalibration.calibrate(seven, now: 0))
        XCTAssertNotNil(StepCalibration.calibrate(seven + [calPair(1000, 1200, 7)], now: 0))
        XCTAssertEqual(StepCalibration.minWindows, 8)
        XCTAssertEqual(StepCalibration.windowSeconds, 900)
    }

    func testAnImplausibleOrInconsistentSetChangesNothing() {
        // A strap counting four ticks a step is outside 0.5 to 3.
        XCTAssertNil(StepCalibration.calibrate((0..<10).map { calPair(1000, 4000, $0) }, now: 0))
        // Windows that disagree wildly (0.6 to 2.4) are not one walking pattern.
        let scattered = [600, 900, 1200, 1500, 1800, 2100, 2400, 700, 2300, 1000].enumerated()
            .map { calPair(1000, $0.element, $0.offset) }
        XCTAssertNil(StepCalibration.calibrate(scattered, now: 0))
    }
}
