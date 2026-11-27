import SwiftUI
import StrandDesign

/// "Change" for the one sleep need (`SleepNeed`, v6 step 7): Automatic, or 7h 0m to 9h 30m in 15-minute steps. Used
/// by Settings and by the Sleep tab's "Your sleep need" card, so both write the same stored choice. After a change
/// the scores are worked out again, because Rest measures a night against the need.
struct SleepNeedMenu: View {
    @EnvironmentObject var intelligence: IntelligenceEngine
    @EnvironmentObject var repo: Repository
    @AppStorage(SleepNeed.chosenMinutesKey) private var chosen = 0
    /// The menu's label: "Change" on the card, the current value in Settings.
    var label: LocalizedStringKey = "Change"

    var body: some View {
        Menu {
            Picker("Sleep need", selection: Binding(get: { SleepNeed.normalizedChoice(chosen) }, set: { pick($0) })) {
                ForEach(SleepNeed.choices, id: \.self) { minutes in
                    if minutes == 0 {
                        Text("Automatic (\(SimpleDayPlan.durationText(SleepNeed.automaticHours(days: repo.days) * 60)))")
                            .tag(0)
                    } else {
                        Text(verbatim: SimpleDayPlan.durationText(Double(minutes))).tag(minutes)
                    }
                }
            }
        } label: {
            Text(label)
                .font(StrandFont.subhead.weight(.semibold))
                .foregroundStyle(StrandPalette.restColor)
        }
        .accessibilityLabel("Change your sleep need")
    }

    private func pick(_ minutes: Int) {
        let value = SleepNeed.normalizedChoice(minutes)
        guard value != SleepNeed.normalizedChoice(chosen) else { return }
        chosen = value
        Task {
            await intelligence.analyzeRecent()
            await repo.refresh()
        }
    }
}

/// The Settings row's value: the need as it stands ("8h 0m · Automatic" or the chosen figure), opening the same menu.
struct SleepNeedSettingValue: View {
    @EnvironmentObject var repo: Repository
    @AppStorage(SleepNeed.chosenMinutesKey) private var chosen = 0

    var body: some View {
        let value = SimpleDayPlan.durationText(SleepNeed.currentHours(days: repo.days) * 60)
        if SleepNeed.normalizedChoice(chosen) > 0 {
            SleepNeedMenu(label: "\(value)")
        } else {
            SleepNeedMenu(label: "\(value) · Automatic")
        }
    }
}
