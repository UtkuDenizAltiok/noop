# Lift Log — the handover brief

**Maintained by Claude, from inside the repository. Last verified against the code on 3 Sep 2026,
at commit `ff3312bd` on branch `lift-log-ui`, rebased onto upstream `v11.1.0`.**

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

**The session outlives its screen.** Swiping the sheet down *minimises* to a bar above the tab bar,
reachable from every tab; the clock, the strap gesture and the buzzes keep running.

**Advancing.** Exactly two deliberate inputs: the on-screen button, or a **double-tap on the WHOOP
strap** (so the phone can stay face-down on a bench). One strap buzz confirms a double-tap
registered; three buzzes mean the rest is nearly up.

**Metrics.** Six figures per session, every one arithmetic the user can redo by hand from the sets
on the same screen. No composite "workout score".

## 3. Where everything lives

### Storage — `Packages/WhoopStore`
| File | What |
|---|---|
| `Sources/WhoopStore/Database.swift` | ONE migration, **`v42-lift-log`** — five tables, seven indexes, complete schema. It was v40 plus a v41 follow-up until the 11.1.0 rebase; see §10 |
| `Sources/WhoopStore/LiftMuscle.swift` | the closed **20-token** muscle vocabulary, 4 regions, and `directSetCredit` / `indirectSetCredit` |
| `Sources/WhoopStore/LiftLogStore.swift` | row structs + CRUD + `liftSetCounts` / `liftRpeProfile`; `maxRememberedExercises = 500` |
| `Sources/WhoopStore/DeviceRegistryStore.swift` | all five lift tables listed in `deviceScopedTables` |
| `Tests/WhoopStoreTests/LiftLogStoreTests.swift` | **38 tests** |

Tables: `liftExercise`, `liftProgram`, `liftProgramItem`, `liftSession`, `liftSet`.

### Metrics — `Packages/StrandAnalytics`
| File | What |
|---|---|
| `Sources/StrandAnalytics/LiftMetrics.swift` | volume load, session load, work/rest, Epley 1RM, RPE profile, muscle counts, `ReferenceDose`. **Pure** — no store, no clock, no UI |
| `Tests/StrandAnalyticsTests/LiftMetricsTests.swift` | **29 tests** |

### App layer — `Strand/` (compiles into **both** macOS `Strand` and iOS `NOOPiOS`)
| File | What |
|---|---|
| `Data/LiftSessionEngine.swift` | the **slot-based state machine**. Pure; time enters as a parameter |
| `Data/LiftSessionController.swift` | `@MainActor ObservableObject` owning the engine, the 1-second tick, buzz gating, persistence and the strap claim |
| `Data/LiftSessionPersistence.swift` | crash-safe `Codable` snapshot in UserDefaults (`noop.activeLiftSession`) |
| `Data/LiftMuscleNames.swift` | app-layer localized display names (WhoopStore holds no UI strings) |
| `Data/LiftFormat.swift` | kg/lb conversion + number and duration formatting |
| `Data/HapticPrefs.swift` | adds the `haptics.liftRest` gate |
| `Screens/LiftLogView.swift` | the hub: programs, weekly sets-per-muscle, session history |
| `Screens/LiftProgramEditorSheet.swift` | program name/note + ordered exercise lines |
| `Screens/LiftProgramItemSheet.swift` | one line: exercise picker (with forget), muscle classification, targets |
| `Screens/LiftSessionView.swift` | the workout sheet + control bar + finish sheet |
| `Screens/LiftSessionBar.swift` | the minimised session bar |
| `Screens/LiftSessionDetailSheet.swift` | a finished session read back in full |
| `Screens/KeyboardDismiss.swift` | `dismissesKeyboardOnTap` helper |
| `BLE/FrameRouter.swift` | **double-tap de-duplication** (see §6) |
| `App/AppModel.swift` | `strapDoubleTapOverride` |

### iOS shell — `StrandiOS/`
- `App/StrandiOSApp.swift` — creates `LiftSessionController` (injecting buzz + strap claim), injects it as an environment object.
- `App/RootTabView.swift` — `MoreDestination.liftLog`, the `MoreRow("Lift Log", "dumbbell.fill", .liftLog)` in `moreSection("Body")`, the session bar via `.safeAreaInset(edge: .bottom)`, the session sheet, and the `.task` that resumes an interrupted session **as the bar, not as a sheet**.

