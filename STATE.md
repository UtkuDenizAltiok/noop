# State

**Updated 30 Sep 2026, afternoon — Journey 2: NOOP, perfected (`RULES.md` mandate). 19 PRs merged (#2574, #2575,
#2576 on 28–29 Sep). Open: #2612 (30-min background spacing) and #2613 (RSA weight 0.6 → 0.3 on DREAMT). Utku's
build: `a8d25c1` (just update).** The only file that changes every session. Replace, don't append — history goes in
`HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- **Nothing is running.** Last ship: `a8d25c1` (run 36713495781, verified on the releases page 30 Sep 14:35) =
  `upstream/main` `7f396e98` + #2612 + #2613 (`testing-stack` `31dde993`).

Session 1 Oct (night): Utku away (logs + backup Friday 2 Oct noon); asked for general optimisation. Findings so far:
sync cadence is not a radio lever (#1007: radio time = data moved); midnight cold pass = correct invalidation
(`configDropped(sleepConsistency)`), refactor-only lever (BACKLOG B); REM emission variants tested on BOTH PSG sets
(section 10, local): nothing improves both (hrVar 0.35 fixes sleep-accel REM share, neutral κ, nothing on DREAMT;
clock ramp ×1.5–2 explodes REM) — no REM change. Sections 9/10 + `remClock` knob are uncommitted in `noop-dreamt`.
- [ ] Peak memory of a re-score on his 30 Sep backup (MetricKit 29 Sep peak 358 MB in the background): worktree
  `~/Library/Caches/noop-handbook/mem-wt` (branch `tmp-mem`, `upstream/main` + `prof.patch`, never pushed), Release
  build `builds/mem`, `BACKUP_DB` = scratchpad copy; footprint polled during the passes.
  DONE: steady 77 MB, peak 144 MB (the first pass after launch, 4000-day window); MetricKit's 358 MB is not the
  re-score and caused no kill (exits normal 4) — not pursued. His data removed from the simulator (app uninstalled:
  the demo-seeded simulator must be rebuilt before the next `usage.sh`), worktree + branch + build deleted.
- [ ] Dead-code PR: branch `dead-code-2` (worktree `~/Developer/noop-dead-code`): 17 Swift declarations with one
  whole-word occurrence (their own) on `7f396e98` + the dead Kotlin twins `ImuSessionFileStore.prepareForRead`,
  `WhoopRepository.hasAnyHistory`, `SleepSessionEntity.isNapShaped`/`NAP_MAX_HOURS`. Kept (live elsewhere):
  `allowSleepReDetection` + `dismissedSleepManagementWindows` (Android UI uses them), `useResonancePace` (next PR).
- [ ] Bug PR next: "Use my resonance pace" (iOS Automations) is read by nothing — `BreathingView.startOneMinuteCue`
  always uses the locked pace; Android's check-in always uses 5.5 and has no switch. Fix: both honour the pref.

- [ ] Scrub the public handbook history (Utku: "you decide", 1 Oct): uploads `4973d70f` + `560f7f86` squashed into one
  commit on `570d1c87` (the three per-night lines in 4973d70f's BACKLOG D disappear from the branch history); local
  tag `backup/handbook-pre-scrub`; force-push with lease (old `560f7f86`). Proof: `git log origin/handbook` shows
  570d1c87 → the new commit, and no commit on the branch carries the old BACKLOG D wording.

Waits on Utku:
- [ ] **Just update to `a8d25c1`.** Told 30 Sep ~14:40. Visible change: on nights with heartbeat data, REM and deep a
  few points lower and light higher (his six nights: REM 31.9 → 29.3 % of sleep); scores that use stages may move a
  little. Nothing else should change (the spacing, #2574–#2576 were already on his phone).
- **Context (Utku, 30 Sep):** for a while his nights are atypical (poorer sleep) and he does no training. Judge a
  staging change by re-staging the SAME night with old and new code (`tools/his-nights/`), never night against night;
  recovery/HRV dips in these days are real, not bugs; no workouts to test strain on.
- [ ] **Strap logs**, one on the morning of 2 Oct (covers the first full day on `a8d25c1`), plus his wake time: read the
  night's stages against the old build's (the same night re-staged by `dist/tools/his-nights/run.sh` on a backup),
  the MetricKit day lines for 30 Sep and 1 Oct, and the midnight / relaunch cold passes (`BACKLOG.md` B).

**Next safe action:** session start (README). Then: (1) `upstream-check.sh` — answer any review on #2612 / #2613
ONCE (`WORKFLOW.md` §5); after a merge prove the tree, retire the branch, rebuild the stack, ship. (2) `BACKLOG.md`
B (the midnight pass re-scores every night cold) or D (a night's start moved by the next evening's data), measured on
the 30 Sep backup (`~/Downloads/NOOP-backup-2026-09-30.noopbak`; unzip a COPY into the scratchpad, never the repo).
(3) `BACKLOG.md` C (REM still over-called with the term off; wake on DREAMT) — per stratum, never a DREAMT base rate.

## Our PRs upstream (`ryanbr/noop`)

Open (30 Sep; fork-PR checks wait for the maintainers' approval):
- **#2612** `rescore-spacing` `47254b18` — a backgrounded offload re-scores at most every 30 min. Phone result in the
  body (2.5–3.1 passes and 15–18 CPU-s an hour, from 6.8 and 54). iOS only. Body `private/pr-rescore-spacing-body.md`.
- **#2613** `dreamt-psg` `7b638413` + `ca008aba` — `Tools/SleepPSG` reads DREAMT (section 8, R-R live), then
  `SleepStagerV2.respWeight` 0.6 → 0.3 (61/28 subjects; Utku's yes). Both platforms + pins, golden regenerated,
  V2-flag test re-aimed. Android CI 36712653602 green. Body `private/pr-rsa-weight-body.md`.
Merged (19): #2574, #2575, #2576 (28–29 Sep), #2569 (#2371), #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418,
#2419 (via #2480), #2420, #2422, #2437 (via #2481), #2444. Issue #2446 fixed upstream in #2453. The parity gate on
`main` drifts after busy merge days and the maintainers re-derive it: compare with a clean `main` checkout before
blaming a branch; never refresh the authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main` `7f396e98`), `handbook` (this), `rescore-spacing` `47254b18` (#2612),
  `dreamt-psg` `ca008aba` (#2613), `testing-stack` `31dde993` (`main` + those two), `testing-build` `a8d25c15` (the
  stack + `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`.
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`),
  `~/Developer/noop-rescore-spacing`, `~/Developer/noop-dreamt`. Build folders, logs and reports:
  `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`, `WORKFLOW.md` §9): `verify/`, `builds/stack-ios`,
  `his-nights/` (the local harness's build), `dreamt/` (DREAMT and sleep-accel reports: aggregates, still local only).
  All safe to delete. xcodegen rewrites `StrandiOS/Resources/Info.plist` (upstream's `project.yml` declares a
  `stalebattery` task its committed plist lacks): discard it, never commit it.
- **Local only:** `dist/private/` (event log, `usage.log`, PR drafts). Utku's logs and backup: his files in
  `~/Downloads` (personal: never commit, never upload). Datasets in `~/datasets`: PhysioNet sleep-accel (2.2 GB) and
  DREAMT v2.2.0 (`data_64Hz` + `participant_info.csv`, 14 GB; restricted, PhysioNet Restricted Health Data License
  1.5.0: never shared, aggregates only). Simulator `281E44EC` (iPhone 17 Pro): a clean Release of `main` `0c982899` over
  NOOP's 120 demo days (`--demo-seed`), light appearance.

## Verified — the latest numbers

- **Background re-scoring on his phone** (strap logs 29–30 Sep, build `769113c0`): 41 passes / 243 CPU-s in 16.5 h and
  54 / 308 in 17.5 h (27–28 Sep before the spacing: 113 / 900 in 16.6 h). A backgrounded pass ~8 s CPU (median), a
  foreground one ~1.5 s for the same work. Cold passes: midnight 33 s CPU (0/7 days reused), iOS relaunch 20 s
  (assertion expired), foreground relaunch 5 s.
- **Phone (MetricKit):** 26 Sep (`37408cc`) background 23 h 28 m, CPU 1 h 36 m, peak 339 MB, writes 193 MB; 29 Sep
  (`769113c0`) foreground 14 m, background 4 h 25 m, CPU 1 h 10 m, peak 358 MB, writes 201 MB, hangs 2, exits normal 4.
- **Re-score cost, simulator, his backup** (`dist/tools/rescore-profile/`): upstream `0c982899` warm 1.6 s / cold
  4.7–5.0 s CPU; #2574 warm 1.2 s, #2575 cold 4.4–4.5 s (both merged). Next warm costs: the fingerprint (25 %) and
  re-reading today's R-R window (17 %).
- **Sleep staging vs PSG** (`Tools/SleepPSG`): sleep-accel n = 31 (no R-R), with #2576 kappa 0.371, deep 15.09 % vs
  13.76 %. DREAMT n = 100 (R-R live; clinical, median AHI 13.5): shipped at respWeight 0.6 kappa 0.208, wake 6.9 %
  vs 25.1 %, deep 12.8 % vs 3.4 %, REM 19.9 % vs 10.5 % of the night; at 0.3 (#2613) per-subject kappa 0.204 → 0.216,
  61/28 subjects. His six nights (`dist/tools/his-nights/`): deep 21.6 / REM 31.9 / light 46.5 % of sleep → 21.2 / 29.3
  / 49.5 at 0.3; REM stays ~27 % even with the term off (`BACKLOG.md` C).
- **Last full `verify.sh` runs, all steps passed:** #2612 `47254b18`, #2613 `29f43bb2` (then `ca008aba`, test comments
  only: its tests + doc lint re-run) — WhoopStore 631 · StrandAnalytics 2102–2103 · StrandImport 327 · doc lint · i18n
  · ledger · ratchet · governance 127 · macOS 2,254–2,260 with only the two `TodayCarryOverTests` · iOS build.

## Next

1. Session start (README), then "Next safe action" above.
2. `BACKLOG.md` B — the midnight pass re-scores every night cold; relaunches too. Same scores, cheaper.
3. `BACKLOG.md` D — why the next evening's data moved a night's start (reproduce on the 30 Sep backup first).
4. `BACKLOG.md` C — REM with the term off, wake on DREAMT, the z-score floor; per stratum, per subject.
5. Every change: measure before/after, `verify.sh`, PR, rebuild `testing-stack`, ship, tell Utku "just update".
6. At the end of every session: README "End a session".
