# State

**Updated 6 Oct 2026 — ChatGPT/Codex owns project direction and execution.** Mac setup is restored and verified.
The working agreement is in README and RULES; Journey 2 continues with its measured evidence and feature contracts.
**24 PRs merged; open: #2613, #2660, #2661.**
#2659 merged on 4 Oct. Latest testing release **`6de9d6d`**, base **12.0.0**, run **37471192603** (6 Oct): exact release/tag target, all five uploaded assets and IPA HTTP 200 verified. Release notes describe the current changes and opt-in reminder.
Utku's phone: last confirmed build 429 (`a8d25c1` or `d6b998c`, both 429), on 3 Oct; current install is unconfirmed.
Keep the current state concise; completed milestones belong in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

No work in flight. Both review revisions, their single replies, the integration tests and ship are reconciled
complete. `6de9d6d` is verified; ship exec `35316` exited successfully. All code worktrees are clean and pushed;
temporary integration worktree/branch and rewrite safety tags are removed. The synthetic simulator is shut down.
Completed details are in History and the records below.

**Settled decisions:** recompute keeps the normal 21-day analysis window and reports marker clearing accurately. The
reminder's unset default is OFF; earlier battery-alert permission does not opt users into a new recurring reminder,
and saved ON/OFF choices survive. No new physiological tuning: only the already-verified #2613 change is carried
forward.

## Phone — pending checks for the current testing release

Mac verification and shipping are complete. The current phone install and these real-device results remain unconfirmed.
Ask Utku for the strap log after each (More → App → Test Centre → Strap log → Save…):

- [ ] **Just update to `6de9d6d`** through AltStore over the existing NOOP Staging app. Keep the app and its data; no wipe is needed.
- [ ] **Silent sync reminder** (#2661): More → App → Automations → turn "Remind me when syncing stops" on (unset
  default is now OFF). Swipe NOOP away; about 3 hours
  later a silent "Strap not synced" line should be on the Lock Screen (no sound). Opening NOOP clears it. If nothing
  shows, check Settings → Notifications → NOOP Staging is allowed. The log line: "Sync reminder: armed for …".
- [ ] **Deleted-sleep list** (#2660): Sleep → edit a night → Delete; after the undo strip goes, a "Deleted sleep
  windows" card lists it; "Recompute this night" clears its marker (recent nights return only if raw data supports
  them), "Hide" removes the row only.
