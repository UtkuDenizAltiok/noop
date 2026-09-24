# Workflow

How work on NOOP is done here. The app repo's own `AGENTS.md` (`CLAUDE.md` points to it) and `docs/CONTRIBUTING.md`
still apply; this adds what this fork and Utku need. Commands run from the app repo root; tools live in `dist/tools/`,
and each explains itself in its first lines.

## 1. Working with Utku

Utku Deniz Altiok (GitHub `UtkuDenizAltiok`) is **not a programmer**: he does not read code or use the terminal,
installs builds from the fork's releases page with AltStore, and tests on his own WHOOP 5.0 and iPhone. Whoever works
here writes the code, runs the tools and explains in plain language. His product judgement has corrected the
engineering several times — treat it as authoritative. He wants technical questions decided, reviewers verified
rather than obeyed, and a working implementation kept unless a change is truly worth it.

- **Finishing a change means shipping a build** (§6) and telling him **"just update"** or **"wipe"** in one line,
  with the 7-character id that ends the release title. Never ship a broken build.
- **Public steps** follow `RULES.md` (standing permission): replies and pushes on our PRs, and a PR for this journey's
  work once verified; a new issue or a comment on someone else's thread is asked first.
- **Ask him for evidence, step by step.** A test he runs is written as numbered steps with what he should see, and
  ends with the strap log (More → Test Centre → Strap log → Save…). Ask him to note the times of what he saw: the log
  proves what NOOP did, only his eyes prove what iOS drew.
- **He reads the evidence himself.** When his reading of a file differs from yours, re-read it completely, then
  show him line numbers and a search he can repeat. Say plainly what a log can and cannot show.
- **Never delete** his things without asking (his strap logs in `~/Downloads` included); **never touch** his comments.

## 2. Session routine and continuity

