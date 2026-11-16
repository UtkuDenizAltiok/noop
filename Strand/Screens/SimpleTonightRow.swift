import SwiftUI
import StrandDesign

// MARK: - Simple mode: "Tonight"
//
// The evening question (when should I sleep, and how long?) answered the same way wherever it is asked:
// on Today's sleep card and on the Sleep tab. One resolver (`SimpleTonight.resolve`) and one set of lines
// (`SimpleTonightLines`), so the two screens cannot give two bedtimes for one evening.

/// What Simple mode says about tonight, resolved once for whichever screen shows it.
struct SimpleTonight: Equatable {
    /// The wind-down reminder's own plan, while the reminder is on and its fall-asleep time is still ahead.
    let plan: SimpleDayPlan.TonightPlan?
    /// The goal from the wearer's need, catch-up and usual wake time, while the reminder is off.
    let goal: SimpleDayPlan.TonightGoal?
    /// Minutes of catch-up sleep the debt asks for tonight (0 when the wearer is not behind).
    let catchUp: Int
    /// Whether the reminder's row may state its sleep need as a duration (`SimpleDayPlan.tonightStatesNeed`).
    let planStatesNeed: Bool

    /// Nothing to say: no plan and no goal.
    static let silent = SimpleTonight(plan: nil, goal: nil, catchUp: 0, planStatesNeed: true)

    var hasSomethingToSay: Bool { plan != nil || goal != nil }

    /// Tonight, from the inputs both screens hold: the Sleep tab's need in whole minutes, the debt its ledger
    /// shows, the wearer's usual wake minute, and the need last night's line states (WHOOP's imported one
    /// when there is one). The reminder's settings are read through `WindDownNudge`, which owns them.
    ///
    /// With the reminder on, its own plan is the row. Otherwise the goal, left out while last night's line
    /// states a different need: a goal built on NOOP's need under WHOOP's figure would put two needs side by
    /// side.
    @MainActor
    static func resolve(now: Date = Date(), calendar: Calendar = .current, needMin: Int?, debtMin: Double?,
                        usualWakeMinute: Int?, lastNightNeedMin: Double?) -> SimpleTonight {
        let plan = SimpleDayPlan.tonightPlan(now: now, calendar: calendar, reminderOn: WindDownNudge.isEnabled,
                                             needMinutes: WindDownNudge.sleepNeedMinutes,
                                             leadMinutes: WindDownNudge.leadMinutes,
                                             wakeMinutesForWeekday: { WindDownNudge.wakeMinutes(forWeekday: $0) })
        let catchUp = SimpleDayPlan.catchUpMinutes(debtMinutes: debtMin ?? 0)
        var goal: SimpleDayPlan.TonightGoal?
        if plan == nil, let needMin,
           SimpleDayPlan.tonightStatesNeed(lastNightNeedMin: lastNightNeedMin, tonightNeedMin: needMin) {
            goal = SimpleDayPlan.tonightGoal(now: now, calendar: calendar, needMinutes: needMin,
                                             catchUpMinutes: catchUp, usualWakeMinute: usualWakeMinute)
        }
        let statesNeed = plan.map {
            SimpleDayPlan.tonightStatesNeed(lastNightNeedMin: lastNightNeedMin, tonightNeedMin: $0.needMinutes)
        } ?? true
        return SimpleTonight(plan: plan, goal: goal, catchUp: catchUp, planStatesNeed: statesNeed)
    }
}

/// The lines of a "Tonight" row, under its icon and overline: the reminder's plan, or the goal.
struct SimpleTonightLines: View {
    let tonight: SimpleTonight

