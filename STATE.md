# State

**Updated 28 Sep 2026 (session 2) — Journey 2: NOOP, perfected (`RULES.md` mandate). 15 PRs merged, none open.
Utku's build: `8fac9a26` = upstream `fcc384d2` + the background re-score spacing (`BACKLOG.md` A, branch
`rescore-spacing`, not yet a PR). Next: his strap log from the morning of 29 Sep, then the PR; then #2371 (B).** The
only file that changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- [x] **Shipped `8fac9a26`** (`testing-stack` `d0fe1231` = `upstream/main` `fcc384d2` + the spacing commit, built for
  iOS locally first, pinned-lease push): run 36398385255, verified on the releases page 28 Sep 10:54 (.ipa +
  template). Nothing is running.

Waits on Utku:
- [ ] **Just update to `8fac9a26`** (replaces `0ad5ba97`; includes upstream's 28 Sep fixes). Told 28 Sep ~10:55.
- [ ] **Strap log on the morning of 29 Sep**, saved soon after he first opens NOOP (More → Test Centre → Strap log →
  Save…, AirDrop), plus the time he woke. It is the "after" for the spacing (the `re-score: deferred … at most every
  30 min` lines, passes per hour, when the night's score landed) and its MetricKit day line the first "after" for
  upstream's strap-log fix. A second morning's log if the first is thin.

**`BACKLOG.md` A, PR 1 — background re-score spacing** (Utku's yes of 28 Sep, `RULES.md`):
- Branch `rescore-spacing` `d1f8c9bd` on `4cdae213`, pushed to the fork, worktree `~/Developer/noop-rescore-spacing`.
  One rule in `RescoreBackgroundPolicy.decide` (iOS-only, upstream #1557): a backgrounded offload whose last pass
  STARTED < 30 min ago defers (debt recorded; the next offload past the spacing, the processing task or the next
  foreground settles it). Not while a pass runs here (#1681 path untouched). Foreground, macOS, Android unchanged.
- Measured by replaying his logs (`private/passes.py`): 27–28 Sep 113 passes / 900 CPU-s → 32 / 250; 26–27 Sep
  103 / 754 → 32 / 226; 24–25 Sep 153 / 360 → 51 / 92.
- Tests: 42 policy/scheduler tests pass; with the rule off 5 assertions fail (seen; sha restored). Full `verify.sh`
  on `d1f8c9bd` passed except the parity ratchet and governance 1/124, which fail identically on clean `4cdae213`
  (upstream drift; fork CI shows it on `main`).
- [ ] **PR upstream after the 29 Sep log** confirms it on the phone (RULES 7). Draft `private/pr-rescore-spacing-body.md`
  (fill PHONE_RESULT; rebase on `upstream/main` first if it moved; journal the PR number the moment it exists).

**Next safe action:** until the log arrives, `BACKLOG.md` B (#2371) on its own branch: flag `rrMs == 500` as suspect
(`tsSuspect = 1`) when the strap's HR that second is < 110, at `StreamStore.insert` (the batch carries the same-second
HR on all three WHOOP 5 paths) + the Kotlin twin + a versioned migration (Room twin) + tests; `rr-fill.py` numbers of
28 Sep are in `BACKLOG.md` B (channel 6, live type-40, has no rows in his data: say so). Then A option (1).
The data is in Utku's files in `~/Downloads` (`noop-strap-log-260925-1303.txt`, `…260927-1248.txt`,
`…260928-0913.txt`, `NOOP-backup-2026-09-28.noopbak`: personal, never commit, never upload).
Standing permission (`RULES.md`): replies and pushes on our PRs, and a verified PR for this journey's work.
Do not redo: ship `8fac9a26` (run 36398385255), the stack push `d0fe1231`, the fork `main` mirror to `fcc384d2`,
the push of `rescore-spacing` `d1f8c9bd`.

## Our PRs upstream (`ryanbr/noop`)

None open. Merged (15): #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via #2480), #2420, #2422, #2437
(via #2481), #2444 (`HISTORY.md`). Our issue #2446 was fixed upstream in #2453. How ryanbr merges and what he asks
for: `WORKFLOW.md` §5. The parity gate on `main` drifts after busy merge days and the maintainers re-derive it: if our
`verify.sh` fails ledger/governance after a rebase, compare with a clean `main` checkout first; never refresh the
authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main`, `fcc384d2`), `handbook` (this), `rescore-spacing` @ `d1f8c9bd`
  (PR to come), `testing-stack` @ `d0fe1231` (`main` + that commit), `testing-build` @ `8fac9a26` (the stack +
  `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`.
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`),
  `~/Developer/noop-rescore-spacing` (`rescore-spacing`). Build folders and verify
  logs: `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`, `WORKFLOW.md` §9).
- **Local only:** `dist/private/` (the event log, `usage.log`, old PR texts). Utku's logs and backup are his files in
  `~/Downloads`. Simulator `281E44EC` (iPhone 17 Pro) has NOOP with 120 demo days (`--demo-seed`), light appearance.

## Verified — the latest numbers

- **#2444 on `d38a1473`**, full `verify.sh`, every step passed: WhoopStore 611 · StrandAnalytics 2056 · StrandImport 327
  · doc lint · i18n · ledger · ratchet · governance 124 · macOS 2,151 (only the two `TodayCarryOverTests`) · iOS build;
  StrandDesign 111. Simulator, Release, demo data, alternating A/B: Today by day **6.72/6.47 + 22.65/22.50 → 0.00/0.00
  + 0.11/0.11**; Sleep 4.96/6.92 + 34.37/17.43 → 0.01/0.01 + 0.06/0.12; Today at night (dark, stars) 6.31 + 22.14 →
  1.95 + 22.66. Pixels vs `main`: ≤ 2 levels (breath phase), header ring identical. Stars twinkle at night (20:04).
  Each test seen to fail (sky gate 1,665 / 411; ring premise + clock; census names upstream's 3 paused timelines).
- **Simulator baseline, 24 Sep 15:04–15:11** (`main` `141cbd93`, Release, iPhone 17 Pro `281E44EC`, iOS 26.5, demo data
  of 120 days from `--demo-seed`, no strap; `tools/usage.sh`, 60 s after 10 s settling; raw lines in
  `private/usage.log`). CPU-s a minute, NOOP · render server (backboardd) · footprint:
  Today (Liquid) **7.03 · 21.86** · 66 MB; Sleep **7.24 · 17.04** · 96 MB; Trends 0.01 · 0.01 · 87 MB; Coach 0.00 · 0.01
  · 79 MB; More 0.00 · 0.01 · 93 MB; Live (no strap) 0.00 · 0.01 · 111 MB (footprint grows as tabs are visited; one
  run, in that order). A still screen costs nothing; the two animated screens are all of it. Debug is heavier (Today
  10.5 · 21.0, still loading). 22 Sep, Today, NOOP alone: 6.29 (Debug, no demo data) — not comparable.
- **Phone (MetricKit, 26 Sep, build `37408cc`):** foreground 1 m 54 s, background 23 h 28 m, CPU 1 h 36 m, peak memory
  339 MB, disk writes 193 MB. The baseline to beat (`BACKLOG.md` A). No earlier day line exists.
- **#2371 on Utku's 5.0 (backup of 28 Sep):** the 500 ms filler only below ~110 bpm (`BACKLOG.md` B).
- **Re-score spacing `d1f8c9bd`**, full `verify.sh`: WhoopStore 624 · StrandAnalytics 2070 · StrandImport 327 · doc
  lint · i18n · ledger · macOS 2,231 (only the two `TodayCarryOverTests`) · iOS build; ratchet + governance 1/124 fail
  identically on clean `4cdae213` (upstream drift). Replay of his logs: 900 → 250 background re-score CPU-s (27–28 Sep).

## Next

1. **Session start** (README): status `--net`, `upstream-check.sh`, then the lines in "Now".
2. **`BACKLOG.md` A** — spacing shipped in `8fac9a26`; PR after his 29 Sep log. Then option (1), the incremental
   window, if the log shows passes still worth cutting.
3. **`BACKLOG.md` B** — #2371, the 500 ms filler, both platforms (can start before the log arrives).
4. Then the rest of `BACKLOG.md`: the night sky's render cost, a score reviewed against the literature, dead code.
5. Every change: measure before/after, `verify.sh`, PR, rebuild `testing-stack`, ship, tell Utku "just update".
6. At the end of every session: README "End a session".
