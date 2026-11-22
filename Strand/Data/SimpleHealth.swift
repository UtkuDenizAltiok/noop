import Foundation
import StrandAnalytics

/// Simple mode's "Is my body all right?" (Design v6, step 4): the Health monitor's verdict and reading rows,
/// and the Stress screen's sentence and markers, in plain words.
///
/// Presentation only. Every figure is the one the full view resolves (`BodyVitalSigns.readings`,
/// `StressModel`); these rules decide how it is said. A reading is judged on the numbers as they are printed,
/// so a row can never call a value "higher" beside a range it reads inside (the rule step 2's score pages use,
/// `SimpleScoreRules.comparison`).
enum SimpleHealthRules {

    // MARK: Reading rows

    /// What a row's range is.
    enum Basis: Equatable {
        /// The wearer's own band: where most of their nights fall (`VitalBands`, once its baseline is trusted).
        case personal
        /// A fixed range for adults: before the wearer's own band is known, after a long gap in wear, and
        /// always for blood oxygen, whose healthy range is the same for everyone.
        case typical
    }

    /// How a value stands against its range.
    enum Word: Equatable {
        case within, higher, lower
    }

    /// One reading as Simple mode's Health monitor shows it.
    struct Row: Equatable, Identifiable {
        /// The `BodyVitalReading.key` ("rhr", "hrv", "resp", "spo2", "skin").
        let key: String
        /// The value as printed, without its unit ("58"); nil when there is no value.
        let printedValue: String?
        /// The range's ends, printed like the value; nil without a range.
        let printedLow: String?
        let printedHigh: String?
        let basis: Basis
        /// Nil when there is no value or no range to judge it against.
        let word: Word?
        /// The night the value is from, only when it is not the latest logical day (a carried reading).
        let carriedDayKey: String?
        /// Valid nights behind the wearer's own band (`VitalBands.Result.nights`).
        let nights: Int
        /// Whether this reading can have a band of its own at all: blood oxygen never does.
        let canBePersonal: Bool

        var id: String { key }
        var isOutside: Bool { word == .higher || word == .lower }
    }

    /// The order of the rows: the two readings that move most from night to night first, the steadiest last.
    /// The raw SpO₂ counts stay out: they have no range and no meaning on their own (Show everything has them).
    static let rowOrder = ["rhr", "hrv", "resp", "spo2", "skin"]

    /// The rows, in `rowOrder`, from the readings the full view's tiles draw.
    static func rows(_ readings: [BodyVitalReading], todayKey: String) -> [Row] {
        rowOrder.compactMap { key in
            guard let reading = readings.first(where: { $0.key == key }) else { return nil }
            let value = reading.value.map(reading.format)
            let low = reading.normalRange.map { reading.format($0.lowerBound) }
            let high = reading.normalRange.map { reading.format($0.upperBound) }
            var word: Word?
            if let value, let low, let high {
                switch SimpleScoreRules.comparison(printed: value, lowPrinted: low, highPrinted: high) {
                case .higher: word = .higher
                case .lower: word = .lower
                case .within: word = .within
                case nil: word = nil
                }
            }
            return Row(key: key, printedValue: value, printedLow: low, printedHigh: high,
                       basis: reading.banding.basis == .personal ? .personal : .typical,
                       word: word,
                       carriedDayKey: reading.day.flatMap { $0 == todayKey ? nil : $0 },
                       nights: reading.banding.nights,
                       canBePersonal: key != "spo2")
        }
    }

    /// A range as printed ("52–62"). A fixed adult range is whole numbers, so its ".0" goes ("12–20", not
    /// "12.0–20.0"); the wearer's own band keeps the value's decimals. A signed end (a skin-temperature change)
    /// gets spaces around the dash, so "-0.4 – +0.5" does not read as one number.
    static func rangeText(low: String, high: String, basis: Basis) -> String {
        func trimmed(_ s: String) -> String { basis == .typical && s.hasSuffix(".0") ? String(s.dropLast(2)) : s }
        let (l, h) = (trimmed(low), trimmed(high))
        if l == h { return l }
        let signed = [l, h].contains { $0.hasPrefix("-") || $0.hasPrefix("+") }
        return [l, h].joined(separator: signed ? " – " : "–")
    }

    // MARK: Verdict

    /// Why some readings are still judged against adult ranges.
    enum Learning: Equatable {
        /// The wearer's own normal is still being learned: `have` of `need` nights so far.
        case nights(have: Int, need: Int)
        /// It was known, but the strap has not been worn at night for so long that it no longer counts.
        case stale
    }

    /// The sentence the Health monitor opens with, unless the illness watch has something to say (then its own
    /// card is the verdict: one source, so the two cannot disagree).
    enum Verdict: Equatable {
        case noReadings
        case allClear(learning: Learning?)
        /// `keys` in row order. `cautious` asks for the line about illness and strain: a reading is outside the
        /// wearer's own normal, or outside a range that holds for everyone (blood oxygen). A reading outside an
        /// adult range in the first nights is more often just the wearer, and is said so instead.
        case outside(keys: [String], learning: Learning?, cautious: Bool)
    }

