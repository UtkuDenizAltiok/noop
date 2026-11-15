import Foundation
import StrandAnalytics

// MARK: - Simple mode: "Your day"
//
// The Simple Today answers "what should I do today?" in one card: the readiness verdict in a sentence,
// then a suggested Effort range with how far the day has got. Everything here is presentation: the range
// is upstream's approved Charge → Effort mapping (`CoupledView.optimalStrainRange`, byte-identical with
// Android's `optimalStrainRange`, task #43), already used by the Coupled view and the once-a-day "optimal
// strain reached" nudge. Nothing is computed, stored or fed back into a score.
//
// One rule decides when the range is shown, because two readouts of one fact must not disagree
// (AGENTS.md). The verdict (the card's headline, "A good day to push" … "Rest and recover today") comes from
// `ReadinessEngine`, which also weighs training load and breathing; the range comes from Charge alone. On a
// day where they point different ways (a high Charge while training load jumped, say), printing "Take it
// easier today" above "a hard day" would tell the wearer two things at once, so the range is left out and
// the verdict stands alone.

/// Pure rules for the Simple-mode "Your day" card.
enum SimpleDayPlan {

    /// How hard a day a suggested range describes.
    enum Intensity: Equatable {
        case easy, moderate, hard
    }

    /// Where today's Effort sits against the suggested range.
    enum Progress: Equatable {
        /// No Effort measured yet today (the ring shows a dash).
        case notStarted
        case below
        case within
        case above
    }

    /// The suggested Effort band on the 0–21 axis, or nil when Simple mode should not suggest one.
    ///
    /// - Parameters:
    ///   - todaysCharge: today's OWN Charge. Pass nil for a carried earlier score, a calibrating baseline
    ///     or any day other than today: a range is advice for today, and an older night's Charge cannot
    ///     give it.
    ///   - readiness: today's readiness verdict. The range is shown only beside a verdict it agrees with
    ///     (see the file note); with no verdict yet (`.insufficient`) Charge is the only source, so there
    ///     is nothing for it to contradict.
    static func suggestedBand(todaysCharge: Double?, readiness: ReadinessEngine.Level) -> ClosedRange<Int>? {
        guard let band = CoupledView.optimalStrainRange(recovery: todaysCharge) else { return nil }
        let shown: Bool
        switch (readiness, intensity(of: band)) {
        // "A hard session should land well today": only the hard range says the same.
        case (.primed, .hard): shown = true
        // "A good spot for training": a moderate or a hard day, not an easy one.
        case (.balanced, .moderate), (.balanced, .hard): shown = true
        // "Keep it easy" / "Prioritise rest": only the easy range says the same.
        case (.strained, .easy), (.rundown, .easy): shown = true
        case (.insufficient, _): shown = true
        default: shown = false
        }
        return shown ? band : nil
    }

    /// The intensity a band describes, read from where it starts on the 0–21 axis. A test walks every
    /// Charge from 0 to 100 so a change to the approved mapping cannot leave these words behind.
    static func intensity(of band: ClosedRange<Int>) -> Intensity {
        switch band.lowerBound {
        case 14...: return .hard
        case 10..<14: return .moderate
        default: return .easy
        }
    }

    /// The band on the reader's Effort scale, in whole numbers: 0–21 as it is, 0–100 through the one
    /// 0–21 → 0–100 conversion (`StrainScorer.effortValue(fromWhoopStrain:)`), so 14–18 reads 67–86.
    static func band(_ band21: ClosedRange<Int>, on scale: EffortScale) -> ClosedRange<Int> {
        guard scale == .hundred else { return band21 }
        let low = Int(StrainScorer.effortValue(fromWhoopStrain: Double(band21.lowerBound)).rounded())
        let high = Int(StrainScorer.effortValue(fromWhoopStrain: Double(band21.upperBound)).rounded())
        return low...high
    }

    /// The range as figures only ("67–86"): numbers and an en dash, the same in every language.
    static func rangeText(_ band: ClosedRange<Int>) -> String {
        [band.lowerBound, band.upperBound].map(String.init).joined(separator: "–")
    }

    /// Today's Effort as the Effort ring prints it: whole numbers on 0–100, one decimal on 0–21. The same
    /// two expressions as the ring's `CountUpNumber`, so "So far 23" always matches the ring's 23.
    static func effortText(stored: Double, scale: EffortScale) -> String {
        let value = UnitFormatter.effortValue(stored, scale: scale)
        return scale == .whoop ? String(format: "%.1f", value) : "\(Int(value.rounded()))"
    }

