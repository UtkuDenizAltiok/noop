# Lift Log — verified backlog

**Maintained by Claude, from inside the repository. Every item below was checked against the code on
2 Sep 2026 at commit `cabfa8e4`.** Read `dist/LIFT_LOG_BRIEF.md` first.

An earlier version of this file was written from outside the repository, from screenshots and a
partial read. Its code observations have now been verified one by one: most were correct and are
kept with the verification noted; the parts that were superseded by later work have been removed.
**The scientific reasoning in §5 was researched against the literature and is settled — do not
quietly rewrite it.** If you believe something there is wrong, say so explicitly and flag it.

---

## 1. Warm-up sets can no longer be marked — REGRESSION, fix first

**Verified:** `Strand/Screens/LiftSessionView.swift` has no warm-up control. `isWarmup` appears only
where it is *preserved* (`write(_:)` passes `row.isWarmup` through) or read. The old wizard UI had a
"Warm-up set" toggle; the workout-sheet rewrite (`5a87885c`) dropped it and I did not notice.

**Why it matters most.** Warm-ups are excluded from volume *and* from the per-muscle counts —
`LiftMetrics.volumeLoadKg` and `muscleCounts` both filter `!isWarmup`, and the store's SQL counter
has `AND s.isWarmup = 0`. With no way to mark one, **every warm-up now counts as a working set**,
inflating the single figure the whole design rests on. A user warming up three times before a heavy
squat gets three phantom quad sets per exercise.

**Fix:** restore a per-row warm-up affordance on the sheet. A tap-and-hold on the set number, or a
small "W" toggle in the row, matching how the reference app the user cited marks them. The engine
and store already support it end to end — this is UI only.

## 2. The weekly bar tells the user to stop at the floor

**Verified:** `LiftLogView.muscleBar` uses `ReferenceDose.fractionOfHypertrophyMinimum(sets)`, which
clamps to 1.0 at 4 sets, and `met = sets >= 4` switches the bar and the number to
`StrandPalette.statusPositive`. So at exactly 4 sets the bar is **full and green**.

**Why it matters.** 4 sets/week is the *floor* — the point below which growth is not reliably
detected — and the same meta-regression found gains continuing well above it with no clear ceiling.
Full + green reads as "done". This also directly contradicts the design note written for this
feature, which says a muscle at 9 sets "is not 225% complete".

**Fix:**
- Scale the bar across a realistic span (roughly 0–20 fractional sets), not 0–4.
- Draw 4 as a **threshold tick**, not as the end of the bar.
- Drop the success-green. There is no success point, so no colour should imply one — use the normal accent, muted below the floor.
- Reword the caption as a floor: "About 4 sets a week is where growth becomes detectable. More helps, with strongly diminishing returns."

## 3. Two implementations of the fractional count, and they already differ

**Verified.** The load-bearing metric is computed twice:
- `WhoopStore.liftSetCounts` (SQL) — used by the hub's 7-day view, `LiftLogView.swift:315`
- `LiftMetrics.muscleCounts` (in-memory) — used by the session detail, `LiftSessionDetailSheet.swift:267`

They share the credit constants, but **the guards differ**: `LiftMetrics` has
`for m in s.secondaryMuscles where m != s.primaryMuscle`, and the SQL version has no such exclusion.

Today they agree, because the write path (`LiftMuscle.encodeList(_:excluding:)`) strips the primary
before storing. So this is a **latent** divergence, not a live bug — but it means one malformed row,
or one future writer that forgets to exclude, makes two screens report different numbers for the
same data, with no test catching it.

**Fix:** make one the single implementation. Simplest is to have the store fetch rows and delegate
the arithmetic to `LiftMetrics`, deleting the SQL aggregation — the windows involved are small. If
the SQL version is kept for performance, add the exclusion guard and a shared test that runs both
over the same fixture and asserts they agree, including a row that wrongly lists its primary.

## 4. Build the strength trend across sessions

**Verified:** best set, estimated 1RM and volume exist per session in `LiftSessionDetailSheet`, and
volume carries a "vs last time" delta. **No cross-session view exists at all** — the trend is the
whole point of a log book, and it is where load actually lives.

This is also the real answer to the user's earlier question, "doesn't ignoring weight in the set
count make weight irrelevant?" It is not irrelevant; it answers a *different* question. Three
questions, three numbers:

| Question | The number | Weight involved? |
|---|---|---|
| Is this muscle getting enough to grow? | Sets per muscle | No — deliberately |
| Am I getting stronger? | Best set, estimated 1RM over time | Yes, centrally |
| Did I do more work than last time? | Volume (kg) | Yes |

**Fix:** per exercise over time — working weight, best set, estimated 1RM. The index
`idx_liftSet_device_exercise` already serves the read; `lastLiftSets(deviceId:exercise:before:)` is
the one-session version of the same query. Keep the estimate labelled *estimated* and off sets above
~12 reps.

## 5. Two display rules about RPE coverage

Both are display-only; the counting behaviour is correct and must not change.

**(a) Unrated sets are invisible on the card that matters.** A session with 18 of 19 working sets
unrated produces muscle numbers whose meaning is unknown. The count deliberately does not filter by
RPE (§5 of the brief), but the literature is equally clear that a set earns its place by being taken
close to failure. Surface coverage **on the sets-per-muscle card itself**, not only in the RPE card
below: "14 of 19 sets unrated — sets only count toward growth if they were taken close to failure."

