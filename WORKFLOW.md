# Workflow

How work on the Lift Log is done. The app repo's own `CLAUDE.md` and `docs/CONTRIBUTING.md` still apply; this
adds what this feature and this fork need. Commands run from the app repo root; tools live in `dist/tools/`.

## 1. Working with Utku

Utku Deniz Altiok (GitHub `UtkuDenizAltiok`) is **not a programmer**: he does not read code or use the
terminal, installs builds from the fork's Releases page with AltStore, and tests at the gym on a WHOOP 5.0.
Whoever works here writes the code, runs the tools and explains in plain language. His product judgement has
corrected the engineering several times — treat it as authoritative. He wants technical questions decided,
reviewers verified rather than obeyed, and this implementation kept unless a change is truly worth it.

- **Finishing a change means shipping a build** (§6) and telling him **"just update"** or **"wipe"** in one line.
  Never ship a broken build.
- **Nothing public without his yes**: opening a PR, a comment in his name, an issue.
- **Every build lands on his releases page** (`https://github.com/UtkuDenizAltiok/noop/releases`) — it is where
  he installs from. Tell him the link and the 7-character id that ends the release title.
- **Scope is his.** The Lift Log is an addition to NOOP: use NOOP's existing features (strap log, buzz, double-tap,
  workouts, design tokens) instead of Lift-Log-only structures, unless strictly necessary. Upstream's
  fundamentals (the strap log's content, rate or buffer included) are not changed for it. Build a request exactly as narrow as he words it — the Lock Screen
  light-up is "just light up", nothing more.
- **He reads the evidence himself.** When his reading of a file differs from yours, re-read it completely, then
  show him line numbers and a search he can repeat.
- **Never delete** his things without asking; **never touch** his own comments.

## 2. Session routine

- **Start:** `STATE.md` → `RULES.md` → `bash dist/tools/upstream-check.sh` (our PRs, upstream commits touching
  Lift Log files on either platform, merge conflicts, open threads). The maintainers push to and merge our
  branches, and add twins of our code, within hours.
- **End:** replace `STATE.md`'s content with the truth, update any file the work changed, then
  `bash dist/tools/backup.sh "what changed"`. Drafts belong in `NEXT_PR.md`, never only in a scratch folder.

## 3. Verification

`bash dist/tools/verify.sh` runs the whole loop, cheapest first, and names each log: package tests
(WhoopStore, StrandAnalytics, StrandImport), doc-comment lint, i18n gate against `upstream/main`, parity ledger,
parity ratchet, parity governance tests, `xcodegen`, macOS tests, iOS build. `--quick` skips the Xcode app
targets. Android runs in CI: `gh workflow run "Android CI" --repo UtkuDenizAltiok/noop --ref <branch>`.

- **Anything under `android/**` needs Android CI**, a DAO signature included: the fork's testing build only
  assembles the Android app, so a broken Kotlin test double still ships green (16 Sep).
- **Expected:** exactly two macOS failures, `TodayCarryOverTests` (English language, German region). They fail on
  clean `main` too. Do not pass `-testLanguage`. `verify.sh` treats only those two as known.
- **Build both app targets locally.** Upstream's App build CI builds the PR merged into `main`, and nothing else
  compiles app-target Swift.
- **A new test must be seen to fail.** Break the fix, watch the test go red, restore, compare sha256.
- **Run the app.** Simulator walkthroughs caught a wrapped header, stale copy, a missing reload, "0" + "60" = "600".
  Read the simulator's database to confirm what was stored:
  `find ~/Library/Developer/CoreSimulator/Devices/<id>/data/Containers -name whoop.sqlite -path '*OpenWhoop*'`.
- **Strings:** confirm a new key in the compiler's `.stringsdata` and the built app's `*.lproj/Localizable.strings`.
- **After an Xcode update**, the license must be accepted (Utku) and the first verify run read for new warnings.
- **Report faithfully:** a failing step is named with its log; a skipped step is said to be skipped.

### Reading a strap log

Utku saves it from More → Test Centre → Strap log → Save… and attaches the `.txt`. It holds personal health and
device data: read it locally, quote only what a finding needs, and never commit it — this handbook is public.

`python3 dist/tools/strap-log.py <log.txt>` prints two reports. It is a reading aid for whoever debugs, run on a
computer against NOOP's ordinary exported strap log; it is not part of the app and adds no log of its own.
- **runs** — the export joins TWO stores, so it can hold 13:00 lines yet miss 21:20: first the saved endings of
  up to three EARLIER app runs ("previous app session" — each run's last ≤1,000 lines, archived when the next
  run starts, and only as current as its last 32-line save), then the live log of the run still open when the
  log is saved ("current app session" — its newest 5,000 entries plus up to 256 slack; older ones are dropped). A run whose first line is not
  "Central state: …" lost its beginning. A header's "rolled at <UTC>" is when the NEXT run started. On 16 Sep
  this is what hid 21:15–21:54: the run started at 21:14:45 stopped logging at 21:15:05, the next started at
  21:20:24, and by the 22:44 export its first half hour had been trimmed (58% of its entries are upstream's
  once-a-second heart-rate line; 44 of 5,180 were the Lift Log's).
- **taps** — the strap's own console (`IMU double tap detected`, `Command Run haptics`, `Command Send Historical
  Data`, millisecond ticks) against the app's lines: how many double-taps the strap sensed, what the app did with
  each, tap-to-buzz delay, taps under 8 s apart (knocks, `RULES.md` 35), and buzzes that queued behind a sync
  (36). A tap Utku felt but the strap never sensed cannot be fixed in the app.

## 4. Cross-platform parity

Android is an independent reimplementation; analytics and stored data must be byte-identical (`CLAUDE.md`).

- **Kotlin twin of the figures** (`RULES.md` 33): change `LiftMetrics.kt` with `LiftMetrics.swift`, extend the
  oracle fixture for the new edge, run `bash dist/tools/oracle/run.sh`, paste its stdout as the expected block
  of `LiftMetricsParityOracleTest`, and keep `tools/oracle/main.swift` in step with the test's `render()`.
  Sections the change cannot affect must come back byte-identical — that is the harness's proof.
- **Python 3.12+** runs the parity tools (CI's version; `brew install python@3.12`). Xcode's 3.9 cannot materialize the base (no tarfile
  extraction filter), so the ratchet, governance tests and the base comparison fail locally for that reason
  alone; `verify.sh` marks them skipped rather than guessing.
- **Ledger** (`python3.12 Tools/parity_ledger.py`): no finding beyond the checked-in baseline and no scan error.
  `--no-baseline` diffs against a worktree of `upstream/main` show added findings but NOT authority drift: a
  new twin pair (15 Sep, `isPerformed`) moves `function_pairs` in `Tools/parity_twin_map.json`, which only the
  default run reports. The PR then carries the guarded refresh
  (`--refresh-derived --base origin/main`) — never a hand edit.
- **Ratchet** (`--base "$(git merge-base HEAD upstream/main)" --offline`): no new one-sided declaration. Compare
  against the branch's OWN base: against a newer tip, upstream's own changes read as debt of ours (16 Sep: an
  Oura constant removed upstream).
  A new unpaired function under `Packages/**` or `android/**` is debt; per #2163 a disposition cannot settle
  `add-unpaired-function`, so prefer not adding the identity, else implement the twin.
- **Governance tests** (in `verify.sh`, on a clean checkout of HEAD when the tree is clean): they run upstream only
  when parity tooling changes, so a product PR can leave them red on `main` without anyone seeing (#2229 — ours
  did). Run in place on a base older than #2259, they also scan `Packages/*/.build` left by `swift test` and
  report findings the branch does not have (16 Sep). Compare with `upstream/main`; they need
  Python 3.12 to be meaningful (3.9 adds environment errors).
- Twin claims pair by name and arity: keep one function per twin name. Never refresh the authority unasked.

## 5. GitHub etiquette and PRs

- **One concern per PR**; show the verification in the description; follow the repo's PR template.
- **A comment on GitHub** gets ONE concise reply posted after it, covering only its points, citing commits.
- **A change found by us or heard off GitHub** goes into an EDIT of the description (or of our own post it
  concerns), never a new "update" comment. The description describes the PR as it is now, not a changelog.
- **Before working on an open PR branch**, `gh pr view` it: the maintainer may have pushed to it or merged it.
- **After a squash merge**, prove the squash equals the PR head per file, delete the branch from the fork, and
  start the next branch from `upstream/main`.
- **Release-note credits** and version numbers are upstream's; never bump versions on a feature branch.

## 6. Builds for Utku's phone

`bash dist/tools/ship-build.sh` — requires the work branch pushed. It rebuilds `lift-log-build` as the work
branch + `fork/ships-template` (the commit that uploads the `.xlsx`, kept out of PRs), force-pushes it with a
pinned lease, runs "Testing build (fork)", waits, and verifies the release: target commit, the `.ipa` and the
template. The workflow recreates `testing-latest` BEFORE building, so a failed run leaves an EMPTY release —
never trust a title or an exit code, only the assets. On an HTTP 5xx or a ~2-minute clone failure, rerun.
Release page: `https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest` (bundle `com.noopapp.noop`).

**Just update or wipe:** just update for UI, logic, analytics or a new OPTIONAL snapshot field (pinned by
`LiftSessionPersistenceTests`); wipe only for an edited shipped migration, a stored column changing shape or
meaning, or a non-optional snapshot field. Since #2098 schema changes are new migrations, so wipes should not
recur. When in doubt, say wipe.

## 7. Syncing with upstream

```bash
bash dist/tools/upstream-check.sh                     # what moved; does the work branch still merge
git tag backup/pre-rebase <work-branch>               # LOCAL safety tag — never push tags wholesale
git rebase upstream/main
bash dist/tools/verify.sh                             # then prove the content (below)
bash -c 'B=<work-branch>; OLD=$(git rev-parse origin/$B); git push --force-with-lease=$B:"$OLD" origin $B'
git tag -d backup/pre-rebase
git push origin upstream/main:refs/heads/main         # keep the fork's main a mirror (fast-forward only)
```
- **Prove the rebase kept the content:** `git diff backup/pre-rebase HEAD -- <the branch's files>` shows only
  upstream's lines and intended edits.
- **Unstaged edits** make `git rebase --continue` fail with a misleading "edit all merge conflicts": stash just
  those paths, continue, pop.
- **Conflicts seen:** `Localizable.xcstrings` — merge on KEYS with `python3 dist/tools/xcmerge.py BASE HEAD
  INCOMING OUT` (`git show :1:/:2:/:3:`), never on markers; `LiftMetrics.swift` doc comments — keep both texts,
  including "The Kotlin twin is" lines; `RootTabView`, `NOOPWidgetBundle` — keep both.
- **After a stacked PR is squash-merged:** `git rebase --onto upstream/main <old-dependency-tip> <branch>`.
- Syncing the fork's `main` runs Parity Governance CI on the fork when parity tooling moved; a failure there
  mirrors `main` upstream, not our branch.

## 8. Git and fork hygiene

- **The fork holds exactly:** `main` (mirror), the work branches (stacked, one per upcoming PR, listed in
  `STATE.md`), `lift-log-build`, `lift-log-handbook`; tags
  `fork/ships-template` and `testing-latest` (plus upstream's version tags). Nothing else.
- **Force-push only with a pinned lease** read by `git rev-parse origin/<branch>` — never a typed SHA.
- **Backup tags stay local** and are deleted after the push is verified. Retired refs go into a bundle outside
  the repo (`git bundle create`), not onto GitHub.
- **This handbook branch is PUBLIC.** Only the handbook, `memory/` and `tools/`; drafts and anything personal go
  in `dist/private/` (ignored). Never commit `dist/` to a work branch.
- **zsh** does not word-split `$VAR` and expands globs like `--include=*.kt`: run such commands via `bash -c`
  with arrays. `origin/origin` is `origin/HEAD`, not a branch.

## 9. Conventions and traps

- **Design tokens only** (`StrandPalette`, `StrandFont`, `NoopMetrics`); warnings use `statusWarning`.
- **A disabled `.noopPrimary` button does not dim itself**: add `.opacity(… NoopButtonMetrics.disabledOpacity)`.
- **Row structs take no default parameter values**, so a new column is a compile error at every call site.
- **Booleans are `.integer` 0/1**; any `deviceId` table goes in `deviceScopedTables`.
- **`Localizable.xcstrings` is hand-formatted**: insert a new key as text next to its neighbours in all ten
  locales and validate the JSON; re-serialising the 6 MB file reformats it.
- **`onChange(of:perform:)`** stays single-parameter (the macOS 13 target); its iOS deprecation warning is known.
- **`dismissesKeyboardOnTap`** is a UIKit window recognizer that stands aside for text inputs: a SwiftUI tap
  gesture fired for taps in fields too, and weight → reps took two taps on the phone (fixed 16 Sep).
- **Simulator coordinates:** take them from a screenshot of the SETTLED screen. A tap placed from a
  mid-keyboard-animation screenshot misses and looks like a bug (16 Sep).
- **App-target Swift is validated only by local builds** (`CLAUDE.md`); BLE behaviour only on a real strap.

## 10. Maintaining this handbook

- Keep `STATE.md` true at the end of every session; move finished events into `HISTORY.md` as one line.
- Rules keep their numbers. Settled science is not rewritten silently.
- `bash dist/tools/backup.sh "what changed"` copies Claude Code's memory into `memory/`, commits and pushes;
  `--restore-memory` copies it back on a new machine.
