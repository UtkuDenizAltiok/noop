import Foundation
import StrandAnalytics
import WhoopStore

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
    /// "Not now" asks again after this moment (unix seconds), so a wearer who opens NOOP in the night and is
    /// going back to sleep is asked again in the morning instead of losing the day's check-in.
    static let snoozedUntilKey = "checkIn.snoozedUntil"
    /// The logical day "Skip today" was chosen for: no more asking that day.
    static let skippedDayKey = "checkIn.skippedDay"
    /// The moment the wearer asked to answer now (the Test Centre's button), as unix seconds.
    static let requestKey = "checkIn.requestedAt"

    /// How long "Not now" waits before asking again.
    static let snoozeMinutes = 60
    /// How long before the wearer's usual wake time the check-in may first be offered. Opening NOOP at 04:30
    /// in the middle of the night is not the morning; 90 minutes before the usual wake still lets an early day
    /// be answered.
    static let wakeLeadMinutes = 90

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

    /// The wearer's usual wake time, in minutes after local midnight: the median of the given nights' wake
    /// times. Nil with fewer than three nights, when it is not yet known.
    static func usualWakeMinute(_ wakeMinutesOfDay: [Int]) -> Int? {
        guard wakeMinutesOfDay.count >= 3 else { return nil }
        let sorted = wakeMinutesOfDay.sorted()
        return sorted[sorted.count / 2]
    }

    /// The first minute of the day the check-in may be offered: 04:00, or `wakeLeadMinutes` before the usual
    /// wake time when that is later.
    static func earliestOfferMinute(usualWakeMinute: Int?) -> Int {
        let rollover = offerHours.lowerBound * 60
        guard let usualWakeMinute else { return rollover }
        return max(rollover, usualWakeMinute - wakeLeadMinutes)
    }

    /// Whether to offer the check-in now: switched on, the app open in front of the wearer, inside the morning
    /// hours and not before the earliest minute, not skipped today, not snoozed, and not yet answered today.
    /// "Open in front" matters on a phone: iOS wakes NOOP in the background for the strap's syncs, and nobody
    /// would see a check-in offered then.
    static func shouldOffer(enabled: Bool, appIsActive: Bool, minuteOfDay: Int, earliestMinute: Int,
                            skippedToday: Bool, snoozed: Bool, answeredToday: Bool) -> Bool {
        enabled && appIsActive && offerHours.contains(minuteOfDay / 60) && minuteOfDay >= earliestMinute
            && !skippedToday && !snoozed && !answeredToday
    }

    /// Whether last night's detected sleep times were right: 1 right, 0 wrong. Stored like the answers, under a
    /// fixed question. A correction the wearer then makes on the Sleep tab is stored in the sleep session itself
    /// (`CachedSleepSession.userEdited`, `startTsAdjusted`), next to the detected times, so the developer can
    /// measure the detection's error from the backup.
    static let sleepTimesQuestion = "Check-in: sleep times right (1/0)"

    /// Last night for a morning: the most recent night that ended within the 18 hours before `now` and not
    /// after it, its fragments bridged into one night the way the Sleep tab bridges them (a brief wake in the
    /// night, up to an hour, or 90 minutes overnight, keeps one night: `SleepStageTotals.bridgedNightGroups`),
    /// spanning at least `minimumNightMinutes`. Its times come from `SleepClockTimes`, so the question asks
    /// about the same "fell asleep" and "woke" the Sleep tab shows. Nil when there is none: the question is
    /// then left out rather than asked about a night NOOP did not see.
    static func lastNight(_ sessions: [CachedSleepSession], now: Date,
                          offsetSec: Int) -> (blocks: [CachedSleepSession], times: SleepClockTimes.Times)? {
        let nowTs = Int(now.timeIntervalSince1970)
        var seen = Set<Int>()
        let recent = sessions
            .filter { $0.endTs <= nowTs && $0.endTs >= nowTs - 18 * 3600 && seen.insert($0.startTs).inserted }
        let groups = SleepStageTotals.bridgedNightGroups(
            recent.map { SleepStageTotals.NightBlock(start: $0.effectiveStartTs, end: $0.endTs) }, offsetSec: offsetSec)
        let nights = groups.map { group in group.indices.map { recent[$0] }.sorted { $0.effectiveStartTs < $1.effectiveStartTs } }
            .filter { blocks in
                let start = blocks.map(\.effectiveStartTs).min() ?? 0, end = blocks.map(\.endTs).max() ?? 0
                return end - start >= minimumNightMinutes * 60
            }
        guard let last = nights.max(by: { ($0.map(\.endTs).max() ?? 0) < ($1.map(\.endTs).max() ?? 0) }),
              let times = SleepClockTimes.of(last) else { return nil }
        return (last, times)
    }

    /// The shortest night the question asks about: a nap is not "last night".
    static let minimumNightMinutes = 180

    /// The wake times (minutes after local midnight) of the nights among `sessions`, for `usualWakeMinute`:
    /// each bridged night of at least `minimumNightMinutes` whose wake falls between 03:00 and 14:00.
    static func wakeMinutes(_ sessions: [CachedSleepSession], offsetSec: Int,
                            calendar: Calendar = .current) -> [Int] {
        var seen = Set<Int>()
        let unique = sessions.filter { seen.insert($0.startTs).inserted }
        let groups = SleepStageTotals.bridgedNightGroups(
            unique.map { SleepStageTotals.NightBlock(start: $0.effectiveStartTs, end: $0.endTs) }, offsetSec: offsetSec)
        return groups.compactMap { group -> Int? in
            let blocks = group.indices.map { unique[$0] }
            guard let times = SleepClockTimes.of(blocks), times.up - times.inBed >= minimumNightMinutes * 60 else {
                return nil
            }
            let parts = calendar.dateComponents([.hour, .minute],
                                                from: Date(timeIntervalSince1970: TimeInterval(times.woke)))
            guard let hour = parts.hour, let minute = parts.minute, (3..<14).contains(hour) else { return nil }
            return hour * 60 + minute
        }
    }

    /// The moment a clock time picked in the check-in means: the given hour and minute on the day before, the
    /// day of, or the day after `reference` (the time NOOP saw), whichever is nearest to it. A wearer who
    /// corrects "fell asleep 00:31" to 23:50 means the evening before.
    static func resolveClock(_ chosen: Date, near reference: Int, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: chosen)
        let referenceDate = Date(timeIntervalSince1970: TimeInterval(reference))
        let candidates = (-1...1).compactMap { offset -> Int? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: referenceDate),
                  let at = calendar.date(bySettingHour: parts.hour ?? 0, minute: parts.minute ?? 0, second: 0, of: day)
            else { return nil }
            return Int(at.timeIntervalSince1970)
        }
        return candidates.min { abs($0 - reference) < abs($1 - reference) } ?? reference
    }

    /// How many days of the given journal series hold a complete check-in.
    static func completedDays(_ series: [String: [String: Double]]) -> Int {
        let perQuestion = journalQuestions.map { Set((series[$0] ?? [:]).keys) }
        guard let first = perQuestion.first else { return 0 }
        return perQuestion.dropFirst().reduce(first) { $0.intersection($1) }.count
    }
}
