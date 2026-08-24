package com.noop.ble

import android.os.Build

/**
 * Which manufacturers' ROMs are hostile to background work (#386).
 *
 * NOOP runs a foreground service + exact alarms, which AOSP honours; several OEM battery managers do
 * not. Knowing the device is one of those explains an overnight gap that looks like a NOOP bug, so the
 * Test Centre reports it in diagnostics.
 *
 * This once also carried the battery-optimisation exemption machinery behind a "Keep NOOP alive
 * overnight" Settings row — the exempt check and the intents that requested or revoked it. The row was
 * removed: Android exposes no way for an app to hand that permission back, so the off direction could
 * only ever hand off to a system screen, and a control that cannot complete its own action was more
 * confusing than the problem it addressed. The remaining users of this file read the vendor list only.
 */
object BackgroundHealth {

    /**
     * Manufacturers whose proprietary battery managers kill background work regardless of the AOSP
     * foreground-service contract (the dontkillmyapp.com set). Pure.
     */
    val AGGRESSIVE_VENDORS: List<String> =
        listOf("xiaomi", "oppo", "vivo", "huawei", "oneplus", "realme", "meizu")

    /** True when [manufacturer] is one whose ROM aggressively kills background apps. Pure + Context-free
     *  so it unit-tests without Robolectric. Defaults to this device's manufacturer. */
    fun isAggressiveVendor(manufacturer: String = Build.MANUFACTURER): Boolean {
        val m = manufacturer.lowercase()
        return AGGRESSIVE_VENDORS.any { m.contains(it) }
    }
}
