# Simple mode and the human-friendly NOOP project

**Status (27 Nov 2026):** Design v6 is built and shipped in NOOP 13.0.0 (steps 1–7, then chats 10–11: sleep onset,
wake rescoring, naps, the sleep regularity index, workout minutes from heart rate). What is still open lives in
[State](../STATE.md). The sections below are the design record and how each step was built; "Ground rules and how to
work" holds the practical recipes.

## Where v6 began: Simple mode v6, the most user-friendly NOOP

**Utku's direction, 14 Nov 2026 (rule in [Rules](../RULES.md#settled-decisions)):** Simple mode was only *simpler*
than the full NOOP. It must become the most user-friendly mode, so a wearer understands and uses the app without
confusion, decided from four viewpoints (fitness coach, physiologist, doctor, software developer), and never by
deleting information or features. He is not the expert; the architect decides.

**Where it stands (27 Nov 2026, chat 10):** Design v6 is written (the next section) and **all seven steps are
built**: steps 1 to 6 on `feat/simple-mode` (`053ef4bd` to `f62dc758`) and step 7, "Your own sleep need", on
`feat/v6-step7-and-feedback` with chat 10's fixes from Utku's 27 Nov phone report (sleep onset, "Fell asleep /
Woke", the check-in, the iPhone step calibration); see [Step 7 as built](#step-7-as-built-27-nov-chat-10-featv6-step7-and-feedback-280929e6--fix-38e73acc)
and [Chat 10](#chat-10-utkus-feedback-of-27-nov-sleep-check-in-steps). The phone build and its install choice
(a fresh start, with the final build) are in [State](../STATE.md). **Next: [State](../STATE.md) "Now" lists
Utku's 27 Nov prompt item by item; finish the open ones** (naps are built and verified, not shipped; sleep
improvements from public evidence; [Backlog](../BACKLOG.md), "Next, from Utku's 27 Nov feedback"), then one final
build, then his fresh start. No files from him until he offers. Whatever he reports from the phone is fixed first.

**Step 7's decision (taken in chat 10 as recommended below): one need moves the Rest score too.** The original
note, kept for the record:

**Step 7 starts with one decision: does the one sleep need also move the Rest score?** (chat 9's reading of the
code, grep-located, read before relying). Today three needs exist side by side: the shown Rest scores every night
against a fixed 8 h (`AnalyticsEngine.Rest.composite(daily:)` with its default `needHours`, finding S11); the debt,
tonight's goal and the Sleep need card use the personal need (`SleepModel.debtNeedMin`, upper quartile of the
nights, floored at `Rest.populationNeedFloorHours`, **with age nil**); the engine's own Charge term uses the same
estimator **with the profile's age** (`IntelligenceEngine` near line 1000). S1b ("Automatic" or a chosen 7h 0m to
9h 30m) and S1c (7.5 h from 65) both go through one resolver; if the shown Rest keeps 8 h, a wearer who chooses
9 h reads "Your sleep need: 9h 0m" beside a Rest page that says "Full marks at 8h 0m" (step 2 already prints both
when they differ). Recommended: one resolver for the need (chosen, else automatic with the age), used by the
debt, tonight's goal, the reminder (`WindDownNudge.sleepNeedMinutes`, kept in step by `adoptSleepNeed` on the
stack since #2906) and the Rest composite's duration term, landed with an oracle on both platforms and the
change in every shown Rest stated plainly to Utku before it ships (S11's regularity half stays separate: it
needs the sleep-regularity literature read first). Where the code is:
- The need: `Packages/StrandAnalytics/.../AnalyticsEngine.swift` `Rest.populationNeedFloorHours` (near 1246) and
  `personalizedNeedHours` (near 1261); Kotlin `android/.../analytics/AnalyticsEngine.kt` (near 1579, 1594). Its
  callers with age nil: `SleepModel.debtNeedMin` (Swift), `SleepModelLogic.kt` (near 196),
  `SleepMetricDetailLogic.kt` (near 43); Simple mode's `SimpleDayPlan.standardSleepNeedMinutes` and
  `sleepNeedOrigin` (the card's origin sentence) need a "You chose this yourself." case.
- The shown Rest, every caller of the composite with the default need: Swift `SleepModel.swift` (near 430),
  `CoupledView.swift` (105), `SleepView.swift` (502), `WeeklyDigestView.swift` (57), `IntelligenceEngine.swift`
  (2315, 2480, 3290, 3308, 3326); Kotlin `RestScorer.restFromDaily` at `SleepHeroLogic.kt` (112),
  `TodayScoring.kt` (81), `WeeklyDigestCard.kt` (89), `SleepMetricDetailLogic.kt` (63), `SleepModelLogic.kt`
  (209), `AppViewModel.kt` (1071, 1134), `CoupledScreen.kt` (175). Today's ring reads the stored
  `sleep_performance` series, so check what writes it before assuming a display-only change.
- The setting: a new key in the `.noopbak` whitelist on both sides (`Packages/WhoopStore/.../BackupSettings.swift`
  and `android/.../data/BackupSettings.kt`, byte-identical canonical keys, Int minutes, 0 = Automatic), a picker in
  Settings and on the Sleep need card ("Change"), the Android twin of both, Android CI on the fork (tell Utku
  before a run meant to fail).

**Carried, unverified:** W40 (fitness age against VO₂max, on the phone); **F19** (seen once in the simulator's
demo: between midnight and the 04:00 day rollover the readings behind the same night's Charge changed, resting
heart rate +11 → +10 points, "usually 57" → "usually 56"; the baseline window may follow the calendar day while
the screen follows the logical day, `ChargeBaselines.history`'s `anchorDay` against `Repository.logicalDayKey`;
check on real data before calling it a bug); **F20** (demo only: for a night imported from WHOOP the stage card
reads "7h 11m in bed, asleep for 100% of it" while the day row holds the export's efficiency of 95% and the
clock times span 7h 33m; a first fix that took the row's figures made the card disagree with its own Awake row,
so it was taken out again; look at a really imported night before touching it); **F21** (upstream candidate: the
full view's sleep trend prints "7.2 h avg" under "trailing 30 days", but the figure is the mean of ALL nights,
`AsleepDurationData.typicalTotalMin`; Simple mode now averages the nights shown); **F22** (upstream candidate, found 22 Nov: with the
experimental blood-oxygen estimate switched on, the full view's tile shows the estimate as an ordinary reading,
"NOOP computed · Typical range": its "strap estimate (unverified)" label is set as the *missing* caption, which
is drawn only when there is no value, so it never shows; the guide promises the label. Simple mode now says
"A strap estimate, not checked against a medical device." Check the Android tile before sending it upstream). **F23** (upstream candidate, found 26 Nov building step 5:
`WeeklyDigestEngine.balanceRead` compares the week's mean Effort with its mean Charge, two different 0-100
scales, so the full view calls a week of Charge 50 and Effort 65 "leaning into the red" although Today's range
for a Charge of 50 is 48-67 every day; both platforms). **F24** (upstream, low: the engine's steady line "no
metric moved meaningfully from last week" also shows when there was no last week). **F25** (upstream, low: the
full Workouts screen counts "last 7 days" back from the newest workout, so an old log's "last 7 days" are not
the last 7 days; deliberate upstream, the caption's words are the problem). **F26** (upstream: the weekly digest
calls a rise in Effort "a good sign", `WeeklyMetric.higherIsBetter` is true for Effort; a harder week is not good
in itself, rule 4).

**Who builds (Utku, 15 Nov):** his words were "no subagents you do the work only!". Read as: the architect chat
does the walk, the design and the building itself, one step at a time, without helper agents or worker chats
(recorded in [Rules](../RULES.md#settled-decisions) with that reading labelled). The review discipline stays:
every step is verified as a worker's would be (tests seen to fail, both app targets built, the gates, a simulator
walk) before it reaches the stack.

**What exists to build on** (on the phone since 12 Nov, build `218aec72`): Simple mode v5 (Rounds 1–6), "Show
everything on this screen" on six screens, "Report a problem", the Lift Log guard test, the high heart rate
warning ([its page](high-hr-warning.md)), and v6 steps 1 to 3 (16 Nov; the build that holds them is in
[State](../STATE.md)).

**Working with Utku:** plain everyday words, no technical terms; never ask him about builds, Git or GitHub; end
every answer with one to three simple numbered next steps; tell him plainly when a build is ready before he tests.

## Design v6: the most user-friendly NOOP

Written 15 Nov 2026 from a walk of every Simple screen as a first-time wearer: 47 points of confusion (W1–W51; a few
numbers are unused) and seven science findings (S1–S10, likewise), all listed with their evidence in the
[diary, Round 8](simple-mode-diary.md#round-8-15-nov-2026-the-first-time-wearer-walk-behind-design-v6). Numbers in
brackets below point there.

### What was wrong with v5, in one paragraph

v5 made the app calmer by showing less. It did not make it explain itself. A newcomer still meets six words for
three scores, numbers with no "is that good?", bars with hidden meanings, advice from three different places, a
big score that opens a statistics page when tapped, no word about tonight unless a switch elsewhere is on, and a
"Health monitor" that never says whether anything is wrong. v6 keeps everything v5 shows and hides nothing more;
it changes what each screen says first, what every number is compared with, and where a tap leads.

### The six questions, and the one place each is answered

| When | The wearer's question | Answered by |
|---|---|---|
| Morning | How am I today, and how hard should I go? | Today: scores, then "Your day" |
| Day | How hard has today been? That workout? | Today: Effort and its range; Workouts |
| Evening | When should I sleep, and how long? | Today: "Tonight" (always there, W16); Sleep |
| Weeks | Am I getting fitter, sleeping better? | Trends, one verdict a chart (W23) |
| Rarely | Is something off with my body? With the strap? | Health monitor's verdict (W36); the strap line on Today (W3) |
| First two weeks | What is this telling me, and why the dashes? | "How to read NOOP" and "Getting to know you" (W1, W2) |

### Ten rules for every Simple screen

1. **The answer first, in words.** A screen opens with a sentence that answers its question. The number comes
   second, the detail third.
2. **Every number carries three things:** a plain name; for a score a word that says how good it is, for a body
   reading its comparison with the wearer's own normal ("usually 57"); and its explanation one tap away, from the
   number itself (W48).
3. **One name per thing** (the table below). The WHOOP words appear once, in "How to read NOOP", and in the
   guide's "also called" line (W6).
4. **One adviser.** Only "Your day" on Today says how hard to train: it is the only place that weighs every
   signal. Other screens describe what they see and point there (S9, W20, W34).
5. **One shape per kind of number** (below; W24, W30, W43, W49, W50).
6. **Colour means something.** Green: good for you. Amber: worth watching. Red: a warning. A reading's own colour
   belongs to its icon and its chart line, never to its value (W35, W51).
7. **Nothing is lost.** "Show everything on this screen" stays the last row; whatever a step moves or rewords
   stays reachable there. The Lift Log is not touched. The full view (Simple mode off) stays identical to
   upstream.
8. **Honest about certainty.** An estimate is called an estimate. "Still learning" says how many nights are left.
   A dash for what was not measured. No sentence claims more than the code that feeds it can know (S2).
9. **Presentation only**, from the resolvers the full view uses, unless the change is listed under
   [Science changes](#science-changes-each-its-own-change-evidence-first).
10. **Readable.** No text on a picture (W26). Nothing cut off at phone width or at the largest text size (W35,
    W42).

### One name per thing

| Thing | Its one name in Simple mode | Not used in Simple mode |
|---|---|---|
| The three scores | Charge, Effort, Rest | Recovery, Strain, Sleep score/performance (intro and guide only) |
| How sure NOOP is | "Still learning you" / "Early estimate" / nothing when sure | Calibrating, Building, Solid as bare pills (W8) |
| The wearer's usual value | "your normal", "usually 57" | baseline, typical, mean, vs 30-day |
| A window of time | "last 90 days", "this week" | trailing, readings, "· M" |
| Breathing | Breathing rate, "breaths a minute" | Resp rate, Respiratory, rpm (W38, W39) |
| Oxygen | Blood oxygen | Blood O₂, raw SpO₂ (the raw tile moves to Show everything) |
| Temperature | Skin temperature, "0.1° above your normal" | Skin temp Δ, Δ°C |
| HRV | "Heart-rate variability (HRV)" first on a screen, then HRV | rMSSD |
| Nightly target | Sleep need | — |
| Tonight's target | Tonight's goal (the need plus catch-up) | a second "need" |
| The wristband | strap | band, device, "WHOOP" for the strap |
| Imported figures | "Imported from WHOOP" | a bare "WHOOP" badge (W5) |

### One shape per kind of number

- Scores from 0 to 100 are whole numbers on every Simple screen, workouts included. Effort on the 0–21 scale keeps
  its one decimal (that scale's own convention).
- A duration is always "7h 18m". Never decimal hours.
- Heart rate and HRV are whole numbers. Breathing rate and temperature have one decimal.
- A change is said in words with its unit and its comparison: "up 4 ms over these 3 months", "5 lower than usual",
  "6% higher than last week". Never a bare "+6%". A change that rounds to nothing reads "no change".
- One range picker everywhere: Week, Month, 3 months, 6 months, Year, All.

### Score words (so a number is never alone, W7)

Each word comes from one function per score, shared by every screen that prints it, and tested against the
thresholds it reads so it cannot drift from them.

- **Charge:** Low (under 34), Medium (34 to 66), High (67 and over): the thresholds the ring colour and the Effort
  suggestion already use.
- **Effort:** Easy, Moderate, Hard, Very hard, by where today's Effort sits on the 0–21 axis (under 10, 10 to 14,
  14 to 18, over 18): the bands of `SimpleDayPlan.intensity`, so the word matches "a moderate day".
- **Rest:** the Sleep tab's existing words (Poor, Fair, Good, Optimal, `sleepScoreWord`), now on Today as well.

### Screen by screen

**First run: "How to read NOOP"** (W1). A sheet shown once when Today first appears in Simple mode, and always
available as the guide's first row, "Start here". The upstream wizard is not changed.
- Three rows with the ring colours: "**Charge**: how ready your body is today, from 0 to 100. Worked out while you
  sleep." · "**Effort**: how hard your heart has worked today. It climbs through the day." · "**Rest**: how well
  you slept last night, from 0 to 100."
- "Each morning, look at Charge; 'Your day' then tells you how hard to go. Each evening, 'Tonight' tells you when
  to sleep."
- "If you know the WHOOP app: Charge is Recovery, Effort is Strain, Rest is Sleep performance. NOOP works them
  out itself, so they will not match exactly."
- The first two weeks, as in the card below. Button: "Got it".

**First two weeks: "Getting to know you"** (W2). A card on Today, under the scores, until the fourteenth night.
Title "Getting to know you · night 3 of 14". Four lines, each ticked when reached: "Tonight: your first sleep and
Rest score" · "After 4 nights: your Charge" · "After 7 nights: daily advice and your own sleep need" · "After 14
nights: every reading compared with your own normal". Foot: "Wear the strap to bed. Until then NOOP shows a dash
instead of guessing." The night counts come from the code's own constants (`Baselines.minNightsSeed`,
`minNightsTrust`, `Rest.minNeedNights`, the readiness minimum), never typed into the copy; a test fails if one
moves. It replaces the sentence "Learning what's normal for you: 0 of 4 nights so far".

**Today** (order fixed; it does not shuffle by time of day, so things stay where the wearer learned them)
1. *Health alert, active workout:* unchanged, first.
2. *Strap line* (W3), only when something needs doing: "Strap not connected" with a **Connect** button (the
   Devices scan) · "Strap battery low: 12%" · "Not synced since 22:10 yesterday" with **Sync now**. Nothing when all
   is well. The header's strap button shows the battery percentage beside its icon (W4).
3. *Scores:* ring, name, and the score word in place of the Recovery/Strain/Sleep caption; the date line when a
   score is an earlier day's. Under the card, only when NOOP is not yet sure: "Early estimate: 6 of 14 nights so
   far." The "Solid" pill beside the greeting goes (W8). Tapping a ring opens its score page (below); tapping the
   name opens its guide entry, as now.
4. *Your day:* a headline in place of the pill (W9): "A good day to push" (primed) · "A normal training day"
   (balanced) · "Take it easier today" (strained) · "Rest and recover today" (run down); then the reason sentence;
   then Suggested Effort exactly as v5 built it. With no verdict yet, v5's honest sentences stay.
5. *Sleep:* "Last night" as now, and **"Tonight" always** (rules below).
6. *What's behind your Charge:* the dotted bar becomes a bar that grows right in green when a reading raised the
   Charge and left in amber when it lowered it, as long as its points (W11). Caption: "How last night's readings
   moved your Charge, compared with your own normal. Right raised it, left lowered it."
7. *Activity:* "Steps 8,715 · usually 7,900" and "Active calories 612 kcal · usually 540", each bar full at the
   wearer's own 30-day daily average (W12, S5). No hidden 10,000 or 800. Under 7 days of history: the number alone.
8. *Heart rate:* the card opens "Heart rate today" (below), not the Deep Timeline (W13).
9. *Workouts:* "Today's workouts" with the count alone; each row "Walking · 29 min · 256 kcal", right "Effort 40"
   (W15).
10. The wearer's own opt-ins, the guide card, "Show everything on this screen": unchanged.

**"Tonight"** (W16, S1, S10). One resolver (`SimpleDayPlan`), used by Today and by the Sleep tab.
- **Tonight's goal** = the sleep need + catch-up. Catch-up = the sleep debt the Sleep tab's ledger shows, at most
  60 minutes, rounded to 5; nothing when there is no debt. (The cap is a coach's rule: in the laboratory one hour
  of built-up debt took four nights to clear, Kitamura 2016, so a big debt is repaid over several nights.)
- **Wake time:** the wind-down reminder's when it is on; otherwise the wearer's usual wake time, the median of the
  last 14 main sleeps (at least 5), said as "your usual 07:10 wake".
- Reminder off, wake known: "**Be asleep by 22:35**" / "That gives you 8h 35m before your usual 07:10 wake: your
  8h need plus 35m to catch up." Without debt: "That gives you your 8h before your usual 07:10 wake."
- Reminder on: v5's row unchanged (the reminder's own times), plus, with debt: "You're about 35m behind on sleep,
  so a little earlier is better." No second duration, so the row never states two needs.
- No wake time known: "**Aim for 8h 35m of sleep tonight**" / "Your 8h need plus 35m to catch up."
- As now: only for today, and gone once the asleep-by time has passed.

**Score pages** (W14). In Simple mode a ring opens a plain page; the statistics page it opens today is its last
link. One layout for all three:
- The name, the number, the score word, the day if it is an earlier one, and the guide's one-line meaning.
- *Compared with you:* the last 7 days as bars with the 30-day average marked, and one sentence: "Higher than
  your usual 46."
- *What moved it:* Charge: every reading (Today lists the top three). Rest: its four parts in words and points
  (hours against your need; time asleep while in bed; deep + REM sleep; regular bed and wake times), from
  `RestSubScoreTrace`. Effort: today's workouts, and the suggested range with where the day stands.
- *What to do:* two sentences from the guide entry.
- Two links: "How NOOP calculates it" (the scoring guide) and "All readings and statistics" (the present page).

**Heart rate today** (W13). The Deep Timeline in Simple mode opens on heart rate alone: title "Heart rate today",
"Your heart rate through the day. Pinch to zoom, hold to read a moment.", lowest, average and highest, and when
empty "No heart rate recorded for this part of the day yet. It appears once your strap has synced." Its "Show
everything on this screen" row brings back the other signals and the Owned/All switch (a seventh screen with the
row).

**Sleep**
- The ring says "REST" and its word; "of 100" is made readable (W25, F5).
- Every line of text sits on a panel, none on the night picture (W26).
- Stages (W28): "Deep + REM 2h 36m, 38m less than your usual." Under the strips: "For most adults deep sleep is
  roughly an eighth to a quarter of the night and REM about a fifth to a quarter; deep sleep gets shorter with
  age. Your strap estimates stages, so one night outside this means little." (Confirm the ranges against the
  primary source, Ohayon 2004, before this copy ships.)
