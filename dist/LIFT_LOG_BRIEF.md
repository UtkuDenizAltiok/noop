# Lift Log — the handover brief

**Maintained by Claude, from inside the repository. Last verified against the code on 3 Sep 2026,
at commit `503bf2d0` on branch `lift-log-ui`, rebased onto upstream `v11.5.0`.**

This file is the single thing a fresh session needs. It assumes you know nothing about this work:
no memory of it, no context beyond this repository. Read it fully, then read
`dist/LIFT_LOG_REVIEW.md` for the prioritised backlog.

If you change the feature, **update both files before your context runs low.** They are the only
thing standing between the next session and a re-derivation from scratch. Treat that as part of
finishing the work, not as an extra.

---

## 1. Who you are working with

Utku Deniz Altiok (GitHub `UtkuDenizAltiok`). **Not a programmer** — does not read Swift, had never
used git before this project. The arrangement is: **you write all the code and run all the tooling;
he runs the app, uses it at the gym, and tells you what is wrong.** Explain in plain language, give
exact copy-paste commands when he has to do something himself. His product instincts are good and
have twice corrected mine — treat his design judgement as authoritative and your technical judgement
as the thing he is relying on.

Goal: a gym log book inside NOOP, eventually merged upstream into `ryanbr/noop`.
Fork: `github.com/UtkuDenizAltiok/noop`. Clone: `~/Developer/noop`.

**How he actually runs it — this changes what you need to protect (stated 3 Sep 2026):**
- He **uses it at the gym continuously**, as his own app. It is not shelf-ware waiting to be
  finished; real sessions are happening on it now.
- He **will not publish** — no upstream PR — until he is happy with the feature.
- On **every** update he wipes completely: removes AltStore and NOOP from the iPhone, forgets the
  WHOOP 5.0 strap and deletes its recorded data, then does a fresh install and re-pair.

The third point is load-bearing for engineering decisions. **Stored data does not need to survive
an update**, so schema changes are free right now — change the shape rather than bolting on a
migration. He said explicitly: don't spend effort preserving his health or exercise data.

Do not read that as "data loss is fine" in general. It stops being true the moment he stops wiping
or the feature goes public, and it never covered the app failing to OPEN its database (see §10) —
that breaks all of NOOP, not just the Lift Log.

## 2. What the feature is

A **gym log book** — independently designed, not a port of anything.

**Programs.** Build one once ("Upper A") and reuse it. A program is a name plus an ordered list of
exercise lines. Each line carries the *targets*: exercise, working sets, one rep count, a weight,
rest period, and a free-text technique note.

**Custom exercises, no catalogue.** NOOP ships **no** exercise list. The user types whatever he
calls a movement; it is remembered with the muscle group he gave it and offered back next time.
This was an explicit requirement — **never hardcode an exercise list, and never ship an
exercise→muscle mapping.**

**The session.** A scrollable **workout sheet**: every set of every exercise as a row. Any pending
set can be started at any time (a gym is not a queue — machines get occupied). Green marks the set
being worked, amber the rest that follows, a check marks a completed set with the numbers you
entered. Clocks and the one action are pinned to the bottom and never scroll away.

**The session stays on the machine you are at.** Any pending set can be started at any time, so
skipping a busy exercise leaves an EARLIER slot uncompleted. Finishing a set therefore moves to the
next set of the SAME exercise, and only falls back to plan order once that exercise is done
(`LiftSessionEngine.slotAfter`). Plan order alone sent the user back to the machine they had walked
away from after every set. **Do not simplify this back.**

**A completed set records the numbers it was showing.** The grey values on a pending row are a plan —
this exercise earlier in the session, then last session, then the program's target — and completing
the set commits exactly those (`carry(for:lastSession:)`), rendered as a real entry. A set you did
not do is corrected to 0. **RPE is never carried**: it is knowable only after the set, and inventing
it would make the RPE coverage card report every set as rated.

**The session outlives its screen.** Swiping the sheet down *minimises* to a bar above the tab bar,
reachable from every tab; the clock, the strap gesture and the buzzes keep running.

**Advancing.** Exactly two deliberate inputs: the on-screen button, or a **double-tap on the WHOOP
strap** (so the phone can stay face-down on a bench). One strap buzz confirms a double-tap
registered; three buzzes mean the rest is nearly up.

**Metrics.** Six figures per session, every one arithmetic the user can redo by hand from the sets
on the same screen. No composite "workout score".

## 2b. The invariants — break these and the feature is wrong, not just different

Everything here was either paid for with a real bug or settled deliberately. A change that violates
one is a regression even if it compiles and the tests you ran passed.

0. **The migration is `v45-lift-log`.** It has moved twice (v40 → v42 → v45) because upstream keeps
   taking the numbers. Expect to move it again; §10 has the procedure.
