# Workflow

How work on NOOP 13 is done. The app's `AGENTS.md` and `docs/CONTRIBUTING.md` still apply; this page adds what
this project and its owner need. Commands run from `~/Developer/noop/app` (the app checkout); the handbook's tools
are reached there as `dist/tools/` (a link to `../handbook`), and each tool explains itself in its first lines.

## 1. Privacy: what stays on the owner's Mac

The `main` and `handbook` branches are public. The owner's personal data never goes into either, in any commit.

- **Private** means anything about Utku as a person: his strap logs, backups and developer files; heart rate, HRV,
  sleep stages or any reading from the owner's nights and days, with or without times; device and phone-usage
  figures (MetricKit, battery); where he is (time zone, places); age, body or health details; his messages quoted
  beyond the project decision they record.
- **Where it lives:** `~/Developer/noop/noop-private-utku/` (outside every repository). The handbook reaches it as
  `handbook/private` (a link, ignored by git), so the tools' inbox and event log (`dist/private/lab-inbox/`,
  `dist/private/events.log`) land there. Its `README.md` lists what is inside.
- **The owner allows the working agent to read and use it** to develop and check NOOP (27 Nov 2026): his real
  nights are the best evidence there is. Use it locally; publish only conclusions that contain none of it, worded as
  "checked on the owner's nights (private)", never his numbers.
- **Before every push**, run `bash dist/tools/privacy-check.sh` (it scans the handbook and the app's tracked
  docs for the usual leaks: figures from the owner's nights, a phone model, MetricKit figures, places, e-mail
  addresses). Fix every hit or
  explain why it is not personal. Commits use the GitHub noreply address already set in `git config user.email`.
- Public PSG datasets (PhysioNet sleep-accel) are not private; a restricted one (DREAMT) is used locally and only
  its aggregates are published.

## 2. Verification

`bash dist/tools/verify.sh` runs the whole loop, cheapest first, and names each log: package tests (WhoopStore,
StrandAnalytics, StrandImport), doc-comment lint, the i18n gate against `origin/main`, parity ledger, parity ratchet,
parity governance tests (on a clean checkout of HEAD), `xcodegen`, macOS tests, iOS build. `--quick` skips the Xcode
app targets. For another worktree: `NOOP_REPO=<path> bash dist/tools/verify.sh`. About 25 minutes in full.

- **Commit before `verify.sh`, and run one at a time** (it tests a clean checkout of HEAD; two runs share the build
  cache and the macOS test host). A failing step does not stop the run; read every step's line.
- **Android is tested on GitHub:** `gh workflow run "Android CI" --repo UtkuDenizAltiok/noop --ref <branch>` for any
  change under `android/`; the phone build only assembles Android, so a broken Kotlin test would still ship green.
- **Build both Apple targets locally** (`Strand` for macOS, `NOOPiOS` for iOS); nothing else compiles app-target
  Swift before shipping. `xcodegen` rewrites `StrandiOS/Resources/Info.plist`: `git checkout` it afterwards.
- **A new test must be seen to fail:** copy the changed file aside with its sha256, break the rule, run the test,
  watch it go red, restore, `shasum -c`. Tests run inside a copy of NOOP on the Mac: fail, never crash.
- **A failing GitHub run emails the owner.** Announce a run that is meant to fail before starting it.
- **Run the app.** Simulator walks catch layout, copy and reload bugs no test does. `dist/tools/sim-shot.sh
  <name>` takes a screenshot; `xcrun simctl launch "iPhone 18 Pro" com.noopapp.noop --demo-seed` seeds 120 demo days
  (no strap heart rate, so the engine's pass ends at once: values it stores, such as the sleep need or the sleep
  regularity index, cannot be seen there; prove them with tests). More simulator recipes: `features/simple-mode.md`
  → "How to work".
- **Report faithfully:** a failing step is named with its log; a skipped step is said to be skipped.

### Reading a strap log

