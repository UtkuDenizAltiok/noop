# Rules

Break one of these and the feature is wrong, not just different. Each was paid for with a real bug or settled
deliberately. **Numbers are stable** — other files cite them; retire a rule by marking it, never renumber.

## Invariants

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
   reads. `LiftSessionController.setsToSave` saves a set with anything typed (blank fields take grey values)
   and completes or zeroes the rest by the user's one choice. **RPE is never carried between sets** — only the
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
27. **The program changes only when the user says so, at finish** (`setCountChanges` / `applying`, which moves
    only `targetSets`; a line with no count is 1; a deleted line is skipped).
28. **Saving never decides for the user.** One Save button, disabled and dimmed until each question is answered.
    No Skip. "Unfinished" is `LiftSessionEngine.unenteredSlots`: never performed, or performed with nothing typed.
29. **Every silent drop of a double-tap leaves a log line** (suppressed replay, late sync arrival up to 600 s,
    1.2 s debounce, a knock held back by 35). A reported miss with none of these lines was never sent by the
    strap; its console lines (`IMU double tap detected`) show what its sensor sensed. Utku exports the log:
    More → Test Centre → Strap log → Save… It holds 5,000 lines, about 50 minutes of a gym session, so export
    soon after the session ends; the start of a longer one is already gone (16 Sep 2026).
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

35. **A strap double-tap under 8 s after the last one the session acted on is a knock, not a tap** (16 Sep 2026:
    the strap's sensor reported two double-taps 3 s and 4 s after the one that started a set, and each finished
    it). `LiftSessionController.isKnock` holds it back with no buzz and one log line — unless a rest that is
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
    otherwise switch to counting up.
39. **The Lock Screen lights only for a strap step**, through an ActivityKit alert on that push, never while the
    app is on screen, with a bundled silent sound (`lift-step-silence.caf`). Whether iOS also vibrates the phone
    is iOS's decision.

## Settled decisions

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
- **Max RPE is a safety ceiling, not planned effort** (Utku, 15 Sep): it tells the lifter where to hold back
  to avoid injury. How hard a set actually felt is still only known afterwards and recorded per set.
- **Spreadsheet import (Utku, 9 Sep):** template dropdowns stay English-only (tokens are matched case-, space-
  and hyphen-insensitively); re-importing creates a second program; a new column or muscle means regenerating
  the template.
- **Never built, on purpose:** an exercise catalogue; per-exercise muscle weightings; ACWR / injury warnings;
  a frequency score; a composite workout score.

## Sources

- Resistance-training dose–response meta-regression (Sports Medicine, 2025) — set-counting methods, the
  ~4/week hypertrophy floor, the ~1 and ~4/week strength figures, negligible independent effect of frequency.
- Schoenfeld & Grgic, loading recommendations and the repetition continuum — hypertrophy across a broad load
  span when close to failure; strength is load-specific.
- Hypertrophy variables umbrella review (Frontiers, 2022) — volume has the clear dose–response; proximity to
  failure qualifies it.
