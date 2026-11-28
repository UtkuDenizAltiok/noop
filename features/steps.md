# Steps: how NOOP counts them, and the decided next work

Utku, 27–28 Nov 2026: step counting must be as precise as possible; he does not always carry the iPhone (it can
lie on a table while he walks with the strap). Analysed on 28 Nov (chat 11, read-only); he asked for the work to be
done in the session after his two weeks of wear, with verification. **This page is the plan; follow it in order.**

## How it works today (13.0.0)

- **The strap is the only source of daily steps.** A WHOOP 5.0/MG reports a motion counter; `StepsCounter.
  stepsInWindow` keeps its increments only while the strap's own activity class is walking or running (all
  increments for legacy unclassed data). Steps = ticks ÷ `ProfileStore.stepTicksPerStep` (the "divisor"; default
  1.0). The divisor is in the engine's config signature (`IntelligenceEngine` "stepTicksPerStep"), so a change
  re-scores the analysis window; `WorkoutDetailView` divides a workout's ticks at display.
- **The iPhone calibrates the divisor, iOS only** (`Strand/Data/StepCalibration.swift`, `StepCalibrationViews.swift`,
  `StrandTests/StepCalibrationTests.swift`). It reads the phone's own motion chip through Core Motion
  (`WorkoutPedometer.steps` → `CMPedometer.queryPedometerData`), **not the Health app**: Health mixes sources (an
  Apple Watch, other apps) and could even hold numbers derived from NOOP, which would make the calibration chase
  itself. The motion chip keeps 7 days and answers any span, so minute resolution exists; NOOP deliberately uses
  15-minute windows because single minutes are dominated by edge effects (walk start/stop, the two devices'
  clocks, the strap's history arriving in chunks).
- **The rule:** once a day when NOOP comes to the front (at most every 20 h; switch "Calibrate steps with my iPhone",
  on by default), over the last 7 days, each 15-minute window counts only when the phone counted ≥ 500 steps (it was
  carried while walking, ~5 min at 100/min) **and** the strap counted ≥ 100 ticks in it (worn and walking). The
  divisor is the median of the windows' ticks-per-step if there are ≥ 8 windows (2 h), the median lies in 0.5–3, and
  the middle half agrees (IQR ≤ half the median); otherwise nothing changes. It is set when it moves by ≥ 0.02.
  Evidence for using the phone as the reference: phone apps −6.7 to +6.2 %, wrist devices −22.7 to −1.5 % of
  observed treadmill steps (Case et al., JAMA 2015;313:625-626). The windows of the last run are kept for the
  developer file (`steps.phoneCalibration.windows`, read by `tools/lab.py`).

## Edge cases checked (28 Nov)

| Case | What happens | Verdict |
|---|---|---|
| Phone on a table, walking with the strap | phone < 500 steps → window skipped; the walk still counts from the strap | correct |
| Strap off, phone carried | strap < 100 ticks → skipped | correct |
| Phone carried for part of a window, then put down | that window's ratio is too high; one of ≥ 8, the median does not move (3 such windows in 15 leave it unchanged); many → the spread check rejects the run, the old divisor stays | robust, fails safe |
| Strap history not yet synced for a recent window | `strapStepTicks` nil or low → skipped or an outlier | robust; item 2 below makes it exact |
| Driving or cycling with the phone in a pocket | phones can count false steps, but the strap counts ticks only while it judges walking → usually < 100 → skipped | robust |
| Arm not swinging (pushing a cart or stroller, carrying bags, treadmill rails) | the wrist under-counts; such windows enter the median like any walk | the wrist's limit: the divisor fits the wearer's usual mix, not each walk |
| Walking vs running | one divisor for both | acceptable; check on real windows (item 4) |
| A new strap | `importedReadIds` reads the active strap first; the divisor relearns within a week | correct |
| No phone walking for a week | no run; the divisor stays | fails safe |

## Gaps found, and the decided order of work

1. **Permission and the honest note (drafted, NOT verified):** the automatic daily run never asks iOS for Motion &
   Fitness access (only "Calibrate now" does, through the first read), so a wearer who never taps it gets nothing
   while the switch says on; a first tap can be cut short while iOS's question is up; and after a "Don't Allow" the
   row says "Not enough yet … two hours of walking", blaming the wrong thing (Engineering rule 8 applied to a
   screen). **The draft:** branch `fix/step-calibration-permission` `e2552574` (on `main` 13.0.0): `StepCalibration.
   PhoneAccess` and `note(access:hasResult:lastRunFound:)`; "Calibrate now" asks with one small read and waits up to
   30 s for the answer before pairing; the row says "Tap Calibrate now once …" before permission and where to switch
   it on after a no; two new strings in nine locales; `testTheNoteNamesTheRealReason`. **To finish:** `xcodegen
   generate` (and `git checkout -- StrandiOS/Resources/Info.plist`), build both Apple targets, run
   `StepCalibrationTests` and see the new test fail with `note` broken (the 28 Nov break run did not compile only
   because the project was stale), `verify.sh` all steps passed, a simulator look at the Settings row in the three
   states (no permission asked, denied, allowed), then ship as "just update". No Android change (Android keeps the
   manual divisor).
2. **Pair only windows the strap has already synced:** skip any window that ends after the active strap's newest
   stored step sample (read it once per run), so a partly synced hour can never enter the median. Small; a pure
   helper and a test (a window past the newest sample is skipped).
3. **Check how a divisor change reaches old days:** the re-score covers the analysis window; confirm whether daily
   steps older than that window are stored with the previous divisor. If they are, re-score the stored history once
   when the divisor moves by ≥ 2 %, so one history never mixes divisors (Engineering rule 3: one fact, one number).
4. **With the owner's developer file (after his two weeks):** read the stored windows (`steps.phoneCalibration.
   windows`) and `ticksPerStepInUse` with `tools/lab.py`: how many windows qualified, their ratios and spread, how
   many look like partial carries, walking vs running windows, and the strap's daily steps against the phone's on
   days he carried it. Decide only from that whether the 500-step threshold (≈ 5 min of walking in a window)
   should rise to ≈ 1,000 (fewer partial-carry windows, but fewer windows) or whether running needs its own divisor.
   Without such evidence the method stays as it is.

Not to do: read the Health app for calibration (mixed sources, possible feedback loop); use minute windows (edge
effects); let the phone ever supply daily steps (Utku, 27 Nov: the phone is not always carried).

## What to tell the owner now (13.0.0 behaviour)

Tap "Calibrate now" once and choose "Allow" when iOS asks; leave the switch on. A first "Not enough yet" can be
ignored: the next day's automatic run calibrates once there are about two hours of walking with the phone in a
pocket in the last week. Walks without the phone still count fully from the strap. If he chose "Don't Allow", the
row wrongly says "Not enough yet": switch NOOP on in iPhone Settings → Privacy & Security → Motion & Fitness.