- A **Sleep need** card above the debt (W29, S1): "Your sleep need: 8h 0m", and where it comes from: "The usual
  target for adults: experts recommend 7 to 9 hours. NOOP raises yours if you regularly sleep longer when you
  can." or "Raised from 8h because you regularly sleep longer when you can." or, once the setting exists, "You
  chose this yourself." with **Change**.
- Debt (S10): "About 37m behind on sleep" or "You're caught up on sleep". Under an hour: "Sleep about 37m longer
  tonight to clear it." An hour or more: "That is more than one night can repay. Go to bed about an hour earlier
  for the next few nights." The row under it: "Sleep need 8h 0m · 14 nights counted" (the duplicate "Balance"
  figure stays in Show everything, W30).
- The same "Tonight" row as Today.
- Trend: "Hours asleep · last 30 nights · average 7h 18m"; lowest and highest in hours and minutes; the change in
  words (W30).
- Imported nights say "Imported from WHOOP", and when WHOOP's need for that night differs from NOOP's, the top
  line keeps WHOOP's (it belongs to WHOOP's score for that night) and says so: "8h 50m needed (WHOOP's figure)".

**Trends** (W18–W24)
- "This week" (the stepper stays): each chip reads "6% higher than last week". The week's sentence goes through
  a plain-words layer like `PlainChargeWording` (an unknown sentence falls back to the original). First entry:
  "You trained harder this week than your Charge supported. Expect a lower Charge for a day or two, and plan an
  easier day."
- "Over time", under its own heading, holds the range picker and the charts. Each chart: its name, "average 77
  ms" with the word, one verdict line ("Up 4 ms over these 3 months. Higher is better." / "Down 2 bpm over these
  3 months. Lower is better." / "Steady over these 3 months."), and the row Average · Lowest · Highest · Change.
- "Share recap" moves to the foot of the screen, still visible.

**Stress** (S2, W33–W35)
- Subtitle: "How strained your body looks, from your heart rate and heart-rate variability (HRV)."
- First card, "This morning": the 0–3 number and Low / Medium / High, with "From last night's resting heart rate
  and HRV, compared with your last 30 days. These are the readings behind your Charge too, so a high Charge
  usually comes with low stress."
