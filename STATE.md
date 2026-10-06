# State

**Updated 6 Oct 2026 — ChatGPT/Codex owns project direction and execution.** Mac setup is restored and verified.
The working agreement is in README and RULES; Journey 2 continues with its measured evidence and feature contracts.
**24 PRs merged; open: #2613, #2660, #2661.**
#2659 merged on 4 Oct. The fork's releases page still holds `3772b93` (all four original changes; assets checked 6 Oct).
Utku's phone: last confirmed build 429 (`a8d25c1` or `d6b998c`, both 429), on 3 Oct; current install is unconfirmed.
The only file that changes every session.
Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

**No engineering work is in flight.** ChatGPT/Codex ownership and the local/GitHub working arrangement are complete.
The handbook is the single durable project memory; its AGENTS entry and four ignored local Codex entries are ready.
Checkpoint/backup/installer checks passed. All four code worktrees are clean and match the fork; no local job is running.
The simulator remains shut down. No application code, PR reply or staging release changed during this transition.

- **Last ship (historical):** `3772b93` (run 37136378349, verified on the releases page 3 Oct 19:38: `.ipa` + template) = `upstream/main`
  `6ce65730` + #2613 + #2659 + #2660 + #2661 (`testing-stack` `b6202262`).

## Phone — pending checks from the 3 Oct handover

These are historical waits, not unfinished Mac setup. The current phone install and these results remain unconfirmed.
Ask Utku for the strap log after each (More → Test Centre → Strap log → Save…):

