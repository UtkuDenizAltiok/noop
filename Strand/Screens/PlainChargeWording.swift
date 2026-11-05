import Foundation
import StrandAnalytics

// PlainChargeWording.swift - everyday words for the Charge driver rows, for Simple mode.
//
// The analytics layer's `ChargeDriver` text ("below baseline, limiting recovery", "85 ms baseline",
// "+0.4 C vs baseline") is a byte-identical contract with Android's `RecoveryDrivers`, so it is never
// reworded at the source. Simple mode translates it here, at the display layer: the same rows, in the same
// order, with the same points and the same direction, only said the way a first-time wearer would say it.
// Every sentence states what the reading did to Charge, and that statement is decided by the same signed
// points the chip prints, so a row can never say "raised" beside a negative chip.

/// Builds the Simple-mode version of one Charge driver row.
enum PlainChargeWording {

    /// The driver as Simple mode shows it. The returned label, verdict and texts are already localized:
    /// `ChargeDriverRow` looks label and verdict up as catalogue keys, and a localized sentence that is not
    /// a key passes through that lookup unchanged. Points are copied as they are.
    ///
    /// - Parameters:
    ///   - skinTempDevC: the night's raw skin-temperature deviation in °C (the value the driver was built
    ///     from), so a Fahrenheit reader gets the deviation converted from the unrounded figure.
    ///   - temperatureUnit: the reader's temperature unit.
    static func driver(_ d: ChargeDriver, skinTempDevC: Double?,
                       temperatureUnit: TemperatureUnit) -> ChargeDriver {
        ChargeDriver(label: label(d.label),
                     deltaPoints: d.deltaPoints,
                     valueText: value(d, skinTempDevC: skinTempDevC, temperatureUnit: temperatureUnit),
                     baselineText: normal(d.baselineText),
                     verdict: verdict(d.verdict, deltaPoints: d.deltaPoints)
                        ?? String(localized: String.LocalizationValue(d.verdict)))
    }

    /// The row name, matching the names the plain guide and the Simple Today use.
    static func label(_ key: String) -> String {
        switch key {
        case "Heart rate variability": return String(localized: "Heart-rate variability")
        // The Rest score itself (the composite, /100), so it carries the score's own name.
        case "Sleep quality":          return String(localized: "Rest")
        case "Respiratory rate":       return String(localized: "Breathing rate")
        default:                       return String(localized: String.LocalizationValue(key))
        }
    }

    /// The reading. Rest drops the percent sign so it reads like the Rest ring above it; breathing spells
    /// out its unit; skin temperature uses a degree sign and the reader's own unit.
    static func value(_ d: ChargeDriver, skinTempDevC: Double?, temperatureUnit: TemperatureUnit) -> String {
        switch d.label {
        case "Sleep quality":
            return d.valueText.hasSuffix("%") ? String(d.valueText.dropLast()) : d.valueText
        case "Respiratory rate":
            return breathingUnit(d.valueText)
        case "Skin temperature":
            guard let dev = skinTempDevC else { return d.valueText }
            return skinTempDeviation(dev, unit: temperatureUnit)
        default:
            return d.valueText
        }
    }

    /// "85 ms baseline" becomes "usually 85 ms". Empty stays empty (the row then shows no normal).
    static func normal(_ baselineText: String) -> String {
        let suffix = " baseline"
        guard baselineText.hasSuffix(suffix) else { return baselineText }
        let figure = breathingUnit(String(baselineText.dropLast(suffix.count)))
        return String(localized: "usually \(figure)")
    }

    /// A skin-temperature deviation with its sign, one decimal and a degree sign. A difference converts to
    /// Fahrenheit by 9/5 with no +32 offset (`UnitFormatter.celsiusDeltaToFahrenheit`). POSIX decimals,
    /// like every other figure in these rows.
    static func skinTempDeviation(_ devC: Double, unit: TemperatureUnit) -> String {
        let shown = unit == .fahrenheit ? UnitFormatter.celsiusDeltaToFahrenheit(devC) : devC
        let number = String(format: "%+.1f", locale: Locale(identifier: "en_US_POSIX"), shown)
        return number + " " + UnitFormatter.temperatureUnit(unit)
    }

    /// "14.2 br/min" becomes "14.2 breaths/min".
    private static func breathingUnit(_ text: String) -> String {
        let short = " br/min"
        guard text.hasSuffix(short) else { return text }
        return String(text.dropLast(short.count)) + " " + String(localized: "breaths/min")
    }

    /// The plain sentence for an analytics verdict, or nil for a verdict this table does not know yet (the
    /// caller then shows the original). Each sentence says how the reading compares with the wearer's
    /// normal and what it did to Charge. The sleep sentences follow the printed points, because the
    /// analytics verdict for that row follows the score's side of a good night (85), not the rounded points.
    static func verdict(_ key: String, deltaPoints: Int) -> String? {
        switch key {
        case "at baseline":
            return String(localized: "The same as your normal, so it didn't change your Charge.")
        case "above baseline, supporting recovery":
            return String(localized: "Higher than your normal, which raised your Charge.")
        case "above baseline, limiting recovery":
            return String(localized: "Higher than your normal, which lowered your Charge.")
        case "below baseline, supporting recovery":
            return String(localized: "Lower than your normal, which raised your Charge.")
        case "below baseline, limiting recovery":
            return String(localized: "Lower than your normal, which lowered your Charge.")
        case "slightly above baseline, supporting recovery":
            return String(localized: "Just above your normal, which raised your Charge a little.")
        case "slightly above baseline, limiting recovery":
            return String(localized: "Just above your normal, which lowered your Charge a little.")
        case "slightly below baseline, supporting recovery":
            return String(localized: "Just below your normal, which raised your Charge a little.")
        case "slightly below baseline, limiting recovery":
            return String(localized: "Just below your normal, which lowered your Charge a little.")
        case "above baseline, too small to change Charge":
            return String(localized: "Higher than your normal, but not by enough to change your Charge.")
        case "below baseline, too small to change Charge":
            return String(localized: "Lower than your normal, but not by enough to change your Charge.")
        case "below baseline, limiting recovery, though low resting HR suggests this may be parasympathetic saturation rather than fatigue":
            return String(localized: "Lower than your normal, which lowered your Charge. Your resting heart rate is unusually low too: in fit people, that mix can mean a very rested body rather than a tired one.")
        case "a strong night, supporting recovery", "below a good night, limiting recovery", "a typical night":
            if deltaPoints > 0 { return String(localized: "A good night's sleep, which raised your Charge.") }
            if deltaPoints < 0 { return String(localized: "Not quite a good night's sleep, which lowered your Charge.") }
            return String(localized: "A typical good night, so it didn't change your Charge.")
        case "near baseline":
            return String(localized: "Close to your normal, so it didn't change your Charge.")
        case "warmer than baseline, limiting recovery":
            return String(localized: "Warmer than your normal, which lowered your Charge.")
        case "cooler than baseline, limiting recovery":
            return String(localized: "Cooler than your normal, which lowered your Charge.")
        default:
            return nil
        }
    }
}