1. **The store READS rows; `LiftMetrics` COMPUTES.** One exception, deliberate:
   `WhoopStore.liftSetCounts` aggregates in SQL so the hub's 7-day card does not load every set.
   Every other store function is a plain read, and every metric has exactly ONE implementation.
   Adding a second implementation of any figure is how both of this feature's metric bugs happened —
   don't.
2. **Sets-per-muscle is computed in TWO places and they must agree.** `WhoopStore.liftSetCounts`
   (SQL, the hub's weekly card) and `LiftMetrics.muscleCounts` (in memory, the session detail). Both
   exclude a muscle listed as both primary and secondary. `LiftMetricsStoreAgreementTests` pins them
   against EACH OTHER — keep it green, and if you add a third consumer, add it there too.
3. **`advance` follows `slotAfter(_:)`, never `nextPendingSlot`.** Finish the exercise you are at,
   then fall back to plan order. Plan order alone drags the user back to a machine they left.
4. **A completed set records `carry(for:lastSession:)`** — the numbers the sheet was showing. Never
   nil. And **RPE is never carried**: it is knowable only after the set, and carrying it would make
   the RPE coverage card claim every set was rated.
5. **Every readout on the session surfaces always renders, dashed when empty.** A readout that hides
   itself is indistinguishable from a missing feature — that is how the HR gap was first reported.
6. **Effort is never modified.** A session saves `strain: nil`; the engine fills it from measured HR.
7. **Warm-ups are excluded** from volume and per-muscle counts, on both sides.
8. **`LiftMuscle` raw values are a stored-data contract.** Never rename or remove a case. Adding one
   is safe — but update `Tools/make_lift_program_template.py`'s `MUSCLES` too, or the new group is
   importable by typing and missing from the template's dropdown.
9. **Never use `String(localized: "Rest")` on this screen.** That key is NOOP's SLEEP metric and
   renders "Erholung" in German. The gym rest is `"Rest period"`. This has been reintroduced once
   already; grep for it after any session-screen work.
11. **A text field must never be rewritten from the model while the user is typing in it.** Every
    numeric field holds a DRAFT while focused (`LiftSessionView.draft`) and only falls back to the
    canonical rendering on blur. A binding that reads its text back out of the engine cannot accept
    a decimal at all: "45." parses to 45, re-renders as "45", and the next keystroke makes "455".
12. **Weights and RPE carry up to TWO decimals** (`LiftFormat.trim`), and a typed "," is normalised
    to "." — iOS labels the decimal-pad separator from the DEVICE region and an app cannot change it.
13. **Deleting a lift session deletes the paired `workout` row too.** The session created it, the
    engine fills its strain from measured HR, and leaving it would keep that day's Effort inflated by
    a session the user just deleted — a delete that looks like it worked and did not.
14. **Note lengths are bounded by what is VISIBLE**: program note 120 (`lineLimit(3)` on the hub),
    exercise note 200 (`lineLimit(4)`, and it renders above the set rows). Enforced at entry, on
    import, and again in layout. Both are a MAXIMUM, not a target.
15. **Nothing in this feature may render as COMPLETE.** The evidence gives a hypertrophy floor
    (4 sets/week) and NO ceiling, so a full bar or a success-green is a claim the science does not
    support. The weekly bar draws the floor as a tick a fifth along a 20-set span; that span is a
    drawing choice (`LiftLogView.weeklySetsBarSpan`), not a dose.
10. **The spreadsheet import is a convenience, not part of the feature.** It calls only the three
   store APIs the program editor already used, adds no write path, and touches one button in the
   hub. If it ever conflicts with the core, the core wins and the import can be deleted whole.

## 3. Where everything lives

### Storage — `Packages/WhoopStore`
| File | What |
|---|---|
| `Sources/WhoopStore/Database.swift` | ONE migration, **`v45-lift-log`** — five tables, seven indexes, complete schema. It has been v40, then v42, now v45: upstream takes the numbers every cycle. See §10 |
| `Sources/WhoopStore/LiftMuscle.swift` | the closed **20-token** muscle vocabulary, 4 regions, and `directSetCredit` / `indirectSetCredit` |
| `Sources/WhoopStore/LiftLogStore.swift` | row structs + CRUD + `liftSetCounts` / `liftRpeProfile`; `maxRememberedExercises = 500` |
| `Sources/WhoopStore/DeviceRegistryStore.swift` | all five lift tables listed in `deviceScopedTables` |
| `Tests/WhoopStoreTests/LiftLogStoreTests.swift` | **38 tests** |

Tables: `liftExercise`, `liftProgram`, `liftProgramItem`, `liftSession`, `liftSet`.

### Spreadsheet import — `Packages/StrandImport`
| File | What |
|---|---|
| `Sources/StrandImport/LiftProgramSheetImporter.swift` | parses a filled template into programs + warnings. **Writes nothing** — the caller decides |
| `Sources/StrandImport/XlsxSheet.swift` | a deliberately small `.xlsx` reader (first worksheet, as text) on ZIPFoundation + XMLParser |
| `Tests/StrandImportTests/LiftProgramSheetImporterTests.swift` | **17 tests**, including two that read the SHIPPED template — its columns, and that it locks column edits |
| `Tools/make_lift_program_template.py` | generates `docs/lift-log-program-template.xlsx`; no Python dependencies |
| `Strand/Screens/LiftProgramImportSheet.swift` | the picker, the preview, and the write |

`.xlsx` and `.csv` both work, detected by ZIP magic bytes. `docs/LIFT_LOG_PROGRAM_IMPORT.md` is the
user-facing guide. **The template is a committed build artifact** — regenerate it if the columns or
the muscle vocabulary change, and note the test parses it, so dropping a column fails the suite.

### Metrics — `Packages/StrandAnalytics`
| File | What |
|---|---|
| `Sources/StrandAnalytics/LiftMetrics.swift` | volume load, session load, work/rest, Epley 1RM, RPE profile, muscle counts, `ReferenceDose`. **Pure** — no store, no clock, no UI |
| `Tests/StrandAnalyticsTests/LiftMetricsTests.swift` | **29 tests** |

### App layer — `Strand/` (compiles into **both** macOS `Strand` and iOS `NOOPiOS`)
| File | What |
|---|---|
| `Data/LiftSessionEngine.swift` | the **slot-based state machine**. Pure; time enters as a parameter |
| `Data/LiftSessionController.swift` | `@MainActor ObservableObject` owning the engine, the 1-second tick, buzz gating, persistence, the strap claim, and `presentation(system:)` — the ONE resolution of the session's wording and numbers, rendered by both the minimised bar and the Lock Screen activity |
| `Data/LiftSessionPersistence.swift` | crash-safe `Codable` snapshot in UserDefaults (`noop.activeLiftSession`) |
| `Data/LiftMuscleNames.swift` | app-layer localized display names (WhoopStore holds no UI strings) |
| `Data/LiftFormat.swift` | kg/lb conversion + number and duration formatting |
| `Data/HapticPrefs.swift` | adds the `haptics.liftRest` gate |
| `Screens/LiftLogView.swift` | the hub: programs, weekly sets-per-muscle, session history |
| `Screens/LiftProgramEditorSheet.swift` | program name/note + ordered exercise lines |
| `Screens/LiftProgramItemSheet.swift` | one line: exercise picker (with forget), muscle classification, targets |
| `Screens/LiftSessionView.swift` | the workout sheet + control bar + finish sheet |
| `Screens/LiftSessionBar.swift` | the minimised session bar — reps x weight and live HR |
| `Screens/LiftSessionDetailSheet.swift` | a finished session read back in full |
| `Screens/KeyboardDismiss.swift` | `dismissesKeyboardOnTap` helper |
| `BLE/FrameRouter.swift` | **double-tap de-duplication** (see §6) |
| `App/AppModel.swift` | `strapDoubleTapOverride` |

### Lock Screen — the session Live Activity
| File | What |
|---|---|
| `StrandiOSShared/LiftActivityAttributes.swift` | `ActivityAttributes`; times are carried as DATES so the widget's clock ticks on its own |
| `StrandiOSWidgets/LiftLiveActivity.swift` | the Lock Screen + Dynamic Island rendering. **The extension ships no string catalog** — every word it draws must arrive pre-localized from the app |
| `StrandiOS/Widgets/LiftLiveActivityController.swift` | starts/updates/ends it; pushes only on content change, plus HR at most every 10 s |

Separate activity type from the live-HR one (`NOOPActivityAttributes`); the app suppresses that one
while a session runs rather than stacking two banners. Both share the existing Live Activity opt-out.

**Every readout on these surfaces always renders, with a dash when it has no value** — never hidden.
Hiding the heart rate when the strap was not streaming was read as the feature being missing, which
is a worse failure than a dash: mid-workout, "the strap stopped reading" is something to act on.

### iOS shell — `StrandiOS/`
- `App/StrandiOSApp.swift` — creates `LiftSessionController` (injecting buzz + strap claim), injects it as an environment object.
- `App/RootTabView.swift` — `MoreDestination.liftLog`, the `MoreRow("Lift Log", "dumbbell.fill", .liftLog)` in `moreSection("Body")`, the session bar via `.safeAreaInset(edge: .bottom)`, the session sheet, and the `.task` that resumes an interrupted session **as the bar, not as a sheet**.

### App-target tests — `StrandTests/`
- `LiftSessionEngineTests.swift` — **41 tests**
- `FrameRouterDoubleTapDedupTests.swift` — **4 tests**

## 4. Architecture and conventions you must follow

- **`project.yml` is the XcodeGen source of truth.** `Strand.xcodeproj/` is generated — never hand-edit or commit it. Run `xcodegen generate` after adding files.
- **A new file in `Strand/` compiles into BOTH targets.** The macOS build has caught real errors the iOS build missed (e.g. the zero-argument `onChange(of:)` is macOS 14+, and NOOP targets macOS 13). **Always build both.**
- **No CI compiles the app targets** (`app-build.yml` is disabled). You must build them yourself.
- **Design system is law**: only `StrandPalette` / `StrandFont` / `NoopMetrics` / shared components. The Lift Log uses `StrandPalette.effortColor` (the Workouts colour world). `NoopMetrics.tabBarClearance` clears the floating tab bar.
- **Migrations**: ids `v<N>[-slug]`, strictly sequential, no gaps. **Never edit a shipped migration** — add a new one. Every migration needs a test.
- **`schema_oracle.json` has TWO byte-identical copies** (`Packages/WhoopStore/Tests/.../Resources/` and `android/app/src/test/resources/`). Editing one without the other fails both suites. Keys sorted, `indices` sorted by name, and the file uses `\uXXXX` escapes — preserve them (`json.dumps(..., indent=2)` with default `ensure_ascii=True`).
- **Any table with `deviceId` must be in `DeviceRegistryStore.deviceScopedTables`**, child tables included.
- **Booleans are `.integer` 0/1, never `.boolean`** (GRDB's BOOLEAN → NUMERIC affinity diverges from Room).
- **Row structs have NO default parameter values, deliberately** — so a new column becomes a compile error at every call site instead of silent data loss.

### The i18n tax — plan for it
NOOP ships **10 locales** (de, en, es, fr, it, pl, pt-PT, ru, zh-Hans, zh-Hant). `i18n-coverage.yml`
hard-gates de/es/fr/pt-PT and ratchets the rest. **Every new on-screen string needs all nine
translations or CI fails.** Check with:

```bash
python3 Tools/i18n_audit.py --ci main
```

Add strings by appending to `Strand/Resources/Localizable.xcstrings` in its existing compact
format — never reformat the file. Note the file is **not sorted**: entries sit in insertion order,
and both upstream and this branch append near the top, so it conflicts textually on almost every
rebase even when the two sides touch disjoint keys. Resolving those markers by hand is a trap — the
shared trailing `} },` counts as context and silently truncates the last entry into invalid JSON.
Merge on KEYS instead: take the base file verbatim, plus every entry `theirs` added relative to the
merge base (`git show :1:/:2:/:3:`), which also preserves upstream deletions rather than
resurrecting them.

**The script must not assume the formatting.** By 11.5.0 the catalog mixes the compact
one-line-per-entry style with Xcode's expanded style at a DIFFERENT indent, and it contains a
genuinely duplicated key (`"%lld of %lld nights"` — JSON tolerates it, last wins). So: take the key
list from `json.loads`, find each key's own line with a regex that accepts any leading whitespace and
decodes the escaped key, and treat the last occurrence of a duplicate as authoritative. An
indent-based parser silently mis-attributes entries and produces invalid JSON. Four traps found the
hard way:
- The catalog's existing **`"Rest"` key means NOOP's SLEEP metric** ("Erholung", "Riposo"). The rest timer uses its own `"Rest period"` string.
- `String(localized:)` with interpolation produces `%@` / `%lld` keys; translations need positional `%1$@` / `%2$lld`.

### Local verification loop
```bash
cd Packages/WhoopStore && swift test
cd Packages/StrandAnalytics && swift test
xcodegen generate && xcodebuild -project Strand.xcodeproj -scheme NOOPiOS -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Strand.xcodeproj -scheme Strand -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
python3 Tools/i18n_audit.py --ci main && python3 Tools/doc_comment_lint.py
```

**Expect exactly two failures, and do NOT try to silence them with a locale flag.** This machine is
English-language/German-region, so `TodayCarryOverTests` (2 tests) compares "18. Jun" against the
"Jun 18" it expects. Those two are pre-existing and unrelated — they fail identically on a clean
checkout. Don't chase them.

An earlier version of this file suggested `-testLanguage en -testRegion US` for a clean run. **That
advice was wrong and has been removed:** the flag fixes those two but breaks
`AppLanguageTests.testExplicitLanguageWritesAndSystemRemovesAppleOverride`, which reads back the
`AppleLanguages` override the flag itself is setting. Two known failures beat one mystery. Run the
suite with no locale flags.

### Getting a build onto his phone
```bash
gh workflow run "Testing build (fork)" --repo UtkuDenizAltiok/noop --ref lift-log-ui
```
The `.ipa` lands at the fork's rolling `testing-latest` release. He installs with AltStore. The iOS
bundle id is `com.noopapp.noop` — the same as his existing sideload, so it **updates in place and
keeps his data**. If a run fails in ~2 minutes with a dependency-clone error, that's the runner's
network, not the code: **re-run it.**

## 5. Decisions that are settled

**Effort is never modified.** NOOP's strain is HR-derived (Karvonen %HRR → Edwards TRIMP,
`StrainScorer`). There is no validated public path from typed sets/reps/weight to a cardiovascular
strain equivalent — WHOOP's own muscular load runs velocity-based algorithms over strap
accelerometer/gyroscope under an unpublished model. Deriving one is the case `CLAUDE.md` warns about
(the withdrawn PPG→HR estimate, #194). A session saves with `strain: nil` and the engine's
`rescoreManualWorkouts` fills it from the heart rate the strap **measured** over that window.

**Indirect sets count 0.5.** Not a house convention: the 2025 Sports Medicine dose-response
meta-regression compared 1.0 / 0.5 / 0.0 and found fractional best supported. The reference doses
were derived under it, so the credit and the doses move together or not at all.

**The set count is NOT filtered by RPE.** The reference doses came from unfiltered working-set
counts; filtering would compare a smaller number against a scale built from a larger one. RPE is
reported separately.

**Twenty muscle groups, four regions.** Coarser hides an untrained hamstring inside a full "Legs"
bucket; finer goes past the resolution the evidence is measured at. Raw values are a stored-data
contract — never rename or remove a case; adding one is safe.

**Sets are rows, not JSON.** "What did I lift for this last time" is the read the feature exists for.

**Sessions save as `source: "manual"` under the strap `deviceId`**, sport `"Strength Training"` (the
same token `LiftingImporter` uses), pinned to the workout row by that table's natural key
`(deviceId, startTs, sport)`.

**Weight is stored in kilograms**; display uses the app's existing metric/imperial preference
(`UnitPrefs.systemKey`) — no second setting.

**Rest is an absolute end instant, never a decrementing counter** (a phone that sleeps must wake up
telling the truth), and **never auto-advances**.

**No tap-anywhere-to-advance.** An early build had it; real gym use killed it. Do not reintroduce.

**Set values are entered during the REST, not during the set.** You cannot type a weight with a bar
in your hands.

## 6. Things that are deliberately NOT done

- **No Android twin.** The five tables are pinned `ios_only` in both `schema_oracle.json` copies with a stated reason. Not preference: there is no JDK or Android SDK on this machine, and shipping an unrun Room twin is worse than a documented gap. **Android CI is green on the branch** — `assembleFullDebug` + `testFullDebugUnitTest` both pass, so `SchemaOracleTest` accepts the pin.
- **No per-exercise muscle weightings** ("bench = 0.7 triceps"). No published table exists; inventing one makes every downstream figure fiction wearing the costume of precision.
- **No acute:chronic workload ratio, no injury-risk or overtraining warnings.** Disputed construct; NOOP is not a medical device.
- **No frequency score.** Negligible independent effect on hypertrophy.
- **No single composite "workout score".** Six honest figures beat one invented one.

## 7. A real bug fixed in the shared BLE layer

`FrameRouter` now de-duplicates DOUBLE_TAP on the event's own `event_timestamp`. One physical
gesture reached the app **twice**: live via `handle(frame:)`, and again when the strap offloaded its
banked event log, because `dispatchLiveGestureIfFresh` runs over every offload frame and accepts any
event within `liveGestureWindowSeconds` (45 s). `AppModel.handleDoubleTap`'s 1.2 s debounce cannot
catch a replay that lands seconds later. With the Lift Log claiming the gesture, the phantom
silently advanced the session and cost a logged set.

This is **read-side only** — no new writes, no change to the connection path or the window. It
affects every double-tap consumer, not just the Lift Log.

**Status after the 9 Sep 2026 session: one phantom advance in a full session.** Not a pass and not a
fail. Before the fix it was frequent enough to be reported as a defect, so once is a large
improvement — but it is not zero, and one observation is not a diagnosis. **Do not change this code
again on the strength of it.** Get evidence first: whether the strap was mid-offload when it
happened. A second, unrelated cause is entirely plausible — `AppModel.handleDoubleTap`'s 1.2 s
debounce is still all that separates two genuine taps from one gesture, and a knock against a
loaded bar is a real event, not a replay.

## 8. Where it stands

**Base: upstream `v11.5.0`.** Rebased onto `ryanbr/noop` `main` (9f786fa4) — 206 upstream commits,
the second sync (the first was 10.6.1 → 11.1.0, 216 commits). Eighteen commits on `lift-log-ui` (branched off `lift-log-schema`, which holds the
schema commit):

```
503bf2d0 lift log: stop the weekly bar saying "done" at the floor, and lengthen the notes
8c5802f7 lift log: let a session be discarded or deleted, and bound the note lengths
38b915fb lift log: let a decimal weight be typed, and keep two decimals
91b39043 ci: ship the Lift Log program template with every testing build
6099fe94 lift log: delete dead store API, leaving one computed read in the store
11c0d0a1 lift log: fix a divergent metric, and bound the import so it cannot hurt the app
c21d68f6 lift log: make the spreadsheet import survive a real user's file
53336a57 lift log: build a program from a spreadsheet
18bb63a1 lift log: keep the heart rate on screen even when it is not reading
0d163dd4 lift log: put the running session on the Lock Screen
470f01e5 lift log: draw the rest between the sets, and put HR on the bar
8c721f49 lift log: fix the wrapped Set heading, and show HR and the set's numbers
0c90825e lift log: keep the session on the machine you're at, and record what it showed
cf62bb97 lift log: describe the targets the editor actually has
479ef465 lift log: restore the warm-up marker
82b275df lift log: forget an exercise, dismiss the keyboard, and stop phantom double-taps
874556b7 lift log: a workout sheet, and a session that outlives its screen
ce0395fd lift log: the metrics, and the session detail screen that shows them
6d463d88 lift log: fix the tap-anywhere mistake, and move set entry into the rest
1089aa06 lift log: the session loop, the rest timer and strap double-tap
ff835072 lift log: programs, the exercise vocabulary and muscle classification
2c1a0180 store: add the v45 schema for the in-app strength log
```

The schema commit is **self-contained** — it creates the complete schema in one migration, so a
schema-only PR stands alone.

Pre-rebase tips are kept as tags — `backup/lift-log-ui-pre-11.5.0` is the most recent, and
`backup/lift-log-ui-pre-11.1.0`, `backup/lift-log-schema-pre-11.1.0` and
`backup/lift-log-ui-before-fold` are still there. Local `main` is upstream `v11.5.0`.

**Test counts at `503bf2d0`:** WhoopStore **561** · StrandAnalytics **1988** · StrandImport **284** · StrandTests **1696**
— 0 failures beyond the two locale-dependent `TodayCarryOverTests`. Both app targets build;
`doc_comment_lint.py` and `i18n_audit.py --ci upstream/main` pass with all ten locales; Android CI
passes on the branch (that is what exercises `SchemaOracleTest`, NOT the testing-build workflow,
whose Android job only compiles APKs).

**The feature has now had a full real gym session** (9 Sep 2026) — the whole sheet tapped through in
a gym rather than simulated. It found two data-losing bugs, both fixed in `154d2a7e`, and a second
round of requests answered in `93823f69` / `0dd807ae`; see §12b and §12c of the review. Treat further
UI judgements the same way: ship, use, then fix what the session actually found — **nothing in the
backlog predicted either data-losing bug.**

**Audited on 9 Sep 2026** against "correct, efficient, error-free". What it found and fixed is in
`e8e5839f`; what it found and did NOT fix is in §10 of the review — read that before optimising
anything, because the remaining items are known and quantified rather than unnoticed.

## 9. Still outstanding

1. **`dist/liftlog-issue.md` has never been posted upstream.** It asks ryanbr about storage shape,
   the `ios_only` Android position, placement and the source token — question 3 is the risky one,
   since `CLAUDE.md` calls cross-platform parity "the #1 rule" and a required Room twin would be a
   large piece of work. It was offered on 3 Sep 2026 and he declined for now: he is not going
   upstream until he is happy with the feature. **Do not post it.** It is a public post in his name
   and needs an explicit yes. Note the text is stale — it says "three commits" and predates the
   rebase — so refresh it before it is ever used.
2. **Real gym use is happening continuously** (see §1). The 9 Sep 2026 session is the first full
   one; its findings are in §12b of the review. Ask him what actually went wrong in a session rather
   than assuming the backlog's remaining guesses still describe the problems — two of the six things
   that session raised were not what the backlog predicted, and one backlog item (§7, logging an
   unplanned set) did not come up at all.
3. **No PR opened, and that is deliberate.** He will not publish until he is happy with the
   feature. The rebase onto `v11.1.0` is done and the schema commit is self-contained, so the
   two-PR split (schema, then UI) is ready whenever he decides. Nothing is blocking on code.
4. **The backlog lives in `dist/LIFT_LOG_REVIEW.md`** — read it. Item 2 (the weekly bar reading
   "done" at the 4-set floor) is the next thing worth fixing.
5. **`dist/` is gitignored** (`.gitignore:96`). These notes live on disk and deliberately never
   reach a commit, so they cannot leak into an upstream PR.

## 10. Syncing with upstream — the routine, and the one trap

The branch was cut from upstream 10.6.1 staging. Upstream shipped 11.0.0 and 11.1.0 on top of that,
and **took v40 and v41 for its own migrations** — `v40-daily-skin-temp-absolute` and
`v41-drop-raw-imu-sample`. The lift log's migration moved to **`v42-lift-log`**.

**Expect this on every upstream sync.** There is no way to sidestep it: `SchemaOracleTest` asserts
that a migration's number matches its position in registration order, so the lift log cannot park
itself at `v900` out of upstream's way. Renumbering *is* the mechanism. It is a one-line change.

**The trap, and why it is currently harmless.** GRDB keys applied migrations by identifier and
intersects the applied set with the REGISTERED set, so an identifier it does not recognise is
indistinguishable from one that was never applied. A database written by a build that ran the OLD
number therefore sees the new one as unapplied and runs it again, over tables that already exist.
An unguarded `CREATE TABLE` throws there — and a migrator that throws does not just break the Lift
Log: `Repository.ensureStore()` catches it and returns nothing, so NOOP opens as an empty shell
("Couldn't open the local store"), on every launch, until reinstalled.

Two things keep that from mattering:
- **Every create is `ifNotExists`** — tables AND indexes, consistently (the v38 idiom). The
  migration is a no-op against a database that already carries the schema.
- **Utku wipes on every update.** He removes AltStore and NOOP from the iPhone, forgets the strap
  and deletes its recorded data, then does a fresh install and re-pair. So in practice the migrator
  always runs against an empty database and the re-run path never executes.

That second point is why there is **no** longer a test pinning the re-run, and why the migration
uses no `ALTER TABLE` at all: the schema is created complete, in one migration, first time. **If
that ever changes** — if he stops wiping, or once this is public and real users carry databases —
the re-run path becomes live again and wants a test before any renumber.

**THE PROCEDURE, in order.** This has been done once (216 commits, 10.6.1 → 11.1.0) and these are
the steps that worked:

```bash
git fetch upstream --tags
git log --oneline $(git merge-base lift-log-ui upstream/main)..upstream/main | wc -l   # how far behind
git tag backup/lift-log-ui-pre-<version> lift-log-ui                                   # always
git rebase upstream/main            # on lift-log-schema first, then --onto for lift-log-ui
```

1. **Check the migration numbers FIRST**: `grep 'registerMigration("v4' Packages/WhoopStore/Sources/WhoopStore/Database.swift`
   on both sides. If upstream took ours, renumber — it is one line, and `SchemaOracleTest` enforces
   that a migration's number matches its registration order, so there is no dodging it.
2. **Resolve `Localizable.xcstrings` on KEYS, not markers** (see §4).
3. **Both `schema_oracle.json` copies** must stay byte-identical; the only lift entries are the
   migration id and the five `ios_only` tables.
4. **Verify in this order** — cheapest first, and the last two are what no CI covers:
   `swift test` in WhoopStore / StrandAnalytics / StrandImport → `xcodegen generate` →
   **build BOTH app targets** → `xcodebuild … test` (expect exactly the 2 `TodayCarryOverTests`) →
   `doc_comment_lint.py` → `i18n_audit.py --ci upstream/main` → run **Android CI** on the branch
   (that, not the testing build, is what exercises `SchemaOracleTest`).
5. **Compare tree hashes** if you rewrote history and only meant to change history:
   `git rev-parse HEAD^{tree}` before and after must be identical.

**Done twice now.** 10.6.1 → 11.1.0 (216 commits) and 11.1.0 → 11.5.0 (206 commits). The second was
routine because of the first; these are the additions it produced:

- **Upstream takes migration numbers every cycle.** v40/v41 the first time, v42/v43/v44 the second.
  The lift log has been v40, then v42, now **v45**. Renumber and move on — it is one line plus the
  two `schema_oracle.json` copies plus the `testV**` test names.
- **`Localizable.xcstrings` cannot be merged by indentation.** Upstream now mixes the compact
  one-line style with Xcode's expanded style, at a DIFFERENT indent, and the catalog currently
  contains a genuinely duplicated key (`"%lld of %lld nights"`, which JSON tolerates — last wins).
  A merge script must take the key list from `json.loads` and locate each key's own line, not assume
  a 4-space indent. The working script is described in §4; rebuild it that way if it is gone.
- **Conflicts outside the store are trivial but real.** Both syncs produced one or two: a property
  added at the same spot in `RootTabView`, and both sides appending to `NOOPWidgetBundle`. Keep both
  sides; do not choose.
- **Check the tab wiring by grep after a `RootTabView` conflict.** A build will not catch a lost
  `MoreRow` or a dropped `.sheet`. Grep for `liftLog`, `LiftSessionBar`, `LiftSessionView`.
- **`xcodegen generate` dirties `StrandiOS/Resources/Info.plist` — that is UPSTREAM's drift, not
  yours.** As of 11.5.0 their `project.yml` declares `NSMicrophoneUsageDescription` and
  `NSSpeechRecognitionUsageDescription` (the Coach voice feature) while their committed plist does
  not, so regenerating adds them. `git checkout --` it. Committing it would put an unrelated upstream
  fix in this branch and guarantee a conflict next sync. CI regenerates the plist itself, so the
  built app is unaffected.
- **Confirm the feature code was untouched:**
  `git diff --stat backup/<tag>..lift-log-ui -- 'Strand/Screens/Lift*' 'Strand/Data/Lift*'` should be
  EMPTY. Both syncs left it byte-identical; anything else means a conflict was resolved wrongly.

**Other things to know when you next sync:**

- `FrameRouter.swift` gained ~146 upstream lines in 11.0/11.1 (link epitaphs, clock diagnostics).
  The double-tap de-duplication re-applied cleanly, and `state.onDoubleTap?()` still has exactly
  **one** call site — inside `dispatchDoubleTapOnce`. Re-check that after any FrameRouter merge: a
  new upstream dispatch path that bypassed the dedup would silently reintroduce the phantom set.
- `Localizable.xcstrings` conflicts on nearly every commit. See the merge note in §4.
- Version numbers come from upstream: `MARKETING_VERSION` 11.1.0, iOS build 299. Don't bump them on
  a feature branch.
- Upstream removed the string key `"Skin temperature +%@ °C"` in #1671; the merge correctly took
  that deletion rather than resurrecting it.
- No Android work was needed. The five tables stay pinned `ios_only` in both `schema_oracle.json`
  copies, and the only edit to those files was the migration-id list plus the two folded columns.
  Both copies are still byte-identical, and Android CI passes on the branch.

## 10b. Android — the position, decided 9 Sep 2026

He has no Android device and cannot test one. His instruction: **prioritise iOS; do Android if it
can be done; if not, say so upstream and let someone else take it.** Deciding, not asking:

**What is verifiable without a device.** There is no JDK and no Android SDK on this machine
(checked: `java -version` fails, `ANDROID_HOME` unset, no `android/local.properties`). But **Android
CI runs on GitHub** — `assembleFullDebug` + `testFullDebugUnitTest` on ubuntu — so Kotlin can be
written here, pushed, and compiled/tested there. That is the same authority the project itself uses,
and it is what makes a storage twin possible at all. `SchemaOracleTest` exists precisely to verify
that a Room schema matches the GRDB one, so the feedback is exact rather than guesswork.

**What is realistically doable that way**
- Room entities + DAO + a Room migration for the five tables, and removing the `ios_only` pins from
  both `schema_oracle.json` copies. Verified end-to-end by `SchemaOracleTest`.
- A Kotlin twin of `LiftMetrics`, with the oracle idiom `CLAUDE.md` documents: compile the Swift
  helper standalone, paste its stdout verbatim as the Kotlin expectation.

**What is NOT responsibly doable here**
- The Compose UI. It is a second app's worth of screens whose entire value is ergonomics in a gym —
  a workout sheet you tap between sets, with the phone face-down. Writing it blind and never seeing
  it run would produce something that compiles and is bad to use. Every UI decision this feature got
  right came from a real session (the occupied-machine bug, the carried numbers, the rest band). **If
  the Android UI is required, say so upstream and let an Android user take it.**

**Sequencing.** Do it AFTER the iOS feature settles, not before: a twin tracks the schema, and
twinning a schema that is still moving is rework. The remaining backlog items (§7 add a set, §8
delete a session) look schema-neutral, so the window may open soon.

## 11. What it takes to go upstream, when he says so

He will not open a PR until he is happy with the feature (§1). When he does, this is the shape:

**Ready now**
- The schema commit is self-contained: one migration creating the complete schema, so a schema-only
  PR stands alone.
- The branch rebases onto upstream cleanly by the §10 procedure.
- Every gate CI runs is green, including Android CI.

**A first contact already exists.** [ryanbr/noop#2029](https://github.com/ryanbr/noop/pull/2029) —
two upstream fixes found while auditing (a duplicate string key with divergent French, and an
`Info.plist` drifted from `project.yml`). Small, independent of the Lift Log, opened 9 Sep 2026.
How it is received is useful information about how a feature PR would go.

**Must be decided first — `dist/liftlog-issue.md` asks these, and has never been posted**
- **The Android position is the risk.** The five tables are pinned `ios_only`. `CLAUDE.md` calls
  cross-platform parity "the #1 rule", so a required Room twin is a large piece of work. Everything
  else is small next to this. Do not build more UI on the assumption it is fine.
- Storage shape, screen placement, and the `source: "manual"` workout token.

**Would need doing before submission**
- `dist/` is gitignored and must stay out of the PR. `dist/liftlog-issue.md` is stale (says "three
  commits", predates the rebase) — refresh before it is ever used.
- The commit series is honest but long; upstream may want it squashed into the two-PR split
  (schema, then UI).
- The template's dropdowns are English-only (settled as fine for him — see the review — but a
  10-locale project may want them localized).
- `Tools/make_lift_program_template.py` and `docs/lift-log-program-template.xlsx` are a committed
  build artifact plus its generator; upstream may have an opinion about binaries in the repo.

**A git lesson from this rebase, learned the hard way.** At a conflicted commit during
`git rebase -i`, `git commit --amend` amends the PREVIOUS commit — the conflicted one has not been
committed yet. Doing that silently merged two commits into one under the wrong message. The correct
order is: resolve → `git add` → `git rebase --continue` (which creates the commit) → and only then
amend. Verify a history rewrite by comparing `git rev-parse HEAD^{tree}` before and after: the tree
hash must be identical if only history was meant to change.