    /// Where today's Effort sits against the range, judged on the number as printed (`effortText`), so a
    /// ring reading "14.0" is never called "below" a range that starts at 14.
    static func progress(stored: Double?, scale: EffortScale, band: ClosedRange<Int>) -> Progress {
        guard let stored, let printed = Double(effortText(stored: stored, scale: scale)) else { return .notStarted }
        if printed < Double(band.lowerBound) { return .below }
        if printed > Double(band.upperBound) { return .above }
        return .within
    }

    /// Last night's sleep against the need, for the Simple Today's sleep line: the day row's total (the
    /// figure the Rest score and the Coupled view's slept-vs-needed read use) and the night's imported
    /// need when WHOOP provided one, else the normative need the Sleep tab's debt ledger measures against
    /// (`SleepModel.debtNeedMin`). Nil when the row has no sleep, so the line never claims a night that
    /// was not recorded.
    static func sleepVersusNeed(asleepMin: Double?, importedNeedMin: Double?,
                                normativeNeedMin: Double) -> (asleep: Double, need: Double)? {
        guard let asleepMin, asleepMin > 0 else { return nil }
        if let importedNeedMin, importedNeedMin > 0 { return (asleepMin, importedNeedMin) }
        return (asleepMin, normativeNeedMin)
    }

    /// The day a Rest ring's score comes from when it is an earlier night's, or nil when it is the selected
    /// day's own (or there is none). The Rest ring carries a still-fresh earlier night through
    /// `TodayView.freshRestScore`'s tail fallback; Simple mode names that day under the ring, as it does for a
    /// carried Charge, so an old night is never read as last night's.
    static func carriedRestDay(selectedDayValue: Double?, shownScore: Double?, tailDay: String?) -> String? {
        guard selectedDayValue == nil, shownScore != nil else { return nil }
        return tailDay
    }

    /// The wind-down reminder's UserDefaults keys, which the Simple Today observes so a change on the Alarms
    /// screen re-renders it. They are `WindDownNudge`'s own (private) keys, repeated here because that enum
    /// keeps them private; `WindDownMirrorKeyTests` writes through each one and reads it back through
    /// `WindDownNudge`, so a renamed key fails a test instead of silently going stale.
    enum ReminderKeys {
        static let enabled = "windDown.enabled"
        static let wake = "windDown.wakeMinutes"
        static let need = "windDown.sleepNeedMinutes"
        static let perDayWake = "windDown.perDayWakeMinutes"
    }

    /// Tonight's sleep plan, from the wind-down reminder's own inputs.
    struct TonightPlan: Equatable {
        /// When the wind-down reminder fires: the reminder's own wall-clock time.
        let windDown: Date
        /// The latest time to fall asleep and still get the whole sleep need before the wake time.
        let asleepBy: Date
        /// The wake time the reminder is timed from.
        let wake: Date
        /// The sleep need the reminder uses (the Sleep tab's need once the history has synced).
        let needMinutes: Int
    }

    /// Tonight's plan, or nil when Simple mode should say nothing about tonight.
    ///
    /// Built from exactly the inputs the wind-down reminder schedules from (`WindDownNudge`: the wake time
    /// for the weekday being woken on, the sleep need and the lead), with the reminder's own wall-clock
    /// arithmetic: minute-of-day offsets from the wake, wrapped onto the previous evening when they cross
    /// midnight, so the "wind down at" time is the minute the reminder fires. Nil while the reminder is off,
    /// because its wake time is then only an unused setting rather than a time anyone wakes at (#2353), and
    /// nil once the fall-asleep time for the next wake has passed (late evening, or after midnight), so the
    /// line never shows a plan that can no longer be followed.
    static func tonightPlan(now: Date, calendar: Calendar, reminderOn: Bool, needMinutes: Int, leadMinutes: Int,
                            wakeMinutesForWeekday: (Int) -> Int) -> TonightPlan? {
        guard reminderOn else { return nil }
        let today = calendar.startOfDay(for: now)
        for offset in 0...1 {
            guard let wakeDay = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let wakeMinute = wakeMinutesForWeekday(calendar.component(.weekday, from: wakeDay))
            guard let wake = wallClock(wakeMinute, from: wakeDay, calendar: calendar), wake > now else { continue }
            guard let asleepBy = wallClock(wakeMinute - needMinutes, from: wakeDay, calendar: calendar),
                  let windDown = wallClock(wakeMinute - needMinutes - leadMinutes, from: wakeDay, calendar: calendar),
                  asleepBy > now else { return nil }
            return TonightPlan(windDown: windDown, asleepBy: asleepBy, wake: wake, needMinutes: needMinutes)
        }
        return nil
    }

