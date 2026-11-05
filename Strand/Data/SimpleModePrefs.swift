import Foundation

// MARK: - Simple mode
//
// One switch between two presentations of the SAME data. Simple mode is a calm default: Today shows each
// number once and says what it means, the More tab lists the everyday screens, and every other screen
// stays one tap away under "All features". Turning it off returns the full app exactly as it was.
//
// Presentation only. Nothing here computes, stores or changes a figure: every value Simple mode shows is
// read through the same code the full view uses. Simple mode also never reads or writes the full view's
// layout prefs (`TodayLayoutPrefs`, `KeyMetricPrefs`, `DashboardCardPrefs`), so a wearer who arranged
// Today and then tried Simple mode gets their own arrangement back untouched when they switch it off.
//
// The key sits in the `noop.` namespace so a future Android twin can share it by name and meaning, the
// way `noop.coachEnabled` is shared. It is not in the `.noopbak` whitelist: that list is a byte-identical
// contract with Android and gains the key together with the Android twin.

/// Persistence and pure layout rules for Simple mode.
enum SimpleModePrefs {
    /// UserDefaults key read by the iOS tab shell, the Liquid Today and Settings.
    static let storageKey = "noop.simpleMode"

    /// ON by default, so a first launch opens the calm view. Settings → Simple mode switches it off.
    static let defaultEnabled = true

    /// Whether the Coach tab is shown.
    ///
    /// The full view keeps its existing rule: the Coach master switch alone. Simple mode also asks for a
    /// configured provider, because an unconfigured Coach tab is a setup screen asking for an API key, and
    /// Coach is the one feature that sends data off the device. Simple mode lists Coach in More while its
    /// tab is hidden, so it is never unreachable.
    static func showsCoachTab(simpleMode: Bool, coachEnabled: Bool, coachConfigured: Bool) -> Bool {
        coachEnabled && (!simpleMode || coachConfigured)
    }

    /// The tab tags the iOS shell renders, in order. Tags stay literal (Today 0, Trends 1, Sleep 2,
    /// Coach 3, More 4) whether or not Coach is shown, so More keeps its identity and navigation path.
    static func visibleTabTags(showsCoach: Bool) -> [Int] {
        showsCoach ? [0, 1, 2, 3, 4] : [0, 1, 2, 4]
    }

    /// The Sleep cards Simple mode shows, in order, below the pinned score: the night itself, then the one
    /// sleep-debt figure with its plain advice, then how long the wearer has been sleeping. Manual sleep
    /// marks, the body-clock dial, the metric tiles (which repeat the score and show a second debt figure)
    /// and the stages-vs-typical card stay in the full view; the night card already compares each stage
    /// with the wearer's typical on tap.
    static let sleepSections: [SleepSection] = [.stages, .sleepDebt, .asleepDuration]

    /// The tab a horizontal swipe moves to. It steps through the VISIBLE tags only, so a hidden Coach
    /// tab is skipped instead of being selected as a blank tab, and it stops at either end.
    static func swipeTarget(from current: Int, forward: Bool, visible: [Int]) -> Int {
        guard !visible.isEmpty else { return current }
        guard let index = visible.firstIndex(of: current) else { return visible[0] }
        let next = forward ? min(visible.count - 1, index + 1) : max(0, index - 1)
        return visible[next]
    }
}

/// One section of the Simple-mode Today, in render order.
///
/// Deliberately its own enum rather than new `TodaySection` cases: `TodaySection` raw values are a
/// byte-identical persisted contract with Android, and Simple mode's order is fixed rather than stored.
enum SimpleTodaySection: String, CaseIterable, Identifiable {
    /// The three score rings, each with its familiar other name underneath.
    case scores
    /// The greeting, the one-word day verdict and the one-sentence summary.
    case summary
    /// What shaped today's Charge, compared with the wearer's own normal.
    case behindCharge
    /// Steps and calories.
    case activity
    case heartRate
    case workouts
    /// The wearer's own opt-ins. Each self-hides while its feature is off, exactly as in the full view.
    case menstrualCycle
    case journal
    case addedCards
    /// The link to the plain-language guide.
    case guide

    var id: String { rawValue }

    /// The full-view sections Simple mode leaves out. Listed so a test can pin that the summary shows each
    /// figure once: Start session is a beta, Key Metrics and Your Cards repeat the rings and the vitals.
    static let omittedFullSections: [TodaySection] = [.liveSession, .keyMetrics, .yourCards]
}
