package com.noop.ui

import android.content.Context
import android.content.SharedPreferences
import com.noop.analytics.RestScorer
import com.noop.data.DailyMetric

/**
 * THE sleep need (v6 step 7): what the sleep debt, tonight's goal, the bedtime reminder and the Rest score all
 * measure against. The wearer's own choice when they made one (Settings), else the automatic need
 * ([RestScorer.personalizedNeedHours] with the wearer's age). The engine works the automatic need out once per
 * pass and hands it here ([storeAutomatic]), so every screen reads the number the engine scored with; before its
 * first pass a screen works it out from the days it holds. Swift twin: `SleepNeed` (Strand/Data/SleepNeed.swift).
 *
 * [attach] runs once at start-up ([AppViewModel]); until then the screens fall back to the automatic need from
 * their own days, which is what the engine would compute.
 */
object SleepNeed {
    /** The engine's automatic need in hours, kept as the Double's bits so screens read the engine's exact value. */
    private const val KEY_AUTOMATIC_BITS = "sleep_need_automatic_bits"

    @Volatile private var prefs: SharedPreferences? = null

    fun attach(context: Context) {
        if (prefs == null) {
            prefs = context.applicationContext.getSharedPreferences(ProfileStore.PREFS, Context.MODE_PRIVATE)
        }
    }

    /** The wearer's chosen minutes, 0 when Automatic. */
    val chosenMinutes: Int
        get() = RestScorer.normalizedChosenNeedMinutes(prefs?.getInt(ProfileStore.KEY_SLEEP_NEED, 0) ?: 0)

    /** The wearer's age as the profile keeps it, or null. */
    private val storedAge: Int?
        get() = prefs?.getInt("age", 0)?.takeIf { it > 0 }

    /** The automatic need in hours: the engine's last figure, else worked out from [days]. */
    fun automaticHours(days: List<DailyMetric> = emptyList()): Double {
        val bits = prefs?.getLong(KEY_AUTOMATIC_BITS, 0L) ?: 0L
        if (bits != 0L) return Double.fromBits(bits)
        return RestScorer.personalizedNeedHours(days.mapNotNull { it.totalSleepMin?.let { m -> m / 60.0 } }, storedAge)
    }

    /** The need in hours every screen uses: the choice, else the automatic need. */
    fun currentHours(days: List<DailyMetric> = emptyList()): Double {
        val chosen = chosenMinutes
        return if (chosen > 0) chosen / 60.0 else automaticHours(days)
    }

    /** The engine keeps its automatic need here once per pass. */
    fun storeAutomatic(hours: Double) {
        prefs?.edit()?.putLong(KEY_AUTOMATIC_BITS, hours.toRawBits())?.apply()
    }

    /** Every value the wearer can pick: 0 (Automatic), then 7h 0m to 9h 30m in 15-minute steps. */
    val choices: List<Int> =
        listOf(0) + (RestScorer.CHOSEN_NEED_MIN_MINUTES..RestScorer.CHOSEN_NEED_MAX_MINUTES step 15).toList()
}
