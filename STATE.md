# State

**Updated 28 Sep 2026, end of session 2 — Journey 2: NOOP, perfected (`RULES.md` mandate). 16 PRs merged (#2569 on
28 Sep). Open: #2574, #2575, #2576 (all green, no review yet). Utku's build: `769113c0`. Waiting on his strap logs of
29 and 30 Sep; then the spacing PR.** The only file that changes every session. Replace, don't append — history goes in
`HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- **Nothing is running.** Last ship: `769113c0` (run 36462113779, verified on the releases page 28 Sep ~20:25).

Waits on Utku:
- [ ] **Just update to `769113c0`** = `upstream/main` `0c982899` + the 30-min spacing + #2574 + #2575 + #2576. Told 28 Sep
  ~20:30. Visible change: deep sleep a few points lower (the intended #2576); nothing else he should notice.
- [ ] **Strap logs on the mornings of 29 and 30 Sep** (More → Test Centre → Strap log → Save…, AirDrop) plus his wake
  time. Read them for: `re-score: deferred … at most every 30 min` lines and passes per hour (spacing), `re-score: cost`
  per pass (#2574/#2575 on the phone), when the night's score landed after waking, and the MetricKit day lines (28 and
  29 Sep: first "after" for upstream's strap-log fix and ours). `dist/tools/rescore-profile/passes.py <log>` counts
  passes/CPU; `hr-timeline.py` / `strap-log.py` as usual.
- [ ] **DREAMT for REM (`BACKLOG.md` C):** he registers at physionet.org, signs the DREAMT data use agreement and
  downloads `participant_info.csv` + the `data_64Hz` folder into `~/datasets/dreamt/` himself (steps given 28 Sep; never
  enter his credentials). Its DUA forbids sharing: local only, aggregates only. Then build a harness like `Tools/SleepPSG`
  (64 Hz files: TIMESTAMP, IBI ms, ACC_X/Y/Z, HR, Sleep_Stage every 30 s).

**Next safe action:** session start (README). Then, in order: (1) `upstream-check.sh` — answer any review on #2574 /
#2575 / #2576 ONCE (standing permission; `WORKFLOW.md` §5), rebase if one conflicts (twin-map refreshes conflict on
busy days: take upstream's file, re-run `parity_ledger.py --refresh-derived --base upstream/main`); after a merge,
prove the tree, retire the branch, rebuild the stack, ship. (2) When his logs arrive: read them (above), fill
PHONE_RESULT in `private/pr-rescore-spacing-body.md`, rebase `rescore-spacing` on `upstream/main`, `verify.sh`, open
the spacing PR. (3) When DREAMT is in `~/datasets/dreamt/`: a harness the way `Tools/SleepPSG` is built, REM first. (4) Otherwise `BACKLOG.md` in order.

## Our PRs upstream (`ryanbr/noop`)

Open (all 28 Sep, green, mergeable, no comments at 20:30):
- **#2574** `rescore-cheaper` `022a0fea` — the day fingerprint's five R-R figures in one walk: warm re-score 1.6 → 1.2 s
  CPU (sim, his data), byte-identical fingerprint. Both platforms. Body `private/pr-rescore-fingerprint-body.md`.
- **#2575** `stager-dft-table` `7c298e93` — `SleepStagerV2.respRegularity`'s twiddle factors once per night (table per
  grid length): cold re-score 4.9/5.0 → 4.5/4.4 s CPU, bit-identical. Both platforms; derived twin map refreshed.
  Body `private/pr-stager-dft-body.md`.
- **#2576** `psg-priors` `9787f7ed` + `9482462b` — `Tools/SleepPSG` section 7 (per-subject priors), then the deep base
  prior 0.18 → 0.15 (PSG n = 31: kappa 0.363 → 0.371, deep bias +5.17 → +1.32 pp, wake/REM identical; Utku's yes).
  Both platforms + pins; README updated. Body `private/pr-deep-prior-body.md`. Touches `SleepStagerV2` like #2575:
  whichever merges second may need a rebase (+ twin-map refresh).
Not yet a PR: `rescore-spacing` `d1f8c9bd` (on `4cdae213`; rebase first). Merged (16): #2569 (#2371), #2029, #2098,
#2099, #2386, #2402, #2403, #2415–#2418, #2419 (via #2480), #2420, #2422, #2437 (via #2481), #2444. Issue #2446 fixed
upstream in #2453. The parity gate on `main` drifts after busy merge days and the maintainers re-derive it (they did,
`0e524b38`, 28 Sep): compare with a clean `main` checkout before blaming a branch; never refresh the authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main` `0c982899`), `handbook` (this), `rescore-spacing` `d1f8c9bd`,
  `rescore-cheaper` `022a0fea` (#2574), `stager-dft-table` `7c298e93` (#2575), `psg-priors` `9482462b` (#2576),
  `testing-stack` `7bc5f64a` (`main` + those four), `testing-build` `769113c0` (the stack + `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`.
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`), and one per branch above:
  `~/Developer/noop-rescore-spacing`, `-rescore-cheaper`, `-stager-dft`, `-psg`. Build folders and verify logs:
  `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`, `WORKFLOW.md` §9); it holds only `verify/` (logs of the open
  branches + `derived`, verify's build cache) and `builds/stack-ios` (the stack's iOS build cache): both safe to delete.
- **Local only:** `dist/private/` (event log, `usage.log`, PR drafts). Utku's logs and backup: his files in
  `~/Downloads` (personal: never commit, never upload). PhysioNet sleep-accel (his yes): `~/datasets/motion-and-heart-
  rate-from-a-wrist-worn-wearable-and-labeled-sleep-from-polysomnography-1.0.0` (2.2 GB). Simulator `281E44EC`
  (iPhone 17 Pro): a clean Release of `main` `0c982899` over NOOP's 120 demo days (`--demo-seed`), light appearance.

## Verified — the latest numbers

- **Re-score cost, simulator, his backup** (`dist/tools/rescore-profile/`, Release, 7 warm passes after a synthetic
  offload): upstream `0c982899` warm 1.6 s CPU / cold 4.7–5.0 s. Time Profiler: `dayStreamFingerprint` 44% of warm
  (→ #2574: 1.2 s), `respRegularity` 13% of cold (→ #2575: 4.4–4.5 s). After #2574 the next costs are the fingerprint
  itself (25%, one R-R walk per night with a table lookup per row) and re-reading today's R-R window (17%). On his phone a
  warm pass costs ~3× the simulator (6.9 s CPU in the 28 Sep log).
- **Sleep staging vs PSG** (`Tools/SleepPSG`, sleep-accel n = 31): upstream kappa 0.363, deep 18.94 % vs 13.76 %, REM
  26.44 % vs 21.98 %, wake 4.15 % vs 9.07 % (pooled). With #2576: kappa 0.371, deep 15.09 %. His four nights (port, with
  R-R): deep 28–32 % → 26–27 % of sleep; REM 31–40 % of sleep (not addressed: needs R-R truth).
- **Last full `verify.sh` runs, all steps passed:** #2574 `022a0fea`, #2575 `7c298e93`, #2576 `9482462b` (WhoopStore
  629–631 · StrandAnalytics 2081–2083 · StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 · macOS
  2,244 with only the two `TodayCarryOverTests` · iOS build). Each new test seen to fail on both platforms.
- **Phone (MetricKit, 26 Sep, build `37408cc`):** background 23 h 28 m, CPU 1 h 36 m, peak memory 339 MB, disk writes
  193 MB, exits normal 4. The baseline to beat; re-scoring was ~15 CPU-min of it. His restarts of NOOP are mostly his
  own swipes (asked 28 Sep).
- Earlier numbers (#2444 animation, the 24 Sep simulator screen baseline): `HISTORY.md` and PR #2444.

## Next

1. Session start (README), then "Next safe action" above.
2. `BACKLOG.md` A — read the logs; the spacing PR; decide whether cross-pass window reuse is still worth it.
3. `BACKLOG.md` B — a relaunch costs a cold pass; persisting the day cache is the lever if relaunches stay frequent.
4. `BACKLOG.md` C — REM against DREAMT once he has downloaded it.
5. Every change: measure before/after, `verify.sh`, PR, rebuild `testing-stack`, ship, tell Utku "just update".
6. At the end of every session: README "End a session".
