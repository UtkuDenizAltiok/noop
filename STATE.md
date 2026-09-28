# State

**Updated 28 Sep 2026 (session 2) — Journey 2: NOOP, perfected (`RULES.md` mandate). 15 PRs merged; open: #2569 (#2371).
Utku's build: `eeac53e3` = upstream `3c6172de` + the background re-score spacing (`BACKLOG.md` A, `rescore-spacing`)
+ the #2371 500 ms fill mark (`BACKLOG.md` B, `rr-whoop5-fill`), neither a PR yet. Next: his strap log of the morning
of 29 Sep, then PR A; PR B once upstream re-derives its parity authority.** The
only file that changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- Nothing is running. Latest ship: `eeac53e3` (below). Earlier today: `8fac9a26` (run 36398385255, spacing only).

Waits on Utku:
- [ ] **Just update to `eeac53e3`** (the re-score spacing + #2371 on upstream `3c6172de`; replaces `8fac9a26`, which he
  may not have installed yet). Told 28 Sep ~12:10.
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

**`BACKLOG.md` B (#2371), built 28 Sep:** refined on his backup (5-bpm buckets, same-second `hrSample`): the 500
excess is 33–37× at 80–94 bpm, 3× at 95–99, 1.7× (4 rows) at 100–104, none from 105 → threshold **HR < 100** (not 110).
No 500 lacks a same-second HR; channel 6 has 0 rows and is never scored, so the rule covers channels **5 and 7** only.
After each R-R insert (only for a batch holding a WHOOP 5 500) one statement sets `tsSuspect = 1` where `rrMs = 500 AND
srcChannel IN (5, 7) AND tsSuspect IS NULL AND` same-second `hrSample.bpm < 100`; the same condition over the table
runs once as GRDB `v47-rr-whoop5-fill` / Room `MIGRATION_40_41` (version 41, committed `41.json`). SQL is one literal per
platform (the ledger pairs and compares them), pinned by the same literals in `Whoop5RrFillTests` / `Whoop5RrFillTest`;
`Whoop5RRSqliteTest` runs the same cases through the production insert. Draft: `private/pr-rr-fill-body.md` (complete).
- [x] Worktree `~/Developer/noop-rr-fill`, branch `rr-whoop5-fill` from `upstream/main` `ff00b38e`; commit `e364c68b`.
  WhoopStore 629 pass; new tests seen to fail (insert rule off: 3; migration off: 1; sha restored). On a COPY of his
  backup: 873 rows marked (ch5 508, ch7 365; 18+18 500s at >= 100 bpm kept); 138/508 ch5 fills passed the HRV cleaner
  (radius 2), nightly RMSSD +0.1..+0.3% without them (`scratchpad` scripts, counts only). Ledger: our findings resolved
  by 2 dispositions (DAO method, `migrate/1#39`); `--refresh-derived` blocked only by main's authority drift.
- [x] Full `verify.sh` on `e364c68b`: packages (629 / 2071 / 327), doc lint, i18n, macOS 2,239 (the two known), iOS build
  pass; ledger/ratchet/governance fail — ratchet as on `main`; ledger + 1 extra governance test = our DAO method
  awaiting `--refresh-derived`, which main's broken authority blocks (upstream's 04:37 schedule failed 28 Sep).
- [x] Android CI 36403411510: our tests passed; `WhoopDatabaseUpgradeTest` needed the committed Room `41.json`
  (= `40.json` with the version line only). Amended → `b4b862e9`, pushed with a pinned lease.
- [x] Android CI 36404612920 on `b4b862e9`: success (build + unit tests).
- [x] Seen to fail on Android: throwaway branch with the fix off, CI 36405114857: exactly our 4 tests failed of
  6,526 (3 insert-rule + the migration wiring). Branch deleted from the fork and locally.
- [x] Upstream re-derived its authority (`0e524b38`). Fork `main` mirrored; `rr-whoop5-fill` rebased (content proven
  unchanged), refresh committed → `936e60e1` + `87ea199a`; ledger OK (292 baselined), ratchet 0 errors; force-pushed
  (pinned lease, old `b4b862e9`); backup tag deleted.
