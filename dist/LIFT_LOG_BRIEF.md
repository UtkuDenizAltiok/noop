# Lift Log — the handover brief

**Maintained by Claude, from inside the repository. Fully re-verified on 10 Sep 2026 at commit
`8a3d775e`, branch `lift-log-ui`. **Both upstream PRs are OPEN and one round of review is answered.**

This file is the single thing a fresh session needs. It assumes you know nothing about this work: no
memory of it, no context beyond this repository. Read it fully, then read `dist/LIFT_LOG_REVIEW.md`
for the prioritised backlog.

If you change the feature, **update both files before your context runs low.** They are the only
thing standing between the next session and a re-derivation from scratch. Treat that as part of
finishing the work, not as an extra.

---

## 0. Start here

**The state is good.** Everything is committed, pushed and green (§8). Nothing is half-finished and
nothing needs rescuing. If the user asks for something new, just do it.

**Before you touch the feature, read §2b — the invariants.** Fifteen rules, nearly all of them paid
for with a real bug. A change that violates one is a regression even if it compiles and every test
passes, which has happened three times.

**The four things most likely to catch you out:**

1. **No CI compiles the app targets.** `swift test` passing means nothing about whether the app
   builds. Build BOTH `Strand` (macOS) and `NOOPiOS` yourself — the macOS build has caught real
   errors the iOS one missed. Run `xcodegen generate` first if you switched branches.
2. **Exactly two tests fail, always**, and they are not yours: `TodayCarryOverTests` (2), which
   compare a US date format on an English-language/German-region machine. They fail identically on a
   clean upstream checkout. Do not chase them; do not "fix" them with `-testLanguage` (§4).
3. **Every new on-screen string needs all nine translations** or `i18n-coverage.yml` fails. Budget
   for it — it is a real part of every UI change here.
4. **This feature's bugs are silent wrong data, not crashes.** Sets recording nothing, a metric
   computed two ways, 45.5 kg stored as 455. All three passed every test and every build. **Run the
   app and look**, and when you write a test for a fix, break the fix first and watch the test go
   red (see [[lift-log-verify-before-claiming]]).

**How the user works:** he is not a programmer, tests at the gym, wipes and reinstalls on most
updates, and his reports are precise and worth taking literally. See §1.

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

**Finishing a change means SHIPPING it, not offering to.** Stated plainly on 10 Sep 2026: every
previous session ran the testing build itself after any change, so the new `.ipa` was waiting on the
fork's releases page without him asking. **He does not use the terminal — giving him a command to run
is not delivery.** So the last step of any change to the feature is: commit, push, run the build (§4),
and tell him the release now shows the new commit hash — **and whether this one needs a WIPE or is
just an update** (§4 has the rule; decide it, never leave it to him).

**Never ship a broken build.** His words, 10 Sep 2026. Both app targets must build and the suites must
be green before the workflow is dispatched; a knowingly half-finished branch is the one case where you
ask first instead.

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

**The plan bends during the session.** Each exercise ends in an "Add set" row — a plus that appends a
set and a minus that drops the last planned one — and **both rewrite the program's line**, because a
program is a plan for next time and the sets actually chosen are the better plan. The minus only ever
removes a PENDING last set (invariant 17).

**The session stays on the machine you are at.** Any pending set can be started at any time, so
skipping a busy exercise leaves an EARLIER slot uncompleted. Finishing a set therefore moves to the
next set of the SAME exercise, and only falls back to plan order once that exercise is done
(`LiftSessionEngine.slotAfter`). Plan order alone sent the user back to the machine they had walked
away from after every set. **Do not simplify this back.**

**Any set's numbers can be typed at any time.** A set that has been performed is edited in place; one
that has not is held in `LiftSessionController.pendingValues` and applied the instant it is recorded,
where it BEATS the carried plan. Being mid-set on one machine is not a reason to refuse a correction
to another row — see invariant 19.

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

