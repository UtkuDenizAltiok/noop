import XCTest
@testable import Strand
import WhoopStore

/// Pins the developer loop's rules (handbook `features/lab.md`): the check-in questions are stored under fixed
/// journal questions (a storage contract: answers join on them in every backup), the check-in is offered only when
/// switched on, in the morning (not in the night) while unanswered, Not now asks again later, a day counts only
/// when all three are answered,
/// the sleep question asks about last night's main sleep and never a nap or a future session, and the developer
/// file's README names what it holds.
final class CheckInTests: XCTestCase {

    /// The stored questions are a contract: renaming one would split every earlier answer from the new ones.
    func testJournalQuestionsAreFixed() {
        XCTAssertEqual(CheckIn.journalQuestions,
                       ["Check-in: rested (1-5)", "Check-in: slept well (1-5)", "Check-in: relaxed (1-5)"])
        XCTAssertEqual(CheckIn.sleepTimesQuestion, "Check-in: sleep times right (1/0)")
        XCTAssertEqual(CheckIn.scale, 1...5)
        XCTAssertEqual(CheckIn.Item.allCases.map(\.comparedWith), ["recovery", "sleep_performance", "stress"])
    }

    /// Offered only when switched on and the app is open in front of the wearer, from 04:00 to before 14:00 and
    /// not before the earliest minute, never once answered, skipped or snoozed. "Not now" is a snooze, not the end
    /// of the day: Utku opened NOOP at 04:30 in the night, chose Not now, and was never asked again that morning.
    func testOfferedInTheMorningAndNotNowAsksAgain() {
        func offer(enabled: Bool = true, active: Bool = true, minute: Int = 8 * 60, earliest: Int = 6 * 60 + 30,
                   skipped: Bool = false, snoozed: Bool = false, answered: Bool = false) -> Bool {
            CheckIn.shouldOffer(enabled: enabled, appIsActive: active, minuteOfDay: minute, earliestMinute: earliest,
                                skippedToday: skipped, snoozed: snoozed, answeredToday: answered)
        }
        XCTAssertFalse(offer(active: false), "a background launch must not offer it unseen")
        XCTAssertTrue(offer())
        XCTAssertFalse(offer(minute: 4 * 60 + 30), "04:30 is the middle of the night for a 08:00 riser")
        XCTAssertTrue(offer(minute: 6 * 60 + 30))
        XCTAssertTrue(offer(minute: 13 * 60 + 59))
        XCTAssertFalse(offer(minute: 14 * 60))
        XCTAssertTrue(offer(minute: 4 * 60, earliest: 4 * 60))
        XCTAssertFalse(offer(minute: 3 * 60 + 59, earliest: 0))
        XCTAssertFalse(offer(enabled: false))
        XCTAssertFalse(offer(snoozed: true))
        XCTAssertFalse(offer(skipped: true))
        XCTAssertFalse(offer(answered: true))
        XCTAssertEqual(CheckIn.snoozeMinutes, 60)
    }

    /// The earliest offer is 90 minutes before the usual wake (the median of the last nights' wake times, from
    /// three nights), never before the 04:00 rollover.
    func testTheEarliestOfferFollowsTheUsualWake() {
        XCTAssertNil(CheckIn.usualWakeMinute([480, 470]))
        XCTAssertEqual(CheckIn.usualWakeMinute([480, 470, 500]), 480)
        XCTAssertEqual(CheckIn.usualWakeMinute([420, 600, 480, 470]), 480)
        XCTAssertEqual(CheckIn.earliestOfferMinute(usualWakeMinute: 480), 390)
        XCTAssertEqual(CheckIn.earliestOfferMinute(usualWakeMinute: 300), 240)
        XCTAssertEqual(CheckIn.earliestOfferMinute(usualWakeMinute: nil), 240)
    }

    /// A day counts only when all three questions are answered.
    func testADayCountsOnlyWhenComplete() {
        let q = CheckIn.journalQuestions
        XCTAssertTrue(CheckIn.isComplete([q[0]: 3, q[1]: 4, q[2]: 5]))
        XCTAssertFalse(CheckIn.isComplete([q[0]: 3, q[1]: 4]))
        let series: [String: [String: Double]] = [
            q[0]: ["2026-11-24": 3, "2026-11-25": 4, "2026-11-26": 2],
            q[1]: ["2026-11-24": 3, "2026-11-25": 4],
            q[2]: ["2026-11-25": 5, "2026-11-26": 1],
            "Alcohol": ["2026-11-24": 1],
        ]
        XCTAssertEqual(CheckIn.completedDays(series), 1)
        XCTAssertEqual(CheckIn.completedDays([:]), 0)
    }

