package com.noop.analytics

import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Test

/**
 * Pins [SleepStager.applyWakeRescoring], Webster's rescoring rules (Webster et al., Sleep 1982) and the
 * night's final awakening at the end of its last 10 minutes of unbroken sleep, byte-identical to the Swift
 * twin `SleepStager.applyWakeRescoring`.
 *
 * The oracle: the Swift twin compiled standalone (`swiftc -O twin.swift main.swift`) ran the generator below
 * (an MMIX linear congruential generator, so both languages draw the same numbers) over 5,000 random
 * hypnograms (unsorted input, ties, gaps, the "awake"/"AWAKE" spellings, long wake runs, three run lengths;
 * 4,315 of them change) and printed FNV-1a 64 over every output line, plus the first cases verbatim. Those
 * values are the literals here. The Swift side pins the same function with `SleepWakeRescoringTests`.
 */
class SleepWakeRescoringTest {

    private fun seg(start: Long, end: Long, stage: String) = StageSegment(start = start, end = end, stage = stage)

    private fun line(segs: List<StageSegment>): String =
        segs.joinToString(";") { "${it.start}-${it.end}:${it.stage}" }

    private val t = 1_700_000_000L

    @Test
    fun afterFourMinutesAwakeTheNextMinuteOfSleepIsAwake() {
        val night = listOf(seg(t, t + 1_800, "light"), seg(t + 1_800, t + 2_100, "wake"), seg(t + 2_100, t + 3_900, "light"))
        assertEquals(
            "$t-${t + 1_800}:light;${t + 1_800}-${t + 2_160}:wake;${t + 2_160}-${t + 3_900}:light",
            line(SleepStager.applyWakeRescoring(night)))
    }

    @Test
    fun afterTenAndFifteenMinutesAwakeThreeAndFourMinutesAreAwake() {
        val ten = listOf(seg(t, t + 1_800, "deep"), seg(t + 1_800, t + 2_520, "wake"), seg(t + 2_520, t + 4_320, "rem"))
        assertEquals(seg(t + 1_800, t + 2_700, "wake"), SleepStager.applyWakeRescoring(ten)[1])
        val fifteen = listOf(seg(t, t + 1_800, "deep"), seg(t + 1_800, t + 2_760, "wake"), seg(t + 2_760, t + 4_560, "rem"))
        assertEquals(seg(t + 1_800, t + 3_000, "wake"), SleepStager.applyWakeRescoring(fifteen)[1])
    }

    @Test
    fun aShortSleepInsideLongWakeIsAwake() {
        val d = listOf(
            seg(t, t + 1_800, "light"), seg(t + 1_800, t + 2_460, "wake"), seg(t + 2_460, t + 2_760, "light"),
            seg(t + 2_760, t + 3_420, "wake"), seg(t + 3_420, t + 5_220, "light"),
        )
        assertEquals(
            "$t-${t + 1_800}:light;${t + 1_800}-${t + 3_600}:wake;${t + 3_600}-${t + 5_220}:light",
            line(SleepStager.applyWakeRescoring(d)))
        val e = listOf(
            seg(t, t + 1_800, "light"), seg(t + 1_800, t + 3_060, "wake"), seg(t + 3_060, t + 3_540, "rem"),
            seg(t + 3_540, t + 4_800, "wake"), seg(t + 4_800, t + 6_600, "light"),
        )
        assertEquals(seg(t + 1_800, t + 5_040, "wake"), SleepStager.applyWakeRescoring(e)[1])
        val notE = listOf(
            seg(t, t + 1_800, "light"), seg(t + 1_800, t + 2_460, "wake"), seg(t + 2_460, t + 2_940, "rem"),
            seg(t + 2_940, t + 3_600, "wake"), seg(t + 3_600, t + 5_400, "light"),
        )
        assertEquals(seg(t + 2_640, t + 2_940, "rem"), SleepStager.applyWakeRescoring(notE)[2])
    }

