package com.noop.analytics

import com.noop.data.RrInterval
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class HrvAnalyzerSdnnQualityTest {
    private fun sdnnQualityFixtureRows(offset: Long = 0L): List<RrInterval> =
        List(300) { RrInterval("synthetic", offset + it, 1000 + (it % 4) * 10) }

    @Test
    fun cleanSegmentKeepsItsSampleSdnn() {
        assertEquals(11.199020501841618, HrvAnalyzer.sdnnIndex(sdnnQualityFixtureRows())!!, 1e-12)
    }

    @Test
    fun duplicateDeliveriesCannotSupplyDailySdnn() {
        val duplicated = sdnnQualityFixtureRows().flatMap { listOf(it, it) }
        assertNull(HrvAnalyzer.sdnnIndex(duplicated))
    }

    @Test
    fun bankedIntervalsCannotSupplyDailySdnn() {
        val banked = sdnnQualityFixtureRows().mapIndexed { index, beat ->
            RrInterval("synthetic", (index / 6 * 6).toLong(), beat.rrMs)
        }
        assertNull(HrvAnalyzer.sdnnIndex(banked))
    }

    @Test
    fun refusedSegmentDoesNotDiscardCleanSegment() {
        val clean = sdnnQualityFixtureRows()
        val bad = sdnnQualityFixtureRows(300L).flatMap { listOf(it, it) }
        assertEquals(11.199020501841618, HrvAnalyzer.sdnnIndex(clean + bad)!!, 1e-12)
    }
}
