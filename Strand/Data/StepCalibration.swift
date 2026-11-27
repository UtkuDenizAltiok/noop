import Foundation
#if os(iOS)
import CoreMotion
#endif

/// Calibrates a WHOOP 5.0 or MG strap's step counter against the iPhone's own pedometer (Utku, 27 Nov 2026: steps
/// were not precise; he does not always carry the phone).
///
/// The strap counts "ticks" of its motion counter while it judges the wearer to be walking or running
/// (`StepsCounter`), and NOOP divides them by `ProfileStore.stepTicksPerStep`, which nobody could set without
/// counting steps by hand (it stayed at 1.0). A phone in a pocket counts steps where pedometers count best: in a
/// treadmill study, phone apps were within -6.7 % to +6.2 % of the observed steps and wrist devices within
/// -22.7 % to -1.5 % (Case et al., JAMA 2015;313:625-626; a treadmill shortens strides, so free walking can differ).
///
/// So the phone is a measuring stick, never the source: over the last 7 days (what iOS keeps), NOOP pairs the two
/// counts in 15-minute windows in which BOTH saw real walking (the phone carried, the strap worn), and the median
/// of the windows' ticks-per-step becomes the divisor. Daily steps still come from the strap alone, all day,
/// whether the phone is carried or not; days without the phone simply add no windows. Guard rails: at least two
/// hours of paired walking, a ratio between 0.5 and 3, and windows that agree with each other (spread under half
/// the median). iOS only: Android keeps the manual divisor.
enum StepCalibration {

    /// The setting: calibrate with the iPhone automatically. On unless the wearer turns it off.
    static let enabledKey = "steps.calibrateWithPhone"
    /// The last result, as JSON (`Result`).
    static let resultKey = "steps.phoneCalibration"
    /// When it last ran (unix seconds); it runs at most once in `minimumIntervalSeconds`.
    static let lastRunKey = "steps.phoneCalibration.lastRun"
    /// The last run's qualifying windows, for the developer file (`LabSnapshot`), as JSON.
    static let windowsKey = "steps.phoneCalibration.windows"

    static let windowSeconds = 15 * 60
    /// A window counts when the phone counted at least this many steps in it (a third of the window at an
    /// ordinary walking cadence of 100 a minute).
    static let minPhoneSteps = 500
    /// ...and the strap saw walking in it too: it was worn and counting.
    static let minStrapTicks = 100
    /// Two hours of paired walking before a divisor is trusted.
    static let minWindows = 8
    static let ratioBounds = 0.5...3.0
    /// The windows must agree: the spread between the middle half of their ratios under half the median.
    static let maxRelativeSpread = 0.5
    static let lookbackDays = 7
    static let minimumIntervalSeconds = 20 * 3600

    /// One window's two counts.
    struct Pair: Codable, Equatable {
        let start: Int
        let phoneSteps: Int
        let strapTicks: Int
    }

    /// A calibration: the divisor and what it was learned from.
    struct Result: Codable, Equatable {
        let ticksPerStep: Double
        let windows: Int
        let phoneSteps: Int
        let at: Int
    }

    static func qualifies(_ pair: Pair) -> Bool {
        pair.phoneSteps >= minPhoneSteps && pair.strapTicks >= minStrapTicks
    }

    /// The divisor from paired windows, or nil when there is not enough walking, the ratio is implausible, or the
    /// windows disagree. Median and quartiles by nearest rank on the sorted ratios.
    static func calibrate(_ pairs: [Pair], now: Int) -> Result? {
        let used = pairs.filter(qualifies)
        let ratios = used.map { Double($0.strapTicks) / Double($0.phoneSteps) }.sorted()
        guard ratios.count >= minWindows else { return nil }
        func rank(_ q: Double) -> Double { ratios[min(ratios.count - 1, Int((q * Double(ratios.count - 1)).rounded()))] }
        let median = rank(0.5)
        guard ratioBounds.contains(median), (rank(0.75) - rank(0.25)) / median <= maxRelativeSpread else { return nil }
        return Result(ticksPerStep: (median * 100).rounded() / 100, windows: ratios.count,
                      phoneSteps: used.reduce(0) { $0 + $1.phoneSteps }, at: now)
    }

    /// The last stored result, if any.
    static var lastResult: Result? {
        guard let data = UserDefaults.standard.data(forKey: resultKey) else { return nil }
        return try? JSONDecoder().decode(Result.self, from: data)
    }

    static var isEnabled: Bool { UserDefaults.standard.object(forKey: enabledKey) as? Bool ?? true }

    #if os(iOS)
    /// Whether iOS lets NOOP read the phone's steps (Motion & Fitness).
    static var phoneStepsAllowed: Bool {
        CMPedometer.isStepCountingAvailable() && CMPedometer.authorizationStatus() == .authorized
    }
    #else
    static var phoneStepsAllowed: Bool { false }
    #endif

    /// Run once a day when switched on and allowed: pair the windows, store the result, and when the divisor moves
    /// by 0.02 or more, set it and re-score. `force` ignores the once-a-day spacing (the Settings button), and is
    /// also what asks iOS for permission the first time. Returns the result, or nil.
    @MainActor
    @discardableResult
    static func runIfDue(repo: Repository, profile: ProfileStore, intelligence: IntelligenceEngine,
                         force: Bool = false) async -> Result? {
        #if os(iOS)
        guard isEnabled, CMPedometer.isStepCountingAvailable() else { return nil }
        if !force { guard phoneStepsAllowed else { return nil } }
        let now = Int(Date().timeIntervalSince1970)
        if !force, now - UserDefaults.standard.integer(forKey: lastRunKey) < minimumIntervalSeconds { return nil }
        UserDefaults.standard.set(now, forKey: lastRunKey)
        var pairs: [Pair] = []
        let firstHour = (now - lookbackDays * 86_400) / 3600 * 3600 + 3600
        for hour in stride(from: firstHour, to: now / 3600 * 3600, by: 3600) {
            // An hour with little phone walking cannot hold a qualifying window: skip its four queries.
            guard let hourSteps = await WorkoutPedometer.steps(fromSec: hour, toSec: hour + 3600),
                  hourSteps >= minPhoneSteps else { continue }
            for start in stride(from: hour, to: hour + 3600, by: windowSeconds) {
                guard let phone = await WorkoutPedometer.steps(fromSec: start, toSec: start + windowSeconds),
                      phone >= minPhoneSteps,
                      let ticks = await repo.strapStepTicks(from: start, to: start + windowSeconds) else { continue }
                pairs.append(Pair(start: start, phoneSteps: phone, strapTicks: ticks))
            }
        }
        if let data = try? JSONEncoder().encode(Array(pairs.suffix(300))) {
            UserDefaults.standard.set(data, forKey: windowsKey)
        }
        guard let result = calibrate(pairs, now: now) else { return nil }
        if let data = try? JSONEncoder().encode(result) { UserDefaults.standard.set(data, forKey: resultKey) }
        if abs(profile.stepTicksPerStep - result.ticksPerStep) >= 0.02 {
            profile.stepTicksPerStep = result.ticksPerStep
            await intelligence.analyzeRecent()
        }
        return result
        #else
        return nil
        #endif
    }
}
