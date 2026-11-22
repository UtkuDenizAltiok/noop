import SwiftUI
import StrandDesign
import StrandAnalytics

/// The words of Simple mode's Health monitor (Design v6, step 4). Rules live in `SimpleHealthRules`; this
/// turns their answers into sentences, one whole localized sentence per case so every language can order it.
enum SimpleHealthWords {

    /// A reading's name in the middle of a sentence ("resting heart rate").
    static func midSentenceName(_ key: String) -> String {
        switch key {
        case "rhr":  return String(localized: "resting heart rate")
        case "hrv":  return String(localized: "heart-rate variability (HRV)")
        case "resp": return String(localized: "breathing rate")
        case "spo2": return String(localized: "blood oxygen")
        default:     return String(localized: "skin temperature")
        }
    }

    /// A row's title.
    static func title(_ key: String) -> String {
        switch key {
        case "rhr":  return String(localized: "Resting heart rate")
        case "hrv":  return String(localized: "Heart-rate variability (HRV)")
        case "resp": return String(localized: "Breathing rate")
        case "spo2": return String(localized: "Blood oxygen")
        default:     return String(localized: "Skin temperature")
        }
    }

    /// The guide entry a row opens.
    static func guideTerm(_ key: String) -> PlainGuideTerm {
        switch key {
        case "rhr":  return .restingHeartRate
        case "hrv":  return .hrv
        case "resp": return .breathingRate
        case "spo2": return .bloodOxygen
        default:     return .skinTemperature
        }
    }

    /// The value with a plain unit ("14.2 breaths/min", "97%", "+0.1 °C"), nil without a value.
    static func valueText(_ row: SimpleHealthRules.Row, fahrenheit: Bool) -> String? {
        guard let value = row.printedValue else { return nil }
        switch row.key {
        case "rhr":  return "\(value) bpm"
        case "hrv":  return "\(value) ms"
        case "resp": return "\(value) \(String(localized: "breaths/min"))"
        case "spo2": return "\(value)%"
        default:     return "\(value) \(fahrenheit ? "°F" : "°C")"
        }
    }

    /// The row's sentence: how the value stands against its range. Nil without a value or a range.
    static func rangeSentence(_ row: SimpleHealthRules.Row) -> String? {
        guard let word = row.word, let low = row.printedLow, let high = row.printedHigh else { return nil }
        var range = SimpleHealthRules.rangeText(low: low, high: high, basis: row.basis)
        if row.key == "spo2" { range += "%" }
        switch (row.basis, word) {
        case (.personal, .within): return String(localized: "In your normal range, \(range).")
        case (.personal, .higher): return String(localized: "Above your normal range, \(range).")
        case (.personal, .lower):  return String(localized: "Below your normal range, \(range).")
        case (.typical, .within):  return String(localized: "In the typical adult range, \(range).")
        case (.typical, .higher):  return String(localized: "Above the typical adult range, \(range).")
        case (.typical, .lower):   return String(localized: "Below the typical adult range, \(range).")
        }
    }

    /// What a row says with no value.
    static func missingLine(_ reading: BodyVitalReading) -> String {
        switch reading.key {
        case "hrv" where reading.blankedByOverCount:
            return String(localized: "Not shown: the strap counted extra beats that night, so HRV couldn't be measured fairly.")
        case "spo2":
            return String(localized: "Not measured. NOOP can't work out blood oxygen from the strap itself; it shows here if you import it from WHOOP or Apple Health.")
        case "skin":
            return String(localized: "No reading yet. It needs about 4 nights of wear, or an import from WHOOP.")
        default:
            return String(localized: "No reading yet. It comes from a night's sleep with the strap on.")
        }
    }

    // MARK: Verdict

    static func headline(_ verdict: SimpleHealthRules.Verdict) -> String {
        switch verdict {
        case .noReadings:
            return String(localized: "No overnight readings yet")
        case .allClear:
            return String(localized: "All clear")
        case .outside(let keys, _, _):
            return keys.count == 1
                ? String(localized: "1 reading is outside its normal range")
                : String(localized: "\(keys.count) readings are outside their normal range")
        }
    }

