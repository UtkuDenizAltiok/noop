import Foundation
import WhoopProtocol

// NapDetector.swift — the Swift twin of Android's short-nap review detector (`NapDetector.kt`, reimplemented
// from @cbarrado's PR #569), for Utku's report of 27 Nov 2026 that naps go unrecognised: a still daytime run
// must last 90 minutes to become a session (`SleepStager.daytimeMinSleepMin`), so a 20 to 60 minute nap never
// does.
//
// A nap is INFERRED from a short stretch where the wrist goes quiet and the heart rate settles near the
// wearer's resting band, and the inference is conservative: a tri-state verdict that NEVER writes a session.
// A confident NAP is offered as a question the wearer answers ("Did you nap from 15:10 to 15:42?"); only a Yes
// adds it, through the same hand-added nap path as the Sleep tab's "Add a nap" (`Repository.addManualNap`).
// Why a question: heart rate alone separates quiet wakefulness from early sleep poorly (it fell a median of
// 2 bpm from quiet wake in bed to the first 20 minutes of sleep on 31 PSG nights, `Tools/SleepPSG --section
// onset`), so a wrong nap must never reach the totals by itself.
//
// Pure: no I/O, no clock reads; all times are unix seconds. Byte-identical to the Kotlin twin; the oracle is in
// `NapDetectorTests` and its Kotlin mirror `NapDetectorOracleTest`.

/// Tri-state verdict for one candidate window (Android: `NapVerdict`).
public enum NapVerdict: String, Equatable, Sendable {
    case nap = "NAP"
    case none = "NONE"
    case inconclusive = "INCONCLUSIVE"
}

/// A proposed nap the wearer can confirm or dismiss. `confidence` orders candidates only; it is not a
/// probability (Android: `NapCandidate`).
public struct NapCandidate: Equatable, Sendable, Codable {
    public let start: Int
    public let end: Int
    public let meanHr: Int?
    public let confidence: Double
    public var durationS: Int { end - start }
    public init(start: Int, end: Int, meanHr: Int?, confidence: Double) {
        self.start = start; self.end = end; self.meanHr = meanHr; self.confidence = confidence
    }
}

/// One evaluation's outcome (Android: `NapDecision`).
public struct NapDecision: Equatable, Sendable {
    public let verdict: NapVerdict
    public let candidate: NapCandidate?
}

/// The thresholds, identical to Android's defaults (Android: `NapConfig`).
public struct NapConfig: Equatable, Sendable {
    public var enabled: Bool
    public var minNapMinutes: Int
    public var maxNapMinutes: Int
    public var stillThresholdG: Double
    public var hrSettleMarginBpm: Int
    public var smoothWindowSeconds: Double
    public init(enabled: Bool = true,
                minNapMinutes: Int = NapDetector.defaultMinNapMin,
                maxNapMinutes: Int = NapDetector.defaultMaxNapMin,
                stillThresholdG: Double = NapDetector.defaultStillThresholdG,
                hrSettleMarginBpm: Int = NapDetector.defaultHrSettleMarginBpm,
                smoothWindowSeconds: Double = NapDetector.defaultSmoothWindowS) {
        self.enabled = enabled; self.minNapMinutes = minNapMinutes; self.maxNapMinutes = maxNapMinutes
        self.stillThresholdG = stillThresholdG; self.hrSettleMarginBpm = hrSettleMarginBpm
        self.smoothWindowSeconds = smoothWindowSeconds
    }
}

public enum NapDetector {
    /// Kotlin twin: `NapDetector.DEFAULT_MIN_NAP_MIN`.
    public static let defaultMinNapMin: Int = 20
    /// Kotlin twin: `NapDetector.DEFAULT_MAX_NAP_MIN`.
    public static let defaultMaxNapMin: Int = 90
    /// Kotlin twin: `NapDetector.DEFAULT_STILL_THRESHOLD_G`.
    public static let defaultStillThresholdG: Double = 0.08
    /// Kotlin twin: `NapDetector.DEFAULT_HR_SETTLE_MARGIN_BPM`.
    public static let defaultHrSettleMarginBpm: Int = 8
    /// Kotlin twin: `NapDetector.DEFAULT_SMOOTH_WINDOW_S`.
    public static let defaultSmoothWindowS: Double = 120.0
    /// A data hole longer than this breaks a quiet run. Kotlin twin: `NapDetector.MAX_GAP_S`.
    public static let maxGapS: Int = 10 * 60
    /// Kotlin twin: `NapDetector.DEFAULT_MIN_GRAVITY_SAMPLES`.
    public static let defaultMinGravitySamples: Int = 20
    /// Kotlin twin: `NapDetector.DEFAULT_MAX_MEDIAN_GAP_S`.
    public static let defaultMaxMedianGapS: Int = 90

    /// Dense enough to judge: at least `minSamples` gravity rows whose median gap is at most `maxMedianGapS`.
    /// Kotlin twin: `NapDetector.isWindowDense`.
    public static func isWindowDense(_ gravity: [GravitySample], minSamples: Int = defaultMinGravitySamples,
                                     maxMedianGapS: Int = defaultMaxMedianGapS) -> Bool {
        guard gravity.count >= minSamples else { return false }
        let ts = gravity.map(\.ts).sorted()
        let gaps = zip(ts, ts.dropFirst()).map { $1 - $0 }.filter { $0 >= 0 }
        guard !gaps.isEmpty else { return false }
        let sorted = gaps.sorted()
        return sorted[sorted.count / 2] <= maxMedianGapS
    }

