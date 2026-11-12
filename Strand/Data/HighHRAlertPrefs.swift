import Foundation

// MARK: - High heart rate warning: settings
//
// Three keys: the switch (off by default), the limit and the duration. The card binds them with `@AppStorage`;
// the monitor reads them through `current`, which clamps whatever is stored, so a hand-edited or out-of-range
// value can never reach the engine. Not in the `.noopbak` whitelist yet: that list is a byte-identical contract
// with Android and gains these keys together with the Android twin.

/// Persistence and wording for the high heart rate warning.
enum HighHRAlertPrefs {
    /// Whether the warning is on. Its own switch is the only gate (not the "Wrist alerts" master switch).
    static let enabledKey = "highHrAlert.enabled"
    /// The limit, in bpm.
    static let thresholdKey = "highHrAlert.thresholdBpm"
    /// The duration the average is taken over, in seconds.
    static let windowKey = "highHrAlert.windowSec"

    /// Off until the wearer turns it on.
    static let defaultEnabled = false
    /// The example the feature was asked for with: above 110 bpm…
    static let defaultThresholdBpm = 110
    /// …for 90 seconds.
    static let defaultWindowSec = 90

    /// The limits the stepper offers.
    static let thresholdRange = 40...220
    /// The durations the stepper offers: 10 s to 10 min…
    static let windowRange = 10...600
    /// …in steps of 5 s.
    static let windowStepSec = 5

    /// Whether the warning is on, and its limit and duration, clamped to what the card offers.
    static func current(_ d: UserDefaults = .standard) -> (enabled: Bool, config: HighHRAlertEngine.Config) {
        let enabled = d.object(forKey: enabledKey) as? Bool ?? defaultEnabled
        let threshold = (d.object(forKey: thresholdKey) as? Int) ?? defaultThresholdBpm
        let window = (d.object(forKey: windowKey) as? Int) ?? defaultWindowSec
        return (enabled, HighHRAlertEngine.Config(thresholdBpm: clampedThreshold(threshold),
                                                  windowSec: clampedWindow(window)))
    }

    /// A limit inside `thresholdRange`.
    static func clampedThreshold(_ bpm: Int) -> Int {
        min(max(bpm, thresholdRange.lowerBound), thresholdRange.upperBound)
    }

    /// A duration inside `windowRange`, on the 5-second grid.
    static func clampedWindow(_ sec: Int) -> Int {
        let inRange = min(max(sec, windowRange.lowerBound), windowRange.upperBound)
        return inRange / windowStepSec * windowStepSec
    }

    /// A duration in words: "45 s", "1 min 30 s", "2 min".
    ///
    /// The ONLY place a duration of this feature is turned into words: the card, its summary, the status line
    /// and the Today row all call it, so no two of them can describe the same setting differently.
    static func durationText(_ sec: Int) -> String {
        let minutes = sec / 60
        let seconds = sec % 60
        if minutes == 0 { return String(localized: "\(seconds) s") }
        if seconds == 0 { return String(localized: "\(minutes) min") }
        return String(localized: "\(minutes) min \(seconds) s")
    }
}