    /// The lines under the headline, in order.
    static func lines(_ verdict: SimpleHealthRules.Verdict) -> [String] {
        switch verdict {
        case .noReadings:
            return [String(localized: "Wear your strap to bed. In the morning NOOP shows your resting heart rate, heart-rate variability (HRV), breathing rate and skin temperature here, and says whether they look normal for you.")]
        case .allClear(let learning):
            guard let learning else {
                return [String(localized: "Every reading below is in your normal range.")]
            }
            return [String(localized: "Every reading below is inside the typical range for adults."),
                    learningLine(learning, anyOutside: false)]
        case .outside(let keys, let learning, let cautious):
            var lines = [namesLine(keys)]
            if let learning { lines.append(learningLine(learning, anyOutside: true)) }
            if cautious {
                lines.append(String(localized: "One reading off for a night is common. Several off together, or off for a few nights in a row, can be an early sign of illness or strain. Notice how you feel; Your day on Today says how hard to go. NOOP is not a medical device."))
            }
            return lines
        }
    }

    /// "Resting heart rate and breathing rate": the readings outside, as a list in the app's language,
    /// starting with a capital.
    static func namesLine(_ keys: [String]) -> String {
        let formatter = ListFormatter()
        formatter.locale = AppLanguage.activeLocale
        let names = keys.map(midSentenceName)
        let list = formatter.string(from: names) ?? names.joined(separator: ", ")
        guard let first = list.first else { return list }
        return String(first).uppercased(with: AppLanguage.activeLocale) + list.dropFirst()
    }

    static func learningLine(_ learning: SimpleHealthRules.Learning, anyOutside: Bool) -> String {
        switch learning {
        case .nights(let have, let need):
            return anyOutside
                ? String(localized: "NOOP is still learning your own normal: \(have) of \(need) nights so far. Until then it uses typical ranges for adults, which don't fit everyone, so a reading outside one is often just how you are.")
                : String(localized: "NOOP is still learning your own normal: \(have) of \(need) nights so far. After that it compares each reading with you.")
        case .stale:
            return String(localized: "You haven't worn the strap at night for a while, so NOOP is using typical adult ranges until your next night of wear.")
        }
    }
}

/// The Health monitor's first card in Simple mode: whether anything looks off. When the illness watch has
/// something to say (any level above quiet), its own card is the answer, moved up from the skin-temperature
/// section: one decision, so the opening line and the warning can never disagree, and the same words as
/// Today's warning. Otherwise the readings' own verdict.
///
/// It observes `AppModel` for the illness result, so it is a leaf of its own: the ~1 Hz heart-rate stream
/// re-renders these few lines, never the readings or the rest of the screen (as `HealthAlertBanner`).
struct SimpleHealthVerdict: View {
    @EnvironmentObject var model: AppModel
    let rows: [SimpleHealthRules.Row]

    var body: some View {
        if let illness = model.illnessSignal, illness.level != .quiet {
            HeadsUpCard(result: illness, distance: model.illnessDistance)
        } else {
            SimpleHealthVerdictCard(verdict: SimpleHealthRules.verdict(rows))
        }
    }
}

/// The readings' verdict as a card: an icon, the headline, and its lines.
struct SimpleHealthVerdictCard: View {
    let verdict: SimpleHealthRules.Verdict

    /// Amber only when something is worth watching (Design v6, rule 6): a reading outside the wearer's own
    /// normal, or blood oxygen outside the healthy range. Green for all clear against the wearer's own normal.
    private var tint: Color {
        switch verdict {
        case .allClear(nil): return StrandPalette.statusPositive
        case .outside(_, _, true): return StrandPalette.statusWarning
        default: return StrandPalette.accent
        }
    }

    private var icon: String {
        switch verdict {
        case .noReadings: return "moon.zzz.fill"
        case .allClear: return "checkmark.circle.fill"
        case .outside(_, _, true): return "exclamationmark.circle.fill"
        case .outside: return "info.circle.fill"
        }
    }