1. **The migration is `v46-lift-log`.** It has moved three times (v40 → v42 → v45 → v46) because upstream keeps
   taking the numbers. Expect to move it again; §10 has the procedure.
2. **The store READS rows; `LiftMetrics` COMPUTES.** One exception, deliberate:
   `WhoopStore.liftSetCounts` aggregates in SQL so the hub's 7-day card does not load every set.
   Every other store function is a plain read, and every metric has exactly ONE implementation.
   Adding a second implementation of any figure is how both of this feature's metric bugs happened —
   don't.
3. **Sets-per-muscle is computed in TWO places and they must agree.** `WhoopStore.liftSetCounts`
   (SQL, the hub's weekly card) and `LiftMetrics.muscleCounts` (in memory, the session detail). Both
   exclude a muscle listed as both primary and secondary. `LiftMetricsStoreAgreementTests` pins them
   against EACH OTHER — keep it green, and if you add a third consumer, add it there too.
4. **`advance` follows `slotAfter(_:)`, never `nextPendingSlot`.** Finish the exercise you are at,
   then fall back to plan order. Plan order alone drags the user back to a machine they left.
5. **A completed set records `carry(for:lastSession:)`** — the numbers the sheet was showing. Never
   nil. And **RPE is never carried**: it is knowable only after the set, and carrying it would make
   the RPE coverage card claim every set was rated.
6. **Every readout on the session surfaces always renders, dashed when empty.** A readout that hides
   itself is indistinguishable from a missing feature — that is how the HR gap was first reported.
7. **Effort is never modified.** A session saves `strain: nil`; the engine fills it from measured HR.
8. **Warm-ups are excluded** from volume and per-muscle counts, on both sides.
9. **`LiftMuscle` raw values are a stored-data contract.** Never rename or remove a case. Adding one
   is safe — but update `Tools/make_lift_program_template.py`'s `MUSCLES` too, or the new group is
   importable by typing and missing from the template's dropdown.
10. **Never use `String(localized: "Rest")` on this screen.** That key is NOOP's SLEEP metric and
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
16. **The spreadsheet import is a convenience, not part of the feature.** It calls only the three
   store APIs the program editor already used, adds no write path, and touches one button in the
   hub. If it ever conflicts with the core, the core wins and the import can be deleted whole.
17. **The minus only ever drops a PENDING last set.** Set numbers are POSITIONS — the sheet draws
    `1...targetSets` — so removing from the middle would renumber what was already recorded, and a
    completed set is data rather than a plan. The set being worked or rested from is excluded for the
    same reason. Both cases DIM the control (invariant 6: a control that vanishes reads as broken).
18. **The plan travels in the undo snapshot**, with the stage and the sets, and is restored with them.
    A stage saved under one set count is only meaningful under that count: undoing past a removed set
    would otherwise leave the session working a slot the sheet no longer draws, and completing it
    would write a set nobody could see. This is why `plan` is `private(set) var`, not `let`.
19. **Typing is never refused, but typing never CREATES a set.** Both halves are load-bearing and
    they used to be in conflict: `write` could only edit a set that already had a record, so every
    keystroke into a pending row was silently dropped ("it refreshes to the empty", 11 Sep 2026). The
    engine rule stays — appending on a keystroke would make a set nobody performed into data — so the
    numbers are HELD in the controller and applied when the set is recorded, beating the carry, with
    untouched fields still carrying. The entry is consumed, so a redo shows ghosts again. If you ever
    add another way to enter a number, route it through `LiftSessionController.updateSet`, which is
    the single place that decides where a value lands.

20. **A string that never reaches the CATALOG is invisible to CI.** `i18n-coverage.yml` is
    diff-scoped over `Localizable.xcstrings`, so a `String(localized:)` whose key was never added to
    the catalog has nothing in the diff to fail on — it just renders English in all nine locales.
    **Fifty-one of this feature's 205 strings were in that state** and four gym sessions never
    revealed it, because he runs the app in English. The authority is the COMPILER, not a grep: every
    build emits a `.stringsdata` per source file listing the keys it extracted. Check with
    `Lift*.stringsdata` under `Build/Intermediates.noindex/.../Objects-normal/arm64` against the
    catalog after any UI change. Two corollaries, both paid for: Swift interpolation produces `%@` /
    `%lld` KEYS (the positional `%1$@` form belongs only in the VALUES, and a catalog key written
    positionally never matches), and a value whose specifier disagrees with its key is worse than an
    untranslated one — `%@ reps` and `%lld reps` are two different keys and both are needed.
21. **A generic English word is never safe as a key.** `"Rest"` was NOOP's sleep metric (invariant
    10); `"Push"` is the TODAY screen's readiness nudge, which renders 推送 (push NOTIFICATION) in
    Chinese and "Вперёд" (forward) in Russian. The muscle-picker regions are therefore
    `"Push muscles"` / `"Pull muscles"` / `"Leg muscles"` / `"Trunk muscles"` — the same escape
    `"Rest period"` took. Grep the catalog for any bare one-word key before using it.
