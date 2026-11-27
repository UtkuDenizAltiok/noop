import Foundation
import StrandAnalytics

// MARK: - Simple mode: the welcome (Design v6, step 6)
//
// What a first-time wearer needs before any number makes sense (findings W1 and W2): what the three scores
// are, where to look each morning and evening, and why the first two weeks show dashes. "How to read NOOP" is
// shown once, when Today first appears in Simple mode, and stays in the guide as "Start here". "Getting to
// know you" sits on Today under the scores until NOOP trusts the wearer's normal.
//
// Every night count here is the code's own gate, never typed into the copy, so a moved constant moves the
// words with it; `SimpleWelcomeV6Tests` pins each one against the engine that uses it.

/// Pure rules for "How to read NOOP" and "Getting to know you".
enum SimpleWelcome {

    /// UserDefaults key: true once "How to read NOOP" has been closed. In the `noop.` namespace like
    /// `SimpleModePrefs.storageKey`. A presentation flag, not data, so it is not in the `.noopbak` whitelist.
    static let seenKey = "noop.simpleWelcomeSeen"

    /// Nights of history before "Your day" can weigh all its signals: the readiness engine's minimum baseline
    /// (`ReadinessEngine.minBaseline`, private there). `SimpleWelcomeV6Tests` pins it against the engine's own
    /// behaviour, so this copy cannot drift from it.
    static let adviceNights = 7

    /// The nights NOOP has learned from: the HRV baseline's valid nights, folded exactly as the Charge
    /// baseline folds them (the count `RecoveryScorer.calibrationNights` gates Charge on). The card, the
    /// welcome sheet and Today's Charge all read this one function, so they cannot disagree.
    static func learnedNights(hrv: [Double?], dayKeys: [String]) -> Int {
        Baselines.foldHistory(hrv, dayKeys: dayKeys, cfg: Baselines.hrvCfg).nValid
    }

    /// What arrives when, in the order a new wearer meets it.
    enum Milestone: String, CaseIterable, Equatable {
        /// The first night with the strap: the Rest score.
        case rest
        /// The Charge, once the baseline has its seed nights.
        case charge
        /// "Your day" weighing every signal.
        case advice
        /// Every reading judged against the wearer's own normal, and the Charge no longer an early estimate.
        case ownNormal

        /// The night count it arrives at.
        var nights: Int {
            switch self {
            case .rest: return 1
            case .charge: return Baselines.minNightsSeed
            case .advice: return SimpleWelcome.adviceNights
            case .ownNormal: return Baselines.minNightsTrust
            }
        }
    }

    /// One line of the card: what arrives, and whether it has.
    struct Step: Equatable {
        let milestone: Milestone
        let reached: Bool
    }

    /// The card's lines, each ticked once reached. Rest is ticked by the Rest ring itself as well, because a
    /// night can be scored for Rest before its heart-rate variability counts toward the baseline; the others
    /// follow the learned nights, the count their own gates read.
    static func steps(learnedNights: Int, hasRest: Bool) -> [Step] {
        Milestone.allCases.map { milestone in
            let byNights = learnedNights >= milestone.nights
            return Step(milestone: milestone, reached: milestone == .rest ? (hasRest || byNights) : byNights)
        }
    }

    /// Whether Today shows "Getting to know you": on today only, until the baseline is trusted. A wearer whose
    /// history came from an import is past this on the first day and never sees the card.
    static func showsCard(learnedNights: Int?, isToday: Bool) -> Bool {
        guard isToday, let learnedNights else { return false }
        return learnedNights < Baselines.minNightsTrust
    }

    /// Whether "How to read NOOP" may be offered now: Simple mode, not seen yet, the first-run gates done (the
    /// terms, the setup wizard and What's New all sit over Today and would hide it), Today in front, the app
    /// open in front of the wearer, and no other sheet up (it waits rather than racing one).
    static func shouldOffer(simpleMode: Bool, seen: Bool, firstRunDone: Bool, todaySelected: Bool,
                            appActive: Bool, anotherSheetUp: Bool) -> Bool {
        simpleMode && !seen && firstRunDone && todaySelected && appActive && !anotherSheetUp
    }
}
