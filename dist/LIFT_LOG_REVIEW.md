# Lift Log — verified backlog

**Maintained by Claude, from inside the repository. Every item below was checked against the code on
2 Sep 2026 at commit `191386f5`. After the rebase onto upstream `v11.1.0` on 3 Sep 2026 (commit
`11c0d0a1`, on upstream `v11.5.0`) the whole feature was audited on 9 Sep 2026; items 2, 3, 7, 8, 9 and 10 were checked against the rebased tree and all still hold,
line references included; the rest were not individually re-read, but the rebase touched no Lift Log
screen, so treat them as current unless something says otherwise.** Read `dist/LIFT_LOG_BRIEF.md`
first — in particular §10, which covers the migration rename the rebase forced.

An earlier version of this file was written from outside the repository, from screenshots and a
partial read. Its code observations have now been verified one by one: most were correct and are
kept with the verification noted; the parts that were superseded by later work have been removed.
**The scientific reasoning in §5 was researched against the literature and is settled — do not
quietly rewrite it.** If you believe something there is wrong, say so explicitly and flag it.

---

## Base

Rebased onto upstream **`v11.5.0`** — the second sync, and routine. The lift migration is now
**`v45-lift-log`** (was v40, then v42). Nothing in this backlog was affected: the feature's own
source files came through the rebase byte-identical.

## What to do first

Ordered by value, after the 10 Sep 2026 sessions. Items 2, 3, 8 and 9 are now fixed — what remains
is genuinely quality, not gaps.

| # | Item | Why it is where it is |
|---|---|---|
| 1 | §7 — cannot log an unplanned set | **The last true gap.** Five sets when the program says four is ordinary, and the fifth is simply lost. It has not come up across four gym sessions, so confirm it actually bites before building it. |
| 2 | §5 — RPE coverage is invisible where it matters | Counts deliberately are not filtered by RPE, so coverage has to be shown, or the number's meaning is unknown. |
| 3 | §4 — no cross-session strength trend | The reason to keep a log book at all. Large — and now genuinely buildable, because real history survives updates. |
| 4 | §10b — `LiftFormat.duration` has no hours branch | A session past an hour reads "75:23". Visible on the bar, the sheet and the Lock Screen. |
| 5 | §6 | Say what each number answers. Copy only. |
| 6 | §8 (remainder) — deleting a single SET | Lower value now a whole session can be deleted, and a mis-logged set can be typed over. |

**Do not start with §4.** It is the interesting one and the least urgent.

## 1. ~~Warm-up sets can no longer be marked~~ — FIXED in `191386f5` (now `1c9243dc`)

**Was:** the workout-sheet rewrite (`5a87885c`) dropped the warm-up toggle. `isWarmup` survived in
the engine, the store and the metrics — only the way to SET it was gone. Since warm-ups are excluded
from volume *and* the per-muscle counts, every warm-up counted as a working set and inflated the one
figure the whole design rests on.

**Fix shipped:** the set NUMBER is the toggle — tapping it turns the row's `1` into an amber `W` and
back. The mark can be made BEFORE the set is performed (which is when you know), held in
`LiftSessionController.pendingWarmups` and applied the instant the set is recorded; an unperformed
set has no record to carry the flag, and inventing one would create a set nobody did. State lives in
the controller, so it survives the sheet being minimised and applies however the set was closed out.
3 engine tests. Verified in the simulator: a completed warm-up renders `W` while the header reads
"0 of 4 sets done".

**Kept as a record** because it is the clearest example of what these documents are for: it was found
by reading the code to write them, not by using the app.

## 2. ~~The weekly bar tells the user to stop at the floor~~ — FIXED in `503bf2d0`

**Verified:** `LiftLogView.muscleBar` uses `ReferenceDose.fractionOfHypertrophyMinimum(sets)`, which
clamps to 1.0 at 4 sets, and `met = sets >= 4` switches the bar and the number to
`StrandPalette.statusPositive`. So at exactly 4 sets the bar is **full and green**.

**Why it matters.** 4 sets/week is the *floor* — the point below which growth is not reliably
detected — and the same meta-regression found gains continuing well above it with no clear ceiling.
Full + green reads as "done". This also directly contradicts the design note written for this
feature, which says a muscle at 9 sets "is not 225% complete".

