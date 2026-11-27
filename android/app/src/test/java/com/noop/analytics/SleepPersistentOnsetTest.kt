package com.noop.analytics

import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Test

/**
 * Pins [SleepStager.applyPersistentOnset], sleep onset at the night's first 10 minutes of unbroken staged
 * sleep, byte-identical to the Swift twin `SleepStager.applyPersistentOnset`.
 *
 * The oracle: the Swift twin compiled standalone (`swiftc -O twin.swift main.swift`) ran the generator below
 * (an MMIX linear congruential generator, so both languages draw the same numbers) over 5,000 random
 * hypnograms (unsorted input, ties, gaps, zero-length segments, the "awake"/"AWAKE" spellings, three run
 * lengths) and printed FNV-1a 64 over every output line, plus the first cases verbatim. Those values are the
 * literals here. The Swift side pins the same function with `SleepPersistentOnsetTests`.
 */
class SleepPersistentOnsetTest {

    private fun seg(start: Long, end: Long, stage: String) = StageSegment(start = start, end = end, stage = stage)

    private fun line(segs: List<StageSegment>): String =
        segs.joinToString(";") { "${it.start}-${it.end}:${it.stage}" }

    @Test
    fun beforeTheFirstTenUnbrokenMinutesIsAwake() {
        val t = 1_700_000_000L
        // 5 min light, 2 min wake, 4 min light, 1 min wake, then 30 min of light/deep: onset is the 30-min run.
        val night = listOf(
            seg(t, t + 300, "light"), seg(t + 300, t + 420, "wake"), seg(t + 420, t + 660, "light"),
            seg(t + 660, t + 720, "wake"), seg(t + 720, t + 1500, "light"), seg(t + 1500, t + 2520, "deep"),
        )
        val out = SleepStager.applyPersistentOnset(night)
        assertEquals("${t}-${t + 720}:wake;${t + 720}-${t + 1500}:light;${t + 1500}-${t + 2520}:deep", line(out))
    }

    @Test
    fun aNightAlreadyAsleepFromItsStartIsUnchanged() {
        val t = 1_700_000_000L
        val night = listOf(seg(t, t + 900, "light"), seg(t + 900, t + 1200, "wake"), seg(t + 1200, t + 1800, "rem"))
        assertSame(night, SleepStager.applyPersistentOnset(night))
    }

    @Test
    fun aNightWithNoPersistentRunIsUnchanged() {
        val t = 1_700_000_000L
        val night = listOf(seg(t, t + 300, "light"), seg(t + 300, t + 360, "wake"), seg(t + 360, t + 800, "rem"))
        assertSame(night, SleepStager.applyPersistentOnset(night))
    }

    // ── The oracle ───────────────────────────────────────────────────────────────────────────────────

    private var lcg: Long = -0x61c8864680b583ebL // 0x9E3779B97F4A7C15

    private fun nextInt(n: Int): Int {
        lcg = lcg * 6364136223846793005L + 1442695040888963407L
        return ((lcg ushr 33) % n.toLong()).toInt()
    }

    private val stageNames = listOf("wake", "light", "deep", "rem", "awake", "AWAKE", "light", "rem")
    private val persists = listOf(600L, 300L, 900L)

    private fun makeCase(): Pair<MutableList<StageSegment>, Long> {
        val n = 1 + nextInt(12)
        var t = 1_700_000_000L + nextInt(1000) * 30L
        val segs = ArrayList<StageSegment>()
        repeat(n) {
            if (nextInt(8) == 0) t += nextInt(5) * 30L
            val d = (1 + nextInt(40)) * 30L
            segs.add(seg(t, t + d, stageNames[nextInt(stageNames.size)]))
            t += d
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
        return segs to persists[nextInt(persists.size)]
    }

    @Test
    fun matchesTheSwiftOracleOverFiveThousandRandomNights() {
        var h = -0x340d631b7bdddcdbL // 0xcbf29ce484222325
        val prime = 0x100000001b3L
        val first = ArrayList<String>()
        for (i in 0 until 5000) {
            val (segs, p) = makeCase()
            val input = line(segs)
            val out = line(SleepStager.applyPersistentOnset(segs, minPersistS = p))
            for (b in out.toByteArray(Charsets.UTF_8)) {
                h = h xor (b.toLong() and 0xFF)
                h *= prime
            }
            h = h xor 0x0AL
            h *= prime
            if (i < 3) first.add("$p|$input=>$out")
        }
        assertEquals(
            "300|1700020340-1700021360:deep;1700021360-1700022050:deep;1700022110-1700022890:wake;" +
                "1700022890-1700024030:rem;1700024030-1700024270:awake=>1700020340-1700021360:deep;" +
                "1700021360-1700022050:deep;1700022110-1700022890:wake;1700022890-1700024030:rem;" +
                "1700024030-1700024270:awake",
            first[0])
        assertEquals(
            "900|1700000000-1700000720:rem;1700000720-1700001050:awake;1700001050-1700001080:rem;" +
                "1700001080-1700001620:rem;1700001620-1700002430:light;1700002430-1700002730:awake;" +
                "1700002730-1700003390:wake=>1700000000-1700001050:wake;1700001050-1700001620:rem;" +
                "1700001620-1700002430:light;1700002430-1700002730:awake;1700002730-1700003390:wake",
            first[1])
        assertEquals("45d53ddc7ee2920d", java.lang.Long.toHexString(h).padStart(16, '0'))
    }
}
