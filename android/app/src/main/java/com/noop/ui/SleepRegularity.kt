package com.noop.ui

import android.content.Context
import android.content.SharedPreferences
import com.noop.analytics.SleepRegularityIndex

/**
 * The wearer's Sleep Regularity Index ([SleepRegularityIndex]): how alike the last week's sleep and wake times
 * were. The engine works it out once per pass from the stored sleep sessions and hands it here ([store]), so the
 * Rest score it stores and the Rest score every screen shows read the same number. Null until about five nights
 * in a row exist; the Rest score's regularity part is then the neutral half. Swift twin: `SleepRegularity`
 * (Strand/Data/SleepRegularity.swift).
 *
 * [attach] runs once at start-up ([AppViewModel]); until then, and in JVM tests, there is no index.
 */
object SleepRegularity {
    /** The index from the engine's last pass, kept as the Double's bits; absent when there was none. */
    private const val KEY_INDEX_BITS = "sleep_regularity_index_bits"

    @Volatile private var prefs: SharedPreferences? = null

    fun attach(context: Context) {
        if (prefs == null) {
            prefs = context.applicationContext.getSharedPreferences(ProfileStore.PREFS, Context.MODE_PRIVATE)
        }
    }

    /** The engine keeps its index here once per pass; null clears it. */
    fun store(index: Double?) {
        val p = prefs ?: return
        if (index == null) {
            p.edit().remove(KEY_INDEX_BITS).apply()
        } else {
            p.edit().putLong(KEY_INDEX_BITS, index.toRawBits()).apply()
        }
    }

    /** The index from the engine's last pass, or null. */
    val index: Double?
        get() = prefs?.takeIf { it.contains(KEY_INDEX_BITS) }?.let { Double.fromBits(it.getLong(KEY_INDEX_BITS, 0L)) }

    /** The Rest score's regularity part, 0 to 1, or null (neutral) without an index. */
    val consistency: Double?
        get() = SleepRegularityIndex.consistency(index)
}
