package com.noop.analytics

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * Pins [SleepRegularityIndex] (the Sleep Regularity Index, Phillips et al. 2017), byte-identical to the Swift
 * twin `SleepRegularityIndex`.
 *
 * The oracle: the Swift twin compiled standalone (`swiftc -O twin.swift main.swift`) ran the generator below
 * (an MMIX linear congruential generator, so both languages draw the same numbers) over 3,000 random histories
 * (1 to 20 days, missed nights, nights from 2.5 to 9.5 hours shifting up to three hours, naps, duplicate and
 * empty spans, shuffled order, time zones from -12 to +14 hours) and printed FNV-1a 64 over every result's bit
 * pattern (or "nil"; 2,122 of them), plus the first case. Those values are the literals here. The Swift side
 * pins the same function with `SleepRegularityIndexTests`.
 */
class SleepRegularityIndexTest {

    /** The night of local day [day] in UTC+1: from [startHour] (negative = the evening before) for [hours]. */
    private fun night(day: Int, startHour: Double = -1.0, hours: Double = 8.0): Pair<Long, Long> {
        val localMidnight = 1_700_006_400L + day * 86_400L - 3_600L
        val start = localMidnight + (startHour * 3_600).toLong()
        return start to start + (hours * 3_600).toLong()
    }

    @Test
    fun theSameNightEveryDayScoresOneHundred() {
        assertEquals(100.0, SleepRegularityIndex.compute((1..8).map { night(it) }, 3_600L)!!, 0.0)
    }

    @Test
    fun nightsAlternatingByFourHoursScoreAThird() {
        val week = (1..8).map { if (it % 2 == 0) night(it) else night(it, startHour = 3.0) }
        assertEquals(33.333333333, SleepRegularityIndex.compute(week, 3_600L)!!, 1e-6)
    }

    @Test
    fun itNeedsFourPairsOfWornDays() {
        assertNull(SleepRegularityIndex.compute((1..4).map { night(it) }, 3_600L))
        assertEquals(100.0, SleepRegularityIndex.compute((1..5).map { night(it) }, 3_600L)!!, 0.0)
        assertNull(SleepRegularityIndex.compute((1..15 step 2).map { night(it) }, 3_600L))
        assertNull(SleepRegularityIndex.compute(emptyList(), 3_600L))
    }

    @Test
    fun aDayCountsFromThreeHoursOfSleep() {
        val short = (1..8).map { if (it == 5) night(it, hours = 2.99) else night(it) }
        assertEquals(100.0, SleepRegularityIndex.compute(short, 3_600L)!!, 0.0)
        val three = (1..8).map { if (it == 5) night(it, hours = 3.0) else night(it) }
        assertEquals(200.0 * 9_480.0 / 10_080.0 - 100.0, SleepRegularityIndex.compute(three, 3_600L)!!, 1e-9)
    }

    @Test
    fun aNapCountsAsSleep() {
        val week = (1..8).map { night(it) } + listOf(night(4, startHour = 14.0, hours = 1.0))
        assertEquals(200.0 * 9_960.0 / 10_080.0 - 100.0, SleepRegularityIndex.compute(week, 3_600L)!!, 1e-9)
    }

    @Test
    fun theRestPartIsTheIndexOnItsOwnScale() {
        assertNull(SleepRegularityIndex.consistency(null))
        assertEquals(0.81, SleepRegularityIndex.consistency(81.0)!!, 0.0)
        assertEquals(0.0, SleepRegularityIndex.consistency(-20.0)!!, 0.0)
        assertEquals(1.0, SleepRegularityIndex.consistency(100.0)!!, 0.0)
    }

    // ── The oracle ───────────────────────────────────────────────────────────────────────────────────

    private var lcg: Long = 0x2545F4914F6CDD1DL

    private fun nextInt(n: Int): Int {
        lcg = lcg * 6364136223846793005L + 1442695040888963407L
        return ((lcg ushr 33) % n.toLong()).toInt()
    }

    @Test
    fun matchesTheSwiftOracleOverThreeThousandRandomHistories() {
        var h = -0x340d631b7bdddcdbL // 0xcbf29ce484222325
        val prime = 0x100000001b3L
        var firstCase = ""
        var nils = 0
        for (i in 0 until 3000) {
            val offset = (nextInt(105) - 48) * 900L
            val base = 1_700_006_400L + nextInt(400) * 86_400L
            val days = 1 + nextInt(20)
            val spans = ArrayList<Pair<Long, Long>>()
            for (d in 0 until days) {
                val dayStart = base + d * 86_400L - offset
                if (nextInt(100) < 95) {
                    val bed = dayStart - 7_200L + (nextInt(73) - 36) * 300L
                    val len = 9_000L + nextInt(85) * 300L
                    spans.add(bed to bed + len)
                    if (nextInt(10) == 0) spans.add(bed + 600L to bed + len - 900L)
                }
                if (nextInt(100) < 20) {
                    val nap = dayStart + 46_800L + nextInt(49) * 300L
                    spans.add(nap to nap + 1_200L + nextInt(21) * 300L)
                }
                if (nextInt(40) == 0) spans.add(dayStart to dayStart)
            }
            if (spans.size > 1 && nextInt(4) == 0) {
                val a = nextInt(spans.size)
                val b = nextInt(spans.size)
                val tmp = spans[a]; spans[a] = spans[b]; spans[b] = tmp
            }
            val idx = SleepRegularityIndex.compute(spans, offset)
            val out = idx?.let { java.lang.Long.toHexString(java.lang.Double.doubleToRawLongBits(it)).padStart(16, '0') } ?: "nil"
            if (idx == null) nils += 1
            for (b in out.toByteArray(Charsets.UTF_8)) {
                h = h xor (b.toLong() and 0xFF)
                h *= prime
            }
            h = h xor 0x0AL
            h *= prime
            if (i == 0) {
                val f = spans.firstOrNull()
                firstCase = "$offset|${spans.size}|${f?.let { "${it.first}-${it.second}" } ?: "-"}=>$out"
            }
        }
        assertEquals("-7200|14|1709945100-1709967300=>404ff1c71c71c71c", firstCase)
        assertEquals(2122, nils)
        assertEquals("3a8a2d067deb0bf6", java.lang.Long.toHexString(h).padStart(16, '0'))
    }
}
