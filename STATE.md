# State

**Updated 28 Sep 2026 (session 2) — Journey 2: NOOP, perfected (`RULES.md` mandate). 16 PRs merged (#2569 on 28 Sep); open: #2574 (cheaper re-score fingerprint).
Utku's build: `1ad53536` = upstream `0c982899` (incl. merged #2569) + the re-score spacing (`rescore-spacing`, PR after
his logs) + the one-walk fingerprint (#2574). Next: his strap log of the morning
of 29 Sep, then PR A; PR B once upstream re-derives its parity authority.** The
only file that changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- Nothing is running. Latest ship: `eeac53e3` (below). Earlier today: `8fac9a26` (run 36398385255, spacing only).

Waits on Utku:
- [ ] **Just update to `1ad53536`** (upstream `0c982899` incl. merged #2569 + the 30-min spacing + the one-walk
  fingerprint #2574; replaces `eeac53e3`). Told 28 Sep ~17:10.
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
- [ ] **PR upstream after the 29/30 Sep logs** confirm it on the phone (RULES 7; Utku confirmed 28 Sep pm: keep the spacing). Draft `private/pr-rescore-spacing-body.md`
  (fill PHONE_RESULT; rebase on `upstream/main` first if it moved; journal the PR number the moment it exists).

**`BACKLOG.md` B (#2371): DONE — PR #2569 merged 28 Sep 12:20Z** (tree == our branch; `HISTORY.md`). Branch and
worktree retired. Evidence and method: `private/pr-rr-fill-body.md`.

**`BACKLOG.md` A option (1), cheaper passes (28 Sep pm), branch `rescore-cheaper` (worktree `~/Developer/noop-rescore-cheaper`):**
- Harness: throwaway worktree `~/Library/Caches/noop-handbook/prof` + `prof.patch` (AppModel: 25 s wait, 8 forced passes,
  a 600 s synthetic offload before each warm pass, strap-log lines mirrored to NSLog); `prof-run.sh`; simulator
  281E44EC holds a COPY of his backup DB (demo DB + prefs saved in `~/Library/Caches/noop-handbook/sim-demo-backup`,
  put back when done). Time Profiler: `prof.trace`, `prof-agg.py`, `prof-callers.py`.
- Baseline (upstream `424bc304`, sim, Release): warm pass 1.6 s CPU (1.9–2.1 s elapsed), cold 5.0 s. Of 7 warm passes'
  11.8 s CPU: `dayStreamFingerprint` 5.1 s (44%: five rr COUNT scans with a table lookup per row), rr reads 1.1 s,
  hr/grav/steps reads 0.8 s, other fingerprints 0.7 s, GRDB by-name column lookup (`String.lowercased`) 0.3 s.
- [x] (1) committed `022a0fea` on `rescore-cheaper` (Swift + Kotlin, equivalence tests vs the replaced statement; Swift
  seen to fail: 106 failures with the suspect filter dropped). Pushed; Android CI 36426678021 green. A/B (A = upstream
  `0c982899`, B = branch; `prof`, `prof-b`; logs `ab-*.log`), 2 rounds: warm 1.6 → 1.2 s CPU (−25%), elapsed 2.0 → 1.6 s,
  cold 5.0/4.7 → 4.4/4.2 s; cache decisions identical. Draft `private/pr-rescore-fingerprint-body.md`.
- [x] Full `verify.sh` on `022a0fea`: every step passed.
- [x] Android seen-to-fail (Utku told first): run 36434511659 failed exactly `dayFingerprintOneWalkMatchesTheFiveSubSelects` (1 of 6,535); throwaway branch deleted.
- [x] **PR #2574** opened 28 Sep (`rescore-cheaper` `022a0fea`), body `private/pr-rescore-fingerprint-body.md`.
- Plan: (1) one combined rr scan in `dayStreamFingerprint` (Python on his data: 199 → 78 ms per 54 h window,
  identical values), Swift + Kotlin; (2) positional column reads in the hot stream reads; re-measure; then cross-pass
  reuse of the day windows if still worth it.

**Ship 3 (28 Sep evening):** [x] stack `f15e6efe` = `upstream/main` `0c982899` + spacing (`e79687e0`) + fingerprint
(`f15e6efe`), iOS BUILD SUCCEEDED locally, pushed (pinned lease, old `9bde6246`). [x] Shipped `1ad53536` (run
36435795605), verified on the releases page 28 Sep ~17:10; scratch worktree removed; Utku told "just update".

**Sleep staging vs PSG (Utku's yes, 28 Sep ~17:00, to download PhysioNet sleep-accel, 577 MB, to `~/datasets`,
never in the repo):** [ ] download; [ ] `Tools/SleepPSG` baseline report on `upstream/main`; then variants for the
deep bias (+5.18 pp pooled) — kappa AND stage fractions (README: #348 was reverted for a fraction regression).

**Next safe action:** `BACKLOG.md` A option (1): make each re-score pass cheaper with byte-identical scores — profile a
pass (simulator, demo data; `analyzeRecent` cost lines), find where the ~7 s goes (prep 2.1 + score 0.1 + postLoop 0.9
of 6.7 s on his phone, ~3.6 s not broken out), cut it, prove scores identical (oracle over demo data before/after).
Then biometrics and the connection (his 28 Sep afternoon ask). Utku saves strap logs on 29 and 30 Sep mornings.
#2569: answer any review once (standing permission).

## Our PRs upstream (`ryanbr/noop`)

Open: **#2574** (the day fingerprint's R-R figures in one walk: warm re-score −25% CPU; both platforms; 28 Sep). Merged (16): #2569 (#2371, 28 Sep), #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via #2480), #2420, #2422, #2437
(via #2481), #2444 (`HISTORY.md`). Our issue #2446 was fixed upstream in #2453. How ryanbr merges and what he asks
for: `WORKFLOW.md` §5. The parity gate on `main` drifts after busy merge days and the maintainers re-derive it: if our
`verify.sh` fails ledger/governance after a rebase, compare with a clean `main` checkout first; never refresh the
authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main`, `424bc304`), `handbook` (this), `rescore-spacing` @ `d1f8c9bd` (PR after his logs),
  `rescore-cheaper` @ `022a0fea` (PR #2574), `testing-stack` @ `f15e6efe` (`main` + spacing + fingerprint), `testing-build` @
  `1ad53536` (the stack + `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`.
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`),
  `~/Developer/noop-rescore-spacing` (`rescore-spacing`), `~/Developer/noop-rescore-cheaper` (`rescore-cheaper`). Build folders and verify
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
