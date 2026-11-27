import Foundation

/// The Sleep Regularity Index (Phillips et al., Sci Rep 2017;7:3216): the chance that the wearer is in the same
/// state, asleep or awake, at the same clock time on two consecutive days, scaled so 100 is a schedule that
/// repeats exactly, 0 is one with no day-to-day pattern, and -100 one that flips every day. It is the measure the
/// regularity research uses: in 60,977 UK Biobank adults with a week of wrist accelerometry its median was 81,
/// and the most regular sleepers had a 20 to 48 % lower risk of death than the least regular, more than sleep
/// duration predicted (Windred et al., Sleep 2024;47(1):zsad253).
///
/// NOOP reads it from the stored sleep sessions, minute by minute, over the last `pairsWindow` pairs of
/// consecutive days (a week, as in the UK Biobank studies). A minute is asleep when any session covers it (a
/// main night or a nap). A day counts only when its longest sleep lasts `minNightSeconds` or more, so a night
/// without the strap is left out rather than read as a night awake, and a pair counts only when both of its days
/// do. The index needs `minPairs` such pairs: Fischer et al. (Sleep 2021;44(10):zsab103) found it stable with up
/// to half the data missing at random. Before that it is nil and the Rest score's regularity part stays neutral.
/// Each day's window runs from noon to noon in the wearer's time zone (`offsetSec`), so a night sits in one
/// window. Pure; Kotlin twin `SleepRegularityIndex`.
public enum SleepRegularityIndex {

    /// Pairs of consecutive days looked at: the last 7. Kotlin twin: `SleepRegularityIndex.PAIRS_WINDOW`.
    public static let pairsWindow: Int = 7

    /// The fewest counted pairs that give an index. Kotlin twin: `SleepRegularityIndex.MIN_PAIRS`.
    public static let minPairs: Int = 4

    /// The shortest longest-sleep that marks a day as worn: 3 hours, longer than any nap NOOP asks about (90
    /// minutes). Kotlin twin: `SleepRegularityIndex.MIN_NIGHT_SECONDS`.
    public static let minNightSeconds: Int = 10_800

    /// The index from sleep spans (unix seconds; unsorted, overlapping and empty spans are fine), or nil when
    /// fewer than `minPairs` of the last `pairsWindow` day pairs were both worn. Kotlin twin:
    /// `SleepRegularityIndex.compute`.
    public static func compute(spans: [(start: Int, end: Int)], offsetSec: Int) -> Double? {
        let valid = spans.filter { $0.end > $0.start }
            .sorted { $0.start != $1.start ? $0.start < $1.start : $0.end < $1.end }
        guard !valid.isEmpty else { return nil }
        // The longest sleep of each local day, the day of its midpoint.
        var longest: [Int: Int] = [:]
        for s in valid {
            let local = s.start + (s.end - s.start) / 2 + offsetSec
            let day = local >= 0 ? local / 86_400 : (local - 86_399) / 86_400
            longest[day] = max(longest[day] ?? 0, s.end - s.start)
        }
        let worn = Set(longest.filter { $0.value >= minNightSeconds }.map(\.key))
        guard let last = worn.max() else { return nil }
        // The spans as one sorted union, for a forward sweep.
        var union: [(start: Int, end: Int)] = []
        for s in valid {
            if let tail = union.last, s.start <= tail.end {
                union[union.count - 1].end = max(tail.end, s.end)
            } else {
                union.append(s)
            }
        }
        var agree = 0
        var pairs = 0
        for k in 1...pairsWindow {
            let first = last - k
            guard worn.contains(first), worn.contains(first + 1) else { continue }
            pairs += 1
            // Noon before the first day's night, in unix seconds; each minute is read at its middle.
            let windowStart = (first - 1) * 86_400 + 43_200 - offsetSec
            var i = 0
            var j = 0
            for minute in 0..<1_440 {
                let t = windowStart + minute * 60 + 30
                while i < union.count && union[i].end <= t { i += 1 }
                let asleepA = i < union.count && union[i].start <= t
                let t2 = t + 86_400
                while j < union.count && union[j].end <= t2 { j += 1 }
                let asleepB = j < union.count && union[j].start <= t2
                if asleepA == asleepB { agree += 1 }
            }
        }
        guard pairs >= minPairs else { return nil }
        return 200.0 * Double(agree) / Double(pairs * 1_440) - 100.0
    }

    /// The Rest score's regularity part, 0 to 1: the index on its own scale (100 = full marks, 0 or below = none),
    /// or nil without an index. Kotlin twin: `SleepRegularityIndex.consistency`.
    public static func consistency(_ index: Double?) -> Double? {
        index.map { max(0.0, min(1.0, $0 / 100.0)) }
    }
}