- Its sentence describes and never advises training (a plain-words layer keyed on the same band and the same two
  deltas as the full view's sentence): low, both good: "Your resting heart rate is lower and your HRV higher than
  your normal. Your body looks calm and recovered." · low, HRV up: "Your HRV is higher than your normal, a sign of
  a relaxed body." · low, otherwise: "Your resting heart rate and HRV are at or better than your normal." ·
  medium: "About your normal: an ordinary day for your body." / "Your resting heart rate is a little higher than
  your normal. Nothing alarming." / "Your HRV is a little lower than your normal. Nothing alarming." · high, both:
  "Your resting heart rate is up and your HRV is down, the two classic signs of a body under strain. Sleep,
  fluids and an easy day help." · high, HRV down: "Your HRV is well below your normal. That often follows stress,
  poor sleep, alcohol or the start of an illness." · high, heart rate up: "Your resting heart rate is well above
  your normal: your body is working harder than usual." · high, otherwise: "Your readings lean toward strain
  today." Then one line: "How hard to train today is on Today, under Your day."
- Tiles: "Resting heart rate 51 bpm" / "5 lower than usual" and "HRV 82 ms" / "1 higher than usual" on two lines
  each, the value in the normal text colour and the comparison in green or amber; "Calm days: 7 of the last 30".
  The second copy of the stress number moves to Show everything.
- Second card, "Through the day": the existing timeline, the only part measured while awake.
- Trend: "Stress · last month", the common range picker.

**Health monitor** (W36–W40). Subtitle: "Whether your body's readings look normal for you."
1. **A verdict first**, from the states `BodyVitalSigns.readings` already computes: "All clear: your 5 readings
   are in your normal range." · "2 of 5 readings are outside your normal range: breathing rate (higher), skin
   temperature (higher)." with "One reading off for a night is common. Several off together, or for a few nights,
   can be an early sign of illness or strain: take it easy and notice how you feel. NOOP is not a medical
   device." · while learning: "NOOP is still learning your normal (night 6 of 14), so for now these are compared
   with typical adult ranges." · "No overnight readings yet." When the existing health alert is active, the
   verdict is the alert's own text: one source, so the two cannot disagree.
2. **The readings as rows:** resting heart rate, HRV, breathing rate, blood oxygen, skin temperature: the value,
   "usually 54–60", one word (Normal / Higher than usual / Lower than usual), the day if it is an earlier one,
   and its guide entry.
3. Live heart rate: unchanged.
4. **"Long-term estimates"**, opened by "Two different estimates. Neither is your biological age." Fitness age:
   "Compares your resting heart rate and activity with people of your age. Right to within about 5 years." ·
   Vitality: "A weekly score of your sleep, activity and heart readings." with its age inside the card as
   "Expressed as an age: 30" (W37).
5. Skin temperature: unchanged. The strap sync card moves to the foot.

**Workouts** (W41–W44)
- The summary in words: "This week: 5 sessions, 3h 24m active." · "1 more session than last week." · "Health
  guidelines suggest at least 150 minutes of moderate activity a week, or 75 of hard activity. Your recorded
  workouts come to 204." (WHO 2020) · "Average session Effort: 47 (moderate)."
- Rows: "Sun 15 Nov · 29 min · 256 kcal", right "Effort 40"; the clock times stay in the session's detail.
- Zones: "Zones 1 and 2 are easy, zone 3 is steady, zones 4 and 5 are hard. This week 46% of your time was easy."
  The honest note about imported sessions stays until S7 is done.

**More, Alarms, the guide** (W46–W48)
- A first row, **"My strap"** (the Devices screen), whose caption is its state: "Connected · 82%" or "Not
  connected". One caption under each group heading, so no row changes and the Lift Log row stays exactly as it
  is: Your body: "How your body is doing right now" · Training: "Your workouts and gym sessions" · Daily tools:
  "Alarms, warnings, breathing and the coach" · Your data: "Bring data in, keep it safe" · Help: "What things
  mean, and what to do when something is wrong".
- Alarms: "Turn on the wind-down reminder below and NOOP will tell you when to start getting ready for bed."
- Guide: new entries "Start here", "Tonight's goal", "Steps and active calories", "Normal, higher or lower than
  usual"; "Sleep need and sleep debt" rewritten with S1; "Stress" corrected with S2. Every card title on a Simple
  screen opens its entry.

### Science changes (each its own change, evidence-first)

| | What | Kind | Evidence, and what it moves |
|---|---|---|---|
| S1a | Say where the 8h sleep need comes from; "Tonight's goal" adds catch-up | wording, presentation | NSF 2015 (7–9 h; 7–8 h from 65); AASM/SRS 2015 (7 or more); Kitamura 2016 (8.41 h, 7.29–9.26 h; 1 h of debt, 4 nights). No score moves. |
| S1b | **Choose your own sleep need**: Settings and the Sleep need card, "Automatic" (today's rule) or 7h 0m to 9h 30m in 15-minute steps | new setting, both platforms, backup key | Needs differ by about two hours between healthy adults and cannot be measured from ordinary nights; the wearer is the only source. Default Automatic, so nothing moves until the wearer chooses. Floor 7 h (AASM). One resolver feeds the Rest score, the debt and the reminder. |
| S1c | Age in the automatic need: 9 h under 18, 8 h from 18 to 64, **7.5 h from 65**; the Sleep tab passes the age as the engine does | analytics, both platforms, upstream candidate | NSF 2015. Moves Rest and debt for wearers of 65 and over only; oracle on both sides. |
| S2 | Stress says what it measures; no training advice there | wording | The code (`StressView`). No score moves. |
| S3 | Rest's 50 % deep + REM target against laboratory norms of 35–45 % | research only | Needs the stage estimate's own REM over-reading settled first (History: DREAMT, sleep-accel). Not changed. Chat 11: researched, see Chat 11; keep 0.5 until REM is settled on real nights, then an age-aware target. |
| S5 | Steps and active calories against the wearer's own usual | presentation | Paluch 2022 for steps (said in the guide); no source for 800 kcal. |
| S7 | Zone minutes for NOOP's own recorded sessions | analytics, both platforms, later | Done in chat 11 (`2c638a91`): zone minutes per workout already existed (#856); the weekly WHO card now counts each workout's minutes from its own heart rate. See Chat 11. |
| S9, S10 | One adviser; debt advice by size | presentation | The walk; Kitamura 2016. |
| S11 | **The Rest score everyone sees counts a fixed 8 h night and does not measure regularity** (found 16 Nov, building step 2; need half done in step 7, regularity half done in chat 11 with the Sleep Regularity Index, see Chat 11) | analytics, both platforms, upstream candidate; with step 7 | The code: every shown Rest is `Rest.composite(daily:)` (Kotlin `RestScorer.restFromDaily`), called with its defaults: `defaultNeedHours` and no consistency, so the 10-point regularity part is the neutral 5 for every night and **no night can score above 95**. The engine works out a personal need and a regularity figure for the same night (`analyzeDay`'s `sleepNeedHours`, `sleepConsistency`) but only its own Charge term gets them. Step 2 says so on the Rest page and in the guide. A fix moves every Rest score, so it needs: the need settled first (S1b/S1c), the sleep-regularity literature read (not read yet), a stored value or a resolver both screens share, an oracle on both platforms. |
| S12 | **The Stress bands call about a third of ordinary mornings High** (found 22 Nov, building step 4) | research, then analytics on both platforms | The code: the morning number is `3/(1+e^-(z_rhr+z_hrv))` (`StressMath.squash`), High from 2.0, which is a combined deviation of only +0.69 standard deviations. With the two z-scores normal and uncorrelated the sum has a spread of 1.41, so about 31 % of mornings with nothing changed land in High (about 34 % if they move together, as resting heart rate and HRV do); Low the same. WHOOP-imported days use another formula (`WhoopImporter`: `1.5 + 0.6·z_rhr − 0.6·z_hrv` against the whole import, clamped) with a similar share. Step 4 words it honestly in Simple mode ("One morning like this is common"; the sentence names only a reading that moved). A fix (bands or squash) needs the distribution on real nights first: count High mornings in Utku's own history, and one formula for imported and own days. |
| S13 | **The adult ranges used before the wearer's own normal is known flag ordinary people** (found 22 Nov, building step 4; chat 11: not changed, the published wearable norms measure a different resting HR, see Chat 11) | analytics in `BodyVitalSigns`, both platforms, upstream candidate | `BodyVitalSigns.readings` judges HRV against 40–120 ms and resting heart rate against 40–60 bpm until 14 nights are trusted. The code's own norms disagree: `VitalityEngine.rmssdNorm(forAge:)` puts the median nocturnal RMSSD at 40 ms at 30, 33 at 40 and 29 at 50 (so half of healthy 30-year-olds read "below"), and `FitnessAgeEngine.restingHRReference` calls 65 bpm an average healthy adult (above the 60 top; that reference may be a waking figure, so check before using it). Step 4 keeps this calm in Simple mode: no amber while learning and "a reading outside one is often just how you are". A fix needs published spreads by age (not read yet: verify a source such as a systematic review of short-term HRV norms before citing it) and the Kotlin twin. |

| S14 | **When a trend may say "up" or "down"** (decided 26 Nov, building step 5) | presentation, Simple mode | Each Trends chart compares the later half of its window with the earlier half (the full view chip's halves). Simple mode names a change only when it is at least half the wearer's own day-to-day spread (the smallest worthwhile change: 0.5 x CV, Le Meur 2013; 1 x CV, Plews 2012; reviewed by Buchheit, Front Physiol 2014;5:73, who notes no fraction is proven to matter in practice) and at least two typical errors of the difference of the two averages, the typical error widened for day-to-day correlation by the AR(1) effective sample size n(1-r)/(1+r), r capped at 0.9. On the demo every chart reads "About the same". No figure moves. Check on the owner's backup how often each chart says up/down on real months before tuning. |
| S15 | **Workout minutes against the WHO guideline, judged by heart rate** (decided 26 Nov, step 5) | presentation, Simple mode, estimate | A workout counts as moderate when its average heart rate is at least 64 % of the wearer's maximum and vigorous from 77 % (ACSM's Guidelines for Exercise Testing and Prescription, 10th ed., 2018, as tabulated in PMC8581515; vigorous 77-95 % from a secondary source, the contiguous band). Vigorous minutes count twice (WHO 2020, Bull et al.). The session average under-counts intervals, so the estimate errs low. The maximum is `ProfileStore.effortHRmax` (override, else Tanaka 208 - 0.7 x age). Only workouts count, which the card says. Later: zone minutes from the strap's own heart rate for every workout (S7) would replace the average. |
Not copied and not possible: WHOOP's own sleep need (a personal baseline plus strain plus debt minus naps). Its
formula is private. v6 gets the same behaviour, a goal that moves with debt and naps, from published work; it
adds nothing for a hard day because no published figure says how much.

Carried over, unchanged: F11, F12 (measure first), F16, F17, F18, and the warning's W1/W2
([its §12](high-hr-warning.md#12-hardware-evidence-utkus-whoop-50-12-and-14-nov)).

### The build plan, one step at a time

Each step is one reviewed change on `feat/simple-mode`, verified, added to the stack and shipped, with two or
three plain questions for Utku afterwards. New English strings need all nine locales (How to work, below).

| Step | Name | Contains | Ask Utku afterwards |
|---|---|---|---|
| 1 ✓ shipped 16 Nov | Today answers | strap line; score words and the "early estimate" line; Your day headline; Tonight always, with its goal; the two-way Charge bars; activity against your usual; workouts row; the warning's W1 | Could you tell in five seconds how hard to go today? Did "Tonight" give a bedtime that suits you? Anything on Today you still do not understand? |
| 2 ✓ shipped 16 Nov | Tap a score, get an answer | the three score pages; Heart rate today | When you tap Charge, does the page explain it? |
| 3 ✓ shipped 16 Nov | Sleep | all of Sleep above, S1a, S10, the readable text | Is it clear how much sleep you need and why? |
| 4 ✓ shipped 22 Nov | Is my body all right? | Health monitor's verdict and rows; Stress, honest | Does Health tell you plainly whether anything is off? |
| 5 ✓ shipped 26 Nov | Am I improving? | Trends and Workouts in words | Can you tell from Trends whether you are improving? |
| 6 ✓ shipped 27 Nov | Welcome | How to read NOOP; Getting to know you; More; the guide; Alarms | Did "How to read NOOP" make the three scores clear? Does "My strap" in More say what you see? |
| 7 ✓ built 27 Nov (chat 10) | Your own sleep need | S1b and S1c, both platforms, Android in fork CI | Does your own figure feel right after a week? |

Later, each on its own: S7; S3 as research; the Android twin (Phase D); upstream (Phase C), only when it is active.

### Step 1 as built (15 Nov, `feat/simple-mode` `053ef4bd`)

Built as designed, with these differences, each decided while building and recorded so the page stays true:
- **Strap line:** only "Strap not connected" with **Connect** (it opens Devices), for a WHOOP strap, after an
  8-second settle so a launch does not flash it. The battery-low and not-synced lines and the battery percentage
  on the header button are **not built**; they move to step 6 with "My strap".
- **Effort word:** judged on the printed number with a range's top still belonging to it (Easy up to 48, Moderate
  up to 67, Hard up to 86 on the 0–100 scale), the way the card judges "in the range". The design's "under 10, 10
  to 14" called an Effort of 67 Hard while the card said it was in a moderate day's range.
- **Tonight, reminder off:** the title reuses "Aim to be asleep by 22:35"; the line reads "That gives you 8h 35m
  of sleep before your usual 07:10 wake, including 35m to catch up." Without a usual wake time: "Aim for 8h 35m
  of sleep tonight" / "That includes 35m to catch up on sleep you've missed." The row is left out while the
  last-night line shows WHOOP's imported need for that night (the demo's case): a goal on NOOP's need under it
  would put two needs on one card.
- **Activity:** the usual day is the median of the earlier days in the 30-day window (at least 7), rounded to the
  nearest 100 steps or 10 kcal; the bar is full at that usual and absent while there is none.
- **Workouts:** "+1 more" in place of a count; a workout's Effort printed like the ring's.
- **Also done:** the full view's greeting card went back to upstream's exact form (its Simple branches were
  unreachable since v5), and three unused fork strings left the catalogue. The guide's "Your day" entry now says
  "The headline of Your day" (the pill it described is gone).
- **Left for step 6:** the guide's entry on "Calibrating, Building, Solid" still names "Earlier score", a label
  that no longer appears on Today (the date under the ring says it).

Rules live in `SimpleDayPlan` (score words, early estimate, catch-up, usual wake, tonight's goal, usual day),
`SleepModel.debtLedger(days:sleeps:allSessions:habitualMidsleepSec:)` and `debtLedgerLookbackDays` (one debt for
Today and Sleep), `ChargeDriverDirectionBar`, `SimpleStrapStatus`. Tests: `SimpleTodayV6Tests` (12), each seen to
fail with its rule broken. The warning's W1 is `4e7fd6f5` on `feat/high-hr-warning`
([its §12](high-hr-warning.md#12-hardware-evidence-utkus-whoop-50-12-and-14-nov)).

### Step 2 as built (16 Nov, `feat/simple-mode` `8b59779a`)

Built as designed, with these differences, each decided while building:
- **One page, three scores** (`SimpleScorePageView`, rules in `SimpleScoreRules`, `Strand/Data/SimpleScorePage.swift`).
  The page never works a score out. Today hands it a snapshot of what the ring and the cards under it showed
  (`SimpleScoreSnapshot`, carried inside `TabRoute.scorePage`), so the page cannot show another number than the
  ring it was opened from. It reads only the score's history and, for Rest, the night's row.
- **"Compared with you" uses a usual range, not one usual value.** The design's "Higher than your usual 46"
  called a one-point wobble a change (seen in the demo: Rest 93, "lower than your usual 94"). Now: the middle
  half of the scored days in the 30 days before (quartiles, at least 7 days) is the usual range, drawn as a
  band behind the seven bars, and the sentence is "In your usual range, 37–50." / "Higher than…" / "Lower
  than…", judged on the printed numbers. Today's Effort reads "So far today 34. Your usual full day is 46–69."
  because the day is not over. Step 4's Health rows ("usually 54–60") should use the same idea.
- **Rest's four parts carry points that add up to the ring's number** (largest-remainder rounding), and say what
  the score really counts: "Full marks at 8h 0m", and "Regular bed and wake times: 5 of 10. Not measured yet.
  Every night gets half of these points for now, so the highest possible score is 95." (science finding S11).
  When the Sleep tab's personal need differs from 8 h the page says both figures. A night whose score is WHOOP's
  imported one shows the night's figures without points and says why. The guide's Rest entry was corrected.
- **Charge:** every reading, Today's own rows. Bars and the level bar take the ring's green-to-red ramp, so a
  medium Charge is not drawn green. **F17 is fixed for Simple mode:** the breakdown is handed the row's own
  night of Rest (`SimpleScoreRules.chargeRowRest`), and a carried Charge names its night above the rows ("How
  the readings from 14 Nov moved your Charge"). The classic sheet passes the on-screen Rest too (checked in
  `TodayView.chargeBreakdown`), so F17 stays an upstream candidate for the full view.
- **Effort:** the day's workouts, one sentence on what Effort adds up, and the suggested range drawn by the
  view Today's card uses (`SimpleEffortPlanView`), only when Today shows one.
- **What to do:** two or three sentences that end by pointing to "Your day" (or "Tonight"), so Today stays
  the one adviser.
- **Heart rate:** the screen is titled "Heart rate" (not "Heart rate today": it has a day stepper), opens on
  heart rate alone, with Lowest / Average / Highest and units, a plain empty state, and the "Show everything
  on this screen" row (the seventh screen with it). From an earlier day selected on Today it opens on that
  day (`TabRoute.fullDayChartOn`).
- **Not seen in the simulator:** the heart-rate line and its Lowest / Average / Highest row (the demo has no
  heart-rate stream; the empty state was seen), and a ring tap itself (the tap tool does not reach the rings;
  the page was opened with `--demo-open-score charge|effort|rest`, which hands over the ring's own snapshot).
  The Rest parts were seen through a throwaway edit, restored byte-identical.

Tests: `SimpleScorePageTests` (14), each seen to fail with its rule broken (the break script lived in the
chat's scratch folder and was lost when that folder was cleared; step 3's is kept, see below). 41 new strings in
nine locales, one reworded (the guide's Rest entry).

### Step 3 as built (16 Nov, `feat/simple-mode` `9aba63cf`)

Built as designed, with these differences:
- **Readable (W26):** instead of putting each line on its own panel, everything under the hero sits on the
  plain canvas (`SleepView.simpleCanvasBacking`). The night scene is a fixed backdrop behind the scroll, so any
  heading or note scrolling through its band was dark text on a dark picture (seen: "Trend / Asleep duration",
  the movement note). The ring uses the ring face's own text colours (the full view prints white on the pale
  face, finding F5), carries the name "Rest", and **opens the Rest page** Today's ring opens.
- **Provenance in words (W5):** "Imported from WHOOP" on the panel under the ring and on the night's times row;
  a night the strap measured carries no badge. When the night's line states WHOOP's need and it reads
  differently from NOOP's: "The need is WHOOP's figure for this night."
- **"Your sleep need" card (S1a, W29)** above the debt, with its origin sentence
  (`SimpleDayPlan.sleepNeedOrigin`, read from `Rest.populationNeedFloorHours`). The guide's entry was rewritten
  to match (it was planned for step 6).
- **Debt (S10, W30):** a sentence headline and advice by size (`SimpleDayPlan.debtAdvice`). The switch to
  "more than one night can repay" is at `catchUpCapMinutes`, the hour tonight's goal is capped at, so the two
  cannot disagree. The footer is "14 nights counted."; Balance and the need stay in the full view.
- **Tonight on the Sleep tab:** `SimpleTonight.resolve` + `SimpleTonightLines` (new file
  `SimpleTonightRow.swift`), which Today now draws through too. Same rule as Today, so it is also left out while
  last night's line states WHOOP's need (the demo's case: the card was not seen in the simulator, its rules are
  tested).
- **Stages (W28): no laboratory percentages.** The design's sentence about textbook shares of deep and REM sleep
  was dropped on purpose: the strap's estimate reads REM higher than a laboratory does (S3), so printing norms
  beside it would call an ordinary night unusual. Instead: "5m less than your usual" under the two headline
  figures, and "Tap a stage to compare it with your usual. Stages are estimated from heart rate and movement,
  so one unusual night means little." Ohayon 2004 was therefore not needed and not read.
- **Trend (W30):** hours and minutes everywhere, the average of the nights shown (finding F21), the change as a
  sentence (`SimpleDayPlan.nightlyChange`, the same halves the full view's chip compares).
- **Not done:** the stage card's "in bed / asleep %" line is unchanged (finding F20).

Tests: `SimpleSleepV6Tests` (8), each seen to fail with its rule broken (`break_step3.py`, kept in
`~/Library/Caches/noop-handbook/v6-step3/tools/`). 22 new strings in nine locales, one reworded, one removed.

### Step 4 as built (22 Nov, `feat/simple-mode` `88964c18`)

Built as designed, with these differences, each decided while building:
- **The verdict's sources.** From the rows the screen shows (`SimpleHealthRules.verdict`): "All clear" / "N
  readings are outside their normal range" with their names, plus, by case, the learning line (the slowest
  reading's valid nights, "6 of 14 nights so far"), the gap line (adult ranges again after more than 14 nights
  without wear, until the next night), and the illness line ("One reading off for a night is common. Several off
  together, or off for a few nights in a row, can be an early sign of illness or strain. Notice how you feel;
  Your day on Today says how hard to go. NOOP is not a medical device."). The illness line comes only for a
  reading outside the wearer's own normal or blood oxygen below its healthy range; a reading outside an adult
  range in the first nights gets "often just how you are" instead (S13). **When the illness watch has anything
  to say (any level above quiet), its own card is the verdict**, moved up from the skin-temperature section
  (`SimpleHealthVerdict`): the design said this for the active alert; it is extended to the calmer "a few signals
  are up" and "probably not illness" levels, because that card sat lower on the same screen and could contradict
  an "All clear". The card keeps its own words (shared with Today's banner), including "RHR +6": changing those
  labels would change the full view and the notification too.
- **A row's range is the band's own, not quartiles.** Step 2's score pages use the middle half of 30 days; the
  Health rows need "is this outside what is normal for me?", which the band already answers at 2 spreads (about
  95 % of the wearer's nights). So the row prints that band: `BodyVitalReading.normalRange` is built by
  `BodyVitalSigns.judgedRange` from the same history, config, fold and `VitalBands.sigmaK` as the tile's band,
  tested to agree value by value, and called "your normal range" (not "usual range", which step 2 uses for
  quartiles). Words: "In your normal range, 52–62." / "Above…" / "Below…", or "the typical adult range" while
  learning (blood oxygen always). Judged on the printed numbers. Amber only where the illness line would come.
- **Rows:** resting heart rate, HRV, breathing rate, blood oxygen, skin temperature; the raw SpO₂ counts stay in
  Show everything. A skin temperature shown as its change ("+0.1 °C") says "The change from your average skin
  temperature." under it; the absolute's secondary deviation stays in the full view. Two flags were added to the
  reading for plain empty states (`blankedByOverCount`, `isUnverifiedEstimate`).
- **Long-term estimates:** the design's "Right to within about 5 years" was **not** used: `displayBandYears` (±5)
  is a presentation constant and the model's own error is far wider (its comment: an SEE of 5–6 ml/kg/min over a
  0.3-a-year slope). The line says what Fitness age compares and that it is rough. "About the same as your age"
  and "about your age" are in the plain text colour in Simple mode (they were amber or green from a fraction of a
  year). The VO₂max estimator line ("On-device · Unknown") stays in the full view.
- **Stress:** the band words "Low / Medium / High" are kept (the design's), but the sentence is honest about
  size: it names only a reading that moved by more than 1 bpm or 1 ms the band's way (`SimpleStressRules.sentence`;
  the full view's "at or below baseline" could sit beside an HRV a few ms down) and High-with-both adds "One
  morning like this is common" (S12). The design's "Sleep, fluids and an easy day help" was left out (rule 4).
  The explanation names the import's average for an imported day (`WhoopImporter` stores its own stress formula).
  Marker comparisons are coloured only for a change of at least one 30-day spread (`SimpleStressRules.marker`).
  The trend offers Trends' six ranges and names the shown one ("Stress · Last 30 days"). The guide's Stress entry
  was corrected here rather than in step 6.
- **Not seen in the simulator:** the "Through the day" card (the demo has no heart-rate stream; its heading is a
  one-line branch), a real illness alert (drawn through a throwaway edit with a fake result, restored by sha256).

Tests: `SimpleHealthV6Tests` (18), each seen to fail with its rule broken (`break_step4.py`, kept in
`~/Library/Caches/noop-handbook/v6-step4/tools/`). 69 new strings in nine locales, two reworded in place.

### Step 5 as built (26 Nov, `feat/simple-mode` `5a527b2c`)

Built as designed, with these differences, each decided while building:
- **The week's chips** say the change in the score's own points ("4 higher than last week", "Same as last
  week", "Too few days to compare"), not the design's "6%" (a percent of a 0-100 score reads differently at
  40 and at 80). Judged on the two printed averages; coloured only when the engine also counts the metric as a
  mover (half its typical spread, three days each week); Effort never coloured. The Effort gauge prints whole
  numbers on 0-100.
- **The week's sentences** (`SimpleWeekRules.lines`): the engine's own biggest mover in plain words (an oracle
  test walks 800 weeks against `WeeklyDigestEngine.focalPoints`), then **training against Charge day by day**:
  each finished day's Effort against the range Today suggests for that day's Charge (`CoupledView
  .optimalStrainRange`, judged as Today judges it). The design's first sentence ("You trained harder this week
  than your Charge supported...") is **not** used: the engine's balance compares the week's average Effort with
  its average Charge, which called a week of Charge 50 and Effort 65 "leaning into the red" although Today
  allowed 48-67 every day (finding **F23**). Its "plan an easier day" was advice, against rule 4; the sentence
  now ends "Your day on Today suggests the range each morning." A week with no last week says so (**F24**).
- **"Over time"** heads the range picker and the charts. The picker spans its row; the caption is "A Charge on
  62 of the last 90 days."; each chart names its own window ("Last 90 days"). Each chart's footer: one verdict
  line by S14, what it means ("Higher is better: often a sign of rising fitness or better recovery."; Effort
  "Your days have been harder."), and Average (with the score's word) · Lowest · Highest. The design's
  "Change" column was left out: the verdict says the change, and a "+1" column beside "About the same" would be
  two readouts of one fact. **A Rest chart was added** so Trends answers "am I sleeping better?". The Charge
  chart says Charge is recovery against your own recent normal, not fitness.
- **Calendar strip:** "Charge, day by day", Low and High on its scale. **"Share this week"** at the foot.
- **Workouts, "Last 7 days" card first** (`SimpleWorkoutRules`): workouts and total time against the 7 days
  before; minutes of at least moderate effort by S15 against WHO's 150 (with the bpm thresholds it judges by);
  strength days against the guideline's two (the Lift Log's "Strength Training" counts; WHOOP's run-together
  names are split). Adults only (from 18).
- **One window for the card and the list (F25, found on screen):** the full view's ranges count back from the
  newest workout, so the card said "3 workouts" and the caption "4 workouts in the last 7 days". Simple mode's
  ranges now count calendar days ending today (`SimpleWorkoutRules.window`, later today included), the card's
  own window; the full view keeps its anchor. Simple mode offers the six ranges with Trends' labels (6 months
  added, Simple only; leaving Simple mode on 6 months falls back to 1 year).
- **Rows** "Thu 26 Nov · 53m · 287 kcal · 5.3 km" with "Effort 37"; clock times and heart rate stay on the
  workout's page. **Zones** in three words, each share summed from the percentages printed above it (rounded
  separately, 20 % and 4 % had become "23 % hard").
- **Not seen in the simulator:** an "Up" or "Down" verdict (the demo's months are steady; covered by tests),
  the guideline's "to go" wording and the adherence's "below" case (tests).

Tests: `SimpleTrendsV6Tests` (15), each seen to fail with its rule broken (`break_step5.py`, kept in
`~/Library/Caches/noop-handbook/v6-step5/tools/`). 91 new strings in nine locales (`make_spec.py`, same
folder); the window phrase carries its own preposition ("in the last 7 days") because the catalogue's existing
"the last 7 days" has none.

### Step 6 as built (27 Nov, `feat/simple-mode` `f62dc758`)

Built as designed, with these differences, each decided while building:
- **"How to read NOOP"** (`SimpleWelcomeSheet`, rules in `SimpleWelcome`, `Strand/Data/SimpleWelcome.swift`) is
  presented by the tab shell, not by Today: Today is drawn under the terms gate, the setup wizard and What's New,
  so its own `onAppear` fires while they cover it. The shell offers it when Simple mode is on, it has not been
  closed before (`noop.simpleWelcomeSeen`, set on dismiss), the first-run gates are done
  (`homeScreenQuickActionsEnabled`), Today is the tab in front and the app is active, and no other sheet or cover
  is up (UIKit's `presentedViewController`): then it waits, one look a second for at most a minute, because two
  presentations at once drop the second silently (the developer's morning check-in is a full-screen cover on the
  same shell). Seen in the simulator: What's New first, the welcome a second after it closed. The sheet reads no
  data: its "first two weeks" are the plan as bullets, and progress is said in one place only, Today's card. Its
  foot line says "While NOOP is still learning, Getting to know you on Today shows how far it has got", because a
  wearer past two weeks (Utku) has no card to find. WHOOP's three names come from the guide's `alsoCalled`; Rest's
  was "Sleep score" there and is now WHOOP's own "Sleep performance" (its export's column name).
- **"Getting to know you"** (`SimpleGettingToKnowYou`) counts nights with `SimpleWelcome.learnedNights`, the HRV
  baseline's own fold, which is the count `RecoveryScorer.calibrationNights` gates Charge on; Today's
  `cachedBaselineNights` now calls it too. Title "6 of 14 nights so far". The design's "After 7 nights: daily
  advice and your own sleep need" lost the sleep need: the personal need only ever rises above 8 h for long
  sleepers, so "your own sleep need" would promise most wearers something they never see (step 7 lets them choose
  one). The advice count is `SimpleWelcome.adviceNights` (7), pinned against `ReadinessEngine`'s private minimum by
  behaviour (6 nights of history: no verdict; 7: a verdict). Rest is ticked by the Rest ring as well, since a night
  can score Rest before its HRV counts. The card replaces step 1's "Early estimate" line (same window, same count;
  its string is gone) and "Your day" no longer repeats a count: "Advice for your day starts with your Charge, which
  needs 4 nights of sleep with the strap. Until then, go by how you feel." The foot says the Charge is an early
  estimate when it is (`SimpleDayPlan.earlyEstimateNights`, still the one rule). A brand-new wearer was seen:
  "0 of 14 nights so far" (the baselines exist from the first refresh, with zero nights).
- **More:** "My strap" is its own first group (`SimpleMoreGroup.strap`, no heading), a leaf observing the live
  state, opening Devices through `router.openDevices()`. Its caption ("Connected · 82%", "· charging", "Not
  connected") and Today's new low-battery line both read `LiquidTodayView.StrapBatteryDisplay`, the funnel the
  header ring draws from. Group captions: "How your body is doing right now." / "Your workouts and gym sessions." /
  "Alarms, reminders and breathing." (true with and without the heart rate warning row) / "Bring data in and keep
  it safe." / "What things mean, reporting a problem, and settings."
- **The header's battery** already prints the percentage inside its ring (`ChargeSyncIndicator`); not changed.
  **Not synced since** was **not built**, on purpose: a connected strap syncs itself, a disconnected one is said by
  the strap line, and on a WHOOP 5.0 or MG `LiveState.historySyncExperimental` can be true, where the line would be
  a false alarm daily. **Battery low** was built: "Strap battery low: 12%" with "Charge it soon so your next night
  is recorded.", at `BatteryNotifier.BatteryAlertPolicy.lowThreshold` (15 %, the notification's), not while
  charging, judged on the printed number.
- **The guide:** "Start here" first (opens the same sheet), then the new entries "Tonight's goal" (cap from
  `SimpleDayPlan.catchUpCapMinutes`; "falling asleep usually takes 10 to 20 minutes"), "Steps and active calories"
  (Paluch 2022 figures, already in Rules' sources) and "Normal, higher or lower than usual"; "Calibrating, Building,
  Solid" became "How sure NOOP is", its night counts read from the gates and "Earlier score" gone. Card titles that
  now open an entry: Today's Activity and Getting to know you, the Sleep tab's Tonight (with the earlier Your day,
  What's behind your Charge, Your sleep need, Health's rows and Stress).
- **Also:** the Sleep tab's empty state in Simple mode tells a new wearer what tonight brings and where WHOOP data
  comes in (More → All features → Data Sources) instead of "open Intelligence", a screen Simple mode does not list.
  Alarms says "NOOP will tell you when to start getting ready for bed." "Confirmed on WHOOP 4.0" (W46) stays: it
  is true, and nothing yet confirms the strap alarm on a 5.0.
- **Not seen in the simulator:** the low-battery line (no strap; its rule is tested) and the Tonight card's info
  button on the Sleep tab (the demo's imported need hides the card, and a new wearer has no night yet).

Tests: `SimpleWelcomeV6Tests` (12), each seen to fail with its rule broken (`break_step6.py`, kept in
`~/Library/Caches/noop-handbook/v6-step6/tools/`). 52 new strings in nine locales, one removed (`make_spec.py`,
`make_spec_b.py`, same folder; `missing_keys.py` lists the keys a build extracted that the catalogue lacks).

### Step 7 as built (27 Nov, chat 10, `feat/v6-step7-and-feedback` `280929e6` + fix `38e73acc`)

The decision recorded in "Next chat begins here" was taken as recommended: **one need moves the Rest score
too.** Built on both platforms:
- `Rest.resolvedNeedHours` / `RestScorer.resolvedNeedHours`: the wearer's choice (`normalizedChosenNeedMinutes`:
  0 = Automatic, else the nearest 15 minutes from 7h 0m, `chosenNeedMinMinutes`, to 9h 30m) or the automatic
  need with the age. Oracle FNV `438d833811016adb` (Swift `RestNeedTests`, Kotlin `RestResolvedNeedTest`).
- S1c: `populationNeedFloorHours` 7.5 h from 65; a cold start returns the age target itself (it used to return
  max(8, target), so 65+ cold-started at 8).
- The engine resolves the need once per pass and keeps the automatic figure for the screens: Swift
  `SleepNeed` (UserDefaults `sleepNeed.automaticHours`; the choice is `profile.sleepNeedMinutes`), Kotlin
  `com.noop.ui.SleepNeed` (prefs `noop_profile`, the automatic need kept as the Double's bits so screens read
  the engine's exact value). Every Rest composite the app computes passes the need: the stored
  `sleep_performance`, the recompute helpers, Coupled, the Sleep tab's performance, the weekly digest, the
  explore series, the Rest page's breakdown ("Full marks at"). The debt (`debtNeedMin`) reads it too, and the
  wind-down reminder follows the Sleep tab's need (#2906's `adoptSleepNeed`), so all of them agree.
- Kotlin: `RestScorer.composite(daily, needHours, consistency)` is the paired twin of Swift
  `Rest.composite(daily:needHours:consistency:)`; `restFromDaily` had no production caller left and was removed
  (tests moved). `analyzeRecent` takes `chosenSleepNeedMinutes` and `persistAutomaticSleepNeed`; the resolution
  sits in `resolveSleepNeedForRun`, outside the JaCoCo-budgeted `analyzeRecentOnCpu`
  (`IntelligenceEngineJacocoBudgetTest`). Both are recorded `out_of_scope_twin` dispositions.
- The choice: Settings "Sleep need" on both platforms (iOS `SleepNeedSettingValue`/`SleepNeedMenu`, Android a
  stepper through the same choices with `AppViewModel.chooseSleepNeed`); on iOS also "Change" on the Sleep tab's
  "Your sleep need" card, which now says "You chose this yourself..." or the age-true target (from 65: 7 to 8
  hours; under 18: 8 to 10). `.noopbak` key `profile.sleepNeedMinutes` (Int) on both platforms.
- What moves: Rest for a need other than 8 h. Utku (18 to 64, fresh start) is unchanged until he chooses.

Learned: the parity ledger pairs twins through "twin" notes in doc comments (`Kotlin twin: \`X\``); an added
parameter changes a Kotlin identity (name/arity), so an existing pair breaks; a computed `var` range counts as a
property, two `static let`/`const val` constants pair cleanly; `--refresh-derived --base origin/testing-stack`
prints exactly what it objects to. Android's `analyzeRecentOnCpu` has an exact bytecode budget: keep new logic
in a helper.

### Chat 10: Utku's feedback of 27 Nov (sleep, check-in, steps)

His report: the check-in offered in the middle of the night, "Not now", then nothing in the morning; NOOP
marking him asleep while he lay in bed awake (asleep about an hour later than NOOP said), missing naps, brief wakes; steps not
precise though he does not always carry the iPhone; sleep must be scientific and realistic. Built:
- **Sleep onset** (`d232ee7e`, both platforms): `SleepStager.applyPersistentOnset`, the first 10 minutes of
  unbroken staged sleep (the clinical latency to persistent sleep, chosen before measuring). Measured with the
  new `Tools/SleepPSG --section onset` on PhysioNet sleep-accel (31 PSG nights, latency 2 to 41 min): the
  night's start was 15.5 min before PSG onset on average (MAE 15.5, 19/31 within 15 min), the persistent onset
  9.2 (bias -8.1, 25/31); total sleep +22.3 -> +20.7 min. 15 min scored MAE 8.0 and was not taken (not fitted).
  Heart rate fell only 2 bpm (median) from quiet wake in bed to the first 20 min of sleep, so it cannot place
  onset; long quiet wakefulness stays the wrist's limit (latencies 36 and 41 min still 24 and 33 min early),
  which is why the check-in's correction exists.
- **"Fell asleep / Woke"** (`3df198c4`): `SleepClockTimes` (iOS) and its Kotlin twin give in bed, fell asleep,
  woke (the end of the last sleep stage: 5.5 min after PSG's final awakening at the median, against 12.8 for
  the moment movement resumed) and up; "In bed from .. to .." under the row. Brief wakes were already bridged
  into one night (under 60 min, 90 overnight, `SleepStageTotals.bridgedNightGroups`); the check-in now uses it.
- **The check-in** (same commit): Not now = ask again in 60 min; Skip today; not before 90 min ahead of the
  usual wake (median of recent nights, from three); a Test Centre button to answer now; "Wrong" opens time
  pickers that correct the night through the Sleep tab's edit path (a sleep diary beside the strap, Smith et al.
  AASM actigraphy guideline 2018).
- **Steps** (`0969167a`, iOS): `StepCalibration` learns the divisor from 15-minute windows where the phone
  and the strap both saw walking (median of at least 8, ratio 0.5 to 3, consistent), once a day; the phone is a
  measuring stick only (Case et al., JAMA 2015: phone apps -6.7 to +6.2 %, wrist devices -22.7 to -1.5 %).
- **Naps** (after the first build, `5bd5b4e9` + `c12a86ff`, iOS): daytime naps under 90 min were never
  detected (any run needs 60 min; daytime-centred runs 90 min plus an HR dip). The Swift `NapDetector` twins
  Android's review-card detector (oracle FNV `88d66a6214fd4b33`); `NapQuestions` looks at the day's recent hours
  (overlapping 3-hour windows centred 09:00 to 21:00, ended 20 min ago, skipping recorded sleep) and a quiet run
  of 20 to 90 min within 8 bpm of the resting band becomes "Did you nap from .. to ..?" on the Sleep tab; Yes adds
  it through `Repository.addManualNap`, No forgets it, nothing is added without a Yes. Thresholds are Android's
  defaults; tune them on Utku's file.

### Chat 11: the rest of Utku's 27 Nov prompt (wake, regularity, REM, S12, S13)

All on `feat/v6-step7-and-feedback` (folder `~/Developer/noop-v6b`), each measured before it was built:
- **Wake inside the night and the final awakening** (`a1a9d3c2`, helpers as closures `002388ca`, both
  platforms): new `Tools/SleepPSG --section waso` splits the detection's extra sleep against PSG (sleep-accel, 31
  nights): +20.8 min a night = 7.8 before onset + 14.8 of wake inside the night called sleep + 3.7 after the final
  awakening - 5.6 of sleep called wake; NOOP found 27 % of the wake inside the night and 69 % of what it missed had
  no wrist movement at all (the wrist's limit). `SleepStager.applyWakeRescoring`, applied after
  `applyPersistentOnset` on every staging path (motion, its band-veto shadow, heart rate only): Webster's
  rescoring rules (Webster et al., Sleep 1982; parameters as restated by Fisher, arXiv 2104.14291: after 4/10/15
  min of wake the next 1/3/4 min of sleep are wake; a sleep run of 6 min or less inside 10 min of wake on both
  sides, or 10 or less inside 20, is wake; not cascading), then the night ends at its last 10 min of unbroken
  sleep. Per subject: kappa better 24, worse 3 (0.401 -> 0.439), total sleep +20.8 -> +18.5 min, "woke" median 5.5
  -> 1.0 min after PSG's final awakening (mean 14.3 -> 10.8), "fell asleep" MAE 9.2 -> 8.6; 5 or 15 min give the
  same; one subject already under-stated -14.5 -> -17.5. Heart-rate-only staging: no change on these nights.
  Measured and not taken: letting heart rate alone call wake on a still wrist (kappa better 15, worse 13). Oracle
  FNV `2414143cc0221255` (Swift `SleepWakeRescoringTests`, Kotlin `SleepWakeRescoringTest`); the section's port
  check: `detectSleep` equals the tool's epoch rules on 31 of 31 nights.
- **S11, regularity** (`3ff95086`, both platforms): `SleepRegularityIndex.compute` is the Sleep Regularity Index
  (Phillips et al., Sci Rep 2017; median 81 in 60,977 UK Biobank adults, Windred et al., Sleep 2024), minute by
  minute from the stored sessions (nights and naps, noon-to-noon windows in the wearer's zone) over the last 7
  pairs of consecutive days; a day counts when its longest sleep lasts 3 h, a pair when both days count; it needs
  4 pairs (Fischer et al., Sleep 2021: stable with up to half the data missing at random). The Rest part is the
  index on its own scale (`consistency` = index / 100, clamped), neutral before 4 pairs. The engine computes it in
  `computeHabitualSleep` from the same deduplicated sessions and keeps it (`SleepRegularity`: iOS UserDefaults
  `sleepRegularity.index`, Android prefs `sleep_regularity_index_bits`), and every `Rest.composite(daily:)` /
  `RestScorer.composite` on both platforms passes it, so stored and shown Rest agree (it replaced 1 - CV of sleep
  durations, which measured length, not timing). The Rest page: "Your regularity over the last week: N of 100.
  Most adults score around 80; ..." or "Measured after about 5 nights in a row with the strap on ..."; the guide
  says the same (nine locales). Oracle FNV `3a8a2d067deb0bf6` over 3,000 histories (Swift
  `SleepRegularityIndexTests`, Kotlin `SleepRegularityIndexTest`); `SimpleScorePageTests` pins the parts adding up
  for measured and neutral regularity. Not changed: Vitality's regularity input (still the duration proxy).
- **REM** (measured only): `--section baseline` on sleep-accel: REM 26.4 % of the night against 21.3 % (per-subject
  means), 27.5 % of sleep against 23.5 %. The 1 Oct attempts (Backlog C) did not transfer between sleep-accel and
  DREAMT, DREAMT is not on this Mac (restricted; only Utku can download it), so no change; Utku's own file decides.
- **F17** (`901c4b4a`): the classic Today's Charge sheet and the Coupled screen fed the Charge breakdown's Rest
  row the Rest now on screen while its other rows describe a carried day; they now read the row's own night
  (classic Today keeps each day's Rest from the same merged series, also in its day snapshot; Coupled scores the
  row by its own rule). Simple mode already did (`SimpleScoreRules.chargeRowRest`). The upstream PR waits (Phase C).
- **S7** (`2c638a91`): per-workout zone minutes from the strap's own heart rate already existed (`Repository.
  workoutZoneMinutes`, #856); what remained was the "Last 7 days" card judging each workout whole by its average.
  It now counts each workout's minutes at moderate (64 % of the maximum) and vigorous (77 %) effort from its own
  readings by `HRZones.timeInZone` (a two-band zone set), the average only for a workout without readings; one
  read (`Repository.weekEffortMinutes`) feeds the card and the developer export; read only in Simple mode.
  `SimpleTrendsV6Tests` pins 10 easy + 5 moderate + 5 hard minutes counting 5 and 5 (seen to fail).
- **F12** (`d6114ca3`): the Stress screen computed the Baevsky index and the Lomb-Scargle HRV over the whole day's
  R-R on every open, also in Simple mode, which hides them: 0.03 / 0.06 / 0.08 s CPU for 8 / 14 / 20 hours of
  beats (33,638 / 58,865 / 84,091 R-R; this Mac, release, `chat11/bench`). Simple mode now stops after the
  timeline; "Show everything on this screen" re-runs the load (task id carries `simpleMode`). Simple Today's extra
  reads are a few stored daily series, so nothing changed there. No test (a view's load); built and read.
- **S3** (research only, not changed): Rest gives the restorative part full marks at deep + REM = 50 % of sleep
  (`Rest.restorativeTarget`). PSG norms (Ohayon et al., Sleep 2004;27:1255-73, 65 studies, 3,577 people): slow-wave
  sleep falls about 3 points per decade from about 40, REM stays near 20–25 % until about 60, so a healthy
  share of deep + REM is roughly 35–50 % for young adults and lower later in life. NOOP's estimate reads REM about
  4–5 points high on sleep-accel (deep is calibrated), which today pushes a typical night toward the target, so
  lowering the target now would double-count. Decision: keep 0.5; once REM's share is checked on the owner's nights, set
  an age-aware target from Ohayon's tables (read them in full first) on both platforms.
- **S12** (Stress bands): unchanged; it needs the share of High mornings on real nights (his file). A candidate
  to test then: standardise the combined deviation by its own spread in the wearer's history, so "High" means
  the same tail for everyone.
- **S13** (adult ranges before 14 nights): unchanged on purpose. Quer et al., PLoS ONE 2020 (92,457 Fitbit
  wearers): 95 % of men 50–80 bpm, women 53–82, but Fitbit's resting HR is a daytime-like value ("supine
  immediately after waking"), while NOOP's is the night's lowest 5-minute mean, several beats lower: using it would
  call fit wearers low. Natarajan et al., Lancet Digit Health 2020 (nightly RMSSD by age) was not retrievable here
  (HTTP 403). Simple mode is calm while learning; after 14 nights the wearer's own normal decides.

## Ground rules and how to work

**Goal** (Utku, 4–6 Nov 2026; rule in [Rules](../RULES.md#settled-decisions)): a calm, correct, efficient NOOP
that a first-time WHOOP wearer understands. Nothing important is lost: Simple mode is the calm view, Settings →
Simple mode off (or More → All features) shows everything. Utku hands over all operational work: decide, build,
verify, ship; never ask him routine questions (Rules, 6 Nov). He tests on a WHOOP 5.0 and an iPhone (AltStore, "just
update"). 6 Nov: "I hate that the original looks like AI slop" — design carefully what to show, hide and emphasize.

**Lift Log stays fully available in Simple mode (Utku, 6 Nov night; rule in [Rules](../RULES.md#settled-decisions)).**
His own feature (gym sessions with records and taps, merged upstream). Never hide, shorten or restyle any part of it
in Simple mode. Checked 6 Nov: More → Training → Lift Log (Simple list, `RootTabView` `MoreRow(.liftLog)`) and All
features; `LiftLogView` has no Simple-mode branch; the active-session bar (`LiftSessionBar`) sits at the app root in
both modes; Settings keeps "Lift Log session" (Live notifications) and the lifting-friendly Effort switch (Banister,
in Units) open in Simple mode. Only cosmetic difference: Simple Workouts hides every row's source badge, so a lifting
row no longer says "Lifting" there (one line to bring back if he wants it). The guard test exists since 12 Nov (`SimpleModeTests`).

**Where things are:** branches, folders, the testing stack and the phone build are listed once, in
[State](../STATE.md). Simple mode lives on `feat/simple-mode` (folder `~/Developer/noop-simple`); the heart rate
warning on `feat/high-hr-warning` (folder `~/Developer/noop-hrwarn`), which contains `feat/simple-mode`.

**How to work (what the chats learned):**
- Build: `xcodegen generate`, then `git checkout -- StrandiOS/Resources/Info.plist` (until #2898 merges);
  `xcodebuild -scheme NOOPiOS -destination 'platform=iOS Simulator,name=iPhone 18 Pro' CODE_SIGNING_ALLOWED=NO build`;
  full tests: `-scheme Strand -destination 'platform=macOS' test` (2377 on the branch and 2430 on the stack
  after step 3).
- Python tools need `/opt/homebrew/bin/python3.12` and a canonical `TMPDIR` (`export TMPDIR=$(realpath "$TMPDIR")`).
  Gates before any commit: `Tools/i18n_audit.py --ci upstream/main`, `Tools/doc_comment_lint.py`,
  `python3.12 -m unittest discover -p "test_*.py"` in `Tools/` (includes `tests.test_parity_governance_acceptance`).
- Translations: every new English string needs all nine locales (de/es/fr/pt-PT hard gate; it/pl/ru/zh ratchet; an
  English echo fails). Insert one-line JSON entries after `"strings": {` with a small script (count `%@`/`%lld`;
  use positional `%1$@` where word order changes, e.g. zh); merge catalogue conflicts by key with
  `dist/tools/xcmerge.py`. A `Text(verbatim: "\(a)–\(b)")` literal is flagged as un-extracted copy: build such
  strings in a helper (`SimpleDayPlan.rangeText`).
- Rule 11 bites: a test helper named like ANY production function (same name + arity, any package) moves the parity
  baseline (`instant(_:_:_:)` vs `GarminExportParser.instant`). Prefix test helpers (`tonightFixture…`).
- Doc comments: insert a new declaration ABOVE a neighbour's doc/`//` comment, never between it and its line.
- Simulator: `xcrun simctl launch "iPhone 18 Pro" com.noopapp.noop --demo-seed` seeds 120 days ending that day
  (uninstall first to reseed); relaunch to see data. Launch args set prefs for one run: `-noop.simpleMode NO`,
  `-windDown.enabled YES -windDown.wakeMinutes 420`. The screenshot can lag one action: wait, shoot again.
  Coordinates are points (screenshot px ÷ 3). The demo carries WHOOP-imported sleep needs (7h 16m).
- Phone build: add commits to the stack as a fast-forward (cherry-pick onto `origin/testing-stack` in a scratch
  worktree, verify iPhone Release build + StrandTests + gates, push), then `testing-build` by the merge-commit route
  ([Workflow §6](../WORKFLOW.md#6-builds-for-utkus-phone)), dispatch "Testing build (fork)", verify release target,
  five assets, IPA HTTP 200 and a new string in the IPA's `de.lproj`. The macOS leg takes ~25–30 min. A superseded
  running build may be cancelled (`gh run cancel`) and replaced by one combined build.
- Android is tested on the fork only: `gh workflow run "Android CI" --ref <branch>` (push does not trigger it).
- Safety-check limits on this Mac: force-push and `git commit --amend` of a pushed commit are refused (build a clean
  branch with `git merge --squash` instead); `gh pr create`, close/reopen and the Auto-fix switch need Utku's yes in
  chat (permission rules `Bash(gh pr create:*)` etc.); `sleep N; cmd` chains are refused (use an `until` loop or a
  background job). In zsh write `"${VAR}:refs/…"`.
- Foundation's `String(format:locale:)` rounds ties half-to-even (finding 16): round half away from zero first for
  any one-decimal figure shared with Android. Verify citations before writing them.
- **Since the architect chat builds (v6, 16 Nov):**
  - Strings: write a small spec and run `dist/tools/xcstrings-add.py` (adds one-line entries, rewords one in
    place, drops one; it checks all nine locales, the placeholders and English echoes, and never reformats the
    catalogue). A heading passed through a variable (`sectionHead("TODAY'S WORKOUTS")`) is not extracted by the
    compiler and exists only because the catalogue holds it.
  - Simulator: `dist/tools/sim-shot.sh <name> [wait]` gives a half-size screenshot (points = its pixels ×
    0.6526). The demo seed needs about 45 s on a busy Mac before the relaunch. The tap tool opens tabs, rows and
    buttons but not the score rings (a `NavigationLink` with `LiquidPressStyle`) or switches: use a launch
    argument, `--demo-screen <name>` (DEBUG, `DemoScreens.requested` in `StrandiOSApp`), or read the route in
    code and say that it was read, not seen.
  - Seen to fail in one run: copy the changed files to a scratch folder with their sha256, break every new rule
    at once with a script (one break per test), run `-only-testing:StrandTests/<Class>`, restore the copies,
    `shasum -c`. For a changed behaviour, run the new tests against the old file (`git show <base>:<path>`,
    plus any new parameter the tests call).
  - A SwiftUI `Group` with nothing inside has no view for `.task` or `.onAppear` to run on; use a zero-spacing
    `VStack` (the strap line never appeared until this was found on screen).
  - Stacking a step: `git worktree add -b tmp/stack-<step> <folder> origin/testing-stack`, cherry-pick the
    step's commits; for the catalogue conflict write `git show :1:` / `:2:` / `:3:` to three files and run
    `xcmerge.py`; `NOOP_REPO=<folder> bash dist/tools/verify.sh` (commit first; about 25 minutes); a Release
    build for `generic/platform=iOS` with the workflow's flags; `git push origin <tip>:refs/heads/testing-stack`
    (a fast-forward) and `git branch -f testing-stack <tip>`; then `testing-build` by the merge-commit route
    (Workflow §6), `gh workflow run "Testing build (fork)" --ref testing-build`, `gh run watch` in the
    background (about 30 minutes, the Mac leg last; the `.ipa` is attached after about 15), the release checks,
    and a new string in the downloaded `.ipa`'s `de.lproj`. Remove the scratch worktree and its `tmp/` branch.
  - One build or test run at a time on this Mac. The Mac tests open "NOOP Staging" on Utku's screen.
- **Learned in chat 6 (steps 2 and 3, 16 Nov):**
  - Opening a score page in the simulator: `xcrun simctl launch "iPhone 18 Pro" com.noopapp.noop
    --demo-open-score charge|effort|rest` (DEBUG; it hands over the ring's own snapshot once Today has a score).
  - What the demo cannot show: its nights are imported from WHOOP (so the Rest page's four parts and the
    "Tonight" goal are hidden by their own rules), it has no heart-rate stream and no workout today. See such a
    state through a throwaway edit, with the file copied aside and restored by `shasum -c`, and say so.
  - Keep helper scripts and string specs in `~/Library/Caches/noop-handbook/<step>/tools/`, never in the
    chat's scratch folder under `/tmp`: a pause or restart clears it (step 2's break script was lost that way).
  - `WindDownNudge` is `@MainActor`: a resolver that reads it, and its tests, need `@MainActor` too.
  - `xcstrings-add.py` refuses a translation equal to the English key: French "Effort %@" had to become
    "Effort : %@".
  - After a long pause the simulator is shut down: `xcrun simctl boot "iPhone 18 Pro"` then
    `xcrun simctl bootstatus "iPhone 18 Pro" -b`. `git rev-parse --short` takes one ref at a time.
  - A phone build run takes about 25 minutes on GitHub (16 Nov: 10:31 → 10:55 UTC); the `.ipa` is attached
    after about 14. Build the next step locally while it runs.
  - Design rule added by use: compare a number with the wearer's usual RANGE, not one usual value, wherever
    "is that normal for me?" is the question (step 2 as built).
- **Learned in chat 7 (step 4, 22 Nov):**
  - The Mac's time zone moves with Utku: on 16 Nov the tests ran in a zone without summer time, on 22 Nov in
    a summer-time zone, where a step 1 date test failed. Count whole days on a UTC calendar, and pin a summer-time
    zone in any test that differences days (`NSTimeZone.default = TimeZone(identifier: "Europe/Berlin")`,
    restored in `defer`; `Calendar(identifier:)` follows it).
  - A private SwiftUI section with `@State private` properties has a private memberwise initializer: to pass a
    new flag (`VitalsSection(simple: true)`), add an explicit `init`.
  - A modifier on a `Group` is applied to each child: `.task` on a two-child `Group` runs twice. Use a `VStack`.
  - A leaf that observes `AppModel` re-renders on every heart-rate tick: keep it to a few lines
    (`SimpleHealthVerdict`, like `HealthAlertBanner`) and leave the heavy section depending on `repo` only.
  - `--demo-screen health` and `--demo-screen stress` open those screens directly in the simulator.
  - Waiting for a long job: let its background notification arrive. A shell loop without a pause spins a core,
    and `pgrep -f` on a pattern in its own command line finds itself (Workflow §3 says so too).
  - The phone build's two commits can be made without touching any worktree:
    `git merge-tree --write-tree --merge-base=<template>^ <stack> <template>`, `git commit-tree` for the template
    commit on the stack, then the merge commit over `origin/testing-build` (Workflow §6).

- **Learned in chat 8 (step 5 and the developer loop, 26 Nov):**
  - Two readouts can disagree through their *windows*, not their maths: Workouts' card counted calendar days,
    its range picker counted back from the newest workout, and the screen said 3 and 4 workouts for the same "last
    7 days". Give both readouts one window function and test the shared function.
  - A sum on screen must be built from the printed parts: zone shares rounded as groups (23 %) disagreed with
    the per-zone figures printed above them (20 % + 4 %).
  - An oracle walk only pins what its inputs reach: 600 random weeks left the 0.5 mover threshold unpinned
    (moving it to 0.6 passed) until half the weeks were drawn near the bar. Break the constant and watch the
    oracle fail before trusting it.
  - `repo.sleeps` (and other `@Published` caches) can be empty when a root `.task` runs at launch; read the store
    (`sleepSessions`, falling back to `computedSleepSessions` for a strap-only wearer).
  - Anything offered "once a day" must be gated on the scene being active: iOS wakes NOOP in the background for
    syncs, and a background launch would use up the day's offer unseen.
  - The catalogue's existing "the last 7 days" has no preposition in any language; a phrase built into a
    sentence carries its own ("in the last 7 days") so each language can choose its case.
  - `Text(cond ? "A" : "B")`: write two `Text`s in an `if`, so both literals are extracted and localised.
  - On the stack, our open upstream PRs move code (#2901 moved Trends' range bar): a conflict there is resolved
    in the stack's new order, the branch keeps its own.

- **Learned in chat 9 (step 6, 27 Nov):**
  - Today is drawn under the terms gate, the setup wizard and What's New (`StrandiOSApp` overlays them in a
    `ZStack`), so its `onAppear` and `.task` run while they cover it. A once-only sheet belongs to the tab shell,
    gated on `homeScreenQuickActionsEnabled` (the root's "first-run gates done").
  - Two presentations at once drop the second silently. Before presenting, look at UIKit's key window
    `rootViewController?.presentedViewController` and wait it out (`RootTabView.anotherSheetIsUp`).
  - A brand-new wearer in the simulator: `simctl uninstall`, `install`, then launch with `-noop.onboarded YES
    -noop.acceptedTermsVersion 2.0`. What's New shows first (it tests sheet ordering), then a 0-night Today. The
    demo seed is gone after that; reseed with `--demo-seed` (about 45 s) before a demo walk.
  - The i18n gate's list can miss keys the compiler extracted; `v6-step6/tools/missing_keys.py <catalogue>
    <file.stringsdata>…` lists every extracted key the catalogue lacks (the `.stringsdata` files sit in the build
    folder's `Objects-normal/arm64`). Literals returned as `LocalizedStringKey` from a function are extracted.
  - Russian night counts: an ordinal ("после 4-й ночи") needs no plural form; German, French, Spanish, Italian,
    Polish and Portuguese plurals are safe for counts of 2 and more.


- **Learned in chat 11 (the final build, 27 Nov):**
  - The parity ledger counts NESTED functions (a Swift `func` inside a function, a Kotlin local `fun`) as
    functions that need a twin: write such helpers as closures (`let span: (Int) -> Int = { ... }`, `val span =
    { r: Int -> ... }`), then `--refresh-derived --base origin/testing-stack`.
  - Android's budgeted `analyzeRecentOnCpu` stayed within budget by replacing a call with a field the history
    helper sets (`regularityConsistencyForRun`), and by passing an argument instead of using a default
    (`composite$default` costs more bytecode than the direct call).
  - Changing a tuple a test destructures (`computeHabitualSleep`) breaks the Mac test target only: the package
    tests and the iOS build pass, so `verify.sh`'s macOS step is the one that finds it.
  - The simulator's demo data has no strap heart rate, so the engine's pass ends within a second: values the
    engine stores for the screens (`sleepNeed.automaticHours`, `sleepRegularity.index`) never appear there.
    Prove them with unit tests (here `HabitualSleepFinishedNightsTests`) and say so.
  - `Tools/SleepPSG --section waso` and `onset` run the shipped `detectSleep` end to end; a port check row
    (the tool's own rules against the shipped function, night by night) is what proves the app applies a rule.

### Audit verdict (12 Nov, the whole Simple mode diff read against the goal)

The work is sound: presentation only, every number from the code the full view uses, one resolver per fact
(sleep need, Effort range, Tonight times), tested, and the full view untouched. The Lift Log is whole. One real
gap and three smaller ones:

- **F15 (the real gap, fork, fix first): hidden things are NOT one tap away.** Every simplified screen reads the
  one global switch, so the parts it hides can only be seen by turning Simple mode off for the whole app. That
  includes working tools, not just extra charts: Trends' PDF export and training-load chart, Workouts' filters,
  search and multi-select (merge, bulk delete), Sleep's manual sleep marks and body clock, Stress's Advanced HRV,
  Health's records and sources links, Today's Customize. Opening one of these screens from More → All features
  shows the simplified screen again, so the caption there, "Every screen and tool, exactly as before.", is not
  true. This breaks the project's own rule ("the detail one tap away") and Utku's ("nothing important lost").
  Fix: step 1 below.
- **F16 (UPSTREAM candidate, iOS):** the "Enable wrist alerts" help says "Off keeps the strap quiet no matter
  what else is on", but HR-zone coaching (`AppModel.coachZone`) buzzes without reading that switch. Say what the
  switch really covers, or make it cover everything. Read in code only; not checked on a strap.
- **F17 (done in the fork, chat 11 `901c4b4a`; upstream PR waits):** when the Charge ring carries an earlier day, the "What's behind your Charge"
  rows come from that earlier day but the "Rest" row is fed the Rest score now on screen
  (`ChargeBreakdownWiring.breakdown(… row: priorScored ?? day, sleepPerfPercent: restScore)`), which can be a
  different night. Check what the classic Charge sheet passes; if it is the same, it is an upstream candidate.
- **F18 (upstream, low):** `LiveSessionRunner` says it ticks on every heart-rate reading in the background, but
  the reading is published only when its value changes, so a steady heart rate gives it no tick. Found while
  designing the high heart rate warning; relevant only to Live Sessions (beta).
- **Not yet seen on a real phone.** All of Simple mode has been checked in the simulator only. Rule 12 says real
  use finds what matters: Utku's first days with it outrank every list here.

### The roadmap (architect, 12 Nov; updated 15 Nov)

How the work is done: until 14 Nov the architect chat planned and reviewed while Opus 5.5 worker chats wrote the
app code (Rules, 12 Nov). **Since 15 Nov the architect chat builds v6 itself** (Utku: "no subagents you do the
work only!"). Nothing reaches the phone before it is verified as a worker's change would be. One build and test
run at a time on this Mac.

**Phase A — done 12–14 Nov:** "Show everything on this screen" (F15, `a639d47a` `258e0bf2`), the high heart rate
warning (`f80aadc6`, [checked on the strap](high-hr-warning.md#12-hardware-evidence-utkus-whoop-50-12-and-14-nov)),
both reviewed, on stack `25aa5f38` and phone build `218aec72`. The brief and specification are in the
[diary](simple-mode-diary.md#round-7-12-nov-2026-show-everything-on-this-screen-report-a-problem-lift-log-guard).

**Phase B — Simple mode v6, the most user-friendly NOOP:** designed 15 Nov ([Design v6](#design-v6-the-most-user-friendly-noop));
built in the seven steps of [its build plan](#the-build-plan-one-step-at-a-time), by the architect chat itself
(Utku, 15 Nov). It takes in what was queued here: the first-run screen (step 6), F17, the warning's W1 (step 1;
W2 if wanted), and F12 (do not load what Simple mode does not show, measured first, Workflow §11) whenever a step
touches that loading. Whatever Utku reports from the phone comes first.

**Phase C — upstream, only when it is active again** (check at every Start; do nothing while it is quiet)
- Answer any maintainer comment once; rebase #2747/#2724 only when a maintainer engages.
- Then, one small PR each, a few at a time: F1 + F13 together (both platforms), F2, F3, F5, F6, F16, F17 (the
  classic Charge sheet's Rest row for a carried night), F21 (the sleep trend's average), the redundant "Settings"
  overline. S11 (the Rest score's fixed night and unmeasured regularity) is an issue first: it moves every Rest
  score.
- The high heart rate warning: an issue first, with the phone evidence.

**Phase D — Android and the proposal:** Android twin of Simple mode + `noop.simpleMode` in the `.noopbak`
whitelist on both platforms, then propose Simple mode upstream, default OFF (#2463). Only after v6 settles and
upstream is active; nobody here can test Android on a strap, so every Kotlin change runs in fork CI and says so.

**Phase E — measurement quality:** F11 audit (one-decimal figures by twin oracle), then the Backlog biometric
queue (evidence first, Rules 2–3).

## Design v5: the calm NOOP (chat 2's plan, 6 Nov)

What is on the phone today, and the base v6 builds on. Where [Design v6](#design-v6-the-most-user-friendly-noop)
says otherwise (names, captions, where a tap leads, what a screen says first), v6 wins.

**How a regular wearer uses a WHOOP band** (physician + coach view): in the morning they want to know whether
they recovered and how hard to go today; after training, how hard it was; in the evening, when to go to bed;
over weeks, whether things are improving; and, rarely but importantly, a warning when the body looks off
(illness signs, a strap problem). Everything else is detail for the curious.

**Rules for Simple mode** (apply to every screen):
- Lead with the answer, then the reason, then the detail one tap away. One number per fact; one name per thing
  (Charge / Effort / Rest, with Recovery / Strain / Sleep as small captions).
- Compare with "your normal", not raw numbers alone; say whether higher or lower is good.
- Warnings first (health alert, strap off or disconnected, active workout). Old data carries its date; missing
  data is a dash, never a zero; never claim what was not measured (AGENTS "a diagnostic may only assert…").
- No lab metrics, provenance, betas or duplicate cards in Simple mode; they stay in the full view and All
  features. Short sentences, but complete: what it is, whether it is good, what to do.
- Simple mode should also do less work: do not compute what it does not show (measure before claiming).
- **Whatever a screen hides is one tap away on that same screen** (12 Nov, F15): each simplified screen ends
  with "Show everything on this screen". Hiding a working tool behind the app-wide switch counts as removing it.

**Show / emphasize / hide, screen by screen** (✓ done, → next):
| Screen | Show and emphasize | Hide in Simple (still in full view) |
|---|---|---|
| Today | ✓ rings + captions (dates on carried Charge/Rest), ✓ "Your day" (verdict + suggested Effort range + progress), ✓ sleep card (Last night + Tonight), ✓ top-3 Charge readings | ✓ Key Metrics, Your Cards, Start session beta, Data sources |
| Sleep | ✓ score, hours vs need (one resolver with Today), night card, debt ledger in words, trend (Tonight lives on Today) | ✓ sleep marks, body clock, stages vs typical, Night detail tiles |
| Trends | ✓ score trends, Average below its range | ✓ CTL/ATL/TSB, PDF export |
| Stress | ✓ level, markers vs your normal, day timeline, trend, guide link | ✓ Advanced HRV, method card |
| Health | ✓ sync, heart rate, vitals, skin temp, Fitness Age, Vitality | ✓ recovery contributors (duplicate), records/sources links |
| Workouts | ✓ Start/Add, range, one summary card, sessions, zones in words | ✓ filters/search, Current/Archived, multi-select, stat tiles, 13-week calories, breakdown, HR-recovery trend, source badges |
| Settings | ✓ Simple mode, Profile, Units, Strap, Live notifications | ✓ "More settings" (Appearance, Streak, Features, Sync), Advanced (unchanged), "Settings" overline |
| Alarms | ✓ plain strap-alarm evidence (`0a6f3021`) | the capture method and issue number |
| Lift Log | **everything, always** (Utku's rule, 6 Nov) | nothing, ever |
| Live, Breathe | unchanged | — |

**The suggested Effort range** (step 1): NOOP already has an approved, presentation-only mapping,
`CoupledView.optimalStrainRange(recovery:)` (byte-identical with Android's `optimalStrainRange`): Charge ≥ 67 →
14–18, 34–66 → 10–14, < 34 → 4–10 on the 0–21 axis. Effort's 0–21 display is a linear rescale of NOOP's 0–100
(`UnitFormatter.effortScaleFactor = 21/100`), so on 0–100 the bands are about 67–86, 48–67 and 19–48: compute
them through the unit helper, never hard-code. NOOP's Effort is not WHOOP's Strain, so present it as a rule of
thumb from your Charge ("Suggested Effort today: 48–67, a moderate day"), with progress so far, and explain it in
the guide. Before surfacing it, read the band's history (task #43 comments on both platforms).

**Open findings (the diary)** — fix with evidence; UPSTREAM ones as separate small PRs:
- **F1** (UPSTREAM, both): readiness `.insufficient` summary "Still learning your baseline" shows whenever
  today's row is missing, i.e. every morning before the night syncs. Simple mode fixed (v4).
- **F2** (UPSTREAM): carried-score caption says "Last night" for scores up to two days old
  (`carryFreshnessDays = 2`). Simple mode shows only the date (v4).
- **F3** (UPSTREAM): Health "Recovery contributors" repeat the Charge drivers with a simple-average baseline; the
  footnote says baselines take 14 days while the Charge seed is 4 nights. Check Android for a twin.
- **F4** (done as #2905): two sleep-debt numbers on one Sleep tab.
- **F5** (UPSTREAM): the Sleep ring's "of 100" is faint white on the light ring face (both modes).
- **F6** (UPSTREAM): Stress tiles truncate their comparison chips ("+2 vs…") at phone width.
- **F7** (done as #2904): Charge breakdown skin temperature ignored °F.
- **F8** (fork, done in v5): one name, "Breathing rate".
- **F9** (fixed upstream as #2906, `eb0391a0`; Round 5): the nudge's need was a
  stored default 8 h nothing set on either platform; it now follows the Sleep tab's need.
- **F13** (UPSTREAM candidate): with no row for today the readiness verdict reads the newest row (an older night)
  beside an "Earlier score" Charge (Round 5).
- **F14** (fork, done `9060515b`): a carried Rest ring now names its day (Round 5).
- **F10** (checked 6 Nov, no change): the 12.0.0 "What's new" expectation ("WHOOP 4.0 is the supported path… deeper
  metrics for 5/MG are still being figured out") matches upstream's current README (WHOOP 5.0 / MG row and the
  "analysis limits" section: live HR confirmed, some overnight inputs unavailable or incomplete on 5/MG). Honest,
  consistent with the docs; not a bug.
- **F11** (audit): one-decimal figures formatted through Foundation's locale formatter (finding 16) can differ
  from Android at a tie. Breathing and skin temperature are guarded; check the rest with a twin oracle.
- **F12** (done in chat 11 `d6114ca3` for Stress, measured; Today's extra reads are small stored series) (efficiency, measure first): Simple Today and Simple Stress hide sections whose data is still loaded
  (Key Metrics sparks, Your Cards, Advanced HRV's `freqHRV`/`stressIndex` in `loadDaytime`). Skipping that work
  in Simple mode should cut CPU; prove it with before/after numbers (Rule 1) and keep the full view unchanged.

**Don't:** change a score, formula or stored value without evidence (Rules 2–3); remove a feature (hide it in
Simple mode); let two readouts of one fact disagree; touch the Live screen's layout; skip translations the gate
requires; let the full view drift from upstream (send full-view fixes upstream instead).

## Diary

How Simple mode got here (the 4 Nov request, the first design, Rounds 1–7, every finding and what
happened to it): [Simple mode diary](simple-mode-diary.md).
