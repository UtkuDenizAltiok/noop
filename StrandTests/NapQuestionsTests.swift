import XCTest
import StrandAnalytics
@testable import Strand

/// Pins the nap questions' rules (`NapQuestions`): a nap already answered, or overlapping a recorded night or nap,
/// is never asked; of two overlapping candidates the longer is asked; only windows centred in the day and ended
/// at least 20 minutes ago are looked at.
final class NapQuestionsTests: XCTestCase {

    private func napQ(_ start: Int, _ end: Int) -> NapCandidate {
        NapCandidate(start: start, end: end, meanHr: 58, confidence: 0.6)
    }

    func testOnlyNewNonOverlappingNapsAreAsked() {
        let t = 1_800_000_000
        let answered = napQ(t, t + 1800)
        let duringNight = napQ(t + 10_000, t + 11_800)
        let short = napQ(t + 20_000, t + 21_500)
        let longer = napQ(t + 20_500, t + 23_000)
        let alone = napQ(t + 40_000, t + 41_800)
        let asked = NapQuestions.newQuestions([alone, longer, short, duringNight, answered],
                                              answered: [NapQuestions.id(answered)],
                                              recorded: [(start: t + 9_000, end: t + 12_000)])
        XCTAssertEqual(asked, [longer, alone])
    }

    func testOnlyDaytimeWindowsThatHaveSettledAreLookedAt() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let midnight = 1_800_000_000 - (1_800_000_000 % 86_400)
        let now = midnight + 18 * 3600                                  // 18:00
        let starts = NapQuestions.windowStarts(now: now, calendar: calendar)
        XCTAssertFalse(starts.isEmpty)
        for start in starts {
            let centreHour = ((start + NapQuestions.windowSeconds / 2) % 86_400) / 3600
            XCTAssertTrue((9..<21).contains(centreHour), "window centred at \(centreHour):00")
            XCTAssertLessThanOrEqual(start + NapQuestions.windowSeconds, now - NapQuestions.settleSeconds)
        }
    }
}