The owner saves it from More → App → Test Centre → Strap log → Save…; it holds personal data: read it from the
private folder, quote only what a finding needs, never commit it. `python3 dist/tools/hr-timeline.py <log>` shows
heart rate, silences, wrist on/off, banner steps and app runs; `python3 dist/tools/strap-log.py <log> runs|taps|
steps` lists app runs, double-taps and Lift Log steps. One log covers about the last day (2 MB cap, #2386). A log
proves what NOOP did and when, never what iOS drew.

## 3. Parity: Swift and Kotlin byte-identical

Android is an independent reimplementation; analytics and stored data must be byte-identical (app `AGENTS.md`).

- **Oracle, not reading:** compile the Swift side standalone (`swiftc -O twin.swift main.swift`) over thousands of
  generated inputs, print an FNV-1a hash and a few cases, and paste them as the Kotlin test's expected literals; the
  same generator in a Swift test pins the other direction (examples: `SleepWakeRescoringTests`,
  `SleepRegularityIndexTests`). `dist/tools/oracle/` is an older harness to copy.
- **Ledger and ratchet:** `Tools/parity_ledger.py` must report no new finding; a new twin pair needs
  `--refresh-derived --base origin/main`, never a hand edit. Nested functions count as functions: write small
  helpers as closures. Ratchet against `origin/main`. Python 3.12 (`/opt/homebrew/bin/python3.12`) runs these tools.

## 4. Builds for the owner's phone

`main` is the product and the build branch. The workflow "Testing build (fork)" builds iOS, macOS and Android from
the ref it is given and recreates the one release the owner installs from,
`https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest` (bundle `com.noopapp.noop`, "NOOP Staging").

1. `verify.sh` all steps passed on the commit; Android CI for Kotlin changes; a local Release iPhone build:
   `xcodebuild -project Strand.xcodeproj -scheme NOOPiOS -configuration Release -destination 'generic/platform=iOS'
   -derivedDataPath ~/Library/Caches/noop-handbook/build/release CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
   CODE_SIGN_IDENTITY="" build` (a failed CI build leaves the release empty).
2. Fast-forward `main` to the verified commit and push it (never force-push `main`).
3. `gh workflow run "Testing build (fork)" --repo UtkuDenizAltiok/noop --ref main`; about 30 minutes, the iPhone file
   after about 15. Never run two at once: both rewrite the same release (cancel the older with `gh run cancel`).
4. `bash dist/tools/release-check.sh <main sha> "<a new English string>"`: the release targets that commit, five
   files, the `.ipa` downloads (HTTP 200), and the string's German translation is inside it.
5. Tell the owner plainly that the build is ready and whether it is **just update** (install over the app with
   AltStore; keeps everything) or **wipe and reinstall** (only for an edited shipped migration or a stored value
   changing meaning; a new migration never needs it). The 27 Nov 13.0.0 install was a deliberate fresh start.

If the workflow cannot start (GitHub disabled Actions once, 12 Nov), the iPhone file can be made locally: after
`verify.sh`, build Release as above, copy the `.app`, remove its `Watch` folder, run
`Tools/prepare-ios-sideload-app.sh` on it, zip it as `Payload/NOOP.app` into `NOOP-ios-unsigned-v<version>.ipa`,
compare it with the release's current file, then `gh release upload testing-latest … --clobber`, download it back
and compare sha256. Say which file came from which commit.

The branches `testing-stack` and `testing-build` and the tag `fork/ships-template` belong to the old pipeline (up to
27 Nov 2026) and are kept as history; `tools/retired/ship-build.sh` is that pipeline's script.

## 5. Git

- **Branches:** `main` (the product), `handbook` (this handbook), feature branches named for their change. A feature
  branch is verified, then `main` fast-forwards (or merges) to it. The 17 branches of the old pull requests to the
  original repository (`fix/…`, `codex/…`, `ios-…`, `dreamt-psg`) and the earlier feature branches are history:
  their work is in `main`; keep them (deleting a pull request's branch would close that pull request).
- **Worktrees:** the app checkout is `~/Developer/noop/app` (`main`); the handbook is `~/Developer/noop/handbook`.
  For a separate branch, add a worktree under `~/Developer/noop/work/<name>` and remove it when the branch is merged.
- **Before any history rewrite, tag the old tip** `backup/<what>` locally; retired refs go into a bundle in the
  private folder's `backups/`, never onto GitHub. Force-push only with a pinned lease read by `git rev-parse`.
- **Versions:** `MARKETING_VERSION` in `project.yml` and `versionName` in `android/app/build.gradle.kts` change
  together (13.0.0 from 27 Nov); build numbers (`CURRENT_PROJECT_VERSION`, `versionCode`) increase independently.
  The in-app "What's New" comes from `docs/releases/v<version>.md` through `Tools/appchangelog-gen.py` (needs
  PyYAML; a private virtual environment is fine), with the same items in `CHANGELOG.md`.
- **zsh** does not word-split `$VAR` and expands globs: run such commands through `bash -c`. In zsh write
  `"${VAR}:refs/…"`, never `"$VAR:refs/…"` (`:r` is a zsh modifier).

## 6. Conventions and traps

- **Design tokens only** (`StrandPalette`, `StrandFont`, `NoopMetrics`; Android `Palette`/`Metrics`); warnings use
  `statusWarning`. A disabled `.noopPrimary` button does not dim itself: add `.opacity(… disabledOpacity)`.
- **Row structs take no default parameter values**, so a new column is a compile error at every call site.
- **Booleans are `.integer` 0/1**; any `deviceId` table goes in `deviceScopedTables`.
- **`onChange(of:perform:)` stays single-parameter** (the macOS 13 target).
- **Strings:** every new English string gets all nine locales (de/es/fr/pt-PT gate; it/pl/ru/zh ratchet; an English
  echo fails): `dist/tools/xcstrings-add.py` adds, rewords or drops entries without reformatting the catalogue;
  merge catalogue conflicts by key with `dist/tools/xcmerge.py`.
- **Doc comments:** insert a new declaration above a neighbour's doc comment, never between it and its declaration
  (`Tools/doc_comment_lint.py` then reports at the wrong line on purpose).
- **The Mac's time zone can change between sessions:** count whole days on a UTC calendar and pin a summer-time zone
  in any test that differences days.

## 7. Measuring usage

Rule 1: no usage claim without a number, before and after.
- **CPU in the simulator:** `bash dist/tools/usage.sh "<label>" 60 20` (NOOP and the render server over the same
  window, plus the footprint). Measure Release over demo data, alternating old and new builds; a still screen is the
  control. A pure computation can be timed directly in a small release-mode benchmark over realistic synthetic input
  (as for the Stress readouts, 27 Nov).
- **On the owner's phone:** iOS's MetricKit report (#2420) is written into the strap log once a day; a normal day's
  log before and after a change is the real measurement. Count radio work (syncs, commands, reconnects) and pushes
  from the log.
- **Instruments** (`xcrun xctrace record --template 'Time Profiler' --attach <pid>`) when a number needs a cause;
  `dist/tools/rescore-profile/` aggregates a profile.

## 8. Caches

Build products, logs and screenshots go in `~/Library/Caches/noop-handbook/` (`build/`, `verify/<commit>/`,
`chat<n>/` working files of a session). They can be deleted and rebuilt; keep a session's logs until its work has
shipped. Nothing private is written there.

## 9. Maintaining this handbook

- Keep State true at every milestone and at the end of every session; move finished events into History as one
  entry. Rules keep their numbers. Settled science is not rewritten silently.
- `bash dist/tools/checkpoint.sh save "what"` saves locally; `bash dist/tools/backup.sh "what"` commits and pushes,
  folding local checkpoints into one milestone; `bash dist/tools/checkpoint.sh status --net` shows the handbook,
  every worktree, running jobs, recent GitHub runs and the release. After editing either tool, run
  `bash dist/tools/test-checkpoint.sh`.
