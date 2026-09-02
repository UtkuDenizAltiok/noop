# Lift Log — the handover brief

**Maintained by Claude, from inside the repository. Last verified against the code on 3 Sep 2026,
at commit `8fda1c9d` on branch `lift-log-ui`, rebased onto upstream `v11.1.0`.**

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
| `Sources/WhoopStore/Database.swift` | migrations **`v42-lift-log`** (five tables) and **`v43-lift-log-targets`** (adds `liftProgramItem.targetWeightKg`, `liftSession.sessionRpe`). They were v40/v41 until the 11.1.0 rebase — see §10 |
| `Sources/WhoopStore/LiftMuscle.swift` | the closed **20-token** muscle vocabulary, 4 regions, and `directSetCredit` / `indirectSetCredit` |
| `Sources/WhoopStore/LiftLogStore.swift` | row structs + CRUD + `liftSetCounts` / `liftRpeProfile`; `maxRememberedExercises = 500` |
| `Sources/WhoopStore/DeviceRegistryStore.swift` | all five lift tables listed in `deviceScopedTables` |
| `Tests/WhoopStoreTests/LiftLogStoreTests.swift` | **39 tests**, including the migration-rename pin (§10) |

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

**Base: upstream `v11.1.0`.** The branch was rebased onto `ryanbr/noop` `main` (2787d465) on
3 Sep 2026 — 216 upstream commits, from the 10.6.1 staging point it was originally cut from.
Nine commits on `lift-log-ui` (branched off `lift-log-schema`, which holds the schema commit):

```
8fda1c9d lift log: pin the renumbered migrations against an existing database
1c9243dc lift log: restore the warm-up marker
7af4ef8e lift log: forget an exercise, dismiss the keyboard, and stop phantom double-taps
f84b5c4a lift log: a workout sheet, and a session that outlives its screen
b3c0e861 lift log: the metrics, and the session detail screen that shows them
60317f1c lift log: fix the tap-anywhere mistake, and move set entry into the rest
70fb270a lift log: the session loop, the rest timer and strap double-tap
49b71839 lift log: programs, the exercise vocabulary and muscle classification
f1d0bf24 store: add the v42 schema for the in-app strength log
```

The pre-rebase tips are kept as tags in case anything needs to be read back:
`backup/lift-log-ui-pre-11.1.0` (191386f5) and `backup/lift-log-schema-pre-11.1.0` (a207a447).
Local `main` is now upstream `v11.1.0`.

**Test counts at `8fda1c9d`:** WhoopStore **512** · StrandAnalytics **1756** · StrandTests **1510**
— 0 failures beyond the two locale-dependent `TodayCarryOverTests`. Both app targets build
(macOS `Strand` and iOS `NOOPiOS`); `doc_comment_lint.py` and `i18n_audit.py --ci upstream/main`
both pass, with all ten locales still covered.

*(One test run out of five reported a third failure that did not reproduce and was never named in
the output. If a third failure appears, it is not from this work — get its name before chasing it.)*

## 9. Still outstanding

1. **`dist/liftlog-issue.md` has never been posted upstream.** It is written and current, and asks
   ryanbr about storage shape, the `ios_only` Android position, placement and the source token. Utku
   chose to hold it until the feature had real gym use. **It is a public post in his name — get an
   explicit yes before posting.** `ryanbr/noop` has issues enabled and the maintainer is active.
2. **The feature has had almost no real gym use.** Two sessions: one partly simulated at home, one
   real. Everything below §5 is provisional against actual training.
3. **No PR opened.** The plan is two PRs — schema, then UI. The rebase onto `v11.1.0` is done, so
   the branch is submittable as-is; nothing has been pushed to the fork yet since the rebase, and
   the fork's `origin/*` refs still hold the pre-rebase history (a force-push will be needed).
   Note the two-PR split is now blurred: `v43-lift-log-targets` lives on the **UI** branch, not the
   schema branch, so a clean schema-only PR needs that migration moved down first.
4. **The backlog lives in `dist/LIFT_LOG_REVIEW.md`** — read it. Item 2 (the weekly bar reading
   "done" at the 4-set floor) is the next thing worth fixing.
5. **`dist/` is gitignored** (`.gitignore:96`). These notes live on disk and deliberately never
   reach a commit, so they cannot leak into an upstream PR.

## 10. The 11.1.0 rebase, and the migration rename it forced