22. **A de-duplication memory must be a SET, not a slot.** `FrameRouter`'s double-tap de-dup kept
    only the last dispatched `event_timestamp`, which suppresses a replay only when the replayed
    event is the most recent one dispatched. Two taps interleaved with their replays measured FOUR
    dispatches; three taps across an offload that re-walks its log measured TWELVE. Bounded by
    `liveGestureWindowSeconds` plus a hard cap. Any future "have I already seen this?" guard on the
    BLE path wants the same shape — a batch replays in whatever order it likes.
23. **Say what a number IS, next to numbers that are measured.** Fractional set counts and the
    4-sets-a-week tick are MODELLED, and they sit beside "Effort — measured from heart rate". Both
    per-muscle cards carry `· estimated`, both explainers name the user's own classification as the
    source, and the tick is framed as a research reference across GROUPS, not a personal target. The
    work-vs-rest caption said "under load" when the figure is set start to set end — now "in sets".
    The rule: a caption may not imply a measurement the app did not take.
## 3. Where everything lives

### Storage — `Packages/WhoopStore`
| File | What |
|---|---|
| `Sources/WhoopStore/Database.swift` | ONE migration, **`v46-lift-log`** — five tables, seven indexes, complete schema. It has been v40, v42, v45, now **v46**: upstream takes the number every single cycle. See §10 |
| `Sources/WhoopStore/LiftMuscle.swift` | the closed **20-token** muscle vocabulary, 4 regions, and `directSetCredit` / `indirectSetCredit` |
| `Sources/WhoopStore/LiftLogStore.swift` | row structs + CRUD + `liftSetCounts`; `maxRememberedExercises = 500`. `deleteLiftSet` was REMOVED in the pre-PR audit — uncalled, untested, and `deleteLiftSession` already cascades to its sets |
| `Sources/WhoopStore/DeviceRegistryStore.swift` | all five lift tables listed in `deviceScopedTables` |
| `Tests/WhoopStoreTests/LiftLogStoreTests.swift` | **38 tests** (the migration ones are named `testV46…`) |

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
| `Data/LiftSessionEngine.swift` | the **slot-based state machine**. Pure; time enters as a parameter. `addSet` / `removeSet` / `canRemoveSet` move a line's set count, bounded by `maxSetsPerExercise` (20) |
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
- `LiftSessionEngineTests.swift` — **52 tests**
- `LiftSessionPendingInputTests.swift` — **9 tests**. The controller seam: typing into a set you are
  not currently doing. Drive the controller directly (`@MainActor`), since the bug lived between the
  view and the engine and neither alone could catch it.
