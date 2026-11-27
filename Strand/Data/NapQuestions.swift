import Foundation
import StrandAnalytics
import WhoopStore

/// Naps NOOP asks about (chat 10; Utku, 27 Nov 2026: naps go unrecognised). A still daytime run must last 90
/// minutes to become a sleep session (`SleepStager.daytimeMinSleepMin`), so a 20 to 60 minute nap never does.
/// `NapDetector` (the twin of Android's review-card detector) finds quiet runs of 20 to 90 minutes with a heart
/// rate near the resting band in the day's recent hours; each becomes a question on the Sleep tab ("Did you nap
/// from 15:10 to 15:42?"), and only a Yes adds it, through the Sleep tab's own "Add a nap" path
/// (`Repository.addManualNap`). A wrong guess therefore never reaches the totals by itself: heart rate separates
/// quiet wakefulness from early sleep poorly (2 bpm on 31 PSG nights, `Tools/SleepPSG --section onset`).
enum NapQuestions {

    /// The questions waiting for an answer, as JSON `[NapCandidate]`.
    static let pendingKey = "naps.pendingQuestions"
    /// The questions already answered (Yes or No), as ids, so none is asked twice.
    static let answeredKey = "naps.answeredQuestions"
    /// When the hours were last looked at (unix seconds).
    static let lastRunKey = "naps.lastRun"

    /// Overlapping windows: 3 hours long, a new one every 90 minutes, so a nap across a boundary is whole in one.
    static let windowSeconds = 3 * 3600
    static let windowStepSeconds = 90 * 60
    static let lookbackSeconds = 24 * 3600
    /// A window must end this long before now, so a nap still going on is not asked about halfway.
    static let settleSeconds = 20 * 60
    /// Only windows centred in the day (local 09:00 to 21:00): the night belongs to sleep detection, and a night
    /// not yet scored must not turn into nap questions.
    static let dayHours = 9..<21
    static let minimumIntervalSeconds = 30 * 60

    static func id(_ c: NapCandidate) -> String { "\(c.start)-\(c.end)" }

    /// The candidates worth asking about: not answered before, not overlapping a night or nap already recorded,
    /// and not overlapping each other (the longer of two overlapping ones is kept; the earlier on a tie).
    static func newQuestions(_ candidates: [NapCandidate], answered: Set<String>,
                             recorded: [(start: Int, end: Int)]) -> [NapCandidate] {
        let fresh = candidates.filter { c in
            !answered.contains(id(c)) && !recorded.contains { $0.start < c.end && c.start < $0.end }
        }.sorted { $0.durationS != $1.durationS ? $0.durationS > $1.durationS : $0.start < $1.start }
        var kept: [NapCandidate] = []
        for c in fresh where !kept.contains(where: { $0.start < c.end && c.start < $0.end }) { kept.append(c) }
        return kept.sorted { $0.start < $1.start }
    }

    /// The window starts to look at, newest last: every `windowStepSeconds` over the last `lookbackSeconds`,
    /// ending at least `settleSeconds` before now and centred in `dayHours` (local).
    static func windowStarts(now: Int, calendar: Calendar = .current) -> [Int] {
        let first = (now - lookbackSeconds) / windowStepSeconds * windowStepSeconds
        return stride(from: first, through: now - settleSeconds - windowSeconds, by: windowStepSeconds).filter { start in
            let hour = calendar.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(start + windowSeconds / 2)))
            return dayHours.contains(hour)
        }
    }

    static var pending: [NapCandidate] {
        guard let data = UserDefaults.standard.data(forKey: pendingKey) else { return [] }
        return (try? JSONDecoder().decode([NapCandidate].self, from: data)) ?? []
    }

    private static func store(pending: [NapCandidate]) {
        if let data = try? JSONEncoder().encode(pending) { UserDefaults.standard.set(data, forKey: pendingKey) }
    }

    private static var answered: Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: answeredKey) ?? [])
    }

    /// Mark a question answered (Yes or No): it leaves the list and is never asked again.
    static func markAnswered(_ c: NapCandidate) {
        store(pending: pending.filter { id($0) != id(c) })
        let list = (UserDefaults.standard.stringArray(forKey: answeredKey) ?? []) + [id(c)]
        UserDefaults.standard.set(Array(list.suffix(300)), forKey: answeredKey)
    }

    /// Look at the recent daytime hours (at most every half hour) and add new questions. Reads only what the
    /// store already holds.
    @MainActor
    static func runIfDue(repo: Repository, now: Date = Date()) async {
        let nowTs = Int(now.timeIntervalSince1970)
        guard nowTs - UserDefaults.standard.integer(forKey: lastRunKey) >= minimumIntervalSeconds else { return }
        UserDefaults.standard.set(nowTs, forKey: lastRunKey)
        var sessions = await repo.sleepSessions(from: nowTs - lookbackSeconds - 86_400, to: nowTs)
        sessions += await repo.computedSleepSessions(from: nowTs - lookbackSeconds - 86_400, to: nowTs)
        let recorded = sessions.map { (start: $0.effectiveStartTs, end: $0.endTs) }
        let resting = repo.days.last(where: { $0.restingHr != nil })?.restingHr
        var found: [NapCandidate] = []
        for start in windowStarts(now: nowTs) {
            let end = start + windowSeconds
            if recorded.contains(where: { $0.start < end && start < $0.end }) { continue }
            let gravity = await repo.gravitySamplesUnion(from: start, to: end, limit: 50_000)
            let hr = await repo.hrSamples(from: start, to: end, limit: 20_000)
            let decision = NapDetector.evaluate(gravity: gravity, hr: hr, restingHr: resting, config: NapConfig())
            if decision.verdict == .nap, let c = decision.candidate { found.append(c) }
        }
        let merged = newQuestions(pending + found, answered: answered, recorded: recorded)
        store(pending: Array(merged.suffix(10)))
    }
}
