import SwiftUI
import StrandDesign
import StrandAnalytics
import WhoopStore
import ZIPFoundation

// The developer loop (handbook `features/lab.md`): the morning check-in that gives the developer the wearer's own
// account to check the scores against, and the developer export that carries everything to the developer's Mac.
// Both are for whoever develops NOOP; the wearer only answers and carries the file. They live in the Test Centre.

// MARK: - The morning check-in sheet

/// Three questions on 1-to-5 scales (`CheckIn`), asked full screen before the wearer sees the morning's scores so
/// the answers are not anchored to them, then whether NOOP's times for last night were right, with the right times
/// one step away when they were not: a sleep diary beside the strap, the way sleep clinics pair actigraphy with a
/// diary (Smith et al., AASM clinical practice guideline on actigraphy, J Clin Sleep Med 2018).
struct CheckInSheet: View {
    @EnvironmentObject var repo: Repository
    @EnvironmentObject var intelligence: IntelligenceEngine
    /// The logical day the answers belong to (the journal's own convention: the night and day into this morning).
    let day: String
    /// Last night as NOOP saw it (`CheckIn.lastNight`), when it saw one.
    let night: (blocks: [CachedSleepSession], times: SleepClockTimes.Times)?
    let onClose: (Outcome) -> Void

    /// How the sheet was left: answered, "Not now" (ask again later) or "Skip today".
    enum Outcome { case saved, snoozed, skipped }

    @State private var answers: [CheckIn.Item: Int] = [:]
    @State private var sleepTimesRight: Bool?
    @State private var fellAsleepAt = Date()
    @State private var wokeAt = Date()
    @State private var saving = false

    private var complete: Bool { answers.count == CheckIn.Item.allCases.count }

    /// The corrected times, when the wearer said NOOP's were wrong: each picked clock time placed on the day
    /// nearest to NOOP's own time (`CheckIn.resolveClock`). Nil until "Wrong" is chosen.
    private var corrected: (fellAsleep: Int, woke: Int)? {
        guard sleepTimesRight == false, let times = night?.times else { return nil }
        return (CheckIn.resolveClock(fellAsleepAt, near: times.fellAsleep), CheckIn.resolveClock(wokeAt, near: times.woke))
    }

