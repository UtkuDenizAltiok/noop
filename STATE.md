# State

**Updated 28 Sep 2026 — Journey 2: NOOP, perfected (`RULES.md` mandate). All our PRs are merged (15 in total; #2420 and
#2444 this journey) and #2446 was fixed upstream. No open PRs. Utku's build: `0ad5ba97` = upstream `4cdae213` (just
update). Next: the background re-score cost (`BACKLOG.md` A), then #2371 (B).** The only file that changes every
session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- [x] **Shipped `0ad5ba97`** (`testing-stack` = `upstream/main` `4cdae213`, built locally first; pinned-lease push):
  run 36391977913, verified on the releases page 28 Sep 09:46 (.ipa + template). Nothing is running.

Waits on Utku:
- [ ] **Just update to `0ad5ba97`** (all merged work + upstream's 28 Sep fixes, including the strap-log view that
  rebuilt ~5,000 rows per line in the background). No test steps beyond using it normally.
- [ ] **Strap logs** saved on two mornings after installing it (More → Test Centre → Strap log → Save…, AirDrop to the
  Mac): their MetricKit day lines are the "after" for upstream's background fix and the "before" for `BACKLOG.md` A.

**Next safe action:** session start routine (README), then `BACKLOG.md` A: measure one re-score pass in the simulator
(demo data), read `IntelligenceEngine`'s post-offload re-score and the windows, decide option (1)/(2)/(3), explain any
behaviour change to Utku first. Then B (#2371) as its own PR, both platforms, oracle-proven. The data for both is in
Utku's files in `~/Downloads` (`noop-strap-log-260925-1303.txt`, `…260927-1248.txt`, `…260928-0913.txt`,
`NOOP-backup-2026-09-28.noopbak`: personal, never commit, never upload).
Standing permission (`RULES.md`): replies and pushes on our PRs, and a verified PR for this journey's work.
Do not redo: ship `0ad5ba97` (run 36391977913), the stack reset to `4cdae213`, the branch retirements of 28 Sep, issue
#2446, PR #2444.

## Our PRs upstream (`ryanbr/noop`)

None open. Merged (15): #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via #2480), #2420, #2422, #2437
(via #2481), #2444 (`HISTORY.md`). Our issue #2446 was fixed upstream in #2453. How ryanbr merges and what he asks
for: `WORKFLOW.md` §5. The parity gate on `main` drifts after busy merge days and the maintainers re-derive it: if our
`verify.sh` fails ledger/governance after a rebase, compare with a clean `main` checkout first; never refresh the
authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main`, `4cdae213`), `handbook` (this), `testing-stack` @ `4cdae213` (no open
  PRs, so = `main`), `testing-build` @ `0ad5ba97` (the stack + `fork/ships-template`). No PR branches.
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`.
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`). Build folders and verify
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

## Next

1. **Session start** (README): status `--net`, `upstream-check.sh`, then the lines in "Now".
2. **`BACKLOG.md` A** — the background re-score (~20 CPU-min a day on his phone).
3. **`BACKLOG.md` B** — #2371, the 500 ms filler, both platforms.
4. Then the rest of `BACKLOG.md`: the night sky's render cost, a score reviewed against the literature, dead code.
5. Every change: measure before/after, `verify.sh`, PR, rebuild `testing-stack`, ship, tell Utku "just update".
6. At the end of every session: README "End a session".