**Fixed as planned**, all four points: a 20-set span, four sets drawn as a TICK, no success-green
anywhere (bar or number), muted fill below the floor, and the caption now says "the tick marks".

**The rule worth carrying: nothing in this feature may render as COMPLETE, because nothing about the
dose is.** The evidence gives a floor and no ceiling for hypertrophy. The 20-set span is a drawing
choice, commented as one in `LiftLogView.weeklySetsBarSpan` — it is not a dose and a count past it
fills the bar while the number keeps counting. If a future change wants a "full" state here, that is
a science question, not a design one.

## 3. ~~Two implementations of the fractional count, and they already differ~~ — FIXED in `e8e5839f`

**Verified.** The load-bearing metric is computed twice:
- `WhoopStore.liftSetCounts` (SQL) — used by the hub's 7-day view, `LiftLogView.swift:315`
- `LiftMetrics.muscleCounts` (in-memory) — used by the session detail, `LiftSessionDetailSheet.swift:267`

They share the credit constants, but **the guards differ**: `LiftMetrics` has
`for m in s.secondaryMuscles where m != s.primaryMuscle`, and the SQL version has no such exclusion.

Today they agree, because the write path (`LiftMuscle.encodeList(_:excluding:)`) strips the primary
before storing. So this is a **latent** divergence, not a live bug — but it means one malformed row,
or one future writer that forgets to exclude, makes two screens report different numbers for the
same data, with no test catching it.

**Fixed the second way:** the SQL version keeps its aggregation (the read is indexed and the window
small) and now carries the same exclusion guard, and `LiftMetricsStoreAgreementTests` runs BOTH over
the same fixtures and asserts they agree — including a malformed row written with raw SQL, because
the public API cannot produce one. Verified it fails as intended: removing the guard turns four of
its five tests red with 1.5 against 1.0.

**Kept as a record** because the mechanism recurs: the divergence was invisible only because the
write path happened to clean every row. "No current writer triggers it" is a coincidence, not a
guarantee — and adding the spreadsheet importer added exactly such a writer. **If you add a third
consumer of the set count, add it to that test.**

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

## 8. ~~You cannot delete a logged session or set~~ — SESSION DELETE FIXED in `8c5802f7`

**Verified:** `deleteLiftSession` and `deleteLiftSet` exist in the store with **zero app call sites.**
A mis-logged session — one started by a phantom double-tap, say — is permanent from the UI.

**Fixed for SESSIONS.** `LiftSessionDetailSheet` has a destructive "Delete session", and a session
can also be **discarded before it is ever saved** from the finish sheet — until then every route off
that screen saved, because "Skip" skips the RPE question rather than the session.

**The workout question, decided: deleting a lift session DELETES the paired `workout` row too.** A
lift session writes one so the training lands in Workouts and Today, and the engine fills its strain
from the HR measured over that window. Removing the sets but leaving the workout would keep the day's
Effort inflated by a session the user just said did not happen — worse than no delete at all, because
it would look like the delete worked. The confirmation says so.

**Still open: deleting an individual SET.** `deleteLiftSet` remains unused. Lower value now that a
whole session can go, and a mis-logged set can already be corrected by typing over it.

## 9. ~~Unused store surface~~ — FIXED in `6099fe94`

**Deleted, with their three tests.** `liftRpeProfile` was not merely unused — it was a SECOND
implementation of a metric `LiftMetrics.rpeProfile` already computes, i.e. the same shape as the
set-count divergence in §3, invisible only because nothing called it.

**The rule that came out of it, now invariant §1 in the brief: the store READS rows, `LiftMetrics`
COMPUTES.** The one deliberate exception is `liftSetCounts`, and it is pinned against its twin.
Both of this feature's metric bugs were second implementations; do not add a third.

## 9b. Upstream findings — real, but deliberately NOT changed

Looked at during the 11.5.0 audit. Each is real; none is worth carrying a permanent local diff for,
because **every line we change in upstream code is a line we re-merge on every sync**. These are PR
candidates for later, not edits to make now.