    /// A correction must leave a night of at least half an hour, woken after falling asleep.
    private var correctionIsValid: Bool {
        guard let corrected else { return true }
        return corrected.woke - corrected.fellAsleep >= 30 * 60
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NoopMetrics.sectionSpacing) {
                    Text("Before you look at your scores: how do you feel this morning?")
                        .font(StrandFont.headline)
                        .foregroundStyle(StrandPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(CheckIn.Item.allCases) { item in
                        question(item)
                    }
                    if let times = night?.times {
                        sleepTimes(times)
                    }
                    Text("Your answers stay on this phone, in your journal. They travel only inside a developer file you choose to share.")
                        .font(StrandFont.footnote)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    NoopButton("Save", systemImage: "checkmark", kind: .primary, fullWidth: true) { save() }
                        .disabled(!complete || saving || !correctionIsValid)
                        .opacity(complete && correctionIsValid ? 1 : NoopButtonMetrics.disabledOpacity)
                    Button { onClose(.skipped) } label: {
                        Text("Skip today")
                            .font(StrandFont.subhead)
                            .foregroundStyle(StrandPalette.textSecondary)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(NoopMetrics.cardPadding)
            }
            .background(StrandPalette.surfaceBase)
            .navigationTitle("Morning check-in")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    // Not now: asked again in an hour (`CheckIn.snoozeMinutes`), not lost for the day.
                    Button("Not now") { onClose(.snoozed) }
                }
            }
        }
        .onAppear {
            if let times = night?.times {
                fellAsleepAt = Date(timeIntervalSince1970: TimeInterval(times.fellAsleep))
                wokeAt = Date(timeIntervalSince1970: TimeInterval(times.woke))
            }
        }
    }

    private func question(_ item: CheckIn.Item) -> some View {
        VStack(alignment: .leading, spacing: NoopMetrics.space2) {
            Text(Self.title(item))
                .font(StrandFont.subhead.weight(.semibold))
                .foregroundStyle(StrandPalette.textPrimary)
            HStack(spacing: NoopMetrics.space2) {
                ForEach(Array(CheckIn.scale), id: \.self) { value in
                    choice(text: "\(value)", chosen: answers[item] == value) { answers[item] = value }
                }
            }
            HStack {
                Text(Self.lowAnchor(item))
                Spacer()
                Text(Self.highAnchor(item))
            }
            .font(StrandFont.footnote)
            .foregroundStyle(StrandPalette.textTertiary)
        }
        .padding(NoopMetrics.cardPadding)
        .background(NoopPanelSurface(cornerRadius: NoopMetrics.cardRadius))
    }

    private func sleepTimes(_ times: SleepClockTimes.Times) -> some View {
        let asleep = Night.clockString(times.fellAsleep)
        let woke = Night.clockString(times.woke)
        return VStack(alignment: .leading, spacing: NoopMetrics.space2) {
            Text("NOOP saw you fall asleep at \(asleep) and wake at \(woke). Is that about right?")
                .font(StrandFont.subhead.weight(.semibold))
                .foregroundStyle(StrandPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: NoopMetrics.space2) {
                choice(text: String(localized: "Right"), chosen: sleepTimesRight == true) { sleepTimesRight = true }
                choice(text: String(localized: "Wrong"), chosen: sleepTimesRight == false) { sleepTimesRight = false }
            }
            if sleepTimesRight == false {
                DatePicker("When did you fall asleep?", selection: $fellAsleepAt, displayedComponents: .hourAndMinute)
                    .font(StrandFont.subhead)
                DatePicker("When did you wake up?", selection: $wokeAt, displayedComponents: .hourAndMinute)
                    .font(StrandFont.subhead)
                if correctionIsValid {
                    Text("Saving also corrects last night on the Sleep tab. NOOP keeps its own times beside yours, so the developer can see how far off it was.")
                        .font(StrandFont.footnote)
                        .foregroundStyle(StrandPalette.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Waking should come at least half an hour after falling asleep.")
                        .font(StrandFont.footnote)
                        .foregroundStyle(StrandPalette.statusWarning)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(NoopMetrics.cardPadding)
        .background(NoopPanelSurface(cornerRadius: NoopMetrics.cardRadius))
    }

    private func choice(text: String, chosen: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(StrandFont.headline)
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(chosen ? StrandPalette.surfaceBase : StrandPalette.textPrimary)
                .background(chosen ? StrandPalette.accent : StrandPalette.surfaceInset,
                            in: RoundedRectangle(cornerRadius: NoopVisualStyle.compactRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(chosen ? .isSelected : [])
    }

    static func title(_ item: CheckIn.Item) -> String {
        switch item {
        case .rested:  return String(localized: "How rested do you feel?")
        case .slept:   return String(localized: "How well did you sleep?")
        case .relaxed: return String(localized: "How relaxed do you feel?")
        }
    }

    static func lowAnchor(_ item: CheckIn.Item) -> String {
        switch item {
        case .rested:  return String(localized: "1: very tired")
        case .slept:   return String(localized: "1: very badly")
        case .relaxed: return String(localized: "1: very stressed")
        }
    }

    static func highAnchor(_ item: CheckIn.Item) -> String {
        switch item {
        case .rested:  return String(localized: "5: fully rested")
        case .slept:   return String(localized: "5: very well")
        case .relaxed: return String(localized: "5: very relaxed")
        }
    }

    private func save() {
        guard complete, correctionIsValid else { return }
        saving = true
        let correction = corrected
        Task {
            for item in CheckIn.Item.allCases {
                if let value = answers[item] {
                    await repo.saveJournalNumeric(day: day, question: item.journalQuestion, value: Double(value))
                }
            }
            if night != nil, let right = sleepTimesRight {
                await repo.saveJournalNumeric(day: day, question: CheckIn.sleepTimesQuestion, value: right ? 1 : 0)
            }
            if let correction, let night, await Self.applyCorrection(correction, to: night, repo: repo) {
                // Re-score so the morning's numbers use the corrected night, as the Sleep tab's editor does.
                await intelligence.analyzeRecent()
                await repo.refresh()
            }
            saving = false
            onClose(.saved)
        }
    }

    /// Write the wearer's times through the Sleep tab's own edit path (`Repository.editSleepTimes`): the first
    /// fragment's start becomes "fell asleep" and the last fragment's end becomes "woke" (one call when the night
    /// is one block). The detected times stay beside the correction in the store. Returns whether anything was
    /// written: a time within a minute of NOOP's is left alone.
    @MainActor
    static func applyCorrection(_ corrected: (fellAsleep: Int, woke: Int),
                                to night: (blocks: [CachedSleepSession], times: SleepClockTimes.Times),
                                repo: Repository) async -> Bool {
        let blocks = night.blocks.sorted { $0.effectiveStartTs < $1.effectiveStartTs }
        guard let first = blocks.first, let last = blocks.max(by: { $0.endTs < $1.endTs }) else { return false }
        let moveStart = abs(corrected.fellAsleep - night.times.fellAsleep) >= 60
        let moveEnd = abs(corrected.woke - night.times.woke) >= 60
        guard moveStart || moveEnd else { return false }
        if first.startTs == last.startTs {
            await repo.editSleepTimes(detectedStartTs: first.startTs, oldEndTs: first.endTs,
                                      storedStagesJSON: first.stagesJSON,
                                      newStartTs: moveStart ? corrected.fellAsleep : first.effectiveStartTs,
                                      newEndTs: moveEnd ? corrected.woke : first.endTs)
            return true
        }
        if moveStart, corrected.fellAsleep < first.endTs {
            await repo.editSleepTimes(detectedStartTs: first.startTs, oldEndTs: first.endTs,
                                      storedStagesJSON: first.stagesJSON,
                                      newStartTs: corrected.fellAsleep, newEndTs: first.endTs)
        }
        if moveEnd, corrected.woke > last.effectiveStartTs {
            await repo.editSleepTimes(detectedStartTs: last.startTs, oldEndTs: last.endTs,
                                      storedStagesJSON: last.stagesJSON,
                                      newStartTs: last.effectiveStartTs, newEndTs: corrected.woke)
        }
        return true
    }
}

// MARK: - Offering the check-in

/// The morning a check-in is being asked for, as an `Identifiable` for `.fullScreenCover(item:)`.
struct CheckInMorning: Identifiable {
    let day: String
    let night: (blocks: [CachedSleepSession], times: SleepClockTimes.Times)?
    var id: String { day }
}

/// Offers the morning check-in (`CheckIn.shouldOffer`): switched on, in the morning but not before about an hour
/// and a half ahead of the wearer's usual wake, not yet answered, skipped or snoozed today; full screen, so it
/// comes before the scores. "Not now" asks again in an hour; the Test Centre's button opens it at any time.
/// Attached once, at the app's root.
struct CheckInPresenter: ViewModifier {
    @EnvironmentObject var repo: Repository
    @EnvironmentObject var intelligence: IntelligenceEngine
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(CheckIn.enabledKey) private var enabled = false
    @AppStorage(CheckIn.requestKey) private var requestedAt: Double = 0
    @State private var offered: CheckInMorning?

    func body(content: Content) -> some View {
        content
            .task { await offerIfDue(force: false) }
            .onChangeCompat(of: scenePhase) { phase in
                if phase == .active { Task { await offerIfDue(force: false) } }
            }
            .onChangeCompat(of: requestedAt) { _ in
                Task { await offerIfDue(force: true) }
            }
            #if os(iOS)
            .fullScreenCover(item: $offered) { morning in
                CheckInSheet(day: morning.day, night: morning.night) { finish($0, day: morning.day) }
                    .environmentObject(repo)
                    .environmentObject(intelligence)
            }
            #else
            .sheet(item: $offered) { morning in
                CheckInSheet(day: morning.day, night: morning.night) { finish($0, day: morning.day) }
                    .environmentObject(repo)
                    .environmentObject(intelligence)
                    .frame(minWidth: 460, minHeight: 620)
            }
            #endif
    }

    private func finish(_ outcome: CheckInSheet.Outcome, day: String) {
        switch outcome {
        case .saved: break
        case .snoozed:
            UserDefaults.standard.set(Date().timeIntervalSince1970 + Double(CheckIn.snoozeMinutes * 60),
                                      forKey: CheckIn.snoozedUntilKey)
        case .skipped:
            UserDefaults.standard.set(day, forKey: CheckIn.skippedDayKey)
        }
        offered = nil
    }

    /// `force` is the wearer's own request (the Test Centre's button): it opens the check-in whatever the time,
    /// snooze or skip say.
    @MainActor
    private func offerIfDue(force: Bool) async {
        guard enabled, offered == nil, scenePhase == .active else { return }
        let now = Date()
        let today = Repository.logicalDayKey(now)
        let parts = Calendar.current.dateComponents([.hour, .minute], from: now)
        let minuteOfDay = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        let skipped = UserDefaults.standard.string(forKey: CheckIn.skippedDayKey) == today
        let snoozed = now.timeIntervalSince1970 < UserDefaults.standard.double(forKey: CheckIn.snoozedUntilKey)
        guard force || (CheckIn.offerHours.contains(minuteOfDay / 60) && !skipped && !snoozed) else { return }
        let answered = CheckIn.isComplete(await repo.nativeJournalNumeric(day: today))
        // Read from the store, not `repo.sleeps`: at launch that cache may not be filled yet. A strap-only
        // wearer's nights are the computed ones, so those are read when no imported night is there.
        let nowTs = Int(now.timeIntervalSince1970)
        var sessions = await repo.sleepSessions(from: nowTs - 15 * 86_400, to: nowTs)
        if sessions.isEmpty { sessions = await repo.computedSleepSessions(from: nowTs - 15 * 86_400, to: nowTs) }
        let offset = TimeZone.current.secondsFromGMT(for: now)
        let earliest = CheckIn.earliestOfferMinute(
            usualWakeMinute: CheckIn.usualWakeMinute(CheckIn.wakeMinutes(sessions, offsetSec: offset)))
        guard force || CheckIn.shouldOffer(enabled: enabled, appIsActive: scenePhase == .active,
                                           minuteOfDay: minuteOfDay, earliestMinute: earliest,
                                           skippedToday: skipped, snoozed: snoozed, answeredToday: answered)
        else { return }
        offered = CheckInMorning(day: today, night: CheckIn.lastNight(sessions, now: now, offsetSec: offset))
    }
}

extension View {
    /// Offer the developer's morning check-in at the app's root (`CheckInPresenter`).
    func offersMorningCheckIn() -> some View { modifier(CheckInPresenter()) }
}

// MARK: - The developer snapshot (lab.json)

/// `lab.json`, schema 1: what the backup cannot say by itself. The app and device facts and the settings the
/// algorithms read; the check-ins so far; and what NOOP's Simple screens conclude at export time (the Trends
/// verdicts for every range and chart, the week's comparisons and sentences beside the engine's own, the Workouts
/// summary), so the developer can check those rules against the wearer's real data without running the app.
enum LabSnapshot {

    static let schema = 1

    @MainActor
    static func json(model: AppModel, now: Date = Date()) async -> Data {
        let repo = model.repo
        let profile = model.profile
        let scale = UnitPrefs.resolveEffortScale(UserDefaults.standard.string(forKey: UnitPrefs.effortScaleKey)
                                                 ?? EffortScale.hundred.rawValue)
        var root: [String: Any] = ["schema": schema]
        let iso = ISO8601DateFormatter()
        iso.timeZone = .current
        iso.formatOptions = [.withInternetDateTime]
        root["exportedAt"] = iso.string(from: now)

        let info = Bundle.main.infoDictionary
        root["app"] = ["version": info?["CFBundleShortVersionString"] as? String ?? "?",
                       "build": info?["CFBundleVersion"] as? String ?? "?",
                       "bundle": Bundle.main.bundleIdentifier ?? "?"]
        var system = utsname()
        uname(&system)
        let machineBytes = system.machine
        let machine = withUnsafeBytes(of: machineBytes) { raw in
            String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
        }
        root["device"] = ["model": machine,
                          "system": ProcessInfo.processInfo.operatingSystemVersionString,
                          "timeZone": TimeZone.current.identifier,
                          "utcOffsetMinutes": TimeZone.current.secondsFromGMT(for: now) / 60,
                          "locale": Locale.current.identifier,
                          "simpleMode": UserDefaults.standard.object(forKey: SimpleModePrefs.storageKey) as? Bool
                              ?? SimpleModePrefs.defaultEnabled,
                          "effortScale": scale.rawValue] as [String: Any]
        root["profile"] = ["age": profile.age, "sex": profile.sex, "heightCm": profile.heightCm,
                           "weightKg": profile.weightKg, "hrMaxOverride": profile.hrMaxOverride,
                           "effortHRmax": profile.effortHRmax ?? NSNull()] as [String: Any]
        root["strap"] = ["model": UserDefaults.standard.string(forKey: "selectedWhoopModel") ?? NSNull()] as [String: Any]

        // The iPhone step calibration (`StepCalibration`): the divisor in use, the last result and the paired
        // windows behind it, so the developer can check the ratio against the strap's own records.
        let windows = UserDefaults.standard.data(forKey: StepCalibration.windowsKey)
            .flatMap { try? JSONDecoder().decode([StepCalibration.Pair].self, from: $0) } ?? []
        var calibration: [String: Any] = ["enabled": StepCalibration.isEnabled,
                                          "phoneStepsAllowed": StepCalibration.phoneStepsAllowed,
                                          "ticksPerStepInUse": profile.stepTicksPerStep,
                                          "windows": windows.map { [$0.start, $0.phoneSteps, $0.strapTicks] }]
        if let result = StepCalibration.lastResult {
            calibration["result"] = ["ticksPerStep": result.ticksPerStep, "windows": result.windows,
                                     "phoneSteps": result.phoneSteps, "at": result.at] as [String: Any]
        }
        root["stepCalibration"] = calibration

        // Check-ins so far.
        let series = await repo.numericJournalSeries()
        let sleepAnswers = series[CheckIn.sleepTimesQuestion] ?? [:]
        root["checkIn"] = ["enabled": UserDefaults.standard.bool(forKey: CheckIn.enabledKey),
                           "completedDays": CheckIn.completedDays(series),
                           "questions": CheckIn.journalQuestions + [CheckIn.sleepTimesQuestion],
                           "sleepTimesRight": sleepAnswers.values.filter { $0 >= 1 }.count,
                           "sleepTimesWrong": sleepAnswers.values.filter { $0 < 1 }.count] as [String: Any]

        // The morning Stress number for each day (`StressModel`, the Stress screen's own history). It is worked out
        // on screen, not stored, so the backup alone cannot give the developer the relaxed-against-Stress check or
        // the band shares (finding S12).
        let storedStress = await repo.series(key: "stress", source: "my-whoop")
        if let stress = StressModel(days: repo.days, stored: storedStress) {
            let dayFormat = DateFormatter()
            dayFormat.locale = Locale(identifier: "en_US_POSIX")
            dayFormat.timeZone = TimeZone(identifier: "UTC")
            dayFormat.dateFormat = "yyyy-MM-dd"
            root["stressDaily"] = stress.fullTrend.suffix(400).map {
                ["day": dayFormat.string(from: $0.date), "value": $0.value] as [String: Any]
            }
        }

        // What Simple Trends would say, for every range and chart (SimpleTrendRules on the screen's own windows).
        let restSeries = await repo.exploreSeries(key: "sleep_performance", source: "my-whoop")
        let restByDay = Dictionary(restSeries.map { ($0.day, $0.value) }, uniquingKeysWith: { _, last in last })
        let charts: [(String, (DailyMetric) -> Double?, Bool)] = [
            ("charge", { $0.recovery }, false), ("hrv", { $0.avgHrv }, false),
            ("rhr", { $0.restingHr.map(Double.init) }, false), ("rest", { restByDay[$0.day] }, false),
            ("effort", { $0.strain }, true),
        ]
        var trends: [[String: Any]] = []
        for range in TrendsView.Range.allCases {
            for (name, value, isEffort) in charts {
                let resolved = HostedTrendData.resolve(days: repo.days, selected: range, value: value)
                let shown = resolved.points.map { isEffort ? UnitFormatter.effortValue($0.value, scale: scale) : $0.value }
                let decimals = isEffort && scale == .whoop ? 1 : 0
                var row: [String: Any] = ["range": range.days ?? 0, "chart": name,
                                          "shownRange": resolved.effective.days ?? 0, "n": shown.count,
                                          "verdict": String(describing: SimpleTrendRules.verdict(values: shown,
                                                                                                 decimals: decimals))]
                if !shown.isEmpty {
                    row["mean"] = shown.reduce(0, +) / Double(shown.count)
                    row["min"] = shown.min() ?? 0
                    row["max"] = shown.max() ?? 0
                }
                trends.append(row)
            }
        }
        root["trends"] = trends

        // The week: the engine's sentences and balance beside Simple mode's lines and comparisons.
        let today = Repository.logicalDayKey(now)
        let digest = WeeklyDigestSource.digest(from: repo.days, anchorDay: Repository.localDayKey(now))
        let loads = SimpleWeekRules.dayLoads(days: repo.days, weekStart: digest.weekStart, weekEnd: digest.weekEnd,
                                             today: today)
        let adherence = SimpleWeekRules.adherence(loads, scale: scale)
        root["week"] = ["weekStart": digest.weekStart, "daysWithData": digest.daysWithData,
                        "engineFocalPoints": digest.focalPoints, "engineBalance": digest.balance.rawValue,
                        "simpleLines": SimpleWeekRules.lines(digest, adherence: adherence, scale: scale)
                            .map { String(describing: $0) },
                        "simpleChips": Dictionary(uniqueKeysWithValues: digest.metrics.map {
                            ($0.metric.rawValue, String(describing: SimpleWeekRules.chip($0, scale: scale)))
                        }),
                        "adherence": adherence.map { String(describing: $0) } ?? NSNull()] as [String: Any]

        // Workouts: the "Last 7 days" card's figures.
        let workouts = await repo.workoutRows(days: 30)
        let week = SimpleWorkoutRules.week(rows: workouts, now: now, calendar: .current, maxHR: profile.effortHRmax)
        root["workouts"] = ["last7Count": week.count, "last7Minutes": week.totalSeconds / 60,
                            "previous7Count": week.previousCount, "moderateMinutes": week.moderateMinutes,
                            "vigorousMinutes": week.vigorousMinutes, "guidelineMinutes": week.guidelineMinutes,
                            "withoutHeartRate": week.withoutHeartRate, "strengthDays": week.strengthDays,
                            "rowsLast30Days": workouts.count] as [String: Any]

        root["readMe"] = "Schema 1. Raw data and every stored score are in noop-backup.noopbak; this file adds what "
            + "the app concluded at export time. Read it with dist/tools/lab.py in the NOOP handbook."
        let options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys]
        return (try? JSONSerialization.data(withJSONObject: root, options: options)) ?? Data("{}".utf8)
    }
}

// MARK: - The developer export

/// One `.zip` for whoever develops NOOP: `lab.json` (the snapshot above), the verified backup (every reading,
/// score, workout and journal answer, check-ins included; it restores into NOOP), the Test Centre bundle's files
/// (strap log, build and device facts, raw capture, last crash, already scrubbed of identifiers) and a README for
/// the reader. Made on demand; nothing leaves the phone unless the wearer shares it.
enum DeveloperExport {

    enum Outcome: Equatable {
        case ready(URL)
        case failed(String)
    }

    /// The README written into every developer file, for the person or agent who opens it.
    static func readme(now: Date, appVersion: String, checkIns: Int) -> String {
        """
        # NOOP developer export (lab schema \(LabSnapshot.schema))

        Made \(ISO8601DateFormatter().string(from: now)) by NOOP \(appVersion), for whoever develops NOOP (a
        person or an AI agent). The wearer only carried it.

        ## Files
        - lab.json: what the app concluded at export time (Simple Trends verdicts for every range and chart, the
          week's comparisons and sentences beside the engine's, the Workouts summary, and each day's morning Stress
          number, which is computed on screen and not stored), the app and device facts, the settings the
          algorithms read, and the morning check-in counts.
        - noop-backup.noopbak: a full NOOP backup (a zip holding noop-backup.sqlite and settings.json): raw
          streams, day rows, sleep sessions (with the wearer's own corrections beside the detected times),
          workouts and journal answers. It restores into NOOP from Backup & Sync, and opens with sqlite3.
        - report.txt: the strap log. meta.json: build, phone and storage facts. Any raw strap capture and the
          last crash the Test Centre holds.

        ## Truth data
        Morning check-ins answered so far: \(checkIns). Journal questions (numeric, under deviceId noop-journal):
        \(CheckIn.journalQuestions.joined(separator: ", ")), each 1 to 5 with 5 the good end, answered before the
        scores are seen; and \(CheckIn.sleepTimesQuestion) about last night's detected sleep.

        ## How to read it
        In the NOOP handbook checkout (branch handbook): python3.12 -I dist/tools/lab.py <this zip>. The protocol
        is handbook features/lab.md.

        ## Privacy
        Identifiers such as the strap's serial number are removed from the text files. The backup holds the
        wearer's health data: keep it private, never commit or upload it, report aggregates only.
        """
    }

    /// Build the developer `.zip` in the app's scratch folder.
    @MainActor
    static func make(model: AppModel, live: LiveState) async -> Outcome {
        let repo = model.repo
        let fm = FileManager.default
        let folder = NoopScratch.file("developer-export")
        try? fm.removeItem(at: folder)
        do { try fm.createDirectory(at: folder, withIntermediateDirectories: true) }
        catch { return .failed(error.localizedDescription) }

        let backupURL = folder.appendingPathComponent("noop-backup.noopbak")
        if case .failure(let message) = await DataBackup.writeBackup(checkpoint: { await repo.checkpointForBackup() },
                                                                    to: backupURL) {
            return .failed(message)
        }

        let storage = await TestCentreReport.storageProbe(repo: repo, live: live)
        let strapModel = UserDefaults.standard.string(forKey: "selectedWhoopModel")
        let bundle = TestBundleAssembler.assemble(profile: .master, live: live, storage: storage, strapModel: strapModel)
        let lab = FileExport.BundleEntry(name: "lab.json", data: await LabSnapshot.json(model: model))
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let readme = FileExport.BundleEntry(
            name: "README.md",
            data: Data(readme(now: Date(), appVersion: version,
                              checkIns: CheckIn.completedDays(await repo.numericJournalSeries())).utf8))

        let zipURL = folder.appendingPathComponent(FileExport.timestampedName("noop-lab", ext: "zip"))
        let entries = [readme, lab] + bundle
        let written = await Task.detached(priority: .userInitiated) { () -> Bool in
            do {
                let archive = try Archive(url: zipURL, accessMode: .create)
                // The backup is already a compressed archive: stored as it is.
                try archive.addEntry(with: "noop-backup.noopbak", fileURL: backupURL, compressionMethod: .none)
                for entry in entries {
                    try archive.addEntry(with: entry.name, type: .file, uncompressedSize: Int64(entry.data.count),
                                         compressionMethod: .deflate) { position, size in
                        let start = Int(position)
                        return entry.data.subdata(in: start..<min(start + size, entry.data.count))
                    }
                }
                return true
            } catch {
                return false
            }
        }.value
        try? fm.removeItem(at: backupURL)
        return written ? .ready(zipURL) : .failed(String(localized: "The developer file could not be written."))
    }
}

// MARK: - The Test Centre card

/// The developer loop's card at the top of the Test Centre: the developer file, and the morning check-in switch.
struct DeveloperExportCard: View {
    @EnvironmentObject var model: AppModel
    @EnvironmentObject var live: LiveState
    @AppStorage(CheckIn.enabledKey) private var checkInEnabled = false
    @AppStorage(CheckIn.requestKey) private var requestedAt: Double = 0
    @State private var checkInDays = 0
    @State private var making = false
    @State private var status: String?

    var body: some View {
        NoopCard {
            VStack(alignment: .leading, spacing: NoopMetrics.space3) {
                SectionHeader("Developer export", overline: "For whoever improves NOOP")
                Text("One file for the person improving NOOP: your backup, the strap log, the app's facts and what NOOP's screens concluded. It stays on this phone until you share it, for example by AirDrop to a Mac.")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Group {
                    if making {
                        NoopButton("Making the file…", systemImage: "hourglass", kind: .primary, fullWidth: true) {}
                    } else {
                        NoopButton("Make the developer file", systemImage: "doc.zipper", kind: .primary,
                                   fullWidth: true) { make() }
                    }
                }
                .disabled(making)
                .opacity(making ? NoopButtonMetrics.disabledOpacity : 1)
                if let status {
                    Text(status)
                        .font(StrandFont.footnote)
                        .foregroundStyle(StrandPalette.statusWarning)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Divider().overlay(StrandPalette.hairline)
                Toggle(isOn: $checkInEnabled) {
                    Text("Morning check-in")
                        .font(StrandFont.headline)
                        .foregroundStyle(StrandPalette.textPrimary)
                }
                .tint(StrandPalette.accent)
                Text("Each morning, before you see your scores, NOOP asks how rested you feel, how well you slept and how relaxed you feel, from 1 to 5, and whether its sleep times for last night were right. The answers show the developer whether Charge, Rest, Stress and the sleep detection follow your own experience.")
                    .font(StrandFont.subhead)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("It comes when you open NOOP in the morning, not in the middle of the night. Not now asks again an hour later.")
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                if checkInEnabled {
                    NoopButton("Answer this morning's check-in", systemImage: "sun.horizon", kind: .secondary,
                               fullWidth: true) { requestedAt = Date().timeIntervalSince1970 }
                }
                Text(checkInDays == 1
                     ? String(localized: "1 morning answered so far.")
                     : String(localized: "\(checkInDays) mornings answered so far."))
                    .font(StrandFont.footnote)
                    .foregroundStyle(StrandPalette.textTertiary)
            }
        }
        .task(id: checkInEnabled) {
            checkInDays = CheckIn.completedDays(await model.repo.numericJournalSeries())
        }
    }

    private func make() {
        making = true
        status = nil
        Task {
            let outcome = await DeveloperExport.make(model: model, live: live)
            making = false
            switch outcome {
            case .ready(let url):
                FileExport.exportFile(at: url, suggestedName: url.lastPathComponent)
            case .failed(let message):
                status = message
            }
        }
    }
}
