# The Lift Log — feature reference

The gym log book inside NOOP, built with Utku 2–23 Sep 2026 and merged upstream (#2098, #2099, #2232, #2403). The
journey that built it is finished (24 Sep 2026); this page is what anyone changing NOOP needs so as not to break it:
what it does, every file behind it, the invariants that keep it right (numbered 1–48, cited as "Lift Log rule N"),
what found each bug, and the open ideas if Utku asks for more. The detailed day-by-day record is in this branch's git
history before 24 Sep 2026.

## What it does

- **Programs** — a name plus ordered exercise lines: working sets, one rep count, weight, max RPE (a ceiling,
  1–10), rest, note. Built in the editor or imported from the committed `.xlsx` template (`.csv` also works).
- **No catalogue.** Users name exercises and assign muscles; NOOP ships no exercise list and no
  exercise→muscle mapping.
- **The session is a sheet**: every set of every exercise is a row. Any pending set can be started at any time
  (machines get occupied). Finishing a set moves to the next set of the SAME exercise, then plan order.
  Green = working, amber band = rest, check = recorded.
- **The plan bends**: each exercise ends in an "Add set" row (⊕ appends, ⊖ drops the last pending set), and
  "Add exercise" at the end of the sheet adds one of the user's saved exercises, or a new one (saved at once,
  with its muscles), as one set planned at 0 kg × 0 reps. Both change this session only; finishing asks whether
  the program keeps the new counts and the new exercises.
- **Any set's numbers can be typed at any time.** A recorded set is edited in place; a pending one is held and
  applied when recorded.
- **Grey numbers stay grey** — this exercise earlier in the session, else last session, else the program
  target — until something is typed. The RPE field shows the line's max RPE grey, and a set left unrated saves
  it; a previous set's rating is only ever shown, never saved onto another set.
- **Finishing asks only what it cannot know** (one Save button, disabled until answered): a set that was done
  is complete — typed numbers, else grey ones — with no question. Sets never started are **completed** with
  their grey numbers or **discarded** — saved as 0 kg × 0 reps, out of every figure, fillable later under Edit
  sets; if a set count changed or an exercise was added, whether the program keeps it (one question). A discard that would leave no set counting files
  nothing, and the sheet warns before Save.
- **The program follows the session**: at Save each line takes its heaviest done set's weight and reps.
- **A finished session can be edited** ("Edit sets"): weights, reps, RPE, warm-up marks, session RPE, sets added
  or removed. Only that session changes, never the program. Zeros show only here.
- **Two inputs advance**: the on-screen button, or a **double-tap on the strap**. One buzz confirms the tap;
  three mean the rest is nearly over. The phone can stay face-down all session. A strap double-tap under 5 s
  after the last one acted on is taken as a knock: no buzz, nothing moves, one log line.