*Correction carried forward from the earlier draft:* an earlier version inferred that near-total
skipping of RPE meant the entry point was badly placed. The user has since said he simply forgot at
the gym. **This is not a diagnosed UI defect — do not rebuild the RPE entry point on the strength of
it.** The display change stands on its own.

**(b) A mean drawn from one rating is not a mean.** `LiftSessionDetailSheet.rpeSection` shows the
mean at the same visual weight as every other figure regardless of how many sets fed it. Below ~3
rated sets, suppress the mean and show coverage instead. `LiftMetrics.RpeProfile` already carries
`ratedSets` / `unratedSets`, so this is a display rule, not new maths.

## 6. Say what each number answers

**Verified:** `LiftSessionDetailSheet` has one footnote about Effort; no card says what its figure is
*for*. One quiet line each, in the user's language:

- Sets per muscle — "How much growth stimulus each muscle got. Ignores weight on purpose: a hard set is a hard set."
- Volume — "Total weight moved. Useful against your own past sessions, meaningless against anyone else's."
- Best set / estimated 1RM — "Whether you are getting stronger."
- Effort — "Measured from your heart, not from the weights."

## 7. You cannot log an unplanned set

**Verified:** `LiftSessionEngine.slots(forExercise:)` returns exactly `1...targetSets`, and there is
no `addSet`. If the program says four sets and you do five, **the fifth cannot be recorded.** That is
a common, ordinary thing to do in a gym.

**Fix:** an "add set" affordance per exercise, appending a slot beyond `targetSets`. The engine needs
a per-exercise extra-set count; `LiftSlot` already keys everything by `setIndex`, so the change is
contained. Consider the same for adding an exercise not in the program.

## 8. You cannot delete a logged session or set

**Verified:** `deleteLiftSession` and `deleteLiftSet` exist in the store with **zero app call sites.**
A mis-logged session — one started by a phantom double-tap, say — is permanent from the UI.

**Fix:** a destructive action on `LiftSessionDetailSheet`. Note that deleting the lift session does
**not** remove the paired `workout` row; decide deliberately whether it should, and say so in the
confirmation.

## 9. Unused store surface

**Verified:** `liftRpeProfile` and `liftExercisesLogged` have zero app call sites. `LiftMetrics`
supplies the RPE profile the UI actually uses. Either wire them up or delete them — an unused public
API on a store is a maintenance claim nobody is honouring, and it will be noticed in review.

## 10. Smaller things, worth knowing

- **N+1 reads.** `LiftSessionView.loadLastTime()` and `LiftSessionDetailSheet.load()` issue one `lastLiftSets` query per exercise. Fine at 5–8 exercises; not fine if a session ever gets long. A single windowed query would do.
- **`LiftRecordedSet` used as a value carrier.** `loadLastTime()` constructs one with `exerciseIndex: 0` purely to hold ghost values. It works, but the meaningless field is a smell — a small dedicated struct would read better.
- **`LiftSessionBar` nests a Button inside a Button** (the check inside the tappable bar). It behaved correctly in the simulator, but nested hit-testing is exactly the kind of thing that differs on device. Worth watching.
- **The session bar is iOS-only.** It is mounted in `RootTabView`; the macOS app builds the files but never shows a running session anywhere. Acceptable — macOS is not the gym target — but it means a session started on Mac is invisible once its sheet closes.

## 11. Verified as correct — do NOT change

- **Fractional counting (direct 1.0, indirect 0.5).** Confirmed against the meta-regression that compared this exact choice against 1.0 and 0.0 and found fractional best supported.
- **Not filtering the set count by RPE.** Correct for comparability with the reference doses. The answer to unrated sets is coverage reporting, not filtering.
- **Effort untouched, HR-derived.** No muscular-load blending.
- **Session load (sRPE × minutes)** as the only cross-modality figure.
- **Twenty muscle groups, closed list, primary + secondary.** Matches the resolution the literature measures at.
- **Warm-ups excluded from counts and volume.** Studies count working sets. (The *marking* is broken — see §1 — but the exclusion rule is right.)
- **Rest anchored to an absolute instant; never auto-advancing.** Proven by killing the app mid-rest.
- **Session detail arithmetic.** Checked by hand: volume 500 kg = 30×8 + 32.5×8; e1RM 41.2 = 32.5×(1+8/30); chest 4.0 direct with front delts and triceps at 2.0 from four indirect sets.

## 12. Sources for the scientific claims

- Resistance training dose-response meta-regression (Sports Medicine, 2025) — the set-counting method comparison, the ~4/week hypertrophy floor, the ~1/week and ~4/week strength figures, and the negligible independent effect of frequency.
- Loading recommendations / re-examination of the repetition continuum (Schoenfeld & Grgic) — hypertrophy across a broad load span when close to failure; strength is load-specific.
- Hypertrophy variables umbrella review (Frontiers, 2022) — volume as the variable with a clear dose-response; proximity to failure as the qualifier.

## 13. Not code — but blocking

- **`dist/liftlog-issue.md` has never been posted to `ryanbr/noop`.** Written, current, held by the user's own decision until the feature has real gym use. **Public post in his name — explicit yes required.**
- **Almost no real gym use.** Two sessions, one partly simulated. Every UI judgement here is provisional until that changes.
- **The double-tap de-duplication (§7 of the brief) is unconfirmed on hardware.** If duplicate advances stop, the diagnosis was right. If they continue, the cause is elsewhere and the fix should be revisited rather than assumed.
- **Whether the confirmation buzz now feels immediate is unknown.** The app-side delay is gone; what remains is BLE round trip and the strap's haptic engine, which software cannot shorten.