    var body: some View {
        let lines = SimpleHealthWords.lines(verdict)
        NoopCard(padding: 14, tint: tint) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 30, height: 30)
                    .background(tint.opacity(0.16), in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 6) {
                    Text(SimpleHealthWords.headline(verdict))
                        .font(StrandFont.headline)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(StrandFont.subhead)
                            .foregroundStyle(StrandPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The readings as rows, each with its value, how it stands against its range, and its guide entry one tap
/// away (Design v6, rule 2).
struct SimpleVitalRowsCard: View {
    let readings: [BodyVitalReading]
    let rows: [SimpleHealthRules.Row]
    let fahrenheit: Bool
    @State private var openTerm: PlainGuideTerm?

    var body: some View {
        VStack(alignment: .leading, spacing: NoopMetrics.gap) {
            SectionHeader("Your readings", overline: "Overnight")
            NoopCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        if index > 0 {
                            Rectangle().fill(StrandPalette.hairline).frame(height: NoopMetrics.hairlineWidth)
                                .padding(.leading, 52)
                        }
                        if let reading = readings.first(where: { $0.key == row.key }) {
                            Button { openTerm = SimpleHealthWords.guideTerm(row.key) } label: {
                                SimpleVitalRowView(row: row, reading: reading, fahrenheit: fahrenheit)
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint(Text("Opens what this reading means"))
                        }
                    }
                }
            }
            Text("Your normal range is where most of your own nights fall, weighted toward recent weeks. Tap a reading to see what it means and what moves it.")
                .font(StrandFont.footnote)
                .foregroundStyle(StrandPalette.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .sheet(item: $openTerm) { term in
            // Presented with `onClose`, the guide brings its own navigation bar and Done button.
            PlainGuideView(initialTerm: term, onClose: { openTerm = nil })
        }
    }
}

/// One reading row: icon, name and value, then the sentence, then a carried day or a caveat when there is one.
private struct SimpleVitalRowView: View {
    let row: SimpleHealthRules.Row
    let reading: BodyVitalReading
    let fahrenheit: Bool

    /// Amber for a value outside the wearer's own normal or outside blood oxygen's healthy range; a value
    /// outside an adult range in the first nights stays quiet, as the verdict says it is often just the wearer.
    private var sentenceColor: Color {
        guard row.isOutside, row.basis == .personal || !row.canBePersonal else { return StrandPalette.textSecondary }
        return StrandPalette.statusWarning
    }

    var body: some View {
        let term = SimpleHealthWords.guideTerm(row.key)
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: term.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(term.tint)
                .frame(width: 24)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(SimpleHealthWords.title(row.key))
                        .font(StrandFont.body)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    // The value in the normal text colour: the reading's own colour stays on its icon. One line,
                    // taken before the name ("14.2 breaths/min" never breaks at the slash); at the largest text
                    // sizes it shrinks rather than being cut off (rule 10).
                    Text(verbatim: SimpleHealthWords.valueText(row, fahrenheit: fahrenheit) ?? "—")
                        .font(StrandFont.number(17))
                        .foregroundStyle(row.printedValue == nil ? StrandPalette.textTertiary : StrandPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .layoutPriority(1)
                }
                if row.printedValue == nil {
                    Text(SimpleHealthWords.missingLine(reading))
                        .font(StrandFont.subhead)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                } else if let sentence = SimpleHealthWords.rangeSentence(row) {
                    Text(sentence)
                        .font(StrandFont.subhead)
                        .foregroundStyle(sentenceColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                // A skin temperature shown as its change ("+0.1 °C") says what the number is, so it is not read
                // as a temperature of 0.1 degrees (W38).
                if row.key == "skin", let value = reading.value, !VitalBands.isAbsoluteSkinTemp(value) {
                    Text("The change from your average skin temperature.")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if row.printedValue != nil, reading.isUnverifiedEstimate {
                    Text("A strap estimate, not checked against a medical device.")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if row.printedValue != nil, reading.caveat != nil {
                    Text("This night's HRV may be off: the strap counted extra beats.")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let day = row.carriedDayKey {
                    Text("From \(TodayView.lastChargeDateFmt(day))")
                        .font(StrandFont.caption)
                        .foregroundStyle(StrandPalette.textTertiary)
                }
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(StrandPalette.textTertiary)
                .padding(.top, 5)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// One of Simple mode's Stress markers: the reading, its value in the normal text colour, and its comparison on
/// a line of its own, so nothing is cut short (W35). Green or amber only for a clear change, by
/// `SimpleStressRules.marker`; the reading's own colour never paints its value (Design v6, rule 6).
struct SimpleStressMarkerTile: View {
    let label: LocalizedStringKey
    let value: String
    let comparison: String?
    let tone: SimpleStressRules.Marker.Tone

    private var toneColor: Color {
        switch tone {
        case .calm: return StrandPalette.statusPositive
        case .strained: return StrandPalette.statusWarning
        case .neutral: return StrandPalette.textSecondary
        }
    }

    var body: some View {
        NoopCard(padding: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label).strandOverline()
                Text(verbatim: value)
                    .font(StrandFont.number(24))
                    .foregroundStyle(StrandPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let comparison {
                    Text(comparison)
                        .font(StrandFont.footnote)
                        .foregroundStyle(toneColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The heading over Fitness age and Vitality in Simple mode: two estimates of different things, so it says
/// at once that neither is a biological age (W37).
struct SimpleLongTermHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: NoopMetrics.space2) {
            SectionHeader("Long-term estimates", overline: "Weekly")
            Text("Two different estimates. Neither is your biological age.")
                .font(StrandFont.subhead)
                .foregroundStyle(StrandPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