- **~~Duplicated string key~~ and ~~`Info.plist` drift~~ — BOTH FIXED UPSTREAM**, in
  [ryanbr/noop#2029](https://github.com/ryanbr/noop/pull/2029) (branch `upstream-hygiene`, cut from
  `upstream/main`, no Lift Log code in it).
  **Correction worth keeping:** an earlier note here said the two copies of `"%lld of %lld nights"`
  were byte-identical. That was measured on OUR merged branch. On upstream's own tree they **differ**
  — the French diverged (`%lld de %lld nuits` vs `%lld nuits sur %lld`), so one translation was
  silently dead. Measure findings on the tree you intend to fix, not on a merge of it.
- **`v42-daily-sleep-hr-only` uses `.boolean`** where newer migrations use `.integer` for
  cross-platform affinity. **Checked and NOT a bug**: it joins the documented `grdb-boolean-affinity`
  divergence class in the schema oracle, Android CI passes, and both sides store bit-identical
  integers. Recorded so nobody "fixes" it twice.

## 10. Known costs, measured — NOT unnoticed

Audited 9 Sep 2026. These are deliberate positions with numbers attached, not oversights. Re-derive
before "optimising" any of them.

- **The session snapshot is JSON-encoded into UserDefaults on every keystroke.** `persist()` runs on
  advance, `updateSet`, warm-up toggles, start, undo and finish, and encodes the WHOLE snapshot each
  time. That is deliberate — a crash mid-rest keeps what was typed — and it is fine at real sizes: a
  19-set session is a few KB. It becomes O(n) typing cost only for an absurd program, which is part
  of why the importer caps a program at 200 lines. **If sessions ever get genuinely large, this is
  the first thing to change**, and the change is to write sets incrementally rather than to drop the
  durability.
- **`loadLastTime` issues one store query per DISTINCT exercise** (deduplicated in `e8e5839f`; it was
  per plan line). ~8 indexed queries for a real program, off the main thread, once when the sheet
  opens. Fine. A single windowed query would be fewer round trips and is the obvious follow-up if a
  program ever gets long.
- **The importer's bounds** — 8 MB file, 64 MB per decompressed part, 5000 rows, 50 programs, 200
  lines each, 50 warnings — are all far above any real sheet and far below anything that could hurt.
  They are pinned by tests; change them together with those tests.

## 10b. Smaller things, worth knowing

- **Still open from the 9 Sep session: no way to log an unplanned set.** See §7 — it did not come up
  as a complaint that session, but the gap is unchanged.
- **`LiftFormat.duration` has no hours branch.** It formats `M:SS` above a minute, so a 75-minute session reads "75:23" rather than "1:15:23". Truthful but odd once a session passes an hour, which real ones do. `IntervalTimerView` already has the `H:MM:SS` idiom to copy. **Now observed, not just read:** a stale simulator session displayed `1262:46` in the minimised bar where it meant 21 hours. On the session bar — the thing that sits on screen all workout — this is the most visible instance.

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

## 12b. Fixed on 9 Sep 2026, from the first full gym session

The first session where the whole sheet was tapped through in a real gym. Four of the six things it
found were real; the other two are below in §13b and §14.

- **The session walked back to a machine the user had left.** `advance` followed `nextPendingSlot`
  (first uncompleted in PLAN order), so skipping a busy exercise and starting a later one meant every
  subsequent set jumped back to the skipped one. Now `slotAfter(_:)` finishes the current exercise
  first. **This is the single most important behavioural rule in the engine — do not "simplify" it
  back to plan order.**
- **A completed set recorded nothing.** The sheet showed "50 x 10" in grey and stored weight and reps
  as NIL. Nineteen sets came back with no numbers and a session volume of zero. Sets now record
  `carry(for:lastSession:)` — the same numbers the sheet was showing, in the same order of
  preference. RPE is deliberately never carried (it would make the RPE coverage card report full
  coverage for unrated sets). **Keep the ghost chain in `LiftSessionView` and the carry chain in the
  engine in step** — a ghost that does not match what completing the set records is worse than none.
- **The "SET" heading wrapped to "SE / T".** 26pt column against ALL-CAPS +1.4 tracking. Now 34pt, a
  shared constant, centred, with `lineLimit(1)` on the heading row.
- **Live HR** now sits on the control bar beside the clocks; **the minimised bar** now reads
  "Set 2 — 8 x 30 kg" instead of "Set 2 — working".

## 12f. Fourth gym round, 10 Sep 2026 — everything strap-dependent confirmed