### App-target tests — `StrandTests/`
- `LiftSessionEngineTests.swift` — **32 tests**
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
Merge on KEYS instead; the 11.1.0 rebase used a throwaway script that took the base file verbatim
plus every entry `theirs` added relative to the merge base (`git show :1:/:2:/:3:`), which also
preserves upstream deletions instead of resurrecting them. Three traps found the hard way:
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
affects every double-tap consumer, not just the Lift Log. **It has not yet been confirmed on real
hardware.**

## 8. Where it stands

**Base: upstream `v11.1.0`.** Rebased onto `ryanbr/noop` `main` (2787d465) on 3 Sep 2026 — 216
upstream commits, from the 10.6.1 staging point it was cut from. Nine commits on `lift-log-ui`
(branched off `lift-log-schema`, which holds the schema commit):

```
ff3312bd lift log: describe the targets the editor actually has
921a3d6e lift log: restore the warm-up marker
7e425399 lift log: forget an exercise, dismiss the keyboard, and stop phantom double-taps
b2e23bd3 lift log: a workout sheet, and a session that outlives its screen
9f9241e5 lift log: the metrics, and the session detail screen that shows them
9e2c5df2 lift log: fix the tap-anywhere mistake, and move set entry into the rest
cd07cf5e lift log: the session loop, the rest timer and strap double-tap
e21c4c33 lift log: programs, the exercise vocabulary and muscle classification
405de03b store: add the v42 schema for the in-app strength log
```

The schema commit is **self-contained** — it creates the complete schema including
`targetWeightKg` and `sessionRpe`, so a schema-only PR stands alone. (Those two arrived as a second
migration during development; folding them in was safe because nothing has shipped and Utku wipes
on every update.)

Pre-rebase tips are kept as tags: `backup/lift-log-ui-pre-11.1.0`, `backup/lift-log-schema-pre-11.1.0`
and `backup/lift-log-ui-before-fold`. Local `main` is upstream `v11.1.0`.

**Test counts at `ff3312bd`:** WhoopStore **510** · StrandAnalytics **1756** · StrandTests **1510**
— 0 failures beyond the two locale-dependent `TodayCarryOverTests`. Both app targets build;
`doc_comment_lint.py` and `i18n_audit.py --ci upstream/main` pass with all ten locales; Android CI
passes on the branch (that is what exercises `SchemaOracleTest`, NOT the testing-build workflow,
whose Android job only compiles APKs).

Verified on a fresh install in the simulator: one migration applied, all five tables, column order
matching the row structs, and the Lift Log hub rendering its empty state correctly.

## 9. Still outstanding

1. **`dist/liftlog-issue.md` has never been posted upstream.** It asks ryanbr about storage shape,
   the `ios_only` Android position, placement and the source token — question 3 is the risky one,
   since `CLAUDE.md` calls cross-platform parity "the #1 rule" and a required Room twin would be a
   large piece of work. It was offered on 3 Sep 2026 and he declined for now: he is not going
   upstream until he is happy with the feature. **Do not post it.** It is a public post in his name
   and needs an explicit yes. Note the text is stale — it says "three commits" and predates the
   rebase — so refresh it before it is ever used.
2. **Real gym use is now happening continuously** (see §1), but the UI judgements in
   `LIFT_LOG_REVIEW.md` were written before that. Ask him what actually went wrong in a session
   rather than assuming the backlog's guesses still describe the problems.
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

**A git lesson from this rebase, learned the hard way.** At a conflicted commit during
`git rebase -i`, `git commit --amend` amends the PREVIOUS commit — the conflicted one has not been
committed yet. Doing that silently merged two commits into one under the wrong message. The correct
order is: resolve → `git add` → `git rebase --continue` (which creates the commit) → and only then
amend. Verify a history rewrite by comparing `git rev-parse HEAD^{tree}` before and after: the tree
hash must be identical if only history was meant to change.