    @Test
    fun theNightEndsAtItsLastTenMinutesOfSleep() {
        val night = listOf(
            seg(t, t + 3_600, "light"), seg(t + 3_600, t + 3_780, "wake"), seg(t + 3_780, t + 4_140, "light"),
            seg(t + 4_140, t + 4_500, "wake"),
        )
        assertEquals("$t-${t + 3_600}:light;${t + 3_600}-${t + 4_500}:wake", line(SleepStager.applyWakeRescoring(night)))
        val back = listOf(
            seg(t, t + 3_600, "light"), seg(t + 3_600, t + 3_780, "wake"), seg(t + 3_780, t + 4_380, "rem"),
            seg(t + 4_380, t + 4_500, "wake"),
        )
        assertSame(back, SleepStager.applyWakeRescoring(back))
    }

    @Test
    fun aNightWithoutWakeOrPersistentSleepKeepsItsSleep() {
        val asleep = listOf(seg(t, t + 1_800, "light"), seg(t + 1_800, t + 3_000, "deep"))
        assertSame(asleep, SleepStager.applyWakeRescoring(asleep))
        val short = listOf(seg(t, t + 300, "light"), seg(t + 300, t + 420, "wake"), seg(t + 420, t + 840, "rem"))
        assertSame(short, SleepStager.applyWakeRescoring(short))
    }

    // ── The oracle ───────────────────────────────────────────────────────────────────────────────────

    private var lcg: Long = -0x2e4ab5cd2e6d12fdL // 0xD1B54A32D192ED03

    private fun nextInt(n: Int): Int {
        lcg = lcg * 6364136223846793005L + 1442695040888963407L
        return ((lcg ushr 33) % n.toLong()).toInt()
    }

    private val stageNames = listOf("wake", "light", "deep", "rem", "awake", "AWAKE", "light", "wake")
    private val persists = listOf(600L, 300L, 900L)

    @Test
    fun matchesTheSwiftOracleOverFiveThousandRandomNights() {
        var h = -0x340d631b7bdddcdbL // 0xcbf29ce484222325
        val prime = 0x100000001b3L
        val cases = ArrayList<String>()
        repeat(5000) {
            val n = 1 + nextInt(24)
            var start = 1_700_000_000L + nextInt(1000) * 30L
            val segs = ArrayList<StageSegment>()
            repeat(n) {
                if (nextInt(8) == 0) start += nextInt(5) * 30L
                val d = (1 + nextInt(50)) * 30L
                segs.add(seg(start, start + d, stageNames[nextInt(stageNames.size)]))
                start += d
            }
            if (segs.size > 1 && nextInt(5) == 0) {
                val i = nextInt(segs.size)
                val j = nextInt(segs.size)
                val tmp = segs[i]; segs[i] = segs[j]; segs[j] = tmp
            }
            if (segs.size > 1 && nextInt(10) == 0) {
                val i = 1 + nextInt(segs.size - 1)
                segs[i] = seg(segs[i - 1].start, segs[i].end, segs[i].stage)
            }
            val p = persists[nextInt(persists.size)]
            val input = line(segs)
            val out = line(SleepStager.applyWakeRescoring(segs, minPersistS = p))
            for (b in out.toByteArray(Charsets.UTF_8)) {
                h = h xor (b.toLong() and 0xFF)
                h *= prime
            }
            h = h xor 0x0AL
            h *= prime
            if (cases.size < 3) cases.add("$p|$input=>$out")
        }
        assertEquals(
            "600|1700020970-1700022230:wake;1700022230-1700022770:light;1700022770-1700023190:light;" +
                "1700023190-1700024420:awake;1700024420-1700024900:AWAKE=>1700020970-1700022470:wake;" +
                "1700022470-1700023190:light;1700023190-1700024420:awake;1700024420-1700024900:AWAKE",
            cases[2])
        assertEquals("2414143cc0221255", java.lang.Long.toHexString(h).padStart(16, '0'))
    }
}