**The four things that had never been verified against a real strap all work**: the Lock Screen
activity shows HR and reps x weight with seconds ticking, ghost values carried across sessions, and
the spreadsheet import worked on a real device. Phantom double-taps: "a few, might be physical" over
a whole session, against something previously frequent enough to report as a defect. **Treat that as
resolved-enough and do not touch the BLE code on that evidence** — the next useful datum is whether
the strap had just synced, not another change.

Added in `8c5802f7`: discard an active session, delete a recorded one, and note-length caps (see §8
and the brief's §2b invariants 13-14).

## 12e. Third gym round, 10 Sep 2026 — decimal weights

**A decimal weight could not be entered, and the attempt produced a WRONG NUMBER.** Every numeric
field read its text back out of the engine, so each keystroke round-tripped through `LiftFormat` and
was replaced by the canonical rendering of the parsed value. Typing "45." parsed to 45, re-rendered
as "45", the point vanished as it was typed, and the next keystroke made "455". 45.5 kg silently
became 455 kg.

**The rule this produced, now brief invariant §11: a text field must never be rewritten from the
model while the user is typing in it.** Fields hold a draft while focused and fall back to canonical
formatting on blur. Applied to weight, reps and RPE — all three shared the binding shape.

Also: `trim` used `%.1f`, so 12.25 became "12.3" and — via that same read-back — replaced what was
typed. Now up to two decimals. And a typed "," is normalised to "." on the way in, because iOS
labels the `.decimalPad` separator key from the DEVICE region and an app cannot relabel it; the field
now always reads back in the notation the screen displays.

**Worth generalising:** this is the THIRD silent-wrong-data bug in this feature (sets recording nil,
the divergent set count, now this). All three passed every test and every build. The pattern is a
value that looks right on screen while being wrong underneath — which is exactly what a gym session
catches and a test suite does not.

## 12c. Second round, 9 Sep 2026

- **The rest is drawn BETWEEN two set rows**, as an amber band with the countdown, instead of
  tinting the finished set's row. Green is untouched.
- **Live HR** on the sheet's control bar, the minimised bar and the Lock Screen.
  **A design rule came out of this, the hard way:** the bar and the Lock Screen first hid the HR
  readout whenever there was no value, to save width on a crowded capsule. It was immediately
  reported as "there is no HR in the minimised tab" — the strap just was not streaming. *An absent
  readout is indistinguishable from an absent feature*, and mid-workout the difference is
  actionable: a dash says the strap stopped reading. All three surfaces now always render, greyed
  with a dash when empty. Apply the same rule to anything else added to these surfaces.
- **The minimised bar shows reps x weight.**
- **A Lock Screen Live Activity** carries the same four things (see brief §3). Not yet checked on
  real hardware — the seconds digits render as "--" in simulator screenshots, which is how the
  simulator captures a system-drawn live timer, but confirm it on a real Lock Screen.
- **Found while in there: the gym rest clock was labelled with the SLEEP metric's string.**
  `String(localized: "Rest")` resolves to the catalog's sleep key, so the label read "Erholung"
  (recovery) in German and "Riposo" in Italian. Fixed to "Rest period". **This is worth generalising:
  the trap is documented in CLAUDE.md and in this brief, and it was still reintroduced by a later
  commit.** Grep for `String(localized: "Rest")` after any session-screen work.

## 12d. Spreadsheet import, 9 Sep 2026

Programs can now be built in Excel/Numbers/Sheets and imported (`.xlsx` or `.csv`). See brief §3 and
`docs/LIFT_LOG_PROGRAM_IMPORT.md`.

**Settled by the user on 9 Sep 2026 — do NOT reopen these:**
- **The template's dropdowns stay English-only.** Asked about; his answer was that the sheet is an
  external file filled in on a computer and non-English speakers are not a concern for it. The
  importer accepts the stored tokens and is case/space/hyphen-insensitive regardless.
- **A re-import creating a SECOND program is fine.** Programs have a "Delete program" action with a
  confirmation in `LiftProgramEditorSheet` (verified, not assumed), so a duplicate is cheap to clear.
  His priority for the import is that it be *reliable*, not that it merge. Do not build merge-by-name
  or update-in-place unless asked.

**Things a later session should know:**
- **The template is a committed build artifact.** Regenerate with
  `python3 Tools/make_lift_program_template.py` if the columns or the muscle vocabulary change.
  `LiftProgramSheetImporterTests` parses the shipped file, so a dropped column fails the suite rather
  than a user's import — but the test cannot notice a template that no longer matches a NEW column.
- **`sheetProtection` flags read backwards.** Each one answers "is this PREVENTED", and they default
  to TRUE once the sheet is protected, so `insertColumns="0"` ALLOWS inserting columns. The template
  shipped that way once and permitted exactly the edit that breaks the column mapping. A test now
  asserts columns stay locked and rows stay editable.
- **Adding a `LiftMuscle` case means updating the generator's `MUSCLES` list too**, or the new group
  is importable-by-typing but missing from the dropdown. `testEveryMuscleInTheVocabularyIsReachable…`
  catches the parser half; nothing catches the template half.
- **The importer reads EVERY sheet in tab order and takes the first that has an exercise column** —
  not "the first tab", and not `sheet1.xml`, which is a stable id rather than a position. Headers are
  tracked separately from rows so "not a program sheet" and "template not filled in yet" stay
  distinguishable errors.
- **Not implemented on purpose:** exporting a program back OUT to a spreadsheet. Easy follow-up; not
  asked for.

## 13. Fixed on 3 Sep 2026, after the rebase

- **The empty-state card described targets that do not exist.** It promised "working sets, rep
  range, target RPE, rest and your own technique note"; the editor offers working sets, reps,
  weight, rest and a note. Two named fields were gone since the tap-anywhere fix and the planned
  weight was never mentioned. Corrected in all ten locales (`ff3312bd`). Worth noting as a class:
  **UI copy written against an earlier design is not caught by any test or linter.** The i18n gate
  checks that a string is translated, never that it is true.

## 13b. Also new since the 11.1.0 rebase

- **Nothing on this list was invalidated by the rebase.** The spot-check above covered the items
  with concrete line references — `LiftLogView.swift:315`, `LiftSessionDetailSheet.swift:267`, the
  `where m != s.primaryMuscle` guard at `LiftMetrics.swift:249`, the absent `addSet`, the zero app
  call sites for `deleteLiftSession` / `deleteLiftSet` / `liftRpeProfile` / `liftExercisesLogged`,
  and the missing hours branch in `LiftFormat.duration`. All still exactly as described.
- **~~The two-PR plan needs a fix before submitting.~~ FIXED.** The follow-up migration was folded
  into `v42-lift-log`, so the schema commit now creates the complete schema and stands alone.
- **Upstream 11.0/11.1 added a Clock format setting (System / 12-hour / 24-hour, #1822).** The Lift
  Log formats its own clocks in `LiftFormat` and does not consult it. Worth a look for consistency —
  and it sits next to the missing hours branch already noted in §10 of this file.

## 14. Not code — but blocking

- **`dist/liftlog-issue.md` has never been posted to `ryanbr/noop`.** Offered 3 Sep 2026 and declined for now — he is not going upstream until he is happy with the feature. **Public post in his name — explicit yes required, and do not raise it again unprompted.** The text is also stale (says "three commits", predates the 11.1.0 rebase).
- **Real gym use is now continuous**, but every UI judgement below was written before that started. Prefer what he reports from an actual session over anything inferred here.
- **He wipes on every update** (removes the app, forgets the strap, fresh install). Schema changes are therefore free — prefer changing the stored shape over adding a migration to patch it.
- **The double-tap de-duplication (§7 of the brief) is still unconfirmed on hardware — and now has one ambiguous data point.** Over a full session on 9 Sep 2026 a phantom advance happened **once**. That is neither a pass nor a fail: before the fix it was reliable enough to be reported as a defect, so once in a session is a large improvement, but it is not zero. **Do not close this, and do not "fix" it further on one observation.** The next step is evidence, not a change: if it recurs, get whether the strap was mid-offload at the time. A second, unrelated cause is plausible — `AppModel.handleDoubleTap`'s 1.2 s debounce is still the only guard against two genuine taps being read as one gesture, and a bumped strap is a real event, not a replay.
- **Whether the confirmation buzz now feels immediate is unknown.** The app-side delay is gone; what remains is BLE round trip and the strap's haptic engine, which software cannot shorten.