- [x] Android CI 36408713200 on `87ea199a`: success. Full `verify.sh` on `87ea199a`: every step passed (ledger, ratchet,
  governance 124 included).
- [x] **PR #2569** opened 28 Sep (`rr-whoop5-fill` `87ea199a` → `ryanbr/noop` `main`), body `private/pr-rr-fill-body.md`.
- [x] #2569 went CONFLICTING (upstream `da4526f7` re-derived `Tools/parity_twin_map.json`): rebased (patch identical),
  refresh regenerated → `283616b4` + `a5afb4c0`, force-pushed (pinned lease, old `87ea199a`).
- [x] Android CI 36419269478 on `a5afb4c0`: success; full `verify.sh` on `a5afb4c0`: every step passed; PR description edited.

**Ship 2 of 28 Sep (both changes):**
- [x] Stack `9bde6246` = `upstream/main` `3c6172de` + spacing (`ccdd0718`) + #2371 (`9bde6246`): iOS BUILD SUCCEEDED
  locally, pushed to `testing-stack` (pinned lease, old `d0fe1231`). Fork `main` = `3c6172de`.
- [x] Shipped `eeac53e3` (run 36405967857), verified on the releases page 28 Sep 12:07 (.ipa + template); scratch
  worktree removed. Told Utku "just update" (the v47 migration is additive).

**Next safe action:** (1) `upstream-check.sh` + upstream's Parity Governance CI (`gh run list --repo ryanbr/noop
--workflow "Parity Governance CI" --limit 3`): once `main` passes again, rebase `rr-whoop5-fill`, run
`parity_ledger.py --refresh-derived --base upstream/main` (commit the refreshed derived files), `verify.sh`, open PR B.
(2) When Utku's 29 Sep log arrives: read it (deferral lines, passes/h, when the night's score landed, MetricKit), fill
PHONE_RESULT, rebase, open PR A. (3) Meanwhile `BACKLOG.md` A option (1) or the next backlog item.
The data is in Utku's files in `~/Downloads` (`noop-strap-log-260925-1303.txt`, `…260927-1248.txt`,
`…260928-0913.txt`, `NOOP-backup-2026-09-28.noopbak`: personal, never commit, never upload).
Standing permission (`RULES.md`): replies and pushes on our PRs, and a verified PR for this journey's work.
Do not redo: ships `8fac9a26` (run 36398385255) and `eeac53e3` (run 36405967857), stack pushes `d0fe1231` and
`9bde6246`, fork `main` mirror to `424bc304`, pushes of `rescore-spacing` `d1f8c9bd` and `rr-whoop5-fill` `a5afb4c0` (PR #2569),
the deleted throwaway branch `tmp-rr-fill-broken`.

## Our PRs upstream (`ryanbr/noop`)

Open: **#2569** (#2371, the WHOOP 5 500 ms fill mark, both platforms; opened 28 Sep). Merged (15): #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via #2480), #2420, #2422, #2437
(via #2481), #2444 (`HISTORY.md`). Our issue #2446 was fixed upstream in #2453. How ryanbr merges and what he asks
for: `WORKFLOW.md` §5. The parity gate on `main` drifts after busy merge days and the maintainers re-derive it: if our
`verify.sh` fails ledger/governance after a rebase, compare with a clean `main` checkout first; never refresh the
authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main`, `424bc304`), `handbook` (this), `rescore-spacing` @ `d1f8c9bd` and
  `rr-whoop5-fill` @ `a5afb4c0` (PR #2569), `testing-stack` @ `9bde6246` (`main` + both), `testing-build` @
  `eeac53e3` (the stack + `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`.
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`),
  `~/Developer/noop-rescore-spacing` (`rescore-spacing`), `~/Developer/noop-rr-fill` (`rr-whoop5-fill`). Build folders and verify
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