    var body: some View {
        if let plan = tonight.plan {
            let clock = AppClock.hourMinuteFormatter()
            Text("Aim to be asleep by \(clock.string(from: plan.asleepBy))")
                .font(StrandFont.subhead.weight(.semibold))
                .foregroundStyle(StrandPalette.textPrimary)
            Group {
                if tonight.planStatesNeed {
                    Text("That gives you \(SimpleDayPlan.durationText(Double(plan.needMinutes))) of sleep before your \(clock.string(from: plan.wake)) wake. Your wind-down reminder comes at \(clock.string(from: plan.windDown)).")
                } else {
                    Text("Your wind-down reminder comes at \(clock.string(from: plan.windDown)), ahead of your \(clock.string(from: plan.wake)) wake.")
                }
            }
            .font(StrandFont.caption)
            .foregroundStyle(StrandPalette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            // The reminder's times are its own; being behind on sleep is said in words rather than as a
            // second duration, so the row never states two needs.
            if tonight.catchUp > 0 {
                Text("You're about \(SimpleDayPlan.durationText(Double(tonight.catchUp))) behind on sleep, so a little earlier is better.")
                    .font(StrandFont.caption)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else if let goal = tonight.goal {
            goalLines(goal)
        }
    }

    /// A fall-asleep time when a usual wake time is known, otherwise the goal alone; the catch-up is named
    /// whenever it is part of the goal.
    @ViewBuilder
    private func goalLines(_ goal: SimpleDayPlan.TonightGoal) -> some View {
        let total = SimpleDayPlan.durationText(Double(goal.goalMinutes))
        let extra = SimpleDayPlan.durationText(Double(goal.catchUpMinutes))
        if let asleepBy = goal.asleepBy, let wake = goal.wake {
            let clock = AppClock.hourMinuteFormatter()
            Text("Aim to be asleep by \(clock.string(from: asleepBy))")
                .font(StrandFont.subhead.weight(.semibold))
                .foregroundStyle(StrandPalette.textPrimary)
            Group {
                if goal.catchUpMinutes > 0 {
                    Text("That gives you \(total) of sleep before your usual \(clock.string(from: wake)) wake, including \(extra) to catch up.")
                } else {
                    Text("That gives you \(total) of sleep before your usual \(clock.string(from: wake)) wake.")
                }
            }
            .font(StrandFont.caption)
            .foregroundStyle(StrandPalette.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text("Aim for \(total) of sleep tonight")
                .font(StrandFont.subhead.weight(.semibold))
                .foregroundStyle(StrandPalette.textPrimary)
            if goal.catchUpMinutes > 0 {
                Text("That includes \(extra) to catch up on sleep you've missed.")
                    .font(StrandFont.caption)
                    .foregroundStyle(StrandPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// One row of a Simple sleep card: an icon, a small overline and the row's own lines.
struct SimpleSleepRow<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(StrandPalette.restColor)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(StrandFont.overline).tracking(1.6).textCase(.uppercase)
                    .foregroundStyle(StrandPalette.textTertiary)
                content()
            }
        }
    }
}

/// The Sleep tab's "Tonight" card: the row Today's sleep card shows, on a card of its own. A leaf that
/// observes the reminder's stored settings, so a change made on the Alarms screen shows as soon as the
/// wearer comes back. Draws nothing when there is nothing true to say about tonight.
struct SimpleTonightCard: View {
    let needMin: Int
    let debtMin: Double
    let usualWakeMinute: Int?
    let lastNightNeedMin: Double?

    @AppStorage(SimpleDayPlan.ReminderKeys.enabled) private var windDownEnabledMirror = false
    @AppStorage(SimpleDayPlan.ReminderKeys.wake) private var windDownWakeMirror = 0
    @AppStorage(SimpleDayPlan.ReminderKeys.need) private var windDownNeedMirror = 0
    @AppStorage(SimpleDayPlan.ReminderKeys.perDayWake) private var windDownPerDayMirror = Data()

    var body: some View {
        // Read so the card re-renders when the Alarms screen changes them; the values themselves come
        // through `WindDownNudge` inside `resolve`.
        _ = (windDownEnabledMirror, windDownWakeMirror, windDownNeedMirror, windDownPerDayMirror)
        let tonight = SimpleTonight.resolve(needMin: needMin, debtMin: debtMin, usualWakeMinute: usualWakeMinute,
                                            lastNightNeedMin: lastNightNeedMin)
        return Group {
            if tonight.hasSomethingToSay {
                NoopCard(tint: StrandPalette.restColor) {
                    SimpleSleepRow(icon: "bed.double.fill", title: String(localized: "Tonight")) {
                        SimpleTonightLines(tonight: tonight)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}