- [ ] **Just update to `3772b93`** (told 3 Oct ~19:45). No wipe: nothing stored changes shape.
- [ ] **Silent sync reminder** (#2661): More → Automations → "Sync reminder" is on. Swipe NOOP away; about 3 hours
  later a silent "Strap not synced" line should be on the Lock Screen (no sound). Opening NOOP clears it. If nothing
  shows, check Settings → Notifications → NOOP Staging is allowed. The log line: "Sync reminder: armed for …".
- [ ] **Deleted-sleep list** (#2660): Sleep → edit a night → Delete; after the undo strip goes, a "Deleted sleep
  windows" card lists it; "Recompute this night" brings it back (from raw data), "Hide" removes the row only.
- [ ] **Banner** (#2659): when NOOP has not been opened for 8 hours (overnight), after opening it only ONE banner
  should be on the Lock Screen; the log then shows "Live HR banner: ended by iOS" and "removed one iOS had ended".
- **Context (Utku, 30 Sep–1 Oct):** his nights are atypical for a while, no training; he sometimes takes the band off
  at night and sometimes swipes NOOP away, and cannot keep a record of it ("you decide"): read gaps from the log
  (WRIST_OFF, app runs), never ask him to log them. Judge a staging change by re-staging the SAME night with old and
  new code (`tools/his-nights/`), never night against night; recovery/HRV dips these days are real.

## Next safe action, in order

1. Next app task: address the 4 Oct review on #2660 (fresh deletion must unhide its row, and recompute copy must not promise
   an old night was reprocessed), explain the two success messages, then resolve its catalogue conflict with current upstream.
   Work in `~/Developer/noop-deleted-sleep`; verify before any push or reply. Setup and the ownership transition are complete.
2. Assess #2661's 4 Oct request for default OFF against the existing default ON, notification behaviour and user benefit.
   ChatGPT/Codex decides the best behaviour, explains it to Utku and records the reason for any changed choice.
   #2613 has no review/comment. Reviews have been read, not answered in the setup/ownership tasks.
3. Once the PR work is verified, rebuild the stale testing stack on current upstream and ship. The existing release remains
   on GitHub; no new staging release was published during restoration. Then collect the pending phone checks/logs and
   choose the next investigation from `BACKLOG.md` by correctness risk, user impact and available evidence.

Not done in session 4 (from the Saturday plan): `tools/his-nights/run.sh` on the 3 Oct backup (his nights at RSA 0.3).
The backup copy was deleted; ask Utku for a fresh `.noopbak` when that is needed.

## Our PRs upstream (`ryanbr/noop`)

Open (checked 6 Oct on `upstream/main` `9f98f811`; fork-PR CI approval is separate from mergeability):
- **#2613** `dreamt-psg` `7b638413` + `ca008aba` — `Tools/SleepPSG` reads DREAMT (section 8), then `respWeight`
  0.6 → 0.3 (61/28 subjects). Android CI 36712653602 green. Body `private/pr-rsa-weight-body.md`.
- **#2660** `ios-deleted-sleep` `3869d0b2` — the "Deleted sleep windows" card on iOS and macOS (Android parity, #515).
  Body restored from GitHub in `private/pr-deleted-sleep-body.md`. The catalogue conflicts with current upstream.
  Review 4 Oct: clear a hidden entry on a fresh delete (the 500-marker cap can otherwise orphan it); qualify the recompute
  note for nights outside `analyzeRecent`'s 21-day window; explain the two success messages as a deliberate platform choice.
- **#2661** `ios-sync-reminder` `60793987` — the silent "Strap not synced" reminder after 3 h without a sync. iOS only.
  Body restored from GitHub in `private/pr-sync-reminder-body.md`. Merges cleanly. Review 4 Oct asks for default OFF;
  the existing settled default ON has not been changed. #2613 also merges cleanly and has no review/comment.
Merged (24): #2659 (4 Oct, `a6f1fe08`; squash and current-main merge-tree proofs are exact),
#2574, #2575, #2576, #2569 (#2371), #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via
#2480), #2420, #2422, #2437 (via #2481), #2444, #2612, #2617, #2618, #2619. Issue #2446 fixed upstream in #2453. The
parity gate on `main` drifts after busy merge days and the maintainers re-derive it: compare with a clean `main`
checkout before blaming a branch. A PR that removes or adds a twin may need
`parity_ledger.py --refresh-derived --base upstream/main` (as #2617 did).

## The fork, exactly

- **Branches:** local/fork `main` are exact mirrors of current `upstream/main` `9f98f811` (6 Oct).
  `handbook` (this), `dreamt-psg`, `ios-deleted-sleep`, `ios-sync-reminder` (one per open PR).
  Fork `live-hr-ended` is proven merged and retired; private archive bundle verified (no banner worktree was recreated).
  `testing-stack` `b6202262` and `testing-build` `3772b938` were restored unchanged. They are the 3 Oct stack/build
  on `6ce65730`, including the now-merged #2659, and need rebuilding after the next verified PR work.
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`. Local
  only on the previous Mac: `backup/handbook-pre-scrub` (not present here; never push it).
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`), and one per PR branch:
  `~/Developer/noop-dreamt`, `-deleted-sleep`, `-sync-reminder` (restored 6 Oct; no banner worktree needed). Build folders, logs and reports:
  `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`): `verify/`, `builds/`, `his-nights/`, `dreamt/`
  (aggregates only), `*.out` run logs. All safe to delete. xcodegen rewrites `StrandiOS/Resources/Info.plist` (a
  `stalebattery` entry upstream's plist lacks): discard it, never commit it.
- **Local only:** `dist/private/` holds event logs, PR drafts and setup evidence. The redundant bootstrap toolchain was removed
  after Homebrew tools and the active GitHub credential helper were verified.
  Personal logs/backups and datasets were not recovered from Git. Before personal-data analysis, obtain a fresh `.noopbak`
  and the needed logs; never commit or upload them. The previous Mac had sleep-accel (2.2 GB) and DREAMT v2.2.0
  (14 GB, restricted); neither dataset is installed on this Mac and no restricted dataset was downloaded.
  The previous simulator `281E44EC` and its seeded app state were not recovered. A fresh `NOOP iPhone 17 Pro`
  (`DCAA8034-6801-4D1F-8FD9-B42B2F424B6F`, iOS 27.0) booted successfully and is parked shut down.
  Create fresh demo state before measuring; this simulator has not been seeded or paired with a strap.

## Verified — the latest numbers

- **ChatGPT/Codex transition, 6 Oct:** mandate and product/technical decision authority recorded in README/RULES;
  canonical handbook `AGENTS.md` added, and `codex-setup.sh` installed ignored local entries in all four code worktrees.
  Seven redundant agent-memory files and their copy/hook interfaces were removed after retaining useful facts in the
  handbook; Git history preserves them. Checkpoint/backup/installer sandbox passed 28 checks, shell syntax passed,
  and the public diff and local README links were checked. Evidence: `private/codex-transition-tool-tests.log` and
  `private/codex-transition-public.diff`. Upstream code and the previously verified app baseline are unchanged.

- **Mac setup baseline, 6 Oct, clean `main` `9f98f811`:** `verify.sh --quick` passed every step on full Xcode:
  WhoopStore 632, StrandAnalytics 2135, StrandImport 327 (one existing skip), zero failures; doc lint, i18n, parity ledger,
  ratchet and 127 governance tests passed. Logs: `~/Library/Caches/noop-handbook/verify/9f98f811/` and
  `baseline-xcode-9f98f811.out`. Initial Command Line Tools/Xcode-license failures are archived in
  `baseline-clt-9f98f811/`; they were resolved before the successful rerun.
- **App readiness, 6 Oct:** XcodeGen generated the project; `Strand` macOS and `NOOPiOS` generic iOS Simulator builds
  both passed with signing disabled. Logs: `~/Library/Caches/noop-handbook/restoration-app-builds/{mac,ios}.log`.
  The generated Info.plist difference was saved there and the tracked file restored. Hosted macOS `StrandTests`,
  phone/strap behaviour and a signed device build were not run in this setup task.
- **Tools and access, 6 Oct:** Xcode 27.0 (`27A266a`, first-launch check passed), Command Line Tools 27.0, Homebrew 7.0.8,
  XcodeGen 2.46.0, GitHub CLI 2.102.0, Python 3.12.15. iOS 27.0 runtime `24A434` installed and a simulator boot/display
  check passed. `gh auth status` confirmed `UtkuDenizAltiok` using the macOS keychain; fork ADMIN, upstream READ;
  fork push dry run succeeded. Repository-local author matches the existing handbook author. Claude-only steps skipped.
- **Fork CI, 6 Oct, mirror `9f98f811`:** all six workflows completed successfully: Android 37453629687,
  Swift Packages 37453629659 (all 12 jobs), Source Hygiene 37453629646, Parity Governance 37453629632,
  Tools Python 37453629593 and i18n 37453629544. Android validation remains in CI; no local Android SDK is needed.
- **Session checks, 6 Oct:** `checkpoint.sh status --net` confirmed clean, pushed code worktrees and no stray job.
  `upstream-check.sh` completed across all three PRs and current reviews after a small handbook-tool repair: handle
  merge-tree's expected conflict exit status, and use `git log -n 30` to avoid a `pipefail` exit through `head`.
  Bash syntax and the live run passed. The #2660 translation catalogue conflict is outstanding app work, not a setup failure.

- **Background re-scoring on his phone** (strap logs 29–30 Sep, build `769113c0`): 41 passes / 243 CPU-s in 16.5 h and
  54 / 308 in 17.5 h (27–28 Sep before the spacing: 113 / 900 in 16.6 h). A backgrounded pass ~8 s CPU (median), a
  foreground one ~1.5 s for the same work. Cold passes: midnight 33 s CPU (0/7 days reused), iOS relaunch 20 s
  (assertion expired), foreground relaunch 5 s.
  1 Oct log (`a8d25c1`, 30 Sep 12:24 → 1 Oct 10:29, a gap 12:49–19:38): 47 passes / 326 CPU-s (bg 266).
  2–3 Oct logs (build 429): 39 passes / 362 CPU-s in 15 h and 42 / 415 in 13 h (~24–32 CPU-s/h); cold relaunch +
  midnight 127 of the 415; queued forced duplicates ~40 CPU-s (`BACKLOG.md` A, B). MetricKit payloads empty those days.
- **Phone (MetricKit):** 26 Sep (`37408cc`) background 23 h 28 m, CPU 1 h 36 m, peak 339 MB, writes 193 MB; 29 Sep
  (`769113c0`) foreground 14 m, background 4 h 25 m, CPU 1 h 10 m, peak 358 MB, writes 201 MB, hangs 2, exits normal 4.
- **Re-score cost, simulator, his backup** (`dist/tools/rescore-profile/`): upstream `0c982899` warm 1.6 s / cold
  4.7–5.0 s CPU; #2574 warm 1.2 s, #2575 cold 4.4–4.5 s (both merged). Next warm costs: the fingerprint (25 %) and
  re-reading today's R-R window (17 %).
- **Screens, idle 60 s, simulator, demo data, light, night (1 Oct):** Trends/Sleep/Coach/More NOOP 0.00 + render
  0.01–0.02 CPU-s/min; Today 1.9–2.2 + 22.1 on `main` → 0.00–0.01 + 0.01–0.02 with #2619; Today in DARK at night
  (twinkle by design) 1.97 + 21.82. Re-score memory on his data: 77 MB steady, 144 MB peak.
- **Sleep staging vs PSG** (`Tools/SleepPSG`): sleep-accel n = 31 (no R-R), with #2576 kappa 0.371, deep 15.09 % vs
  13.76 %. DREAMT n = 100 (R-R live; clinical, median AHI 13.5): shipped at respWeight 0.6 kappa 0.208, wake 6.9 %
  vs 25.1 %, deep 12.8 % vs 3.4 %, REM 19.9 % vs 10.5 % of the night; at 0.3 (#2613) per-subject kappa 0.204 → 0.216,
  61/28 subjects. His six nights (`dist/tools/his-nights/`): deep 21.6 / REM 31.9 / light 46.5 % of sleep → 21.2 / 29.3
  / 49.5 at 0.3; REM stays ~27 % even with the term off (`BACKLOG.md` C).
- **Last full `verify.sh` runs, all steps passed (3 Oct, on `6ce65730`):** #2659 `a64d8474` (macOS 2,271), #2660
  `3869d0b2` (2,273), #2661 `60793987` (2,272) — WhoopStore 632 · StrandAnalytics 2114 · StrandImport 327 · doc lint · i18n ·
  ledger · ratchet · governance 127 · macOS with only the two `TodayCarryOverTests` · iOS build. Earlier: #2617 `4d3e6c89` (run alone), #2618 `194b0687`, #2619 `7e7cf01f`
  (1 Oct); #2612 `47254b18`, #2613 `29f43bb2` (then `ca008aba`, test comments only: its tests + doc lint re-run) —
  WhoopStore 631 · StrandAnalytics 2102–2103 · StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 127 ·
  macOS 2,254–2,260 with only the two `TodayCarryOverTests` · iOS build. Never run two verifies at once (shared build
  cache and test host; 1 Oct two overlapped and the result had to be redone).

## Next

1. "Next safe action" above.
2. Choose from `BACKLOG.md` by correctness risk, user impact and evidence: item 9 (backup deletion markers), A (queued
   duplicate re-scores after #2646), B (cold passes), D (night start moved by later data), C (wake/REM).
3. Every app change: measure before/after, `verify.sh` (alone), PR, rebuild `testing-stack`, ship, tell Utku "just update".
4. At the end of every session: README "End a session".