- `LiftSessionPersistenceTests.swift` — **5 tests**. Small, and load-bearing for something no other
  test answers: whether a snapshot written by the PREVIOUS build still reads, which is what decides
  wipe-or-update (§4). Written as literal JSON on purpose — encoding with today's `Snapshot` would
  only prove the build can read itself.
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
# then, always: commit, push, and RUN THE TESTING BUILD (below) so the .ipa is on his releases page
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

### Getting a build onto his phone — RUN THIS YOURSELF, every time
Not optional, and not something to offer: he does not use the terminal, and pushing code does not
build anything. Until this runs, the releases page still holds the PREVIOUS build.
```bash
gh workflow run "Testing build (fork)" --repo UtkuDenizAltiok/noop --ref lift-log-ui
gh run watch <id> --repo UtkuDenizAltiok/noop --exit-status    # ~13 min
```
The `.ipa` lands at the fork's rolling `testing-latest` release. He installs with AltStore. The iOS
bundle id is `com.noopapp.noop` — the same as his existing sideload, so it **updates in place and
keeps his data**. If a run fails in ~2 minutes with a dependency-clone error, that's the runner's
network, not the code: **re-run it.**

**Tell him how to verify he has the right build:** the release title ends in the commit hash it was
built from (`NOOP Staging — base 11.5.0 · <date> · 8017691`). The tag is always `testing-latest`, so
the URL never changes and the assets are replaced in place —
`https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest`. He can also start a build from
the web UI himself: **Actions → "Testing build (fork)" → Run workflow → branch `lift-log-ui`**.

### Wipe, or just update? Say which, with every build
Asked for on 10 Sep 2026. He had been wiping on EVERY update out of caution — removing AltStore and
NOOP, forgetting the strap, deleting its recorded data, then re-pairing — which costs him a re-pair
and his history every single time. Most updates do not need it. **Decide, and tell him in one line.**

**Just update** (install over the top; data and pairing are kept) when nothing already on his phone
changes meaning. The bundle id `com.noopapp.noop` is unchanged, so AltStore updates in place:
- UI, app-layer logic, analytics computation, new screens;
- a field ADDED to the UserDefaults session snapshot as OPTIONAL — it decodes as nil
  (`LiftSessionPersistenceTests` pins exactly this, by decoding literal JSON written the old way);
- anything under `Packages/` that only computes.

**Wipe** when data already stored cannot be trusted to read the same way:
- the **migration was renumbered** (every upstream sync so far has taken our number: v40 → v42 → v45).
  GRDB keys applied migrations by identifier, so the old id is unrecognised and the migration RE-RUNS
  over tables that already exist. Today every create is `ifNotExists` and it is a harmless no-op — but
  the moment one is not, the migrator throws, `Repository.ensureStore()` returns nothing, and **NOOP
  opens as an empty shell on every launch until reinstalled** (§10). That failure is not confined to
  the Lift Log;
- a shipped migration was EDITED rather than added (never do this);
- a stored column changed shape or meaning — this project deliberately changes shape rather than
  writing a migration *because* he wipes, so those changes are exactly the ones that require it;
- a row struct gained a field old rows do not carry.

**When in doubt, say wipe.** A wipe costs a re-pair; the thing it prevents is the app not opening.

**Worked example — `8017691a` (add/drop a set): just an update.** No schema change (nothing under
`Packages/`), and the only persisted-shape change was the optional `programItemId` on the in-flight
session snapshot. A session running when he installs even resumes, minus the program write-back for
that one session. Verified, not assumed: three tests decode a snapshot written the old way.

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
in your hands. That is a statement about WHEN it is convenient, not a restriction: since 11 Sep 2026
any set's numbers can be typed at any time, including a set that has not happened yet (invariant 19).

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

**Status after two full sessions (9 and 10 Sep 2026): effectively resolved.** One phantom advance in
the first, and "a few, might be physical" in the second — against something that was previously
frequent enough to be reported as a defect. **Do not change this code on that evidence.** The next
useful datum is whether the strap had just synced when one happened, not another edit. What follows
is the original diagnosis, kept because it is the reasoning any future change has to engage with.

