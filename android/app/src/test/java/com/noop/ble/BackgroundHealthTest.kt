package com.noop.ble

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * #386: the aggressive-OEM vendor classifier behind the Test Centre `oemKillHeuristic`. Pure +
 * Context-free — the ONE canonical set, so an overnight gap on a hostile ROM is explained rather
 * than mistaken for a NOOP bug. Case-insensitive, substring match (real `Build.MANUFACTURER`
 * values vary in casing and extra words).
 */
class BackgroundHealthTest {

    @Test
    fun `known aggressive vendors match, case-insensitively`() {
        // Real Build.MANUFACTURER values (a Redmi/Poco device reports "Xiaomi", not "Redmi").
        listOf(
            "Xiaomi", "xiaomi",
            "OPPO", "oppo", "realme", "Realme",
            "vivo", "Vivo",
            "HUAWEI", "Huawei",
            "OnePlus", "oneplus",
            "Meizu",
        ).forEach { assertTrue("$it should be aggressive", BackgroundHealth.isAggressiveVendor(it)) }
    }

    @Test
    fun `standard vendors do not match`() {
        listOf("Google", "samsung", "Samsung", "motorola", "Nothing", "Sony", "Fairphone", "")
            .forEach { assertFalse("$it should NOT be aggressive", BackgroundHealth.isAggressiveVendor(it)) }
    }

    @Test
    fun `the canonical set is exactly the dontkillmyapp vendors`() {
        // Pin the list so a future edit is a deliberate, reviewed change (it drives who gets prompted).
        assertEquals(
            listOf("xiaomi", "oppo", "vivo", "huawei", "oneplus", "realme", "meizu"),
            BackgroundHealth.AGGRESSIVE_VENDORS,
        )
    }
}
