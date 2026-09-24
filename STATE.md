# State

**Updated 24 Sep 2026 ~15:00 — Journey 2 begins: NOOP, perfected (`RULES.md` mandate). Journey 1 (the Lift Log and the
Live HR banner) is finished (`HISTORY.md`). Open PRs: #2419, #2420, #2437. Utku's build: `3ad319d` (just update).
Next: the baseline (`BACKLOG.md` §0), then the 500 ms R-R filler (#2371).** The only file that changes every session.
Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

Nothing is running (24 Sep ~15:00). One thing waits on Utku:
- [ ] **A normal day's strap log** from build `3ad319d`, NOOP left in the background all day (not swiped away), saved
  the next morning (More → Test Centre → Strap log → Save…). It carries iOS's MetricKit day line (#2420): the "before"
  for every battery and CPU claim (`BACKLOG.md` §0). Proof: his message + the log.

**Next safe action:** session start routine; then `BACKLOG.md` §0 — the simulator baseline (CPU-s a minute idle and
memory footprint of Today, Live, Sleep, Trends, More; `WORKFLOW.md` §11) needs nobody — then item 1, #2371.
Standing permission (`RULES.md`): replies and pushes on our PRs, and a verified PR for this journey's work.
Do not redo: PR #2437 and its description edit (24 Sep ~14:05), the reply to ryanbr's #2422 review (24 Sep 07:11 UTC),
ship `3ad319d` (run 35983431616), the branch renames (below).

## Our PRs upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2419](https://github.com/ryanbr/noop/pull/2419) | Settings → Live notifications: one switch each (heart rate, Lift Log, sync); each hides only its own | open, `lockscreen-switches` @ `99abbcb7`, green, no comments |
| [#2420](https://github.com/ryanbr/noop/pull/2420) | iOS MetricKit reports → one strap-log line each (local only) | open, `metrickit-daily-report` @ `d81f0cc1`, green, no comments |
| [#2437](https://github.com/ryanbr/noop/pull/2437) | the Live HR banner reads what it shows once the change has landed (the WRIST_OFF dash waited for iOS) | open, `live-hr-banner-settled` @ `bc5da07d`, 4/4 green, confirmed on the phone, no comments |

Merged so far: 11 PRs of ours — #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2422 (`HISTORY.md`). All three open branches merge cleanly into `upstream/main` `141cbd93`
(checked 24 Sep ~14:30). The parity gate on `main` drifts after busy merge days and the maintainers re-derive it
(`44ef71eb`, `24f2c879`): if our `verify.sh` fails ledger/governance after a rebase, compare with a clean `main`
checkout first; never refresh the authority ourselves.

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main`, `141cbd93`), `handbook` (this), `testing-stack` @ `3951497c`
  (= `141cbd93` + #2437 + #2419's net diff + #2420), `testing-build` @ `3ad319d6` (the stack + `fork/ships-template`),
  and one per open PR: `live-hr-banner-settled` (#2437), `lockscreen-switches` (#2419), `metrickit-daily-report`
  (#2420). Renamed 24 Sep from `lift-log-handbook`, `lift-log-build`, `noop-optimisations`; the fork's description
  and website point to `handbook`.
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest` = build
  `3ad319d` (shipped 24 Sep 12:07, verified; just update).
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop-banner-settled` (#2437),
  `~/Developer/noop-lockscreen` (#2419), `~/Developer/noop-metrickit` (#2420), `~/Developer/noop/dist` (`handbook`).
- **Local only:** `dist/private/` (the event log; the descriptions of the open PRs, `pr-*-body.md`). Utku's strap logs
  of 24 Sep 11:24 and 13:56 are in his `~/Downloads` (his files; personal — never commit). Simulator `281E44EC`
  (iPhone 17 Pro) has a NOOP test install.

## Verified — the latest numbers

- **#2437 on `bc5da07d`**, full `verify.sh`, every step passed: WhoopStore 611 · StrandAnalytics 2056 · StrandImport 327
  · doc lint · i18n · ledger · ratchet · governance 124 · macOS 2,144 (only the two `TodayCarryOverTests`) · iOS build.
  Seen to fail without its fix (`[91, 91]`, 6 refreshes for 1). On the phone (build `3ad319d`, 13:48–13:55): strap off
  → WRIST_OFF and the dash in the same second, seen 5–7 s later; Bluetooth off → dash the same second; back → number.
- **The Live HR banner:** every case confirmed on Utku's phone on 24 Sep (`features/live-hr-banner.md` §5).
- **Baselines so far:** simulator, Today idle, NOOP alone 6.29 CPU-s a minute (22 Sep, before this journey's changes);
  on the phone (24 Sep logs) re-scoring after a sync is cheap since upstream #2293 (mostly 0.1 s CPU a pass); half of
  the history syncs are the automatic follow-up that finds nothing (`BACKLOG.md` 4).

## Next

1. **Session start** (README): status `--net`, `upstream-check.sh`, then the line in "Now".
2. **`BACKLOG.md` §0** — the simulator baseline now; the phone baseline when Utku sends a normal day's log.
3. **`BACKLOG.md` 1 — #2371**, the 500 ms R-R filler stored as a real beat on WHOOP 5: the first measurement fix.
4. **Follow #2419, #2420, #2437** (`WORKFLOW.md` §5); rebuild `testing-stack` and ship after any merge or change.
5. **Hooks (Claude Code) are installed** (22 Sep): a session starts with the recovery brief. If a new session shows none,
   tell Utku rather than touching Claude's settings.
6. At the end of every session: README "End a session".
