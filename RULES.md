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
- **NOOP itself may now be improved, in separate PRs** (Utku, 23 Sep 2026: "optimize and perfectize the main NOOP
  … do everything it does at the moment but in a more perfect and optimized way", less battery for phone and strap).
  The Lift Log is mostly finished. Each change is ONE concern, keeps behaviour the same (or fixes a proven bug),
  is measured or tested rather than asserted, covers both platforms where both have the code, and is opened only
  with his yes. Work the maintainers already did (widget, Watch and notification dedup, Today's leaf isolation,
  the Liquid motion gate) is left alone; a change to BLE behaviour needs a strap test first.
- **Standing permission (Utku, 23 Sep 2026): "You can reply you can push anything you want."** Replies on our own
  PRs and pushes to our branches no longer need a per-item yes; still one concise reply per review, in plain words.
  Opening a PR for work he asked for counts too. Anything else public in his name (a new issue, a comment on someone
  else's thread) still gets asked.
- **Upstream's logging is not the Lift Log's to change** — not its content, rate or buffer. The Lift Log adds only
  its drop lines (29), into that same log.
- **Never built, on purpose:** an exercise catalogue; per-exercise muscle weightings; ACWR / injury warnings;
  a frequency score; a composite workout score.

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

49. **A heart rate is shown only while the strap is measuring it, on every surface, and the Live HR banner stays until
    its switch removes it** (#2422, 23–24 Sep 2026, four strap logs; Utku, 24 Sep: NOOP closing the banner "when it sees
    no HR" is illogical when only opening NOOP can bring it back — show "–"; the switch is how to be rid of it). A WHOOP
    5.0 taken off the wrist sends WRIST_OFF about 2 s later (inferred, 24 Sep log; the new line will name it) and then
    goes SILENT with the link up; back on, an event reaches NOOP as readings resume (WRIST_ON, presumably) and 0 bpm
    follows for a few seconds while it finds the pulse. The app clears the live heart rate on WRIST_OFF,
    three unreadable samples, ten seconds of silence while awake, or a dropped link (`LiveState.clearLiveHeartRate`,
    R-R first); Today's big number is the live heart rate or nothing. The banner shows the number or "–", and the
    change between them is pushed at once (`LiveHRBannerPushPolicy`: a dash held back by the 2-s spacing and never
    retried left "91" standing, 24 Sep); its 30-s stale date lets iOS draw the dash (~2 min, without waking NOOP) when
    NOOP is asleep or closed. NOOP ends it ONLY for its switch (acting at once) or the Lift Log banner on screen (40) —
    never for a dropped link, a strap off the wrist, a sync, nothing to show on screen, or a timer
    (`LiveHRBannerLifecycle`). iOS lets only an app on screen START one: it starts when NOOP is on screen with the strap
    connected, before any reading if need be; one iOS ended (its ~8-h limit) or the user swiped away starts again at the
    next open; one older than an hour is renewed at an open (new first, then the old one ends), so the 8-h limit
    restarts. It follows the strap from process start (`LiveActivityController.follow` in `StrandiOSApp.init`), never
    from a screen, like 41. Each step of its life and each WRIST_ON / WRIST_OFF leaves an always-on strap-log line
    ("Live HR banner: …", "Strap: WRIST_OFF …"). Never requested from the background.

## Sources

- Resistance-training dose–response meta-regression (Sports Medicine, 2025) — set-counting methods, the
  ~4/week hypertrophy floor, the ~1 and ~4/week strength figures, negligible independent effect of frequency.
- Schoenfeld & Grgic, loading recommendations and the repetition continuum — hypertrophy across a broad load
  span when close to failure; strength is load-specific.
- Hypertrophy variables umbrella review (Frontiers, 2022) — volume has the clear dose–response; proximity to
  failure qualifies it.