- **Start:** README's start prompt → `STATE.md` ("Now" first) → `RULES.md` → `bash dist/tools/checkpoint.sh status
  --net` (README "After an interruption" when "Now" has open steps) → `bash dist/tools/upstream-check.sh`.
- **End:** README "End a session".

A session can stop anywhere, without an end (a usage limit, a server error, a compaction); the conversation is not a
store.
- **Journal first.** Before a step that is long (a build, a verify, CI), public (a push, a release, a PR, a comment) or
  hard to undo (a rebase, a force-push, a migration), write it in `STATE.md` "Now" with what will prove it happened
  (branch and commit, run id, PR number); tick it with its result when it ends. Record a PR's number or a run's id the
  moment it exists. "Now" also carries what was asked, decisions not yet in `RULES.md`, "Do not redo", and "Next safe
  action".
- **Save often, upload at milestones.** `checkpoint.sh save "what"` is a local commit of the handbook (and of Claude
  Code's memory notes) — instant, offline, never public. `backup.sh "what"` uploads after any milestone that took
  real work; it folds the local checkpoints into one commit.
- **Evidence is written down, not remembered.** `verify.sh`, `ship-build.sh` and `backup.sh` each add a line to
  `dist/private/events.log`; a verification's numbers go into `STATE.md`. Nothing needed later lives only in a scratch
  folder or `$TMPDIR`: harnesses go to `tools/`, drafts to `private/`.
- **Background jobs** are named in "Now" with how to check them; never started twice.
- **"Continue" after an interruption is an instruction:** status, settle "Now", finish its open steps, report.
- **Hooks (Claude Code only; installed on Utku's Mac since 22 Sep 2026)** put the recovery brief into every new,
  resumed or compacted session and checkpoint the handbook after every reply (`checkpoint.sh install-hooks` /
  `remove-hooks`; they never upload, block or fail). Installing them is the owner's call: Claude Code's auto-mode guard
  refuses to let the agent write — or read — Claude's settings files. `bash dist/tools/test-checkpoint.sh` proves the
  tool in a sandbox.
- **Other AI tools** keep the same discipline by hand: `checkpoint.sh status --net` at the start, `checkpoint.sh save`
  after milestones, README "End a session" before a fresh start.

## 3. Verification

`bash dist/tools/verify.sh` runs the whole loop, cheapest first, and names each log: package tests (WhoopStore,
StrandAnalytics, StrandImport), doc-comment lint, i18n gate against `upstream/main`, parity ledger, parity ratchet,
parity governance tests (on a clean checkout of HEAD), `xcodegen`, macOS tests, iOS build. `--quick` skips the Xcode
app targets. For a worktree: `NOOP_REPO=<worktree> bash dist/tools/verify.sh`. Android runs in CI:
`gh workflow run "Android CI" --repo UtkuDenizAltiok/noop --ref <branch>`.

- **Anything under `android/**` needs Android CI**: the fork's testing build only assembles the Android app, so a
  broken Kotlin test double still ships green.
- **Expected:** exactly two macOS failures, `TodayCarryOverTests` (English language, German region); they fail on clean
  `main` too. `verify.sh` treats only those two as known.
- **Build both app targets locally.** Nothing else compiles app-target Swift before a PR (`AGENTS.md`).
- **A new test must be seen to fail.** Break the fix, run the test, watch it go red, restore, compare sha256. A split
  commit series is also built commit by commit.
- **Run the app.** Simulator walkthroughs caught layout, copy and reload bugs no test did. The simulator's database:
  `find ~/Library/Developer/CoreSimulator/Devices/<id>/data/Containers -name whoop.sqlite -path '*OpenWhoop*'`.
- **Live Activities in the simulator:** iOS's own log names every banner created, ended and marked stale —
  `xcrun simctl spawn <device> log show --last 2m --style compact --predicate 'process == "liveactivitiesd"'`.
  `kill -9` of the app is how iOS closes it; reinstalling ends its banners, so never install between compared steps.
  `simctl io screenshot` omits the Dynamic Island; the simulator panel's screenshot shows it. A value the simulator
  cannot produce (a live heart rate) is worth a temporary hard-coded one, restored byte-identical afterwards.
- **Simulator settings live in the app's own container:** edit `$(xcrun simctl get_app_container <dev> <bundle>
  data)/Library/Preferences/<bundle>.plist` with Python `plistlib` (keys with dots), not `simctl … defaults write`.
- **A layout or behaviour fix is proven like a test:** build the OLD version into the same simulator with the same
  state, then the fix, and compare.
- **Why iOS closed NOOP is in the iPhone's own record:** Settings → Privacy & Security → Analytics & Improvements →
  Analytics Data. `NOOP Staging.cpu_resource_fatal-<date>.ips` = killed for background CPU; `JetsamEvent-…` = memory.
  Their stacks are unsymbolicated and only 3–4 samples: consistent evidence, not proof.
- **Name test helpers unlike any production function** (`RULES.md` 11). A drift in a package you did not touch: diff
  `parity_ledger.py --no-baseline` against a clean `git archive` of the base.
- **Never wait on `pgrep -f <pattern>` from a command that contains the pattern** — it finds itself and never ends.
- **Strings:** confirm a new key in the compiler's `.stringsdata` and the built app's `*.lproj/Localizable.strings`;
  all ten locales, merged on keys (`tools/xcmerge.py`), never by hand-reformatting the 6 MB catalog.
- **After an Xcode update**, the license must be accepted (Utku) and the first verify run read for new warnings.
- **Report faithfully:** a failing step is named with its log; a skipped step is said to be skipped.
- **The AI tool's own session history is the last resort** after an interruption: Claude Code keeps it in
  `~/.claude/projects/-Users-utk-Developer-noop/<session>.jsonl` (search it with Python, one JSON object per line).

### Reading a strap log

Utku saves it from More → Test Centre → Strap log → Save… and attaches the `.txt`. It holds personal health and device
data: read it locally, quote only what a finding needs, never commit it — this handbook is public.

- `python3 dist/tools/hr-timeline.py <log> [--from HH:MM:SS] [--to HH:MM:SS]` — the live heart rate, readings and
  silences, the strap's WRIST_ON/OFF, every Live HR banner step, Bluetooth on/off, app runs starting and closing.
- **How much a log holds** (since #2386, 22 Sep 2026): every line of every app run, on disk, up to 2 MB in total
  (`StrapLogArchive`, about 20,000 lines); past that the oldest part is dropped. On Utku's phone that was about 25 hours
  on a quiet day (a 1.75 MB log, 23–24 Sep) and about 17 hours at the pace of a testing day. So one log saved each
  morning covers roughly the day before; for a full 24 hours, save one in the evening too.
- `python3 dist/tools/strap-log.py <log> [runs|steps|taps]` — `runs` says which app runs are in the file, how each
  started and whether its beginning was dropped; `taps` matches the strap's own console (millisecond ticks) to what
  the app did with each double-tap; `steps` is the Lift Log.
- A log proves what NOOP did and when, to the second — never what iOS drew or when (Live Activities, the stale dash).
- The strap's console lines (`strap: …`) arrive in bursts during a sync and carry the strap's own ticks: "wear-detection
  moving from on-body to off-body" is the strap's own record of leaving the wrist.

## 4. Cross-platform parity

Android is an independent reimplementation; analytics and stored data must be byte-identical (`AGENTS.md`).

- **Oracle, not reading.** Compile the Swift side standalone over a spread of inputs and paste its stdout as the
  expected block of the Kotlin test; sections a change cannot affect must come back byte-identical. `tools/oracle/`
  is the harness built for `LiftMetrics` (`run.sh`) — copy its shape for any new twin.
- **Python 3.12+** runs the parity tools (`brew install python@3.12`); Xcode's 3.9 cannot, and `verify.sh` marks those
  steps skipped rather than guessing.
- **Ledger:** no finding beyond the checked-in baseline and no scan error. A new twin pair moves `function_pairs` in
  `Tools/parity_twin_map.json`; the PR then carries the guarded refresh (`--refresh-derived --base origin/main`) —
  never a hand edit.
- **Ratchet:** against the branch's OWN base (`--base "$(git merge-base HEAD upstream/main)" --offline`), or
  upstream's own changes read as our debt. A new unpaired function under `Packages/**` or `android/**` is debt: port
  its twin rather than leave it.
- **Governance tests:** on a clean checkout of HEAD. When `main` itself has drifted (the maintainers re-derive it after
  busy days), compare with a clean `main` checkout and say so in the PR; never refresh the authority ourselves.

## 5. GitHub etiquette and PRs

- **One concern per PR**, split into commits by concern when later work rewrites earlier behaviour; follow the repo's
  PR template; show the verification (tests seen to fail, the verify numbers, what ran on the strap).
- **Write PRs and replies in simple, clear words** (Utku, 21 Sep): what changed and why, as a user would say it, then
  the technical notes a reviewer needs. No sophisticated or AI-sounding phrasing.
- **A comment on GitHub** gets ONE concise reply posted after it, covering only its points, citing commits.
- **A change found by us or heard off GitHub** goes into an EDIT of the description, never a new "update" comment. The
  description describes the PR as it is now. PR drafts live in `dist/private/pr-<name>-body.md`.
- **Before working on an open PR branch**, `gh pr view` it: the maintainer may have pushed to it or merged it.
- **After a squash merge**, prove it equals the PR head (`git merge-tree --write-tree <squash>^ <head>` gives the
  squash's own tree), delete the branch on the fork and its worktree, re-mirror `main`, rebuild the testing stack.
- **Release-note credits** and version numbers are upstream's; never bump versions on a PR branch.

## 6. Builds for Utku's phone

The fork's testing pipeline has three layers:
- **`testing-stack`** — every open PR of ours on top of `upstream/main`, never itself a PR. Rebuilt from scratch after
  any merge or change: `git worktree add -b <tmp> <scratch> upstream/main`, cherry-pick each open PR (a PR whose
  commits conflict one by one goes in as its NET diff, one commit), check `git diff --stat upstream/main` lists only
  our files, **build it for iOS locally** (a failed CI build leaves the release EMPTY), then force-push with a pinned
  lease.
- **`testing-build`** — `bash dist/tools/ship-build.sh testing-stack` rebuilds it as the stack + `fork/ships-template`
  (the commit that uploads the Lift Log's `.xlsx` program template, kept out of PRs), force-pushes it, runs "Testing
  build (fork)", waits, and verifies the release: target commit, the `.ipa`, the template, the download. Never trust a
  title or an exit code, only the assets (the workflow recreates `testing-latest` BEFORE building). On an HTTP 5xx or a
  ~2-minute clone failure, rerun.
- **`testing-latest`** — the one release (Pre-release) Utku installs from:
  `https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest` (bundle `com.noopapp.noop`, "NOOP Staging").

**Just update or wipe:** just update for UI, logic, analytics or a new optional stored field; wipe only for an edited
shipped migration or a stored value changing shape or meaning. Schema changes are new migrations, so wipes should not
recur. When in doubt, say wipe.

## 7. Syncing with upstream

```bash
bash dist/tools/upstream-check.sh [branch]            # what moved; does the branch still merge; open threads
git tag backup/pre-rebase <branch>                    # LOCAL safety tag — never pushed
git rebase upstream/main && NOOP_REPO=<worktree> bash dist/tools/verify.sh
bash -c 'B=<branch>; OLD=$(git rev-parse origin/$B); git push --force-with-lease=$B:"$OLD" origin $B'
git tag -d backup/pre-rebase
git push origin upstream/main:refs/heads/main         # keep the fork's main a mirror (fast-forward only)
```
- **Prove a rebase kept the content:** `git diff backup/pre-rebase HEAD -- <the branch's files>` shows only upstream's
  lines and intended edits. A PR that merges cleanly needs no rebase: upstream's CI builds it merged into `main`.
- **Unstaged edits** make `git rebase --continue` fail with a misleading "edit all merge conflicts".
- **Conflicts seen:** `Localizable.xcstrings` — merge on KEYS with `python3 dist/tools/xcmerge.py BASE HEAD INCOMING
  OUT` (`git show :1:/:2:/:3:`), never on markers.

## 8. Git and fork hygiene

- **The fork holds exactly:** `main` (mirror of `upstream/main`), one branch per open PR, `testing-stack`,
  `testing-build`, `handbook`; tags `fork/ships-template` and `testing-latest` (plus upstream's version tags); one
  release, `testing-latest`. Nothing else. A merged PR's branch is deleted once the squash is proven equal (§5).
- **Each open PR has its own worktree** beside the app repo (`~/Developer/noop-<name>`); `~/Developer/noop` stays on
  `main`; `~/Developer/noop/dist` is this handbook.
- **Force-push only with a pinned lease** read by `git rev-parse origin/<branch>` — never a typed SHA.
- **Never start a branch by copying files from another branch** (it once silently reverted two upstream commits): take
  the file from the target base and re-apply the edit, then check `git diff upstream/main -- <path>`.
- **Before any history rewrite**, tag the old tip `backup/<what>` locally; `checkpoint.sh status` lists such refs until
  they are deleted after the push is verified. Retired refs go into a bundle outside the repo, not onto GitHub.
- **This handbook branch is PUBLIC.** Only the handbook, `memory/` and `tools/`; drafts and anything personal go in
  `dist/private/` (ignored). Never commit `dist/` to a work branch.
- **zsh** does not word-split `$VAR` and expands globs like `--include=*.kt`: run such commands via `bash -c` with
  arrays. `origin/origin` is `origin/HEAD`, not a branch.

## 9. Conventions and traps

- **Design tokens only** (`StrandPalette`, `StrandFont`, `NoopMetrics`; Android `Palette`/`Metrics`); warnings use
  `statusWarning`. A disabled `.noopPrimary` button does not dim itself: add `.opacity(… disabledOpacity)`.
- **Row structs take no default parameter values**, so a new column is a compile error at every call site.
- **Booleans are `.integer` 0/1**; any `deviceId` table goes in `deviceScopedTables`.
- **`onChange(of:perform:)`** stays single-parameter (the macOS 13 target); its iOS deprecation warning is known.
- **Simulator coordinates:** take them from a screenshot of the SETTLED screen.
- **App-target Swift is validated only by local builds; BLE behaviour only on a real strap** (`AGENTS.md`).

## 10. Maintaining this handbook

- Keep `STATE.md` true at every milestone and at the end of every session; move finished events into `HISTORY.md` as
  one line. Rules keep their numbers. Settled science is not rewritten silently.
- `bash dist/tools/backup.sh "what changed"` copies Claude Code's memory into `memory/`, commits (folding local
  checkpoints) and pushes; `--restore-memory` copies it back on a new machine. Neither it nor `checkpoint.sh` ever
  copies from an empty memory folder. After editing either, run `bash dist/tools/test-checkpoint.sh`.

## 11. Measuring usage

`RULES.md` 1: no usage claim without a number, before and after, in the PR.
- **CPU, simulator:** a simulator app is a Mac process — `ps -o time= -p $(pgrep -f "NOOP Staging.app/NOOP Staging")`
  read 60 s apart gives its CPU-seconds a minute. Same screen and state before and after, with NOOP alone as the
  baseline (22 Sep: 6.29 idle on Today). The simulator suspends NOOP in the background (no strap), so background timing is checked in unit
  tests and on the phone.
- **Memory, simulator:** `footprint <pid>` (or `vmmap --summary <pid>`) for the physical footprint; compare the same
  screens.
- **Instruments** (`xcrun xctrace record --template 'Time Profiler' --attach <pid>`, also Allocations, Leaks, Energy
  Log on a device) when a number needs a cause.
- **On Utku's phone:** iOS's MetricKit report arrives once a day (about the day before) and #2420 writes it into the
  strap log as one line: foreground and background time, CPU time, peak memory, disk writes, hangs, and why the app
  exited and how often; another line after a crash, a hang, a CPU or disk-write exception or a slow launch. A day's
  log before and after a change is the real measurement; ask him for the log of a normal day.
- **Strap and radio:** count from the strap log — history syncs ("Backfill: session started"), their triggers, the
  once-a-second heart rate, commands sent (`→ …`), reconnects. Every exchange costs the strap's battery too.
- **Pushes and wakes:** Live Activity pushes, widget reloads ("Widgets: N reloaded / N admitted / N offered" in the log
  header), notifications — counted from the log, or from a unit test of the policy that decides them.