    /// Whether tonight's line may state its sleep need as a duration. Not when the card's last-night line
    /// already states a DIFFERENT need: that happens when WHOOP's own need for last night was imported (the
    /// Sleep tab shows WHOOP's figure for that night) while tonight's plan uses NOOP's, and two needs on one
    /// card would contradict each other. Compared in whole minutes, as both lines print them.
    static func tonightStatesNeed(lastNightNeedMin: Double?, tonightNeedMin: Int) -> Bool {
        guard let lastNightNeedMin else { return true }
        return max(0, Int(lastNightNeedMin.rounded())) == tonightNeedMin
    }

    /// The wall-clock instant `minutes` after the start of `day`, where a negative or over-a-day value moves to
    /// the neighbouring day first (floor division) and keeps its minute of day, the way the reminder's
    /// calendar trigger does (`WindDownNudge.nudgeDayShift` + `nudgeMinuteOfDay`).
    private static func wallClock(_ minutes: Int, from day: Date, calendar: Calendar) -> Date? {
        let dayLength = 24 * 60
        let shift = Int((Double(minutes) / Double(dayLength)).rounded(.down))
        let minuteOfDay = minutes - shift * dayLength
        guard let shiftedDay = calendar.date(byAdding: .day, value: shift, to: day) else { return nil }
        return calendar.date(bySettingHour: minuteOfDay / 60, minute: minuteOfDay % 60, second: 0, of: shiftedDay)
    }

    /// How many Charge readings the Simple Today lists before "Show all".
    static let leadingDriverCount = 3

    /// The Charge readings with the ones that moved the score most first (largest points, either way).
    /// Ties keep the breakdown's own order, so the list does not shuffle between loads.
    static func driversByImpact(_ drivers: [ChargeDriver]) -> [ChargeDriver] {
        drivers.enumerated().sorted { a, b in
            let (ma, mb) = (abs(a.element.deltaPoints), abs(b.element.deltaPoints))
            return ma != mb ? ma > mb : a.offset < b.offset
        }.map(\.element)
    }

    /// "6h 42m" (or "45m") for the sleep line, with the Sleep tab's own catalogue keys and rounding, so the
    /// Today line and the Sleep tab's line print a night identically.
    static func durationText(_ minutes: Double) -> String {
        let m = max(0, Int(minutes.rounded()))
        if m < 60 { return String(localized: "\(m)m") }
        return String(localized: "\(m / 60)h \(m % 60)m")
    }

    // MARK: - Score words (v6: a number is never alone)

    /// How good a Charge is, in one word.
    enum ChargeLevel: Equatable {
        case low, medium, high
    }

    /// The word for a Charge, read from the one Charge → Effort mapping (`CoupledView.optimalStrainRange`):
    /// the Charge that earns a hard day is High, a moderate day Medium, an easy day Low. So the word under the
    /// ring and the suggested range under it can never describe the same Charge two ways.
    static func chargeLevel(_ charge: Double) -> ChargeLevel {
        guard let band = CoupledView.optimalStrainRange(recovery: charge) else { return .low }
        switch intensity(of: band) {
        case .hard: return .high
        case .moderate: return .medium
        case .easy: return .low
        }
    }

    /// How hard a day's Effort has been, in one word.
    enum EffortLevel: Equatable {
        case easy, moderate, hard, veryHard
    }

    /// The word for a day's Effort (stored 0–100): Easy up to the top of the easy day's suggested range, Moderate
    /// up to the top of the moderate day's, Hard up to the top of the hard day's, beyond it Very hard. Judged
    /// the way `progress` judges "in the range": on the number as the ring prints it, against the ranges on
    /// the reader's scale, a range's top still belonging to it. So an Effort the card calls "in the range" of
    /// a moderate day is never called Hard under the ring. The three tops are read from the mapping itself.
    static func effortLevel(stored: Double, scale: EffortScale) -> EffortLevel {
        guard let printed = Double(effortText(stored: stored, scale: scale)) else { return .easy }
        let tops = [0.0, 50.0, 100.0].compactMap { CoupledView.optimalStrainRange(recovery: $0) }
            .map { band($0, on: scale).upperBound }
        guard tops.count == 3 else { return .easy }
        if printed <= Double(tops[0]) { return .easy }
        if printed <= Double(tops[1]) { return .moderate }
        if printed <= Double(tops[2]) { return .hard }
        return .veryHard
    }

    /// The nights NOOP has learned from so far, while today's own Charge is still an early estimate; nil once
    /// the baseline is trusted (`Baselines.minNightsTrust`) and for any score that is not today's own (a
    /// carried or calibrating ring says so in its own words).
    static func earlyEstimateNights(validNights: Int?, chargeIsTodaysOwn: Bool,
                                    trust: Int = Baselines.minNightsTrust) -> Int? {
        guard chargeIsTodaysOwn, let validNights, validNights < trust else { return nil }
        return max(0, validNights)
    }

    // MARK: - Tonight's goal (v6: the evening question is always answered)