    /// The longest stretch of smoothed wrist motion at or under `stillThresholdG`, unbroken by motion or by a
    /// data gap over `maxGapS`, as (start, end). Kotlin twin: `NapDetector.longestQuietRun`.
    public static func longestQuietRun(_ gravity: [GravitySample], stillThresholdG: Double = defaultStillThresholdG,
                                       smoothWindowSeconds: Double = defaultSmoothWindowS) -> (start: Int, end: Int)? {
        let rows = gravity.enumerated().sorted {
            $0.element.ts == $1.element.ts ? $0.offset < $1.offset : $0.element.ts < $1.element.ts
        }.map(\.element)
        guard rows.count >= 2 else { return nil }
        let motion = WorkoutDetector.activitySeries(rows)
        let smoothed = WorkoutDetector.smoothedIntensity(motion, windowS: smoothWindowSeconds)
        let ts = motion.map(\.ts)
        var bestStart = -1, bestEnd = -1, runStart = -1
        // Kotlin's local `closeRun`, as a closure: it ends the open run at `endIdx` and keeps the longest.
        let endRunAt: (Int) -> Void = { endIdx in
            if runStart >= 0, runStart <= endIdx {
                let s = ts[runStart], e = ts[endIdx]
                if bestStart < 0 || (e - s) > (bestEnd - bestStart) { bestStart = s; bestEnd = e }
            }
            runStart = -1
        }
        for i in 0..<ts.count {
            if i > 0, ts[i] - ts[i - 1] > maxGapS { endRunAt(i - 1) }
            if smoothed[i] > stillThresholdG {
                endRunAt(i - 1)
            } else if runStart < 0 {
                runStart = i
            }
        }
        endRunAt(ts.count - 1)
        return bestStart < 0 ? nil : (bestStart, bestEnd)
    }

    /// Mean heart rate over `[start, end]` from plausible samples (25 to 220 bpm), truncated, or nil.
    /// Kotlin twin: `NapDetector.meanHrIn`.
    public static func meanHrIn(_ hr: [HRSample], start: Int, end: Int) -> Int? {
        let inWindow = hr.filter { $0.ts >= start && $0.ts <= end && (25...220).contains($0.bpm) }
        guard !inWindow.isEmpty else { return nil }
        return Int(Double(inWindow.reduce(0) { $0 + $1.bpm }) / Double(inWindow.count))
    }

    /// Classify a window: off or sparse is INCONCLUSIVE; no quiet run of `minNapMinutes` is NONE; longer than
    /// `maxNapMinutes` is INCONCLUSIVE (it may be main sleep); a known resting band that the window's mean heart
    /// rate sits above by more than the margin is NONE (still but awake); otherwise NAP. Kotlin twin:
    /// `NapDetector.evaluate`.
    public static func evaluate(gravity: [GravitySample], hr: [HRSample], restingHr: Int?,
                                config: NapConfig) -> NapDecision {
        guard config.enabled, isWindowDense(gravity) else { return NapDecision(verdict: .inconclusive, candidate: nil) }
        guard let quiet = longestQuietRun(gravity, stillThresholdG: config.stillThresholdG,
                                          smoothWindowSeconds: config.smoothWindowSeconds) else {
            return NapDecision(verdict: .none, candidate: nil)
        }
        let durationMin = Double(quiet.end - quiet.start) / 60.0
        if durationMin < Double(config.minNapMinutes) { return NapDecision(verdict: .none, candidate: nil) }
        if durationMin > Double(config.maxNapMinutes) { return NapDecision(verdict: .inconclusive, candidate: nil) }
        let meanHr = meanHrIn(hr, start: quiet.start, end: quiet.end)
        if let restingHr, let meanHr, meanHr > restingHr + config.hrSettleMarginBpm {
            return NapDecision(verdict: .none, candidate: nil)
        }
        return NapDecision(verdict: .nap, candidate: NapCandidate(
            start: quiet.start, end: quiet.end, meanHr: meanHr,
            confidence: confidenceFor(durationMin: durationMin, restingHr: restingHr, meanHr: meanHr, config: config)))
    }

    /// 0 to 1 ordering confidence, not a probability. Kotlin twin: `NapDetector.confidenceFor`.
    static func confidenceFor(durationMin: Double, restingHr: Int?, meanHr: Int?, config: NapConfig) -> Double {
        let span = Double(max(config.maxNapMinutes - config.minNapMinutes, 1))
        let durTerm = 0.4 + 0.45 * min(max((durationMin - Double(config.minNapMinutes)) / span, 0.0), 1.0)
        guard let restingHr, let meanHr else { return min(max(durTerm, 0.0), 0.7) }
        let headroom = max(config.hrSettleMarginBpm, 1)
        let below = max(restingHr + config.hrSettleMarginBpm - meanHr, 0)
        let hrTerm = 0.15 * min(max(Double(below) / Double(headroom), 0.0), 1.0)
        return min(max(durTerm + hrTerm, 0.0), 1.0)
    }
}
