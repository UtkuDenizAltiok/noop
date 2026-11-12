import Foundation

// MARK: - Simple mode
//
// One switch between two presentations of the SAME data. Simple mode is a calm default: Today shows each
// number once and says what it means, the More tab lists the everyday screens, and every other screen
// stays one tap away under "All features". Each simplified screen also ends in "Show everything on this
// screen" (`isSimple`), so what it leaves out is one tap away on that screen. Turning it off returns the full
// app exactly as it was.
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

    /// Whether a screen draws its simple layout right now: the stored switch, unless the wearer tapped
    /// "Show everything on this screen" (`SimpleModeShowAllRow`). The one funnel every simplified screen
    /// reads, so a hidden card or tool is always one tap away on its own screen, never only behind the
    /// app-wide switch. `showingAll` is per-screen view state; it is never stored.
    static func isSimple(stored: Bool, showingAll: Bool) -> Bool {
        stored && !showingAll
    }

    /// The rows of Simple mode's More list, in render order. Coach is listed only while it is switched on
    /// but has no tab of its own (`showsCoachTab`), so it is never unreachable. Every other entry is always
    /// listed: the Lift Log included, which Simple mode never hides.
    static func moreEntries(showsCoachRow: Bool) -> [SimpleMoreEntry] {
        SimpleMoreEntry.allCases.filter { $0 != .coach || showsCoachRow }
    }

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
    /// "Your day": the greeting, the day's verdict in a sentence and, when it agrees with that verdict,
    /// the suggested Effort range with today's progress (`SimpleDayPlan`).
    case summary
    /// One line about last night's sleep against the need, tapping through to Sleep.
    case sleepLine
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

/// One always-open group of Simple mode's More list, in render order.
enum SimpleMoreGroup: String, CaseIterable {
    case yourBody, training, dailyTools, yourData, help
}

/// One row of Simple mode's More list, in render order (`SimpleModePrefs.moreEntries`).
///
/// Data rather than view code so a test can pin what the list holds: the iOS tab shell renders each case
/// through an exhaustive switch (`SimpleMoreIndex` in `RootTabView`), so a row cannot be added here without
/// deciding where it leads, and cannot be dropped from the screen while it is still listed. Every row is
/// also in the full More list; Simple mode chooses, it never removes.
enum SimpleMoreEntry: String, CaseIterable, Identifiable {
    case liveHeartRate, healthMonitor, stress
    case workouts, liftLog
    /// Daily tools: Alarms, then the high heart rate warning (`HighHRAlertView`), Breathe and Coach.
    case alarms, heartRateWarning, breathe, coach
    case appleHealth, backupSync
    /// Help: the plain guide, then the Test Centre (where the strap log lives), then Settings.
    case plainGuide, reportProblem, settings

    var id: String { rawValue }

    var group: SimpleMoreGroup {
        switch self {
        case .liveHeartRate, .healthMonitor, .stress: return .yourBody
        case .workouts, .liftLog: return .training
        case .alarms, .heartRateWarning, .breathe, .coach: return .dailyTools
        case .appleHealth, .backupSync: return .yourData
        case .plainGuide, .reportProblem, .settings: return .help
        }
    }
}
