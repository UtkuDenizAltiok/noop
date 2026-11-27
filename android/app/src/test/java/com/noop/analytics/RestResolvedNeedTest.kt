package com.noop.analytics

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * Pins [RestScorer.resolvedNeedHours] (the one sleep need: chosen, else automatic with the age) and the age
 * targets of [RestScorer.populationNeedFloorHours] (7.5 h from 65, NSF 2015), byte-identical to the Swift twins.
 * The oracle: the Swift functions compiled standalone over the generator below (an MMIX LCG both languages draw
 * the same numbers from), FNV-1a 64 over every result's bit pattern; the literals are its output.
 */
class RestResolvedNeedTest {

    @Test
    fun theAgeTargets() {
        assertEquals(8.0, RestScorer.populationNeedFloorHours(null), 0.0)
        assertEquals(9.0, RestScorer.populationNeedFloorHours(17), 0.0)
        assertEquals(8.0, RestScorer.populationNeedFloorHours(18), 0.0)
        assertEquals(8.0, RestScorer.populationNeedFloorHours(64), 0.0)
        assertEquals(7.5, RestScorer.populationNeedFloorHours(65), 0.0)
        // Cold start is the age target itself.
        assertEquals(7.5, RestScorer.personalizedNeedHours(listOf(7.0, 7.2), 70), 0.0)
    }

    @Test
    fun aChosenNeedWinsAndIsClamped() {
        val nights = List(10) { 9.0 }
        assertEquals(9.0, RestScorer.resolvedNeedHours(0, nights, 30), 0.0)
        assertEquals(7.25, RestScorer.resolvedNeedHours(435, nights, 30), 0.0)
        assertEquals(7.0, RestScorer.resolvedNeedHours(400, nights, 30), 0.0)
        assertEquals(9.5, RestScorer.resolvedNeedHours(600, nights, 30), 0.0)
    }

    private var lcg: Long = 0x2545F4914F6CDD1DL

    private fun nextInt(n: Int): Int {
        lcg = lcg * 6364136223846793005L + 1442695040888963407L
        return ((lcg ushr 33) % n.toLong()).toInt()
    }

    @Test
    fun matchesTheSwiftOracle() {
        val ages = listOf<Int?>(null, 0, 12, 17, 18, 30, 64, 65, 80)
        val chosen = listOf(0, -5, 400, 420, 435, 480, 570, 600)
        val lines = ArrayList<String>()
        for (i in 0 until 400) {
            val n = nextInt(14)
            val nights = (0 until n).map { nextInt(1200) / 100.0 - (if (nextInt(10) == 0) 3.0 else 0.0) }
            val age = ages[nextInt(ages.size)]
            val c = chosen[nextInt(chosen.size)]
            val r = RestScorer.resolvedNeedHours(c, nights, age)
            lines.add("$i:${java.lang.Long.toHexString(r.toRawBits())}")
        }
        var h = -0x340d631b7bdddcdbL // 0xcbf29ce484222325
        val prime = 0x100000001b3L
        for (l in lines) {
            for (b in l.toByteArray(Charsets.UTF_8)) { h = h xor (b.toLong() and 0xFF); h *= prime }
            h = h xor 0x0AL; h *= prime
        }
        assertEquals("0:401c000000000000 1:4020000000000000 2:4023000000000000 3:401c000000000000 4:401c000000000000",
            lines.take(5).joinToString(" "))
        assertEquals("438d833811016adb", java.lang.Long.toHexString(h).padStart(16, '0'))
    }
}