    static func verdict(_ rows: [Row]) -> Verdict {
        let measured = rows.filter { $0.printedValue != nil }
        guard !measured.isEmpty else { return .noReadings }
        let onAdultRanges = measured.filter { $0.canBePersonal && $0.basis == .typical }
        var learning: Learning?
        if let fewest = onAdultRanges.map(\.nights).min() {
            learning = fewest < Baselines.minNightsTrust
                ? .nights(have: fewest, need: Baselines.minNightsTrust)
                : .stale
        }
        let outside = measured.filter(\.isOutside)
        guard !outside.isEmpty else { return .allClear(learning: learning) }
        let cautious = outside.contains { $0.basis == .personal || !$0.canBePersonal }
        return .outside(keys: outside.map(\.key), learning: learning, cautious: cautious)
    }
}

/// Simple mode's Stress screen, in words (Design v6, step 4; science finding S2). The morning number is last
/// night's resting heart rate and HRV against the wearer's last 30 days (`StressModel`), so its sentence says
/// what those two readings did and never how hard to train: only "Your day" on Today advises (rule 4).
enum SimpleStressRules {

    /// The sentence under the morning number: the band, and which of the two readings moved, by the same
    /// threshold as the full view's sentence (`StressMath.explanation`, a change of more than 1 bpm or 1 ms).
    /// Each case names only a reading that moved the band's way, so no sentence claims a change that is not
    /// there (the full view's "at or below baseline" could sit beside an HRV a few ms down).
    enum Sentence: Equatable {
        case lowBoth, lowHRV, lowRHR, lowOther
        case mediumRHR, mediumHRV, mediumOther
        case highBoth, highHRV, highRHR, highOther
    }

    /// The change that counts as "moved", in bpm or ms: the full view's threshold.
    static let movedThreshold = 1.0

    static func sentence(band: StressBand, rhrDelta: Double?, hrvDelta: Double?) -> Sentence {
        let rhrUp = (rhrDelta ?? 0) > movedThreshold
        let rhrDown = (rhrDelta ?? 0) < -movedThreshold
        let hrvUp = (hrvDelta ?? 0) > movedThreshold
        let hrvDown = (hrvDelta ?? 0) < -movedThreshold
        switch band {
        case .low:
            if rhrDown && hrvUp { return .lowBoth }
            if hrvUp { return .lowHRV }
            return rhrDown ? .lowRHR : .lowOther
        case .medium:
            if rhrUp { return .mediumRHR }
            return hrvDown ? .mediumHRV : .mediumOther
        case .high:
            if rhrUp && hrvDown { return .highBoth }
            if hrvDown { return .highHRV }
            return rhrUp ? .highRHR : .highOther
        }
    }

    /// One marker tile's comparison with the 30-day average: how much, which way, and whether it is worth a
    /// colour.
    struct Marker: Equatable {
        enum Direction: Equatable { case higher, lower, same }
        enum Tone: Equatable { case calm, strained, neutral }
        /// Whole units, as printed.
        let amount: Int
        let direction: Direction
        let tone: Tone
    }

    /// Colour only a change of at least one of the wearer's own standard deviations: a 1 ms dip in HRV is an
    /// ordinary night, and painting it amber would make the colour mean nothing (Design v6, rule 6).
    static let colouredSpreads = 1.0

    /// Nil when there is nothing to compare (no reading, or no 30 days to compare it with: `StressModel` leaves
    /// the delta nil then, and the tile says nothing rather than claim a comparison).
    static func marker(delta: Double?, spread: Double, higherIsStress: Bool) -> Marker? {
        guard let delta else { return nil }
        let amount = Int(abs(delta).rounded())
        guard amount > 0 else { return Marker(amount: 0, direction: .same, tone: .neutral) }
        let direction: Marker.Direction = delta > 0 ? .higher : .lower
        guard spread > 0.0001, abs(delta) / spread >= colouredSpreads else {
            return Marker(amount: amount, direction: direction, tone: .neutral)
        }
        let towardStress = (direction == .higher) == higherIsStress
        return Marker(amount: amount, direction: direction, tone: towardStress ? .strained : .calm)
    }

    /// The trend ranges Simple mode offers: the six Trends uses (Design v6, one range picker everywhere).
    static let ranges: [ExploreRange] = [.week, .month, .quarter, .half, .year, .all]

    /// The range Simple mode shows: the chosen one if it is among its six, else a month (a range picked in the
    /// full view, such as two weeks, is not offered here).
    static func shownRange(_ chosen: ExploreRange) -> ExploreRange {
        ranges.contains(chosen) ? chosen : .month
    }
}
