package com.noop.analytics

/**
 * The Sleep Regularity Index (Phillips et al., Sci Rep 2017): the chance that the wearer is in the same state,
 * asleep or awake, at the same clock time on two consecutive days, scaled so 100 is a schedule that repeats
 * exactly, 0 one with no day-to-day pattern and -100 one that flips every day (median 81 in 60,977 UK Biobank
 * adults, Windred et al., Sleep 2024). Read minute by minute over the last [PAIRS_WINDOW] pairs of consecutive
 * days from the stored sleep sessions; a day counts only when its longest sleep lasts [MIN_NIGHT_SECONDS], a pair
 * only when both of its days do, and the index needs [MIN_PAIRS] pairs (Fischer et al., Sleep 2021). Swift twin
 * `SleepRegularityIndex`, whose doc carries the reasoning; byte-identical (oracle in `SleepRegularityIndexTest`).
 */
object SleepRegularityIndex {

    /** Pairs of consecutive days looked at: the last 7. Swift twin: `SleepRegularityIndex.pairsWindow`. */
    const val PAIRS_WINDOW: Int = 7

    /** The fewest counted pairs that give an index. Swift twin: `SleepRegularityIndex.minPairs`. */
    const val MIN_PAIRS: Int = 4

    /** The shortest longest-sleep that marks a day as worn: 3 hours. Swift twin: `SleepRegularityIndex.minNightSeconds`. */
    const val MIN_NIGHT_SECONDS: Long = 10_800L

    /**
     * The index from sleep spans (unix seconds, start to end; unsorted, overlapping and empty spans are fine), or
     * null when fewer than [MIN_PAIRS] of the last [PAIRS_WINDOW] day pairs were both worn. Swift twin:
     * `SleepRegularityIndex.compute`.
     */
    fun compute(spans: List<Pair<Long, Long>>, offsetSec: Long): Double? {
        val valid = spans.filter { it.second > it.first }
            .sortedWith(compareBy<Pair<Long, Long>> { it.first }.thenBy { it.second })
        if (valid.isEmpty()) return null
        // The longest sleep of each local day, the day of its midpoint.
        val longest = HashMap<Long, Long>()
        for (s in valid) {
            val day = Math.floorDiv(s.first + (s.second - s.first) / 2 + offsetSec, 86_400L)
            longest[day] = maxOf(longest[day] ?: 0L, s.second - s.first)
        }
        val worn = longest.filter { it.value >= MIN_NIGHT_SECONDS }.keys
        val last = worn.maxOrNull() ?: return null
        // The spans as one sorted union, for a forward sweep.
        val unionStart = ArrayList<Long>()
        val unionEnd = ArrayList<Long>()
        for (s in valid) {
            if (unionEnd.isNotEmpty() && s.first <= unionEnd[unionEnd.size - 1]) {
                unionEnd[unionEnd.size - 1] = maxOf(unionEnd[unionEnd.size - 1], s.second)
            } else {
                unionStart.add(s.first)
                unionEnd.add(s.second)
            }
        }
        var agree = 0L
        var pairs = 0
        for (k in 1..PAIRS_WINDOW) {
            val first = last - k
            if (first !in worn || (first + 1) !in worn) continue
            pairs += 1
            // Noon before the first day's night, in unix seconds; each minute is read at its middle.
            val windowStart = (first - 1) * 86_400L + 43_200L - offsetSec
            var i = 0
            var j = 0
            for (minute in 0 until 1_440) {
                val t = windowStart + minute * 60L + 30L
                while (i < unionEnd.size && unionEnd[i] <= t) i += 1
                val asleepA = i < unionEnd.size && unionStart[i] <= t
                val t2 = t + 86_400L
                while (j < unionEnd.size && unionEnd[j] <= t2) j += 1
                val asleepB = j < unionEnd.size && unionStart[j] <= t2
                if (asleepA == asleepB) agree += 1
            }
        }
        if (pairs < MIN_PAIRS) return null
        return 200.0 * agree.toDouble() / (pairs * 1_440).toDouble() - 100.0
    }

    /**
     * The Rest score's regularity part, 0 to 1: the index on its own scale (100 = full marks, 0 or below = none),
     * or null without an index. Swift twin: `SleepRegularityIndex.consistency`.
     */
    fun consistency(index: Double?): Double? = index?.let { maxOf(0.0, minOf(1.0, it / 100.0)) }
}
