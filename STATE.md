# State

**Updated 24 Sep 2026 ~20:50 — Journey 2: NOOP, perfected (`RULES.md` mandate). First result: #2444, Today and Sleep
stop redrawing what does not move. Open PRs: #2419, #2420, #2437, #2444. Utku's build: `37408cc` (just update).
Next: his logs (before/after) and backup (#2371).** The only file that changes every session.
Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

Nothing is running (24 Sep ~20:50). Waits on Utku:
- [ ] **Just update to `37408cc`** (#2444: Today and Sleep stop redrawing what does not move) and look it over: Today
  and Sleep look as before, the rings fill when they appear, tapping a ring still opens it, a sync still spins the
  header ring, the stars still twinkle late in the evening. Proof: his message.
- [ ] **A strap log saved on the morning of 25 Sep** (More → Test Centre → Strap log → Save…): its MetricKit line
  covers 24 Sep, mostly on `3ad319d` — the phone's "before". **And one on the morning of 26 Sep**: 25 Sep on
  `37408cc` — the "after" for #2444. NOOP left in the background, not swiped away.
- [ ] **A NOOP backup** (More → Settings → Backup & restore → Export…) for #2371: `tools/rr-fill.py` tells whether the
  strap also sends 500 ms as a real beat at ~120 bpm. Personal data: stays on this Mac, never committed.

Following: **#2444** (CI all 15 green at ~20:55, no comments) — `WORKFLOW.md` §5.

**Next safe action:** session start routine; check #2444's CI and comments; then, with Utku's backup, #2371
(`BACKLOG.md` 1), or without it `BACKLOG.md` 4 (the empty follow-up sync) from his logs.
Standing permission (`RULES.md`): replies and pushes on our PRs, and a verified PR for this journey's work.
Do not redo: PR #2444 (20:20), stack `3f88327f` (pushed ~20:40), ship `37408cc` (run 36040916843, verified 20:42);
PR #2437 and its description edit, the reply to ryanbr's #2422 review, the branch renames.

## Our PRs upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2419](https://github.com/ryanbr/noop/pull/2419) | Settings → Live notifications: one switch each (heart rate, Lift Log, sync); each hides only its own | open, `lockscreen-switches` @ `99abbcb7`, green, no comments |
| [#2420](https://github.com/ryanbr/noop/pull/2420) | iOS MetricKit reports → one strap-log line each (local only) | open, `metrickit-daily-report` @ `d81f0cc1`, green, no comments |
| [#2437](https://github.com/ryanbr/noop/pull/2437) | the Live HR banner reads what it shows once the change has landed (the WRIST_OFF dash waited for iOS) | open, `live-hr-banner-settled` @ `bc5da07d`, 4/4 green, confirmed on the phone, no comments |
| [#2444](https://github.com/ryanbr/noop/pull/2444) | Today stops redrawing the sky, the hero rings and the header sync ring while nothing moves (Today by day 6.7 + 22.6 → 0.00 + 0.11 CPU-s/min, simulator) | open 24 Sep 20:20, `today-still-at-rest` @ `d38a1473`, 3 commits, 15/15 green, no comments |

Merged so far: 11 PRs of ours — #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2422 (`HISTORY.md`). All three open branches merge cleanly into `upstream/main` `141cbd93`
(checked 24 Sep ~14:30). The parity gate on `main` drifts after busy merge days and the maintainers re-derive it
(`44ef71eb`, `24f2c879`): if our `verify.sh` fails ledger/governance after a rebase, compare with a clean `main`
checkout first; never refresh the authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main`, `141cbd93`), `handbook` (this), `testing-stack` @ `3f88327f`
  (= `141cbd93` + #2437 + #2419's net diff + #2420 + #2444), `testing-build` @ `37408cc4` (the stack +
  `fork/ships-template`), and one per open PR: `live-hr-banner-settled` (#2437), `lockscreen-switches` (#2419),
  `metrickit-daily-report` (#2420), `today-still-at-rest` (#2444). Renamed 24 Sep from `lift-log-handbook`, `lift-log-build`, `noop-optimisations`; the fork's description
  and website point to `handbook`.
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest` = build
  `37408cc` (shipped 24 Sep 20:42, verified; just update).
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop-banner-settled` (#2437),
  `~/Developer/noop-lockscreen` (#2419), `~/Developer/noop-metrickit` (#2420), `~/Developer/noop-today-still` (#2444),
  `~/Developer/noop/dist` (`handbook`). Build folders and verify logs: `~/Library/Caches/noop-handbook/` (never
  `$TMPDIR/noop-*`, `WORKFLOW.md` §9).
- **Local only:** `dist/private/` (the event log; the descriptions of the open PRs, `pr-*-body.md`). Utku's strap logs
  of 24 Sep 11:24 and 13:56 are in his `~/Downloads` (his files; personal — never commit). Simulator `281E44EC`
  (iPhone 17 Pro) has NOOP with 120 demo days (`--demo-seed`), light appearance; the measuring builds of 24 Sep are in
  the caches folder and the session scratchpad (both disposable).

## Verified — the latest numbers

- **#2444 on `d38a1473`**, full `verify.sh`, every step passed: WhoopStore 611 · StrandAnalytics 2056 · StrandImport 327
  · doc lint · i18n · ledger · ratchet · governance 124 · macOS 2,151 (only the two `TodayCarryOverTests`) · iOS build;
  StrandDesign 111. Simulator, Release, demo data, alternating A/B: Today by day **6.72/6.47 + 22.65/22.50 → 0.00/0.00
  + 0.11/0.11**; Sleep 4.96/6.92 + 34.37/17.43 → 0.01/0.01 + 0.06/0.12; Today at night (dark, stars) 6.31 + 22.14 →
  1.95 + 22.66. Pixels vs `main`: ≤ 2 levels (breath phase), header ring identical. Stars twinkle at night (20:04).
  Each test seen to fail (sky gate 1,665 / 411; ring premise + clock; census names upstream's 3 paused timelines).
- **#2437 on `bc5da07d`**, full `verify.sh`, every step passed: WhoopStore 611 · StrandAnalytics 2056 · StrandImport 327
  · doc lint · i18n · ledger · ratchet · governance 124 · macOS 2,144 (only the two `TodayCarryOverTests`) · iOS build.
  Seen to fail without its fix (`[91, 91]`, 6 refreshes for 1). On the phone (build `3ad319d`, 13:48–13:55): strap off
  → WRIST_OFF and the dash in the same second, seen 5–7 s later; Bluetooth off → dash the same second; back → number.
- **The Live HR banner:** every case confirmed on Utku's phone on 24 Sep (`features/live-hr-banner.md` §5).
- **Simulator baseline, 24 Sep 15:04–15:11** (`main` `141cbd93`, Release, iPhone 17 Pro `281E44EC`, iOS 26.5, demo data
  of 120 days from `--demo-seed`, no strap; `tools/usage.sh`, 60 s after 10 s settling; raw lines in
  `private/usage.log`). CPU-s a minute, NOOP · render server (backboardd) · footprint:
  Today (Liquid) **7.03 · 21.86** · 66 MB; Sleep **7.24 · 17.04** · 96 MB; Trends 0.01 · 0.01 · 87 MB; Coach 0.00 · 0.01
  · 79 MB; More 0.00 · 0.01 · 93 MB; Live (no strap) 0.00 · 0.01 · 111 MB (footprint grows as tabs are visited; one
  run, in that order). A still screen costs nothing; the two animated screens are all of it. Debug is heavier (Today
  10.5 · 21.0, still loading). 22 Sep, Today, NOOP alone: 6.29 (Debug, no demo data) — not comparable.
- **On the phone** (24 Sep logs) re-scoring after a sync is cheap since upstream #2293 (mostly 0.1 s CPU a pass); half of
  the history syncs are the automatic follow-up that finds nothing (`BACKLOG.md` 4).

## Next

1. **Session start** (README): status `--net`, `upstream-check.sh`, then the line in "Now".
2. **The phone baseline** from Utku's 25 and 26 Sep logs (MetricKit lines: before / after #2444).
3. **`BACKLOG.md` 1 — #2371** once his backup arrives (`tools/rr-fill.py`); otherwise `BACKLOG.md` 4 from his logs.
4. **Follow #2419, #2420, #2437, #2444** (`WORKFLOW.md` §5); rebuild `testing-stack` and ship after any merge or change.
5. **Hooks (Claude Code) are installed** (22 Sep): a session starts with the recovery brief. If a new session shows none,
   tell Utku rather than touching Claude's settings.
6. At the end of every session: README "End a session".
