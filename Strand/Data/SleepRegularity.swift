import Foundation
import StrandAnalytics

/// The wearer's Sleep Regularity Index (`SleepRegularityIndex`): how alike the last week's sleep and wake times
/// were. The scoring engine works it out once per run from the stored sleep sessions and keeps it here, so the
/// Rest score it stores and the Rest score every screen shows read the same number ("Two readouts of one fact",
/// AGENTS.md). Nil until about five nights in a row are recorded; the Rest score's regularity part is then the
/// neutral half. Kotlin twin: `com.noop.ui.SleepRegularity`.
enum SleepRegularity {

    /// The index from the engine's last run, -100 to 100; absent when there was none.
    static let indexKey = "sleepRegularity.index"

    /// The engine keeps its index here once per run; nil clears it.
    static func store(_ index: Double?) {
        if let index {
            UserDefaults.standard.set(index, forKey: indexKey)
        } else {
            UserDefaults.standard.removeObject(forKey: indexKey)
        }
    }

    /// The index from the engine's last run, or nil.
    static var index: Double? { UserDefaults.standard.object(forKey: indexKey) as? Double }

    /// The Rest score's regularity part, 0 to 1, or nil (neutral) without an index.
    static var consistency: Double? { SleepRegularityIndex.consistency(index) }
}
