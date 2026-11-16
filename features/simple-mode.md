# Simple mode and the human-friendly NOOP project

## Next chat begins here: Simple mode v6, the most user-friendly NOOP

**Utku's direction, 14 Nov 2026 (rule in [Rules](../RULES.md#settled-decisions)):** Simple mode was only *simpler*
than the full NOOP. It must become the most user-friendly mode, so a wearer understands and uses the app without
confusion, decided from four viewpoints (fitness coach, physiologist, doctor, software developer), and never by
deleting information or features. He is not the expert; the architect decides.

**Where it stands (16 Nov 2026, end of chat 6):** Design v6 is written (the next section) and **steps 1, 2 and 3
of 7 are built and shipped**: "Today answers" (`053ef4bd`), "Tap a score, get an answer" (`8b59779a`) and "Sleep"
(`9aba63cf`), all on `feat/simple-mode`; what each became is in the three "as built" sections below. The phone
build that holds them is named in [State](../STATE.md). Utku has not tested any of them yet; he asked on 16 Nov
that building goes on without waiting, and later the same day that each chat hands over before it is full. **The
next action is step 4, "Is my body all right?"** (Health monitor's verdict and rows; Stress, honest) from
[the build plan](#the-build-plan-one-step-at-a-time); whatever he reports from the phone is fixed first.

**Where step 4 starts in the code** (named by the design and by grep, NOT read in chat 6; read before relying):
- Health monitor: `Strand/Screens/HealthView.swift` (it already has the Simple funnel and the show-all row);
  the five readings and their states come from `BodyVitalSigns.readings` (`VitalSignsSummary.swift` draws
  them); the existing alert is `HealthAlertBanner.swift`. The verdict must be built from those states, and
  when the alert is active the verdict is the alert's own text (one source).
- Stress: `Strand/Screens/StressView.swift` (Simple branches at its `simpleMode` reads), `StressModel`
  (two z-scores of last night's resting heart rate and HRV against 30 days, squashed onto 0–3) and
  `DaytimeStress` (the only part measured while awake). Science finding S2 says what the number is.
- Reuse what steps 2 and 3 built instead of writing it again: the usual RANGE
  (`SimpleScoreRules.usualRange`, quartiles of the 30 days before; the design's "usually 54–60" for the Health
  rows is this idea), `SimpleScoreRules.comparison` (judged on printed numbers), `SimpleScoreLevelBar`,
  `SimpleDayPlan.versusUsual`, the plain-words layer pattern of `PlainChargeWording` (an unknown sentence falls
  back to the original), and the canvas backing if a screen has text on a picture
  (`SleepView.simpleCanvasBacking`).
- Rule 4 (one adviser): a Stress or Health sentence describes and ends by pointing to "Your day"; it never
  says how hard to train.

**Carried, unverified:** W40 (fitness age against VO₂max, on the phone); **F19** (seen once in the simulator's
demo: between midnight and the 04:00 day rollover the readings behind the same night's Charge changed, resting
heart rate +11 → +10 points, "usually 57" → "usually 56"; the baseline window may follow the calendar day while
the screen follows the logical day, `ChargeBaselines.history`'s `anchorDay` against `Repository.logicalDayKey`;
check on real data before calling it a bug); **F20** (demo only: for a night imported from WHOOP the stage card
reads "7h 11m in bed, asleep for 100% of it" while the day row holds the export's efficiency of 95% and the
clock times span 7h 33m; a first fix that took the row's figures made the card disagree with its own Awake row,
so it was taken out again; look at a really imported night before touching it); **F21** (upstream candidate: the
full view's sleep trend prints "7.2 h avg" under "trailing 30 days", but the figure is the mean of ALL nights,
`AsleepDurationData.typicalTotalMin`; Simple mode now averages the nights shown).

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
| S3 | Rest's 50 % deep + REM target against laboratory norms of 35–45 % | research only | Needs the stage estimate's own REM over-reading settled first (History: DREAMT, sleep-accel). Not changed. |
| S5 | Steps and active calories against the wearer's own usual | presentation | Paluch 2022 for steps (said in the guide); no source for 800 kcal. |
| S7 | Zone minutes for NOOP's own recorded sessions | analytics, both platforms, later | NOOP has the heart rate; today only imported sessions carry zones. |
| S9, S10 | One adviser; debt advice by size | presentation | The walk; Kitamura 2016. |
| S11 | **The Rest score everyone sees counts a fixed 8 h night and does not measure regularity** (found 16 Nov, building step 2) | analytics, both platforms, upstream candidate; with step 7 | The code: every shown Rest is `Rest.composite(daily:)` (Kotlin `RestScorer.restFromDaily`), called with its defaults: `defaultNeedHours` and no consistency, so the 10-point regularity part is the neutral 5 for every night and **no night can score above 95**. The engine works out a personal need and a regularity figure for the same night (`analyzeDay`'s `sleepNeedHours`, `sleepConsistency`) but only its own Charge term gets them. Step 2 says so on the Rest page and in the guide. A fix moves every Rest score, so it needs: the need settled first (S1b/S1c), the sleep-regularity literature read (not read yet), a stored value or a resolver both screens share, an oracle on both platforms. |

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
| 4 | Is my body all right? | Health monitor's verdict and rows; Stress, honest | Does Health tell you plainly whether anything is off? |
| 5 | Am I improving? | Trends and Workouts in words | Can you tell from Trends whether you are improving? |
| 6 | Welcome | How to read NOOP; Getting to know you; More; the guide; Alarms | (first-run screens: shown to him once) |
| 7 | Your own sleep need | S1b and S1c, both platforms, Android in fork CI | Does your own figure feel right after a week? |

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

## Ground rules and how to work

**Goal** (Utku, 4–6 Nov 2026; rule in [Rules](../RULES.md#settled-decisions)): a calm, correct, efficient NOOP
that a first-time WHOOP wearer understands. Nothing important is lost: Simple mode is the calm view, Settings →
Simple mode off (or More → All features) shows everything. Utku hands over all operational work: decide, build,
verify, ship; never ask him routine questions (Rules, 6 Nov). He tests on a WHOOP 5.0 + iPhone 16 Plus (AltStore, "just
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
- **F17 (verify before acting):** when the Charge ring carries an earlier day, the "What's behind your Charge"
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
- **F12** (efficiency, measure first): Simple Today and Simple Stress hide sections whose data is still loaded
  (Key Metrics sparks, Your Cards, Advanced HRV's `freqHRV`/`stressIndex` in `loadDaytime`). Skipping that work
  in Simple mode should cut CPU; prove it with before/after numbers (Rule 1) and keep the full view unchanged.

**Don't:** change a score, formula or stored value without evidence (Rules 2–3); remove a feature (hide it in
Simple mode); let two readouts of one fact disagree; touch the Live screen's layout; skip translations the gate
requires; let the full view drift from upstream (send full-view fixes upstream instead).

## Diary

How Simple mode got here (the 4 Nov request, the first design, Rounds 1–7, every finding and what
happened to it): [Simple mode diary](simple-mode-diary.md).