- **The session outlives its screen**: minimise to a bar above the tab bar; a Lock Screen Live Activity shows
  state, exercise, reps × weight, live HR, the clock and the next set ("Next: Set 2 · Lat pulldown"). A finished
  rest reads 0:00 everywhere, and every running clock reads as the Lock Screen's does. The bar and the banner
  share one layout — icon and numbers near the edges, heart rate over the clock — so the words get the width.
  It also outlives NOOP itself: when iOS closes NOOP and relaunches it, the session is back as the process
  starts and the banner iOS kept on the Lock Screen is picked up again. A strap step lights a dark Lock Screen and nothing more (a silent ActivityKit alert
  on the step's one update, whenever NOOP is not on screen), and logs whether it asked. It is the only banner
  during a session: NOOP's heart-rate and sync banners stand aside. Crash-safe snapshot in UserDefaults. Its own
  switch, Settings → Live notifications → "Lift Log session" (#2419, open): it no longer follows the heart-rate one.
- **Typing moves with one tap**: with the keyboard open, a tap on another field puts the cursor there; a tap
  anywhere else puts the keyboard away and still does what it was aimed at.
- **Saved as a normal `workout`** (`source "manual"`, sport "Strength Training", `strain: nil`), so the engine
  fills strain from the heart rate the strap measured. Deleting a session deletes that workout.
- **Figures** (session detail + hub): volume (per exercise with "vs last time", session total with its
  comparability caption), Foster session load, Epley e1RM (≤ 12 reps, labelled estimated), RPE coverage, and
  estimated sets per muscle against a ~4 sets/week research reference. No composite score.

**The double-tap.** One gesture once reached the app twice: live, then again when the strap offloaded its event
log; the 1.2 s debounce cannot catch that, and each phantom silently skipped a set. It is de-duplicated on the
event's own timestamp, read-side only (the macOS Automations gesture shares the path and was verified). In the 15
Sep log all 16 taps the strap reported were dispatched and buzzed within 3 s, and all 14 held-back replays sat
within 9 s of an already-dispatched tap: misses are the strap not sensing the tap. In the 16 Sep log (the file has
the session from 21:54 on) the strap's own console reported 22 double-taps and all 22 were acted on. Two of them
came 3 s and 4 s after the tap that started a set — knocks the strap reported as taps — which is why a strap tap
under 5 s (8 s until 21 Sep) after the last acted-on one is held back. That log also showed the four slowest buzzes
(1.0–2.8 s) were the taps whose event also kicked a sync, so the tap is now handed on, and buzzed, first. The 17
Sep log: 28 sensed, 28 reached the app, 2 held back as knocks — which he felt as unregistered.

## Size and shape (measured 16 Sep 2026, before gym round 3)

38 files the Lift Log owns: **6,933 code lines + 1,876 comment lines**, of which **~2,900 are tests** (42%).
Excludes upstream's own `LiftingImporter` (Hevy/Liftosaur) and the maintainers' `LiftMetrics.kt`.

- Biggest files: `LiftSessionView.swift` 860, `LiftLogStore.swift` 749, `LiftSessionEngineTests.swift` 651,
  `LiftLogStoreTests.swift` 629, `LiftSessionController.swift` 528, `LiftProgramItemSheet.swift` 481.
- **The largest single block** is the spreadsheet import — `LiftProgramSheetImporter` + `XlsxSheet` + the
  template generator and their tests, roughly 1,500 lines, a fifth of the feature. **Utku uses it and wants it
  kept** (16 Sep 2026): it is how he builds programs on a computer instead of typing them on a phone. It is
  self-contained (only the store APIs the editor uses, no write path of its own). **Settled:** ryanbr twice
  offered to review it as a separate PR — a review-workload question, never a code-quality one — and then merged
  it inside #2099 anyway, so it already ships upstream. Do not re-open the split, and never remove it.
- Everything else earns its place: no dead symbols (checked), no second implementation of a figure
  (Lift Log rule 2), and the comment ratio is the house style — comments say WHY, and several exist because a real
  gym session proved the alternative wrong.

## Where everything lives

### Storage — `Packages/WhoopStore`
| file | what |
|---|---|
| `Sources/WhoopStore/Database.swift` | migration `v46-lift-log`: `liftExercise`, `liftProgram`, `liftProgramItem`, `liftSession`, `liftSet` |
| `Sources/WhoopStore/LiftMuscle.swift` | closed 20-token vocabulary, 4 regions, `directSetCredit` 1.0 / `indirectSetCredit` 0.5 |
| `Sources/WhoopStore/LiftLogStore.swift` | row structs + 16 functions: upsert/read/delete for exercises, programs, items, sessions, sets (`deleteLiftSets`); `lastLiftSets`; `liftSetCounts` |
| `Tests/WhoopStoreTests/LiftLogStoreTests.swift` | 36 tests |

### Metrics — `Packages/StrandAnalytics`, and the Android twin
| file | what |
|---|---|
| `Sources/StrandAnalytics/LiftMetrics.swift` | `isPerformed(reps:)`, `volumeLoadKg`, `sessionLoad`, `estimatedOneRepMaxKg`, `perExercise`, `rpeProfile`, `muscleCounts`, `ReferenceDose`. Pure |
| `Tests/StrandAnalyticsTests/LiftMetricsTests.swift` · `LiftMetricsStoreAgreementTests.swift` | 27 · 6 tests |
| `android/app/src/main/java/com/noop/analytics/LiftMetrics.kt` · `…/data/LiftMuscle.kt` | Kotlin twins (#2232); nothing in the Android app calls them yet |
| `android/app/src/test/java/com/noop/analytics/LiftMetricsParityOracleTest.kt` · `…/data/LiftMuscleParityOracleTest.kt` | expected blocks = Swift stdout |
| Android storage | `LiftEntities.kt`, `WhoopDatabase.kt` (`MIGRATION_39_40`), `DeviceRegistryDao.kt`; no DAO reads lift sets; no Compose screens |

### Spreadsheet import — `Packages/StrandImport` and tooling
| file | what |
|---|---|
| `Sources/StrandImport/LiftProgramSheetImporter.swift` · `XlsxSheet.swift` | parses a filled template (incl. `Target max RPE`, 1–10); bounded `.xlsx` reader (`rawPart` is test support) |
| `Tests/StrandImportTests/LiftProgramSheetImporterTests.swift` | 24 tests, three read the SHIPPED template |
| `Tools/make_lift_program_template.py` → `docs/lift-log-program-template.xlsx` · `docs/LIFT_LOG_PROGRAM_IMPORT.md` | template generator and committed template · user guide |

### App — `Strand/` (compiles into BOTH macOS `Strand` and iOS `NOOPiOS`)
| file | what |
|---|---|
| `Data/LiftSessionEngine.swift` | pure slot state machine: stages, `slotAfter`, `carry`, `unenteredSlots`, add/remove set (max 20), undo |
| `Data/LiftSessionController.swift` | `@MainActor` owner: the rest's one-shot timers (no tick), buzzes, strap claim, pending input, persistence, `setsToSave`, `anyPerformed`, `programAfterSession`, `presentation(system:)`, `changesSettled` |
| `Data/LiftSessionPersistence.swift` | crash-safe `Codable` snapshot (`noop.activeLiftSession`); new fields must be optional |
| `Data/LiftFormat.swift` · `LiftMuscleNames.swift` · `HapticPrefs.swift` | formatting · localized muscle names · `haptics.liftRest` |
| `Screens/LiftLogView.swift` | hub: programs, weekly sets per muscle, history |
| `Screens/LiftProgramEditorSheet.swift` · `LiftProgramItemSheet.swift` · `LiftProgramImportSheet.swift` | program editor · one line · import |
| `Data/LiftBannerPushPolicy.swift` | when a heart rate alone is worth a Lock Screen push: ≥ 2 bpm and ≥ 30 s, 5 s for the strap appearing or disappearing (Lift Log rule 44) |
| `Screens/LiftLiveReadouts.swift` | the two numbers that change on their own — `LiftRunningClock` (a TimelineView) and `LiftHeartRate` — as leaf views, so a tick or a beat redraws one number (Lift Log rule 43) |
| `Screens/LiftExercisePicking.swift` · `LiftSessionExerciseSheet.swift` | what both exercise pickers share (name suggestions, remembering a name, the muscle picker) · the session's Add exercise sheet |
| `Screens/LiftSessionView.swift` | the session sheet, ⊕/⊖, control bar, finish sheet (questions, warning) and `save()` |
| `Screens/LiftSessionBar.swift` · `LiftSessionDetailSheet.swift` · `LiftSessionEditSheet.swift` · `KeyboardDismiss.swift` | bar (with the next set) · finished session (performed sets only) · its editor · tap-outside keyboard helper (a UIKit window recognizer that stands aside for text inputs) |
| `BLE/FrameRouter.swift` · `App/AppModel.swift` | double-tap de-duplication, drop logs, tap handed on before the sync kick · gesture claim (synchronous) and debounce log |
| `StrandiOS/Widgets/SyncLiveActivityController.swift` (upstream's, #2272) | `holdsBackNewBanner`: no sync banner starts during a session |

iOS shell: `StrandiOS/App/StrandiOSApp.swift` creates the controller and resumes a saved session in its `init`; `StrandiOS/App/RootTabView.swift` adds
More → Body → "Lift Log", the bar and the sheet. Lock Screen: `StrandiOSShared/LiftActivityAttributes.swift`,
`StrandiOSWidgets/LiftLiveActivity.swift` (no catalog: words arrive pre-localized; the Lock Screen face and the
Dynamic Island's compact regions — heart rate leading, clock trailing, each sized by a hidden "00:00",
Lift Log rule 45),
`StrandiOS/Widgets/LiftLiveActivityController.swift` (the light-up alert whenever NOOP is off screen; re-adopts the
banner after a restart, never requests one from the background, and `updateHeartRate`, the per-tick path that
builds nothing unless `Data/LiftBannerPushPolicy.swift` says the number is worth a push, Lift Log rule 44),
`StrandiOS/Resources/lift-step-silence.caf`. The activity's attributes carry nothing; everything shown is content state.

### App tests — `StrandTests/`
`LiftSessionEngineTests` 56 · `LiftSessionPendingInputTests` 11 · `LiftSessionFinishTests` 18 ·
`LiftSessionAddExerciseTests` 14 · `LiftSessionTimingTests` 4 · `LiftSessionEditTests` 8 ·
`LiftSessionPersistenceTests` 6 (old-format JSON: decides wipe or update; the resume at launch) ·
`LiftSessionStrapTapTests` 6 · `FrameRouterDoubleTapDedupTests` 10 · `LiftFormatNumberTests` 10.

## Invariants (Lift Log rules)

1. **`v46-lift-log` is a shipped upstream migration.** Never edit it. A schema change is a NEW migration
   shipped with its Room twin (`WhoopDatabase.kt`, next `MIGRATION_40_41`), both byte-identical
   `schema_oracle.json` copies, `DeviceRegistryStore.deviceScopedTables` plus the Android delete/re-key DAO
   methods, and a test. Real users carry this database.
2. **The store READS rows; `LiftMetrics` COMPUTES.** One deliberate exception: `WhoopStore.liftSetCounts`
   aggregates in SQL for the hub's 7-day card. Both of this feature's metric bugs were second
   implementations — do not add one.
3. **The two set-count implementations agree.** `liftSetCounts` (SQL) and `LiftMetrics.muscleCounts` exclude
   the same sets (warm-ups, 0 reps, a primary repeated as secondary); `LiftMetricsStoreAgreementTests` pins
   them. A third consumer goes into that test.
4. **`advance` follows `slotAfter(_:)`, never `nextPendingSlot`.** Plan order alone drags the user back to a
   machine they left.
5. **Grey stays grey, and nothing saves silently empty.** `advance` records timing only; a set's own numbers
   are only what was typed; `LiftSessionEngine.carry(for:lastSession:)` is the ONE grey chain every surface
   reads. `LiftSessionController.setsToSave` saves every set that was DONE with what was typed, blank fields
   taking grey values (Utku, 21 Sep 2026: done means complete), and completes or zeroes the sets never started by
   the user's one choice. **RPE is never carried between sets** — only the
   line's own max RPE fills a blank rating (34). The bar and the Lock Screen show a set with the numbers its row
   shows, including numbers typed before the set is recorded (`LiftSessionController.setNumbers`).
6. **Every readout on the session surfaces always renders, dashed when empty.**
7. **Effort is never modified.** Sessions save `strain: nil`; strain comes from measured heart rate.
8. **Warm-ups are excluded** from volume and per-muscle counts, on every implementation.
9. **`LiftMuscle` raw values are a stored-data contract**, mirrored in order and spelling by `LiftMuscle.kt`.
   Never rename or remove a case. Adding one: also `MUSCLES` in `Tools/make_lift_program_template.py`, the
   template, and `LiftMuscle.kt` with its oracle.
10. **Never `String(localized: "Rest")` on these screens** — that key is NOOP's SLEEP metric. Gym rest is
    `"Rest period"`.
11. **A text field is never rewritten from the model while focused.** Fields hold a draft and fall back to the
    canonical rendering on blur; otherwise "45." re-renders as "45" and the next keystroke stores 455.
12. **Weights and RPE carry up to two decimals** (`LiftFormat.trim`); a typed "," becomes ".".
13. **Deleting a lift session deletes its paired `workout` row**, or that day's Effort stays inflated.
14. **Note lengths are bounded by what is visible**: program note 120, exercise note 200.
15. **Nothing renders as COMPLETE.** The weekly bar draws the ~4-set floor as a tick on a 20-set span, with no
    success-green.
16. **The spreadsheet import stays** (Utku, 16 Sep 2026): he builds programs on a computer with it. It uses only
    the editor's store APIs and adds no write path of its own, which keeps it self-contained — that isolation is
    for reviewability, never a licence to delete it. It merged upstream inside #2099, so the old "split it out"
    offer is closed. If it ever conflicts with the core, the core wins and the import is FIXED, not dropped.
17. **⊖ only drops a PENDING last set**, never the current slot. Disabled controls DIM, not disappear.
18. **The plan travels in the undo snapshot.**
19. **Typing is never refused, and typing never CREATES a set.** Values for an unperformed set wait in
    `LiftSessionController.pendingValues`; every entry goes through `LiftSessionController.updateSet`.
20. **A string that never reaches the catalog is invisible to CI.** The authority is the compiler's
    `.stringsdata` and the built app's `*.lproj/Localizable.strings`, not grep. All ten locales for every string.
21. **Generic English words are unsafe keys** (`"Push"` is Today's nudge; use `"Push muscles"`).
22. **A de-duplication memory is a SET, not a slot.** `FrameRouter` remembers recent dispatched
    `event_timestamp`s; `state.onDoubleTap?()` has exactly ONE call site, inside `dispatchDoubleTapOnce`.
23. **Say what a number IS.** Estimates say "estimated"; the ~4-set tick is a research reference, not a target.
24. **A figure earns its place only if a reader can ACT on it.** Work-vs-rest was deleted under this rule.
25. **Parity: a PR adds no ledger finding, no ratchet debt, and no scan error.** Twin claims ("The Kotlin twin
    is `LiftMetrics.x`") pair by name and arity; two same-arity overloads of one name are an ambiguous claim —
    keep one function per twin. A new unpaired function under `Packages/**` or `android/**` is governance debt.
    Resolve it by porting the Kotlin twin ahead of its consumer — as #2232 did for the figures and
    `deleteLiftSets` did on 16 Sep 2026 — not by leaving debt for the maintainers; two of three findings that
    day were avoidable (a private helper and a constant, both inlined). A PR that legitimately adds a twin pair
    also carries the guarded authority refresh (`--refresh-derived --base origin/main`, Python 3.12) and its
    regenerated JSON — never a hand edit — and never leaves the governance tests red on `main` (#2229).
26. **Removing a set removes what was entered for it** (held numbers and warm-up mark,
    `LiftSessionController.removeSet`).
27. **The program changes at finish, two ways.** A set count changed with ⊕/⊖, and an exercise added during the
    session (42), only when the user says so — one Program question covers both (`setCountChanges` / `applying`,
    which moves only `targetSets`; a line with no count is 1; `programAfterSession` composes it all). Weight and reps
    always, from each line's HEAVIEST set done that session — more weight first, then more reps
    (`applyingHeaviestSets`; Utku chose the heaviest over the last or first set, and "by itself", 21 Sep 2026).
    Warm-ups, discarded zeros and sets completed at finish without being started move nothing; a bodyweight set
    keeps the line's weight. One write, only when a line differs; a deleted line is skipped.
28. **Saving never decides for the user.** One Save button, disabled and dimmed until each question is answered.
    No Skip. "Unfinished" is `LiftSessionEngine.unperformedSlots`: sets never started ("Sets not started: N"). A
    set that was done is complete and never asked about (21 Sep 2026; it used to include done-but-untyped sets).
29. **Every silent drop of a double-tap leaves a log line** (suppressed replay, late sync arrival up to 600 s,
    1.2 s debounce, a knock held back by 35). A reported miss with none of these lines was never sent by the
    strap; its console lines (`IMU double tap detected`) show what its sensor sensed. Utku exports the log:
    More → Test Centre → Strap log → Save…, and `tools/strap-log.py` reads it (`WORKFLOW.md` §3: a running app keeps
    its newest 5,000 entries, so a long session's start can be trimmed before the export).
30. **Editing a finished session writes only what changed** (`LiftSessionEditSheet.applying`/`changes`). Fields
    are text parsed on Save; an untouched field is not re-parsed (a pound round trip would nudge kilograms); a
    blank field clears; an existing set's timing and order never move. Added sets take the exercise's muscles,
    no timing, `ord` after every set; the last set can be removed (each exercise keeps one); set numbers
    renumber on Save; removed rows go through `deleteLiftSets`. Never touches the program. A weight/reps field
    holding 0 empties on focus and goes back to 0 if left empty or when Save/Add set runs while focused —
    an empty reps field would save nil, and nil counts as performed.
31. **The hub reloads when a session is saved** (`LiftSessionController.savedSessions`, read by `LiftLogView`).
32. **A set with 0 reps was not performed.** `LiftMetrics.isPerformed(reps:)` is exactly `reps != 0`; the SQL
    mirrors it exactly, `(reps IS NULL OR reps <> 0)`, in `liftSetCounts` and `lastLiftSets`. Nil reps still
    counts. Such a set is how a discard is saved and shows only in Edit sets. A session with nothing performed
    says so in its summary. A finish in which no set counts files no session, sets or workout (the guard reads
    `LiftSessionController.anyPerformed`), and the finish sheet warns before Save.
33. **`LiftMetrics.swift` and `LiftMetrics.kt` move together.** Any change to the Swift figures changes the Kotlin
    twin in the same PR and regenerates `LiftMetricsParityOracleTest`'s expected block from the REAL packages
    (`tools/oracle/run.sh`) — never by hand. Sections the change cannot affect must come back byte-identical.
34. **Max RPE is a plan number shown grey, and grey fills a blank — RPE included.** A program line's max RPE
    (1–10, stored in `liftProgramItem.targetRpe`) is typed in the line editor or imported from the template's
    `Target max RPE` column, and shows in the session's RPE field as a grey number. A set the session keeps and
    nobody rated saves it (`testAMaxRpeFillsAnEmptyRatingLikeEveryOtherGreyNumber`); a typed rating always wins;
    a discarded set saves zeros and no rating (`testADiscardedSetTakesNoMaxRpe`); a previous set's own rating is
    shown when the plan sets no maximum but is NEVER saved onto another set. Outside 1–10 is refused — the editor
    will not save it, the importer warns and leaves it blank. **Known cost, accepted by Utku on 16 Sep 2026:** a
    stored rating no longer proves the lifter rated that set, so the session's RPE card can report the plan.
    Say so plainly if the card is ever reworked.

35. **A strap double-tap under 5 s after the last one the session acted on is a knock, not a tap** (16 Sep 2026:
    the strap's sensor reported two double-taps 3 s and 4 s after the one that started a set, and each finished
    it; 8 s at first, 5 s since Utku found 8 too long, 21 Sep). `LiftSessionController.isKnock` holds it back with no buzz and one log line — unless a rest that is
    already over is waiting (a line planned with no rest). Only strap taps are judged; the on-screen button never
    is. The window is time since the last ACTED-ON strap tap, not stage age, so a session started on the phone
    takes its first strap tap at once.
36. **The confirming buzz is written before anything else the tap triggers.** A DOUBLE_TAP event also kicks a
    sync; `FrameRouter` hands the tap on BEFORE `onSyncTrigger`, and the session's strap handler runs
    synchronously (no `Task` hop). Otherwise the strap starts the history transfer first and the buzz lands
    1–2.8 s late. Pinned by `testADoubleTapIsHandedOnBeforeItsEventKicksASync` and
    `testTheStrapHandlerBuzzesBeforeItReturns`.
37. **"Next" is always a set, never the rest before it**, and it is where the taps go:
    `LiftSessionEngine.upcomingSlot` is `slotAfter` with the current set counted as done. The bar and the Lock
    Screen show `LiftSessionController.nextLine` ("Next: Set 2 · Lat pulldown" — set number first, so a narrow
    line cuts the name; "Last set"; "All sets done"). The sheet's header keeps "N of M sets done".
38. **A finished rest reads 0:00 on every surface and waits** — the sheet, the bar and the Lock Screen. The Live
    Activity's countdown range starts at the REST'S start; a range ending "now" re-rendered after the end would
    otherwise switch to counting up. A RUNNING clock in the app is written as the Lock Screen writes it, with
    NOOP's own `ActiveWorkoutClock.clock` ("0:45", "0:00", "1:05:00"; until 21 Sep the app said "45s" and "0s"
    beside a Lock Screen "0:45"). `LiftFormat.duration` ("45s rest") is only for a rest spoken about: a program
    line's, a finished set's.
39. **A strap step lights a dark Lock Screen, and does nothing else** (Utku, 17 Sep 2026: "just light up", then
    dark again on the phone's own timer). One ActivityKit alert on the update the step sends first
    (`LiftSessionController.strapStepTaken`, fired straight after the stage moves), sent whenever NOOP is not the
    app on screen, with a bundled silent sound (`lift-step-silence.caf`). Never gated on "locked": iOS reports
    protected data unavailable only ~10 s after the screen goes dark, and that gate missed taps (21 Sep). Each
    step leaves one strap-log line (`LiftLiveActivityController.LightUp`): alert sent, NOOP on screen, or no
    banner. An alert sent that did not light was iOS's choice. No notification; ActivityKit has no vibration
    switch.
40. **One banner during a session: the Lift Log's.** NOOP's live-HR banner stands aside while a session runs,
    and a foreground sync starts no sync banner (`SyncLiveActivityController.holdsBackNewBanner`, #2272's
    controller); a banner the Sync Strap shortcut started still runs its course.
41. **A session is back as NOOP's process starts — never when a screen appears — and its banner is kept.** iOS
    closes NOOP in the background and relaunches it when the strap next sends something (4 times in 28 minutes,
    21 Sep 2026). `LiftSessionController.resumeSaved` runs in `StrandiOSApp.init`, before any view or publisher:
    the root view's publishers fire as soon as it is built, and when the session came back later (from
    `RootTabView`), that first push found no session and ENDED the banner iOS had kept; iOS then refuses a new
    banner to an app not on screen, so every strap step lit nothing until NOOP was opened (traced in ActivityKit's
    own log). `LiftLiveActivityController` re-adopts a banner still showing, drops one swiped away or ended, and
    never asks for a new one from the background. Each restart logs "session picked up again after NOOP
    restarted" and "Lock Screen banner picked up again"; a banner that cannot come back logs once that it waits
    for NOOP to be opened.
42. **An exercise added during a session** (Utku, 21 Sep 2026) is one of his saved exercises or a new name, which
    is saved to `liftExercise` at once with the muscles chosen (the ONLY things asked). It joins at the END of the
    sheet as ONE set planned at 0 kg × 0 reps, no max RPE (0 is off the 1–10 scale) and the default rest, so its
    row shows zeros — or last session's numbers for an exercise done before — until something is typed; done
    without typing it saves 0 × 0, which is not performed (32). ⊕/⊖ and Undo work as on any line; a session holds
    at most 200 lines (`LiftSessionEngine.maxExercises`, the importer's cap). The program gains it only on "Update
    program": a new last line with the session's set count and its heaviest done set, else 0 × 0, nothing else
    set (`LiftSessionController.programAfterSession`). The line's future program id and `addedInSession` ride
    in the crash snapshot (optional field). The pickers share one copy of the name suggestions, remembering and
    the muscle picker (`LiftExercisePicking.swift`).
43. **A running session does no work between taps, and a screen watches only what it draws.** iOS killed NOOP for
    background CPU three times in the 21 Sep session (and once that morning): `cpu_resource_fatal`, over 80% for
    60 s, the main thread redrawing SwiftUI views. The Lift Log published a once-a-second tick to every screen
    watching the session — the whole tab shell, the sheet, the bar, the hub — and the sheet also watched LiveState
    (every log line, beat and R-R packet) and AppModel. Now there is no tick: a rest's warning and end are one-shot
    timers (`LiftSessionController.scheduleRestTimers` / `restEventTimes`); running clocks and the heart rate are
    leaf views (`LiftLiveReadouts.swift`: `LiftRunningClock`, a TimelineView, and `LiftHeartRate`); the banner
    follows `changesSettled`. Upstream's own rule for Today (its PERF note) says the same. Measured, simulator, 60 s
    idle, no strap: bar 8.35 → 6.14 CPU-s, sheet 9.96 → 6.59, NOOP alone 6.29. `LiftSessionTimingTests` pins that
    nothing is published between taps. Never add an `@Published` that changes on a timer, nor an
    `@EnvironmentObject` for a value a leaf could read instead.

44. **The Lock Screen banner is pushed for what a person would notice, and a heart rate is not that often.**
    Every push wakes the widget extension to re-render, and ActivityKit budgets how often an app may update an
    activity — spend it on a moving number and the update that carries the light-up alert waits behind it. In the
    22 Sep session the banner was pushed for the heart rate every 10 s (about 409 pushes in 75 minutes) and, after
    20:42, the Lock Screen lit 5–10 s after each double-tap while the buzz stayed immediate; the strap log shows
    every alert leaving the app at once, so the wait was iOS's. `LiftBannerPushPolicy` (pure, tested in
    `StrandTests`) now allows a heart-rate push only every 30 s and only on a change of ≥ 2 bpm — 5 s for the strap
    appearing or disappearing — about 143 pushes over the same session; everything else pushes at once and carries
    the current number. `LiftLiveActivityController.updateHeartRate` is the per-tick path and builds nothing unless
    the policy agrees: the app must never compose a presentation once a second for a push it will not send.
45. **A running `Text(timerInterval:)` takes every point it is offered.** Both surfaces size their clock with a
    hidden "00:00" in the same font and right-align the live clock over it. Without that, the Lock Screen banner
    spread a working set's count-up across its whole width (21 Sep), and the Dynamic Island stretched to most of
    the screen with the digits adrift in its middle (22 Sep). The island's compact leading carries the heart rate,
    with the dumbbell standing in until the strap reports one, so neither side of the pill is blank.

46. **The Lift Log needs no background machinery of its own.** It lives in NOOP's process, and NOOP already holds
    `bluetooth-central` with CoreBluetooth state restoration (`CBCentralManagerOptionRestoreIdentifierKey`), which
    is why the heart rate keeps arriving with the app off screen. Every input a session has is a BLE event on that
    same link — the double-tap — so a session advances, buzzes, updates its banner and lights the Lock Screen with
    the phone in a pocket, and it is resumed at process start when iOS relaunches the app (41). Both gym logs of
    22 Sep show it: 34 taps handled, 30 alerts sent, one app run of 1 h 39 m with the phone away. Nothing more is
    needed, and anything more — a location mode, an audio session, a background task assertion held for a workout
    — would cost battery to buy behaviour the Lift Log already has. A force-quit (swiped away) is the one case iOS
    does not relaunch for; the session waits, correctly, until NOOP is opened. Do not add background modes for it.
47. **Every line the Lift Log writes carries its own time.** NOOP's strap log takes each line's clock from whoever
    writes it (`BLEManager.logTimeFormatter`), and the Lift Log's lines had none: all 98 of them in the 22 Sep
    session, so when a tap or a light-up happened had to be inferred from its neighbours — in the one file that
    exists to answer that. `AppModel.stamped()` prefixes them at the five sites that write them. A new Lift Log
    line goes through it; a diagnostic that cannot say when it happened is half a diagnostic (`AGENTS.md`).

48. **A session survives the strap going out of range, and a tap made while it was away is not applied.** Asked by
    Utku on 23 Sep ("what if I leave my phone and walk off?"). The session lives in the phone, not the link: the
    claim on the double-tap (`AppModel.strapDoubleTapOverride`) is set when the session starts and cleared only
    when it ends — no disconnect path touches it — the rest's one-shot timers are the phone's, and the banner
    stays (NOOP's heart-rate banner shows the dash while the link is down, 49). The heart rate reads "—" while the link is down and
    comes back by itself. A double-tap made out of range reaches the app later, through the reconnect's sync, and
    is deliberately NOT acted on: advancing a set minutes late would put the session on the wrong one. It is
    logged as arriving late, and a replay of a tap already handled is suppressed (22). Partly seen in the 23 Sep
    log, and BEFORE that session began: the link timed out at 02:23:22 and was back a second later; a double-tap
    the strap recorded at 02:23:17 reached the app 156 s later through a sync and was ignored, because the live
    window is 5 s (`FrameRouter.liveGestureWindowSeconds`). The session itself, 02:28–02:53, had NO drop, so the
    in-session case rests on the code above, not on evidence — one deliberate walk-away test would settle it.
    Never end or reset a session on a disconnect.

## Settled decisions (Lift Log)

Researched against the literature or decided by Utku. Do not quietly rewrite them; if one looks wrong, say so
and flag it.

- **Effort untouched, HR-derived.** No validated path from sets/reps/weight to cardiovascular strain (#194).
- **Fractional counting: direct 1.0, indirect 0.5** — the 2025 Sports Medicine meta-regression compared 1.0,
  0.5 and 0.0 and found fractional best supported; the reference doses were derived under it.
- **Counts are not filtered by RPE** (the doses came from unfiltered counts); coverage is reported instead.
- **Session load (sRPE × minutes)** is the only cross-modality figure.
- **Twenty muscle groups, four regions, closed list**, user-assigned and snapshotted on every set.
  `MuscleGroups` (#1968) is the fallback for sources without attribution.
- **Warm-ups excluded from counts and volume** (studies count working sets).
- **Sets are rows, not JSON; weight stored in kg.** Rest is an absolute end instant, never auto-advancing.
  **No tap-anywhere-to-advance** (killed by real gym use).
- **A discard keeps zeros rather than deleting** (Utku, 15 Sep): a mistaken discard must be recoverable.
- **Done means complete** (Utku, 21 Sep): a ticked set saves typed-else-grey numbers without a question, and
  the program takes each line's heaviest done set by itself (27, 28).
- **Max RPE is a safety ceiling, not planned effort** (Utku, 15 Sep): it tells the lifter where to hold back
  to avoid injury. How hard a set actually felt is still only known afterwards and recorded per set.
- **Spreadsheet import (Utku, 9 Sep):** template dropdowns stay English-only (tokens are matched case-, space-
  and hyphen-insensitively); re-importing creates a second program; a new column or muscle means regenerating
  the template.
- **The Lift Log is an addition to NOOP, built from NOOP's own parts** (Utku, 17 Sep 2026). It writes to NOOP's
  one strap log (`LiveState.append(log:)`), buzzes through `AppModel.buzz` and its `HapticPrefs` gate, claims
  NOOP's double-tap, saves a normal `workout`, and uses NOOP's design tokens. A Lift-Log-only copy of something
  NOOP already has is added only when strictly necessary, and said why. Existing exception, merged upstream in
  #2099 and kept on purpose: its own Lock Screen banner (Live Activity), with NOOP's heart-rate banner hidden
  during a session. Utku likes how it looks and works (17 Sep 2026) — do not merge it into NOOP's banner.
- **The Lift Log does not change upstream's logging** — not its content, rate or buffer. It adds only its drop lines
  (29), into that same log.
- **Never built, on purpose:** an exercise catalogue; per-exercise muscle weightings; ACWR / injury warnings;
  a frequency score; a composite workout score.

## Sources

- Resistance-training dose–response meta-regression (Sports Medicine, 2025) — set-counting methods, the
  ~4/week hypertrophy floor, the ~1 and ~4/week strength figures, negligible independent effect of frequency.
- Schoenfeld & Grgic, loading recommendations and the repetition continuum — hypertrophy across a broad load
  span when close to failure; strength is load-specific.
- Hypertrophy variables umbrella review (Frontiers, 2022) — volume has the clear dose–response; proximity to
  failure qualifies it.

## What found what (Lift Log)

| what was wrong | found by | rule |
|---|---|---|
| session walked back to a skipped machine | gym | 4 |
| completed sets saved no numbers (19 empty sets) | gym | 5 |
| "SET" header wrapped to "SE / T" | gym | shared 34 pt column |
| hidden HR readout read as a missing feature | gym | 6 |
| 45.5 kg stored as 455; `%.1f` rounding | gym | 11, 12 |
| phantom double-tap advance; de-dup caught only consecutive replays | gym, maintainer review | 22 |
| gym rest labelled with the sleep "Rest" key | code reading | 10 |
| weekly bar full and green at the floor | review | 15 |
| set count computed two ways, guards differed | review | 2, 3 |
| no way to log an unplanned set | Utku asked | 17, 18 |
| typing into a pending set was discarded | gym | 19 |
| no way to delete a session | gym | 13 |
| 51 of 205 strings never reached the catalog | pre-PR audit | 20, 21 |
| estimates read as measurements; work-vs-rest informed nothing | Discord review, Utku | 23, 24 |
| uncalled APIs kept alive | audit, parity ledger | 2, 25 |
| template allowed column inserts (inverted protection flags) | checking a claim | a test pins the lock |
| removing a set kept numbers typed into it | audit | 26 |
| grey numbers written in at "set done" had to be typed over | gym | 5, 28 |
| ⊕/⊖ rewrote the program on every tap | gym | 27 |
| a mistyped or missed number could not be fixed after finishing | gym | 30 |
| a double-tap that did not register left no evidence | gym | 29 |
| a saved session missing from the hub until reopened | simulator | 31 |
| a Save that could not be pressed still looked pressable | simulator | dim disabled buttons |
| Skip and Save session saved the same way | gym | 28 |
| a mistaken discard could not be undone; sets not addable/removable after finishing | gym | 30, 32 |
| a set typed as 0 reps still counted | audit | 32 |
| an all-untyped discard filed an empty session with a workout and strain | maintainer review | 32 |
| a session with nothing performed showed an empty list and a wrong message | simulator | 32 |
| typing into a 0 in Edit sets appended to it ("600") | simulator | 30 |
| SQL counted `reps > 0` where Swift counts `reps != 0` | audit | 32 |
| two same-arity `isPerformed` overloads made the twin claim ambiguous | parity ledger | 25 |
| a Swift figure change without its Kotlin twin, once #2232 landed | upstream moving | 33 |
| a product PR left parity governance red on `main` | maintainers (#2229) | 25 |
| weight → reps took two taps: the tap-outside gesture took back the focus it had just given | gym | `KeyboardDismiss` |
| a knock 3–4 s after a tap finished a set seconds old | gym, strap console log | 35 |
| the confirming buzz came 1–2.8 s late when the tap's event also kicked a sync | strap log | 36 |
| the Lock Screen rest clock counted up past zero | gym | 38 |
| "0 of 16 sets done" told a lifter nothing to act on | Utku asked | 37 |
| the bar showed the grey plan for a set whose numbers were typed | simulator | 5 |
| an exported strap log had lost the first half hour of the session | log analysis, Utku asked why | 29, `tools/strap-log.py` |
| strap steps that buzzed but did not light the Lock Screen (the "locked" gate lags ~10 s) | gym | 39 |
| two deliberate taps held back by an 8 s knock window | gym, strap log | 35 |
| after iOS relaunched NOOP in the background, its first push ended the Lock Screen banner | gym, strap log, ActivityKit log | 41 |
| the in-app clocks said "45s" / "0s" where the Lock Screen said "0:45" / "0:00" | simulator | 38 |
| an exercise not in the program could not be logged | Utku asked | 42 |
| iOS killed NOOP for background CPU: the session redrew every screen each second | crash reports (Analytics Data) | 43 |
| the handbook seven hours behind the work after a usage limit, a server error and a compaction | Utku | WORKFLOW §2 Continuity |
| four Swift 6 warnings added by the strap-log branch | reading its build log before opening the PR | — |
| done sets asked about at finish; the program not following the session | Utku asked | 27, 28 |
| a second, sync banner would appear mid-session once #2272 arrived | reading upstream | 40 |
| the Lock Screen's words cut short by the numbers' width | Utku asked (screenshot) | banner layout |
| a stacked timer spread across the banner | simulator | clock sized from a hidden "00:00" |

**Confirmed on hardware:** Lock Screen activity (HR, reps × weight, ticking seconds), carried values across
sessions, spreadsheet import on device, double-tap with confirm and rest buzzes; and on 16 Sep the max RPE grey
fill, one Save, discards as 0 / 0 in Edit sets, adding and removing sets there, and the warning before an empty
Save.

**The pattern worth remembering:** the bugs that mattered were silent wrong data that passed every test and
build — a value that looks right on screen while being wrong underneath. A real session catches that; a suite
does not.

## Open ideas, only if Utku asks

1. **A strength trend across sessions.** Per session there is best set, e1RM and volume "vs last time", but no
   view across sessions — the reason to keep a log book. Per exercise over time: working weight, best set, e1RM
   (labelled estimated, ≤ 12 reps). `idx_liftSet_device_exercise` already serves the read;
   `lastLiftSets(deviceId:exercise:before:)` is the one-session version. Any new figure needs its Kotlin twin.

   | question | number | weight involved? |
   |---|---|---|
   | Is this muscle getting enough to grow? | sets per muscle | no, deliberately |
   | Am I getting stronger? | best set, e1RM over time | yes |
   | Did I do more work than last time? | volume | yes |

2. **RPE coverage where the counts are.** The RPE card says how many working sets were rated. Still open: the
   sets-per-muscle card shows no coverage, and a mean from one or two ratings is drawn at full weight (below ~3
   rated sets, show coverage instead). Display only; counting must not change.
3. **Android screens** — ryanbr's #2327 (19 Sep): an Android user found the 11.8.0 notes announcing a log book
   Android does not have. The Kotlin figures exist (#2232); Compose screens and a DAO reading lift sets do not
   (so `liftSetCounts` / `lastLiftSets` have no Kotlin twin). Best done by someone who runs Android.
4. **N+1 reads.** `LiftSessionView.loadLastTime()` and `LiftSessionDetailSheet.load()` query `lastLiftSets` once
   per exercise. Fine at 5–8 exercises; a single windowed query if programs grow.
5. **Small smells.** `LiftSessionBar` puts a button inside a tappable bar (fine in the simulator; watch on
   device). The session bar is iOS-only, so a session started on macOS is invisible once its sheet closes.
6. **Android does not hand a double-tap on before its sync kick** (the Swift change of 16 Sep, Lift Log rule 36).
   Android has no Lift Log, so only its buzz-back and other double-tap actions would gain; unmeasured there.
   Say so in the PR rather than changing Kotlin BLE code nobody can test on a strap here.
7. **Removing an exercise added by mistake.** Today: Undo straight after, or discard its sets at finish (they stay
   in that session as 0 × 0, fillable under Edit sets) and answer "Keep as it was". Only if Utku asks.

**Not asked for — do not build unprompted:** exporting a program to a spreadsheet; merge-by-name on re-import. **Only if the maintainer asks:** split the spreadsheet import into its
own PR; trim comments; squash.

## Known costs, measured — not oversights

- **iOS closing NOOP in the background** — the 21 Sep kills were `cpu_resource_fatal`, and the Lift Log's
  per-second redraws were ours to remove (Lift Log rule 43). NOOP alone still costs ~6 CPU-s a minute idle on Today in
  the simulator, and one kill (09:17 on 21 Sep, previous build) may have had no session running: if a gym log still
  shows a background restart, ask for that day's Analytics Data files (Settings → Privacy & Security → Analytics &
  Improvements → Analytics Data: `NOOP Staging.cpu_resource_fatal-…` means CPU, `JetsamEvent…` memory). Upstream's
  area beyond the Lift Log; raise it only with Utku's yes, and with those files.
- **The session snapshot is JSON-encoded into UserDefaults on every change**, keystrokes included. Deliberate (a
  crash mid-rest keeps what was typed); a few KB per session. If sessions grow, write sets incrementally rather
  than dropping durability. The importer's 200-line cap is part of this bound.
- **`loadLastTime` issues one indexed query per distinct exercise**, off the main thread, once per open.
- **Importer bounds** — 8 MB file, 64 MB per decompressed part, 5000 rows, 50 programs, 200 lines each, 50
  warnings — are pinned by tests; change them together.