    /// Last night is the most recent night that ended in the 18 hours before now, its fragments bridged into one
    /// night (a brief wake, like getting up to pee, does not end it), with the Sleep tab's own times: fell asleep
    /// at its first sleep stage, woke at its last. Not a nap, not a session still going, not the night before.
    func testLastNightBridgesABriefWakeAndUsesTheSleepTabTimes() {
        let t = 1_800_000_000
        func block(_ start: Int, _ end: Int, sleepFrom: Int, sleepTo: Int) -> CachedSleepSession {
            let json = "[{\"start\":\(start),\"end\":\(sleepFrom),\"stage\":\"wake\"},"
                + "{\"start\":\(sleepFrom),\"end\":\(sleepTo),\"stage\":\"light\"},"
                + "{\"start\":\(sleepTo),\"end\":\(end),\"stage\":\"wake\"}]"
            return CachedSleepSession(startTs: start, endTs: end, efficiency: nil, restingHr: nil, avgHrv: nil,
                                      stagesJSON: json)
        }
        // In bed 7 h 30 m before now, asleep 70 minutes later, up for 20 minutes in the night, last sleep ends
        // 50 minutes before now; a 90-minute nap; the night before; a session not over yet.
        let first = block(t - 27_000, t - 13_000, sleepFrom: t - 22_800, sleepTo: t - 13_200)
        let second = block(t - 11_800, t - 2_400, sleepFrom: t - 11_600, sleepTo: t - 3_000)
        let nap = block(t - 62_400, t - 57_000, sleepFrom: t - 62_000, sleepTo: t - 61_000)
        let older = block(t - 33 * 3600, t - 25 * 3600, sleepFrom: t - 32 * 3600, sleepTo: t - 26 * 3600)
        let future = block(t - 1000, t + 1000, sleepFrom: t - 900, sleepTo: t + 900)
        let now = Date(timeIntervalSince1970: TimeInterval(t))
        let night = CheckIn.lastNight([older, nap, second, first, future], now: now, offsetSec: 0)
        XCTAssertEqual(night?.blocks.map(\.startTs), [first.startTs, second.startTs])
        XCTAssertEqual(night?.times, SleepClockTimes.Times(inBed: t - 27_000, fellAsleep: t - 22_800,
                                                           woke: t - 3_000, up: t - 2_400))
        XCTAssertNil(CheckIn.lastNight([older, future], now: now, offsetSec: 0))
        XCTAssertNil(CheckIn.lastNight([], now: now, offsetSec: 0))
        // A night the wearer corrected keeps the wearer's times.
        let edited = CachedSleepSession(startTs: t - 27_000, endTs: t - 2_400, efficiency: nil, restingHr: nil,
                                        avgHrv: nil, stagesJSON: first.stagesJSON, userEdited: true,
                                        startTsAdjusted: t - 24_000)
        XCTAssertEqual(CheckIn.lastNight([edited], now: now, offsetSec: 0)?.times.fellAsleep, t - 24_000)
    }

    /// A clock time picked in the check-in lands on the day nearest NOOP's own time: 23:50 for a 00:31 onset is
    /// the evening before, 01:30 is the same night.
    func testAPickedTimeLandsOnTheNearestDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let reference = 1_800_000_000 - (1_800_000_000 % 86_400) + 31 * 60          // 00:31 UTC
        func at(_ hour: Int, _ minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0,
                          of: Date(timeIntervalSince1970: TimeInterval(reference + 5 * 86_400)))!
        }
        XCTAssertEqual(CheckIn.resolveClock(at(23, 50), near: reference, calendar: calendar), reference - 41 * 60)
        XCTAssertEqual(CheckIn.resolveClock(at(1, 30), near: reference, calendar: calendar), reference + 59 * 60)
    }

    /// The README says what the file holds, including lab.json, the backup and the number of check-ins.
    func testDeveloperReadmeNamesItsContents() {
        let text = DeveloperExport.readme(now: Date(timeIntervalSince1970: 1_800_000_000), appVersion: "12.1.0",
                                          checkIns: 12)
        for part in ["lab.json", "noop-backup.noopbak", "report.txt", "meta.json", "dist/tools/lab.py",
                     "Morning check-ins answered so far: 12.", CheckIn.sleepTimesQuestion] {
            XCTAssertTrue(text.contains(part), part)
        }
        XCTAssertEqual(LabSnapshot.schema, 1)
    }
}
