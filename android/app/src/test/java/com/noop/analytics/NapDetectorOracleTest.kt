package com.noop.analytics

import com.noop.data.GravitySample
import com.noop.data.HrRow
import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * The cross-platform oracle for [NapDetector]: the Swift twin (`Packages/StrandAnalytics/.../NapDetector.swift`,
 * ported in chat 10 for iOS nap questions) ran this generator (an MMIX LCG both languages draw the same numbers
 * from) and printed FNV-1a 64 over every decision line; these literals are its output (`NapDetectorTests`).
 */
class NapDetectorOracleTest {

    private var lcg: Long = 0x5851F42D4C957F2DL

    private fun nextInt(n: Int): Int {
        lcg = lcg * 6364136223846793005L + 1442695040888963407L
        return ((lcg ushr 33) % n.toLong()).toInt()
    }

    @Test
    fun matchesTheSwiftOracle() {
        var h = -0x340d631b7bdddcdbL // 0xcbf29ce484222325
        val prime = 0x100000001b3L
        val first = ArrayList<String>()
        for (i in 0 until 300) {
            val start = 1_800_000_000L + nextInt(10_000) * 30L
            val quiet = 5 + nextInt(110)
            val quietFrom = start + (5 + nextInt(30)) * 60L
            val resting: Int? = if (nextInt(5) == 0) null else 45 + nextInt(20)
            val hrOffset = nextInt(25) - 5
            val step = listOf(30, 30, 60, 120)[nextInt(4)]
            val grav = ArrayList<GravitySample>()
            val hr = ArrayList<HrRow>()
            for (k in 0 until (9000 / step)) {
                val ts = start + k * step
                val still = ts >= quietFrom && ts < quietFrom + quiet * 60L
                val jitter = (nextInt(7) - 3) / 1000.0
                val x = if (still) jitter else (if (k % 2 == 0) 0.5 else -0.5) + jitter
                grav.add(GravitySample(deviceId = "d", ts = ts, x = x, y = 0.1, z = 0.98))
            }
            for (k in 0 until 150) {
                val ts = start + k * 60L
                val still = ts >= quietFrom && ts < quietFrom + quiet * 60L
                hr.add(HrRow(ts, if (still) (resting ?: 60) + hrOffset else 90 + nextInt(20)))
            }
            val d = NapDetector.evaluate(grav, hr, resting, NapConfig(enabled = true))
            val c = d.candidate
            val line = "${d.verdict.name}|${c?.start ?: -1}|${c?.end ?: -1}|${c?.meanHr ?: -1}|" +
                java.lang.Long.toHexString((c?.confidence ?: 0.0).toRawBits()).let { if (c == null) "0" else it }
            for (b in line.toByteArray(Charsets.UTF_8)) { h = h xor (b.toLong() and 0xFF); h *= prime }
            h = h xor 0x0AL; h *= prime
            if (i < 3) first.add(line)
        }
        assertEquals("NAP|1800201060|1800204660|57|3fe9d41d41d41d42", first[1])
        assertEquals("88d66a6214fd4b33", java.lang.Long.toHexString(h).padStart(16, '0'))
    }
}
