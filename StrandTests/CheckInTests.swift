import XCTest
@testable import Strand

/// Pins the developer loop's rules (handbook `features/lab.md`): the check-in questions are stored under fixed
/// journal questions (a storage contract: answers join on them in every backup), the check-in is offered only when
/// switched on, in the morning, once a day and while unanswered, a day counts only when all three are answered,
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

    /// Offered only when switched on, from 04:00 to before 14:00, once a day, and never once answered.
    func testOfferedOnceInTheMorningWhenSwitchedOn() {
        func offer(enabled: Bool = true, hour: Int = 7, last: String? = "2026-11-25", answered: Bool = false) -> Bool {
            CheckIn.shouldOffer(enabled: enabled, hour: hour, lastOfferedDay: last, today: "2026-11-26",
                                answeredToday: answered)
        }
        XCTAssertTrue(offer())
        XCTAssertTrue(offer(hour: 4))
        XCTAssertTrue(offer(hour: 13))
        XCTAssertFalse(offer(hour: 3))
        XCTAssertFalse(offer(hour: 14))
        XCTAssertFalse(offer(enabled: false))
        XCTAssertFalse(offer(last: "2026-11-26"))
        XCTAssertTrue(offer(last: nil))
        XCTAssertFalse(offer(answered: true))
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

    /// Last night is the main sleep that ended most recently in the 18 hours before now: not a nap, not a
    /// session that has not ended yet, not the night before.
    func testLastNightIsTheLatestMainSleep() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let t = 1_800_000_000
        let night = (start: t - 9 * 3600, end: t - 3600)              // 8 h, ended an hour ago
        let nap = (start: t - 2 * 3600, end: t - 1800)                // 90 min
        let older = (start: t - 33 * 3600, end: t - 25 * 3600)        // the night before
        let future = (start: t - 1000, end: t + 1000)                 // not over yet
        XCTAssertTrue(CheckIn.lastNight([older, night, nap, future], now: now).map { $0 == night } ?? false)
        XCTAssertNil(CheckIn.lastNight([older, nap], now: now))
        XCTAssertNil(CheckIn.lastNight([], now: now))
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