    /// The most catch-up sleep one night is asked to carry. A coach's cap: built-up sleep debt is repaid over
    /// several nights, not in one (Kitamura 2016: one hour of debt took four nights of extended sleep).
    static let catchUpCapMinutes = 60

    /// Extra sleep to aim for tonight, from the sleep debt the Sleep tab's ledger shows: the debt itself up to
    /// the cap, rounded to five minutes. Nothing for no debt, or for one too small to round to five minutes.
    static func catchUpMinutes(debtMinutes: Double) -> Int {
        guard debtMinutes.isFinite, debtMinutes > 0 else { return 0 }
        let capped = min(debtMinutes, Double(catchUpCapMinutes))
        return Int((capped / 5).rounded()) * 5
    }

    /// How many recent wake times make a usual wake time, and how many are read.
    static let usualWakeMinNights = 5
    static let usualWakeWindowNights = 14

    /// The wearer's usual wake time as a minute of the day: the median wake minute of the most recent main
    /// sleeps (`usualWakeWindowNights` at most), or nil with fewer than `usualWakeMinNights` of them. The
    /// median, so one late Sunday does not move it.
    static func usualWakeMinute(wakeTimes: [Date], calendar: Calendar) -> Int? {
        let recent = wakeTimes.sorted().suffix(usualWakeWindowNights)
        guard recent.count >= usualWakeMinNights else { return nil }
        let minutes = recent.map { date -> Int in
            let parts = calendar.dateComponents([.hour, .minute], from: date)
            return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        }.sorted()
        let mid = minutes.count / 2
        return minutes.count % 2 == 1 ? minutes[mid] : (minutes[mid - 1] + minutes[mid]) / 2
    }

    /// Tonight's sleep goal while the wind-down reminder is off.
    struct TonightGoal: Equatable {
        /// The sleep need plus tonight's catch-up.
        let goalMinutes: Int
        /// The catch-up part of the goal (0 when the wearer is not behind).
        let catchUpMinutes: Int
        /// The latest time to fall asleep and still get the goal before the usual wake; nil when no usual
        /// wake time is known yet.
        let asleepBy: Date?
        /// The usual wake time the plan is timed from; nil when none is known yet.
        let wake: Date?
    }

    /// Tonight's goal from the Sleep tab's need, the catch-up and the wearer's usual wake time. With a usual
    /// wake time it carries the fall-asleep time for the next such wake, and is nil once that time has passed
    /// (a plan that can no longer be followed is not shown, the rule `tonightPlan` follows too). Without one
    /// it is the goal alone.
    static func tonightGoal(now: Date, calendar: Calendar, needMinutes: Int, catchUpMinutes: Int,
                            usualWakeMinute: Int?) -> TonightGoal? {
        let catchUp = max(0, catchUpMinutes)
        let goal = max(0, needMinutes) + catchUp
        guard goal > 0 else { return nil }
        guard let usualWakeMinute else {
            return TonightGoal(goalMinutes: goal, catchUpMinutes: catchUp, asleepBy: nil, wake: nil)
        }
        let today = calendar.startOfDay(for: now)
        for offset in 0...1 {
            guard let wakeDay = calendar.date(byAdding: .day, value: offset, to: today),
                  let wake = wallClock(usualWakeMinute, from: wakeDay, calendar: calendar), wake > now else { continue }
            guard let asleepBy = wallClock(usualWakeMinute - goal, from: wakeDay, calendar: calendar),
                  asleepBy > now else { return nil }
            return TonightGoal(goalMinutes: goal, catchUpMinutes: catchUp, asleepBy: asleepBy, wake: wake)
        }
        return nil
    }

    // MARK: - Activity against the wearer's own usual (v6: no hidden goals)

    /// How many earlier days make a "usual" day.
    static let usualDayMinDays = 7

    /// The wearer's usual daily value of a day-keyed series (steps, active calories): the median of the days
    /// before `dayKey` that recorded anything, or nil with fewer than `usualDayMinDays` of them. The selected
    /// day itself is left out because it is still being lived.
    static func usualDailyValue(series: [(day: String, value: Double)], before dayKey: String) -> Double? {
        let values = series.filter { $0.day < dayKey && $0.value.isFinite && $0.value > 0 }.map(\.value).sorted()
        guard values.count >= usualDayMinDays else { return nil }
        let mid = values.count / 2
        return values.count % 2 == 1 ? values[mid] : (values[mid - 1] + values[mid]) / 2
    }

    /// How full an activity bar is against the usual day: full at the usual value and beyond.
    static func usualFraction(value: Double?, usual: Double?) -> Double? {
        guard let value, let usual, usual > 0 else { return nil }
        return max(0, min(1, value / usual))
    }
}
