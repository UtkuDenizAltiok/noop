# State

**Updated 1 Oct 2026, ~11:00, end of session 3 — Journey 2: NOOP, perfected (`RULES.md` mandate). 19 PRs merged. Open
(5, all clean on `upstream/main` `7f396e98`, no comments yet): #2612, #2613, #2617, #2618, #2619. On the releases page:
`d6b998c`; Utku's phone still runs `a8d25c1` (build 429). Next session: Saturday 3 Oct, with his strap logs, export and
backup.** The only file that changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- **Nothing is running.** Last ship: `d6b998c` (run 36802279087, verified on the releases page 1 Oct 03:59) =
  `upstream/main` `7f396e98` + #2612 + #2613 + #2617 + #2618 + #2619 (`testing-stack` `cb97eb2c`).

Waits on Utku:
- [ ] **Just update to `d6b998c`** (told 1 Oct ~11:00). After installing, if two Live HR banners show, tap the X on the
  Lock Screen group and open NOOP once (the frozen-banner bug below; fixed next session).
- [ ] **Saturday 3 Oct: strap logs (the morning's, plus any saved since), the export zip and the `.noopbak` backup**
  (Settings → Backup & Restore). Read them per "Next safe action" (3).
- [ ] **His yes/no (asked 1 Oct, not yet answered):** (a) the swiped-away reminder notification, (b) iOS's missing
  deleted-sleep list (`BACKLOG.md` 0). Visible features: build only what he says yes to.
- **Context (Utku, 30 Sep–1 Oct):** his nights are atypical for a while, no training; he sometimes takes the band off
  at night and sometimes swipes NOOP away, and cannot keep a record of it ("you decide"): read gaps from the log
  (WRIST_OFF, app runs), never ask him to log them. Judge a staging change by re-staging the SAME night with old and
  new code (`tools/his-nights/`), never night against night; recovery/HRV dips these days are real.

**Next safe action (Saturday), in order:**
1. Session start (README): `checkpoint.sh status --net`, `upstream-check.sh`. Answer any review on our five PRs ONCE
   (`WORKFLOW.md` §5); after a merge prove the tree (`merge-tree`), retire the branch + worktree, rebuild the stack.
2. **Fix the frozen Live HR banner** (`features/live-hr-banner.md` §6.0, evidence there): simulator proof that an
   `.ended` activity is listed and `end(nil, .immediate)` removes it; pure helper + test seen to fail; `verify.sh`
   (alone); PR; rebuild `testing-stack`; `ship-build.sh`; tell him "just update" + id.
3. **His files:** copy/unzip the `.noopbak` into the scratchpad (never the repo; delete after). `strap-log.py runs`,
   `rescore-profile/passes.py` (spacing still ≥ 30 min, CPU/h), `grep MetricKit` (30 Sep, 1 Oct, 2 Oct days; compare
   with 26 Sep 1 h 36 m and 29 Sep 1 h 10 m CPU), `grep 'Live HR banner'` (the bug's shape on `d6b998c`),
   `bash dist/tools/his-nights/run.sh <copy of noop-backup.sqlite>` (his nights with RSA 0.3: REM/deep/light), cold
   passes (`analyzeRecent dayCache reused=0`), WRIST_OFF gaps at night. Write numbers into "Verified" below.
4. His answers on (a)/(b) → build what he says yes to (strings in all locales; Android twin where Android has the code).
5. `BACKLOG.md` in order.

## Our PRs upstream (`ryanbr/noop`)

Open (fork-PR checks wait for the maintainers' approval; no comments yet at 11:00 1 Oct; all merge cleanly):
- **#2612** `rescore-spacing` `47254b18` — background offload re-scores at most every 30 min. Phone result in body.
- **#2613** `dreamt-psg` `7b638413` + `ca008aba` — `Tools/SleepPSG` reads DREAMT (section 8), then `respWeight`
  0.6 → 0.3 (61/28 subjects). Android CI 36712653602 green. Body `private/pr-rsa-weight-body.md`.
- **#2617** `dead-code-2` `332d3dac` + `4d3e6c89` — 15 Swift + 5 Kotlin unreferenced declarations; parity refresh
  (unpaired properties 165 → 162, constants 598 → 597). Android CI 36796672883 green. Body `private/pr-dead-code-2-body.md`.
- **#2618** `resonance-pace-pref` `194b0687` — "Use my resonance pace" decides the check-in's pace (both platforms).
  Android CI 36797831432 green; seen to fail on both platforms (Kotlin: fork run 36837267848, 1 of 6,591). Body
  `private/pr-resonance-pace-body.md`.
- **#2619** `sky-light-still` `7e7cf01f` — light-appearance night sky drawn still (iOS only; Android draws only the
  static sky). Body `private/pr-sky-light-body.md`.
Merged (19): #2574, #2575, #2576, #2569 (#2371), #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via
#2480), #2420, #2422, #2437 (via #2481), #2444. Issue #2446 fixed upstream in #2453. The parity gate on `main` drifts
after busy merge days and the maintainers re-derive it: compare with a clean `main` checkout before blaming a branch.
A PR that removes or adds a twin may need `parity_ledger.py --refresh-derived --base upstream/main` (as #2617 did).

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main` `7f396e98`), `handbook` (this), `rescore-spacing`, `dreamt-psg`,
  `dead-code-2`, `resonance-pace-pref`, `sky-light-still` (one per open PR), `testing-stack` `cb97eb2c` (`main` + those
  five), `testing-build` `d6b998c9` (the stack + `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`. Local
  only: `backup/handbook-pre-scrub` (the handbook before the 1 Oct history scrub; never push it).
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`), and one per PR branch:
  `~/Developer/noop-rescore-spacing`, `-dreamt`, `-dead-code`, `-resonance`, `-sky`. Build folders, logs and reports:
  `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`): `verify/`, `builds/stack-ios`, `his-nights/` (its
  build), `dreamt/` (aggregates only), `*.out` run logs. All safe to delete. xcodegen rewrites
  `StrandiOS/Resources/Info.plist` (a `stalebattery` entry upstream's plist lacks): discard it, never commit it.
- **Local only:** `dist/private/` (event log, `usage.log`, PR drafts). Utku's logs and backup in `~/Downloads`
  (personal: never commit, never upload); copies of a backup go in the session scratchpad and are deleted after use (none exist now). Datasets in
  `~/datasets`: sleep-accel (2.2 GB) and DREAMT v2.2.0 (14 GB; restricted, aggregates only). Simulator `281E44EC`
  (iPhone 17 Pro): Release `main` `7f396e98` over NOOP's 120 demo days (re-seeded 1 Oct), light appearance.

## Verified — the latest numbers

- **Background re-scoring on his phone** (strap logs 29–30 Sep, build `769113c0`): 41 passes / 243 CPU-s in 16.5 h and
  54 / 308 in 17.5 h (27–28 Sep before the spacing: 113 / 900 in 16.6 h). A backgrounded pass ~8 s CPU (median), a
  foreground one ~1.5 s for the same work. Cold passes: midnight 33 s CPU (0/7 days reused), iOS relaunch 20 s
  (assertion expired), foreground relaunch 5 s.
  1 Oct log (`a8d25c1`, 30 Sep 12:24 → 1 Oct 10:29, a gap 12:49–19:38): 47 passes / 326 CPU-s (bg 266).
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
- **Last full `verify.sh` runs, all steps passed:** #2617 `4d3e6c89` (run alone), #2618 `194b0687`, #2619 `7e7cf01f`
  (1 Oct); #2612 `47254b18`, #2613 `29f43bb2` (then `ca008aba`, test comments only: its tests + doc lint re-run) —
  WhoopStore 631 · StrandAnalytics 2102–2103 · StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 127 ·
  macOS 2,254–2,260 with only the two `TodayCarryOverTests` · iOS build. Never run two verifies at once (shared build
  cache and test host; 1 Oct two overlapped and the result had to be redone).

## Next

1. Session start (README), then "Next safe action" above — the frozen-banner fix first, then his files.
2. Utku's answers on the reminder notification and the deleted-sleep list (`BACKLOG.md` 0).
3. `BACKLOG.md` in order (B: cold-pass refactor only if worth it; D: night start moved by later data; C: wake/REM).
4. Every change: measure before/after, `verify.sh` (alone), PR, rebuild `testing-stack`, ship, tell Utku "just update".
5. At the end of every session: README "End a session".