The branch was cut from upstream 10.6.1 staging. Upstream then shipped 11.0.0 and 11.1.0, and
**took v40 and v41 for its own migrations** — `v40-daily-skin-temp-absolute` (adds
`dailyMetric.skinTempC`) and `v41-drop-raw-imu-sample` (drops the legacy `rawImuSample` cache). The
lift log's `v40-lift-log` / `v41-lift-log-targets` therefore had to become **`v42-lift-log`** and
**`v43-lift-log-targets`**.

**Read this before touching either migration.** The rename is not a cosmetic renumber:

- GRDB keys applied migrations by identifier, and `DatabaseMigrator.appliedMigrations` intersects
  what the database has recorded with what the code has **registered**. An identifier it does not
  recognise is simply dropped from that set — it does not error, and it does not stop the run.
- So a phone that already ran `v40-lift-log` sees **`v42-lift-log` as unapplied and runs it again**,
  over tables that already exist and already hold a training history.
- An unguarded `CREATE TABLE` or `ADD COLUMN` there throws. **A migrator that throws makes the whole
  database unopenable** — every screen, not just the Lift Log. That is a launch failure, not a
  feature bug.

What makes it survivable: **every statement in both migrations is idempotent.** All five tables and
all seven indexes are created `ifNotExists`, and both `ADD COLUMN`s in v43 are guarded on
`db.columns(in:)`. The indexes and the column guards were added *during* this rebase — the original
v40 only had `ifNotExists` on the tables, which would not have been enough.

`LiftLogStoreTests.testRenumberedLiftMigrationsReRunOverAnExistingDatabaseWithoutLosingData` pins
all of it: it stores real rows, rewinds `grdb_migrations` to the old identifiers, re-runs the real
migrator, and asserts the rows, the v43 column values and the unique indexes all survive. It was
verified to go **red** when either guard is removed. If you touch these migrations, keep it green.

**It was also confirmed end to end on a real database, not only in memory.** The iOS simulator still
had the app data written by the pre-rebase build, so installing the rebased build over it ran exactly
the upgrade path his phone will take. Afterwards `grdb_migrations` reads:

```
v40-lift-log            <- old, orphaned, inert
v41-lift-log-targets    <- old, orphaned, inert
v40-daily-skin-temp-absolute
v41-drop-raw-imu-sample
v42-lift-log            <- re-ran over the existing tables
v43-lift-log-targets
```

and the data is intact: the "Upper A" program, its exercise line, the session with `sessionRpe` 8.0
still set, four logged sets, and all seven `idx_lift*` indexes. Upstream's own two migrations also
did their work (`dailyMetric.skinTempC` added, `rawImuSample` dropped). The Lift Log hub then opened
and rendered the program and the weekly sets-per-muscle bars from that migrated data.

**Note for his phone:** upstream's `v41-drop-raw-imu-sample` DROPS the `rawImuSample` table on
upgrade. That is upstream's decision, not this branch's — the comment on the migration calls it a
"bounded, write-only legacy cache" superseded by the file-backed store, so nothing read it.

The two orphaned identifiers stay in `grdb_migrations` on his phone forever. They are inert — leave
them; a migration that deleted rows from GRDB's own bookkeeping table would be far more dangerous
than two unused strings.

**Other things the rebase touched:**

- `FrameRouter.swift` gained ~146 upstream lines (link epitaphs, clock diagnostics). The double-tap
  de-duplication re-applied cleanly, and `state.onDoubleTap?()` still has exactly **one** call site
  — inside `dispatchDoubleTapOnce`. Re-check that after any future FrameRouter merge: a new upstream
  dispatch path that bypassed the dedup would silently reintroduce the phantom set.
- `Localizable.xcstrings` conflicted on nearly every commit. See the merge note in §4.
- Version numbers now come from upstream: `MARKETING_VERSION` 11.1.0, iOS build 299 (was 10.6.1 /
  243). The build number went **up**, so an AltStore install still updates his existing app in place.
- Upstream removed the string key `"Skin temperature +%@ °C"` in #1671. The merge correctly took
  that deletion rather than resurrecting it.
- No Android work was needed: the five tables stay pinned `ios_only` in both `schema_oracle.json`
  copies, and the only edit to those files was adding `v42-lift-log` / `v43-lift-log-targets` to the
  migration-id list. Both copies are still byte-identical.