Not a pass and not a Before the fix it was frequent enough to be reported as a defect, so once is a large
improvement — but it is not zero, and one observation is not a diagnosis. **Do not change this code
again on the strength of it.** Get evidence first: whether the strap was mid-offload when it
happened. A second, unrelated cause is entirely plausible — `AppModel.handleDoubleTap`'s 1.2 s
debounce is still all that separates two genuine taps from one gesture, and a knock against a
loaded bar is a real event, not a replay.

## 8. Where it stands

**Base: upstream `main`, 57 commits past `v11.5.0`.** Third sync, done 11 Sep 2026 as part of a
full pre-PR audit. Twenty-six commits on `lift-log-ui` (branched off `lift-log-schema`, which holds
the schema commit). `git log --oneline upstream/main..lift-log-ui` is the current list; the head is
`04d9c1a0`.

The schema commit is **self-contained** — it creates the complete schema in one migration, so a
schema-only PR stands alone.

### What the pre-PR audit found (11 Sep 2026)

Run before proposing the feature upstream. Six real findings; **CI could not have caught four of
them**, which is the point worth carrying forward.

1. **Upstream had taken v45** (`v45-rr-source-index`). Renumbered to **`v46-lift-log`** — migration,
   both oracle copies, the `testV46…` test names, the `DeviceRegistryStore` comment and the oracle's
   own reason text. Three for three: assume it happens again.
2. **The schema commit carried 12 files of upstream RELEASE RESIDUE** — `project.yml` and
   `build.gradle.kts` build-number bumps, `AppChangelog` entries and eight `strings.xml` files, all
   swept in by an earlier rebase. Removed; the commit went from 19 files to 7 and is now genuinely
   schema-only. **Check this before any future PR**: a rebase can quietly re-attach them.
3. **Fifty-one of 205 strings were never in the catalog** — see invariants 20 and 21. The biggest
   finding, entirely invisible to CI and to four gym sessions run in English.
4. **`deleteLiftSet` was dead API** — no caller, no test, and `deleteLiftSession` already cascades.
   Removed, following the precedent that deleted `liftRpeProfile`.
