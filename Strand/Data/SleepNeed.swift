import Foundation
import StrandAnalytics
import WhoopStore

/// THE sleep need (Simple mode v6 step 7): what NOOP's sleep debt, tonight's goal, the bedtime reminder and the Rest
/// score all measure against. The wearer's own choice when they made one (Settings, or Change on the Sleep tab's
/// "Your sleep need" card), else the automatic need: `AnalyticsEngine.Rest.personalizedNeedHours` with the wearer's
/// age (8 h for adults, 7.5 from 65, 9 under 18, raised for regular long sleepers).
///
/// The scoring engine works the automatic need out once per run from the whole nightly history and keeps it here,
/// so every screen reads the number the engine scored with ("Two readouts of one fact", AGENTS.md); before the
/// engine's first run a screen works it out from the days it holds. Kotlin twin: `com.noop.ui.SleepNeed`.
enum SleepNeed {

    /// The chosen need in minutes, 0 = Automatic. Carried by the `.noopbak` whitelist (`BackupSettings`).
    static let chosenMinutesKey = "profile.sleepNeedMinutes"
    /// The automatic need in hours from the engine's last run.
    static let automaticHoursKey = "sleepNeed.automaticHours"

    /// A choice as stored: 0 for Automatic, else the nearest 15 minutes from 7h 0m to 9h 30m.
    static func normalizedChoice(_ minutes: Int) -> Int {
        AnalyticsEngine.Rest.normalizedChosenNeedMinutes(minutes)
    }

    /// The wearer's chosen minutes, 0 when Automatic.
    static var chosenMinutes: Int { normalizedChoice(UserDefaults.standard.integer(forKey: chosenMinutesKey)) }

    /// The wearer's age as the profile keeps it for the backup (`ProfileStore`'s mirrored `profile.age`), or nil.
    static var storedAge: Int? {
        let age = UserDefaults.standard.integer(forKey: "profile.age")
        return age > 0 ? age : nil
    }

    /// The automatic need in hours: the engine's last figure, else worked out from `days`.
    static func automaticHours(days: [DailyMetric] = []) -> Double {
        if let stored = UserDefaults.standard.object(forKey: automaticHoursKey) as? Double, stored > 0 { return stored }
        return AnalyticsEngine.Rest.personalizedNeedHours(
            nightlyHours: days.compactMap { $0.totalSleepMin.map { $0 / 60.0 } }, age: storedAge)
    }

    /// The need in hours every screen uses: the choice, else the automatic need.
    static func currentHours(days: [DailyMetric] = []) -> Double {
        let chosen = chosenMinutes
        return chosen > 0 ? Double(chosen) / 60.0 : automaticHours(days: days)
    }

    /// The engine keeps its automatic need here once per run.
    static func storeAutomatic(_ hours: Double) {
        UserDefaults.standard.set(hours, forKey: automaticHoursKey)
    }

    /// Every value the wearer can pick, in minutes: 0 (Automatic), then 7h 0m to 9h 30m in 15-minute steps.
    static var choices: [Int] {
        [0] + Array(stride(from: AnalyticsEngine.Rest.chosenNeedMinMinutes,
                           through: AnalyticsEngine.Rest.chosenNeedMaxMinutes, by: 15))
    }
}