- [ ] **Banner** (#2659): when NOOP has not been opened for 8 hours (overnight), after opening it only ONE banner
  should be on the Lock Screen; the log then shows "Live HR banner: ended by iOS" and "removed one iOS had ended".
- **Context (Utku, 30 Sep–1 Oct):** his nights are atypical for a while, no training; he sometimes takes the band off
  at night and sometimes swipes NOOP away, and cannot keep a record of it ("you decide"): read gaps from the log
  (WRIST_OFF, app runs), never ask him to log them. Judge a staging change by re-staging the SAME night with old and
  new code (`tools/his-nights/`), never night against night; recovery/HRV dips these days are real.

## Next safe action, in order

1. Collect the pending phone checks/logs when available; update the verified install and observations from evidence.
  No Mac/CI/ship action needs repeating.
2. Investigate backup deletion markers (backlog item 9): omission rechecked on `9f98f811` in
  Repository/BackupSettings/DataBackup. Reproduce export/restore with synthetic markers and fresh defaults, inspect
  Android's representation and current PRs, then choose a portable storage approach and discuss it with maintainers
  before implementation. This is a correctness priority and needs no personal dataset.
3. Resume performance or biometric investigations only when the needed phone logs/backup or ground-truth datasets are
  available; do not tune from remembered aggregates.

## Our PRs upstream (`ryanbr/noop`)

Open (final check 6 Oct on `upstream/main` `9f98f811`; both reviewed heads have all six upstream checks green):
- **#2613** `dreamt-psg` `7b638413` + `ca008aba` — `Tools/SleepPSG` reads DREAMT (section 8), then `respWeight`
  0.6 → 0.3 (61/28 subjects). Android CI 36712653602 green. Its base is 85 commits behind but it merges cleanly; the
  current stack compiled/tested its code and tool. Body `private/pr-rsa-weight-body.md`.
- **#2660** `ios-deleted-sleep` `e9ee598e` — the "Deleted sleep windows" card on iOS and macOS (Android parity, #515).
  Current body saved in `private/pr-deleted-sleep-body.md`. Rebased onto `9f98f811`; catalogue conflict resolved by
  key, all upstream entries preserved.
  Review addressed 6 Oct: fresh delete unhides its row; recompute reports marker cleared and names the 21-day scan;
  two success notes explained. Full local verification + simulator passed; pushed/replied once
  ([reply](https://github.com/ryanbr/noop/pull/2660#issuecomment-6016821944)). All six upstream checks passed.
- **#2661** `ios-sync-reminder` `7f9fc7aa` — the silent "Strap not synced" reminder after 3 h without a sync. iOS only.
  Current body saved in `private/pr-sync-reminder-body.md`. Merges cleanly. Review 4 Oct asks for default OFF;
  unset default changed to OFF after assessing existing battery-alert permission; explicit saved choices remain. Full
  local verification and fresh simulator OFF check passed; pushed and replied once
  ([reply](https://github.com/ryanbr/noop/pull/2661#issuecomment-6017174678)). All six upstream checks passed on the
  published head. #2613 also merges cleanly and has no review/comment.
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
  `testing-stack` is now `a5168502`, current upstream `9f98f811` plus the three open PRs. `testing-build` is
  `6de9d6dc` (stack plus template); local, remote and the rolling `testing-latest` tag match; rewrite safety tags
  removed.
- **Last staging release:** **`6de9d6d`**, base **12.0.0**, run **37471192603**, release **404744559** (6 Oct), built
  from stack `a5168502` on upstream `9f98f811` plus #2613/#2660/#2661 and the template commit. Four required jobs
  passed; cleanup was correctly skipped because it only applies to `noop-staging`. Exact release target and
  remote/local tag equal `6de9d6dcea57ff2d7ea656279583255378452834`; all five nonempty uploaded assets present (two
  APKs, Mac ZIP, iOS IPA and Lift Log XLSX); IPA HTTP 200 verified by ship tool. Current release notes edited and
  verified. **Just update**, never delete the existing app first. Prior `3772b93` is historical in History. Evidence:
  ignored `private/release-{run,assets,tag}-6de9d6d.json`, release metadata/notes and event log.

- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`. Local
  only on the previous Mac: `backup/handbook-pre-scrub` (not present here; never push it).
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`), and one per PR branch:
  `~/Developer/noop-dreamt`, `-deleted-sleep`, `-sync-reminder` (restored 6 Oct; no banner worktree needed). Build
  folders, logs and reports:
  `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`): `verify/`, `builds/`, `his-nights/`, `dreamt/`
  (aggregates only), `*.out` run logs. All safe to delete. xcodegen rewrites `StrandiOS/Resources/Info.plist` (a
  `stalebattery` entry upstream's plist lacks): discard it, never commit it.
- **Local only:** `dist/private/` holds event logs, PR drafts and setup evidence. The redundant bootstrap toolchain was removed
  after Homebrew tools and the active GitHub credential helper were verified.
  Personal logs/backups and datasets were not recovered from Git. Before personal-data analysis, obtain a fresh `.noopbak`
  and the needed logs; never commit or upload them. The previous Mac had sleep-accel (2.2 GB) and DREAMT v2.2.0
  (14 GB, restricted); neither dataset is installed on this Mac and no restricted dataset was downloaded.
  The previous simulator `281E44EC` and its seeded app state were not recovered. A fresh `NOOP iPhone 17 Pro`
  (`DCAA8034-6801-4D1F-8FD9-B42B2F424B6F`, iOS 27.0) now has 120 days of synthetic demo data. Fresh
  delete/recompute/hide and default-OFF reminder walkthroughs passed; no real strap paired. Simulator is parked shut
  down after the walkthroughs.

## Verified — the latest numbers

- **Integration and ship, 6 Oct:** local combined iOS build passed at `a5168502`; fork Android `37470127956` passed
  its one job and Swift Packages `37470132381` passed all 11 expected package/tool jobs at that exact head. Expected
  names/counts and every conclusion checked, evidence in ignored `private/stack-{android,swift}-ci.json`. Both
  reviewed PR heads have six green upstream checks. Ship `6de9d6d` / run `37471192603` completed and
  assets/tag/download verified as above. No running build remains.

- **Review fixes, 6 Oct, based on `9f98f811`:** full `verify.sh` passed at #2660 `e9ee598e` and #2661 `7f9fc7aa`:
  packages 632/2,135/327 (one import skip), all lint/i18n/parity gates and 127 governance tests, Mac 2,272/2,271
  respectively (two existing skips, zero failures), both iOS builds. Generated plists restored; logs in cache
  `verify/<head>/` and `<feature>-review/verify.out`.
  #2660 actual Repository regression: five targeted tests, four expected assertions failed on old code, then passed.
  Both revised strings extracted by compiler and present in all ten built locales. Fresh simulator proved old marker
  clearing, a real fresh delete visible over an orphan hidden token, and Hide persistence after relaunch; synthetic
  data has no raw stream, so regeneration is not claimed. #2661 four targeted tests: old fallback fails the
  unset-default assertion, fix passes and saved ON/OFF persist. Native fresh screen shows OFF with the existing
  three-hour/no-sound copy. Notification delivery remains a phone check.

- **Session continuity, 6 Oct:** two canonical start/end prompts saved in README; every final response ends with
  one to three simple numbered next steps, or "No action needed" plus what comes next. Recovery uses saved state and
  actual Git/PR/CI/release evidence. End-of-session handling preserves unfinished work and names failed backups.
  Prompt requirements, instruction consistency, local README links and expected public paths checked; four clean code
  worktrees still point to the canonical handbook AGENTS. Evidence: `private/session-prompts-checks.log`.

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
  Swift Packages 37453629659 (all 11 jobs), Source Hygiene 37453629646, Parity Governance 37453629632,
  Tools Python 37453629593 and i18n 37453629544. Android validation remains in CI; no local Android SDK is needed.
- **Session checks, 6 Oct:** `checkpoint.sh status --net` confirmed clean, pushed code worktrees and no stray job.
  `upstream-check.sh` completed across all three PRs and current reviews after a small handbook-tool repair: handle
  merge-tree's expected conflict exit status, and use `git log -n 30` to avoid a `pipefail` exit through `head`.
  Bash syntax and the live run passed. The #2660 translation catalogue conflict was app work and is now resolved in its verified rebase.

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
  ledger · ratchet · governance 127 · macOS with only the two `TodayCarryOverTests` · iOS build. Earlier: #2617
  `4d3e6c89` (run alone), #2618 `194b0687`, #2619 `7e7cf01f`
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