5. **Upstream landed `MuscleGroups` (#1968)**, a name-derived matcher over a 13-group vocabulary.
   Not a conflict — see §11 — but the PR has to address it explicitly.
6. **Upstream merged [#2029](https://github.com/ryanbr/noop/pull/2029)** (the unrelated hygiene PR)
   within a day, with one review. That is the only real evidence available about how a feature PR
   would be received, and it is encouraging. It also fixed the `Info.plist` drift, so
   `xcodegen generate` no longer dirties the tree.

**Test counts at `04d9c1a0`, all re-run 11 Sep 2026:** WhoopProtocol **704** · WhoopStore **579** ·
StrandAnalytics **2000** · StrandImport **317** · StrandTests **1823**. Zero failures anywhere except
the two locale-dependent `TodayCarryOverTests`, which fail identically on a clean upstream checkout
(this machine is English-language/German-region) — **do not chase them, and do not "fix" them with
`-testLanguage`**, which trades them for a different failure (see §4).

Both app targets build with no warnings from any Lift Log file; `doc_comment_lint.py` and
`i18n_audit.py --ci upstream/main` pass; both `schema_oracle.json` copies are byte-identical; Android
CI passes on the branch.

**Four real gym sessions have been run on this feature** (9-10 Sep 2026), and everything that could
only be tested with a strap is confirmed working: the Lock Screen activity with HR and reps x weight
and ticking seconds, ghost values carrying across sessions, and the spreadsheet import on a real
device. Every one of the four found something, and **three of the four findings were silent wrong
data rather than anything that looked broken**. Neither the plus/minus set row nor typing into a set
you are not doing has been used in a gym yet.

## 9. Still outstanding

1. **No known gaps remain.** §7 of the review — logging a set the program did not plan — was the last
   one and is FIXED in `8017691a`: a plus/minus row at the end of each exercise, which also rewrites
   the program's line. He asked for it directly on 10 Sep 2026, so the backlog's "confirm it bites
   first" note is spent. **It has not yet been used in a real gym session** — that is the next thing
   worth asking about. The review's "What to do first" table is now all quality rather than gaps.

2. **Ask what actually happened in a session; do not infer from the backlog.** Four sessions have now
   produced findings, and the backlog predicted almost none of them — the occupied-machine bug, sets
   recording nothing, decimal weights, and the wrapped header were all found by using it. Meanwhile
   §7, the item the backlog ranked first, never came up in a session — it was asked for directly
   instead. The plus/minus row that answers it has not been used in a gym yet either: ask.

3. **BOTH PRs ARE OPEN** — [#2098](https://github.com/ryanbr/noop/pull/2098) (schema + Room twin)
   and [#2099](https://github.com/ryanbr/noop/pull/2099) (the app). Opened 11 Sep 2026. **Do not
   touch either branch while review is pending**; see §11.

4. **[ryanbr/noop#2029](https://github.com/ryanbr/noop/pull/2029) was MERGED** on 10 Sep 2026,
   within a day, with one review — the hygiene PR (a duplicate string key with divergent French, and
   a drifted `Info.plist`). It is the only evidence there is about how a feature PR would be
   received, and it is encouraging. It also fixed the plist drift, so `xcodegen generate` no longer
   dirties the tree.

5. **`dist/liftlog-issue.md` is now dead.** It was going to ask ryanbr four design questions; the two
   PRs answer all four in the open. Do not post it.

6. **`dist/` is gitignored** (`.gitignore:96`). These notes live on disk and deliberately never reach
   a commit on `lift-log-ui`, so they cannot leak into an upstream PR. They ARE versioned on the
   orphan branch `lift-log-notes` — see [[lift-log-docs-are-mine]] for how to commit there WITHOUT
   switching branches, which would clobber them.

## 10. Syncing with upstream — the routine, and the one trap

The branch was cut from upstream 10.6.1 staging. **Upstream has taken the lift log's migration
number on every sync so far**, so it has been v40, then v42, and is now **`v46-lift-log`**:

| Sync | Upstream took | Ours became |
|---|---|---|
| 10.6.1 → 11.1.0 | v40 skin-temp, v41 drop-rawImuSample | `v42-lift-log` |
| 11.1.0 → 11.5.0 | v42 sleep-hr-only, v43 coach-messages, v44 ppg-waveform | `v45-lift-log` |
| 11.5.0 → main (+57) | v45 rr-source-index | **`v46-lift-log`** |

As of 11 Sep 2026 upstream's newest is **v45-rr-source-index**, so ours is now **v46**. Assume the
next sync takes it again; it has happened three times out of three.

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

## 10b. Android — SUPERSEDED by §11; the storage twin shipped in #2098

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
twinning a schema that is still moving is rework. Both of the items that were outstanding here —
§7 add a set and §8 delete a session — have now landed WITHOUT touching the schema, so the window is
as open as it has been.

## 11. Upstream — both PRs open, ROUND ONE OF REVIEW ANSWERED (11 Sep 2026)

| PR | What | Branch |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | the `v46-lift-log` schema, its Room twin, and the Android delete/re-key set | `lift-log-schema` (3 commits) |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | `lift-log-ui` (28 commits on top) |

**#2099 depends on #2098**, which must be taken first — the maintainer said so explicitly.
**Upstream CI runs MORE than the fork's:** `app-build.yml` is disabled on the fork but compiles both
app targets on an upstream PR. Build both locally before pushing to either branch.

### What review asked for, and what was done

**ryanbr on #2098 — the Android delete list did not move with the Swift one.** Correct, fixed in
`203b2b82`: five DELETEs, five re-key twins, three hand-written DAO fakes updated, the explicit
`expectedTables` set extended. `deleteDeviceDataCallsEveryDaoDeleteMethod` cannot catch this class —
a table with NO method is absent from `declaredMethods`, so the count it compares is short on both
sides and balances.

**Its rationale was corrected, politely, in the reply.** The cited v38 precedent says a `.noopbak`
restored FROM iOS carries the rows. It cannot: `DataBackup.importFrom` is the only restore entry
point, classifies anything carrying `grdb_migrations` as `BackupOrigin.MAC`, and rejects it. That
landed 2026-06-27; the v38 comment reasoning from it landed 2026-08-18, and the MAC branch has no
test. **Verify a stated mechanism before building on it — that is twice now**, the same claim having
nearly reached the PR earlier as a benefit.

**ryanbr on #2099 — the double-tap de-dup only caught consecutive duplicates.** Real, and worse than
reported: measured FOUR dispatches for two interleaved taps and TWELVE for three across a re-walked
offload, before any fix. Now invariant 22. The test needed a second gesture on ONE router, so the
fixture frame is minted with a rewritten `event_timestamp` and recomputed CRC32, guarded by a test
that the mint actually parses.

**ryanbr — `LiftMetrics` has no Kotlin twin.** Accepted as a stated gap, written into the PR body.
Deliberately not done there: the presentation layer moved in the same push, and porting a layer whose
shape is still moving is how platforms drift. Pure functions; it can follow via the `CLAUDE.md` oracle
idiom.

**ryanbr — the CI workflow commit.** Dropped (second concern, and it edited a workflow for a feature
not on the default branch). Kept reachable on the fork as the tag `fork/ships-template` — cherry-pick
it if his testing builds should carry the `.xlsx` again.

**Community review (Discord) — estimates dressed as measurements.** The strongest criticism anyone has
made of this feature, and acted on: now invariant 23. Note what was NOT done — no metric was removed.
The reviewer suggested simplifying the analysis layer; the diagnosis (rough models looking precise) was
right, the remedy (delete) was not the only one, and labelling is cheaper and more honest.

**Community review — StrandDesign.** Fair: the box should not have been ticked without measuring.
Colours and text styles were already 100% tokens. 22 raw spacing literals that exactly equalled a
`NoopMetrics` value now use it — identical rendering, so the hardware testing still stands. The rest is
micro-spacing with no token, measured per-kloc against `TodayView`, `WorkoutsView`, `SleepView` and
`LiveView`, and at the same density. **Measure against the codebase before accepting a style
criticism**: the claim was directionally right and quantitatively overstated.

### Still to do

- **Rebase #2099 onto #2098 once that lands**, so the diff reads as the UI PR it is meant to be.
- Answer whatever comes back. Do not force-push either branch except in response to review.

### The Android position, as landed

The storage twin is IN #2098 and Android CI verifies it, so parity is closed by the project's own
oracle rather than by argument. The DAO, the Compose screens and the Kotlin `LiftMetrics` are stated
gaps in the PR bodies, for an Android user to take.

### `MuscleGroups` (#1968) — the argument used

Upstream landed a name-derived matcher over 13 groups while this branch was out. Its own header says
"published attribution wins where a source provides it and this matcher is the fallback for the
sources that do not". **The Lift Log is a source that provides it** — the user assigns the
classification and it is snapshotted onto every set — so the two do not compete: stored attribution
wins for sets logged in NOOP, the matcher stays the fallback for Hevy/Liftosaur imports. The lossy
20→13 bridge is offered as a separate PR, not smuggled in.

### If they ask for changes

- **Squash.** 25 commits is a lot; the two-PR split is already the natural seam. Offer it.
- **The `.xlsx` template** is a committed build artifact plus its generator — they may object to a
  binary in the repo. The import is a convenience (invariant 16) and can be dropped whole.
- **`dist/` is gitignored** and stayed out of both PRs. Verified: `git diff --stat` shows no `dist/`.
