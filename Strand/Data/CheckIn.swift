import Foundation

/// The developer's morning check-in (handbook `features/lab.md`): three questions on 1-to-5 scales, one for each
/// of the three morning numbers NOOP works out, and whether last night's detected sleep times were right, so the
/// developer can compare the scores and the sleep detection with the wearer's own account over weeks.
///
/// Why these three, on these scales: self-reported well-being tracks training load more sensitively and
/// consistently than common objective measures (Saw, Main and Gastin, Br J Sports Med 2016;50:281-291), and the
/// usual short form is a morning questionnaire of a few items scored 1 to 5 (McLean et al., Int J Sports Physiol
/// Perform 2010;5:367-383). Every item is worded so that 5 is the good end, the way McLean's items are, so each
/// answer is compared with its score in the same direction.
///
/// Answers are journal numbers (`Repository.saveJournalNumeric`) under fixed questions: they live in the
/// database, ride every backup and need no new table. Opt-in, default off.
enum CheckIn {

    /// The setting that switches the check-in on. Off unless the wearer turns it on.
    static let enabledKey = "checkIn.enabled"
    /// The logical day the check-in was last offered, so it is offered at most once a day.
    static let lastOfferedDayKey = "checkIn.lastOfferedDay"

    /// The answer scale.
    static let scale = 1...5

    /// One question.
    enum Item: String, CaseIterable, Identifiable {
        case rested, slept, relaxed
        var id: String { rawValue }

        /// The journal question an answer is stored under. Never translated and never renamed: answers join
        /// on it in the database and in every backup, on both platforms.
        var journalQuestion: String {
            switch self {
            case .rested:  return "Check-in: rested (1-5)"
            case .slept:   return "Check-in: slept well (1-5)"
            case .relaxed: return "Check-in: relaxed (1-5)"
            }
        }

        /// The score this answer is set against: Charge, Rest and Stress.
        var comparedWith: String {
            switch self {
            case .rested:  return "recovery"
            case .slept:   return "sleep_performance"
            case .relaxed: return "stress"
            }
        }
    }

    /// The three journal questions, in order.
    static var journalQuestions: [String] { Item.allCases.map(\.journalQuestion) }

    /// Whether every item has an answer among a day's journal numbers.
    static func isComplete(_ numericAnswers: [String: Double]) -> Bool {
        Item.allCases.allSatisfy { numericAnswers[$0.journalQuestion] != nil }
    }

    /// The hours of the local day in which the check-in is offered: from the 04:00 day rollover to 14:00.
    /// Asked later, the answer would describe the afternoon rather than the morning the scores describe.
    static let offerHours = 4..<14

    /// Whether to offer the check-in now: switched on, the app open in front of the wearer, inside the morning
    /// hours, not yet offered today, and not yet answered today. "Open in front" matters on a phone: iOS wakes
    /// NOOP in the background for the strap's syncs, and a check-in offered then would be marked as offered for
    /// the day without anyone having seen it.
    static func shouldOffer(enabled: Bool, appIsActive: Bool, hour: Int, lastOfferedDay: String?, today: String,
                            answeredToday: Bool) -> Bool {
        enabled && appIsActive && offerHours.contains(hour) && lastOfferedDay != today && !answeredToday
    }

    /// Whether last night's detected sleep times were right: 1 right, 0 wrong. Stored like the answers, under a
    /// fixed question. A correction the wearer then makes on the Sleep tab is stored in the sleep session itself
    /// (`CachedSleepSession.userEdited`, `startTsAdjusted`), next to the detected times, so the developer can
    /// measure the detection's error from the backup.
    static let sleepTimesQuestion = "Check-in: sleep times right (1/0)"

    /// Last night's main sleep for a morning: the session that ended most recently, within the 18 hours before
    /// `now` and not after it, of at least `minimumNightMinutes`. Nil when there is none (the question is then
    /// left out rather than asked about a night NOOP did not see).
    static func lastNight(_ sessions: [(start: Int, end: Int)], now: Date) -> (start: Int, end: Int)? {
        let nowTs = Int(now.timeIntervalSince1970)
        return sessions
            .filter { $0.end <= nowTs && $0.end >= nowTs - 18 * 3600 && $0.end - $0.start >= minimumNightMinutes * 60 }
            .max { $0.end < $1.end }
    }

    /// The shortest sleep the question asks about: a nap is not "last night".
    static let minimumNightMinutes = 180

    /// How many days of the given journal series hold a complete check-in.
    static func completedDays(_ series: [String: [String: Double]]) -> Int {
        let perQuestion = journalQuestions.map { Set((series[$0] ?? [:]).keys) }
        guard let first = perQuestion.first else { return 0 }
        return perQuestion.dropFirst().reduce(first) { $0.intersection($1) }.count
    }
}
