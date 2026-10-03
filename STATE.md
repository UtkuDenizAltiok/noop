# State

**Updated 3 Oct 2026, ~19:45, end of session 4 — HANDOVER.** Utku handed the engineering to a friend who works with
ChatGPT 6.1 (README "Handover"); this page is where the next session starts. Journey 2: NOOP, perfected (`RULES.md`
mandate). **23 PRs merged; open: #2613, #2659, #2660, #2661.** On the releases page: `3772b93` (all four); Utku's
phone: build 429 (`a8d25c1` or `d6b998c`, both 429) until he updates. The only file that changes every session.
Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

- **Nothing is running.** Last ship: `3772b93` (run 37136378349, verified on the releases page 3 Oct 19:38: `.ipa` + template) = `upstream/main`
  `6ce65730` + #2613 + #2659 + #2660 + #2661 (`testing-stack` `b6202262`).

Waits on Utku (ask him for the strap log after each, More → Test Centre → Strap log → Save…):
- [ ] **Just update to `3772b93`** (told 3 Oct ~19:45). No wipe: nothing stored changes shape.
- [ ] **Silent sync reminder** (#2661): More → Automations → "Sync reminder" is on. Swipe NOOP away; about 3 hours
  later a silent "Strap not synced" line should be on the Lock Screen (no sound). Opening NOOP clears it. If nothing
  shows, check Settings → Notifications → NOOP Staging is allowed. The log line: "Sync reminder: armed for …".
- [ ] **Deleted-sleep list** (#2660): Sleep → edit a night → Delete; after the undo strip goes, a "Deleted sleep
  windows" card lists it; "Recompute this night" brings it back (from raw data), "Hide" removes the row only.
- [ ] **Banner** (#2659): when NOOP has not been opened for 8 hours (overnight), after opening it only ONE banner
  should be on the Lock Screen; the log then shows "Live HR banner: ended by iOS" and "removed one iOS had ended".
- **Context (Utku, 30 Sep–1 Oct):** his nights are atypical for a while, no training; he sometimes takes the band off
  at night and sometimes swipes NOOP away, and cannot keep a record of it ("you decide"): read gaps from the log
  (WRIST_OFF, app runs), never ask him to log them. Judge a staging change by re-staging the SAME night with old and
  new code (`tools/his-nights/`), never night against night; recovery/HRV dips these days are real.

**Next safe action, in order:**
1. Session start (README; for the new engineer, README "Handover" first): `checkpoint.sh status --net`,
   `upstream-check.sh`. Answer any review on our four open PRs ONCE (`WORKFLOW.md` §5; they are in Utku's GitHub
   name: ask him how replies are to be made); after a merge prove it in (`merge-tree`), retire the branch + worktree,
   rebuild the stack, ship.
2. Utku's results from the three checks above, from his strap log.
3. `BACKLOG.md` "Top of the list", then A–D and the numbered candidates (9–11 are new, 3 Oct).

Not done in session 4 (from the Saturday plan): `tools/his-nights/run.sh` on the 3 Oct backup (his nights at RSA 0.3).
The backup copy was deleted; ask Utku for a fresh `.noopbak` when that is needed.

## Our PRs upstream (`ryanbr/noop`)

Open (fork-PR checks wait for the maintainers' approval; no comments at 19:45 3 Oct; each merges cleanly on
`6ce65730`, and all four together):
- **#2613** `dreamt-psg` `7b638413` + `ca008aba` — `Tools/SleepPSG` reads DREAMT (section 8), then `respWeight`
  0.6 → 0.3 (61/28 subjects). Android CI 36712653602 green. Body `private/pr-rsa-weight-body.md`.
- **#2659** `live-hr-ended` `a64d8474` — remove a Live HR banner iOS has ended (it stays frozen on its last number).
  iOS only. Body `private/pr-live-hr-ended-body.md`.
- **#2660** `ios-deleted-sleep` `3869d0b2` — the "Deleted sleep windows" card on iOS and macOS (Android parity, #515).
  Body `private/pr-deleted-sleep-body.md`.
- **#2661** `ios-sync-reminder` `60793987` — the silent "Strap not synced" reminder after 3 h without a sync. iOS only.
  Body `private/pr-sync-reminder-body.md`.
Merged (23): #2574, #2575, #2576, #2569 (#2371), #2029, #2098, #2099, #2386, #2402, #2403, #2415–#2418, #2419 (via
#2480), #2420, #2422, #2437 (via #2481), #2444, #2612, #2617, #2618, #2619. Issue #2446 fixed upstream in #2453. The
parity gate on `main` drifts after busy merge days and the maintainers re-derive it: compare with a clean `main`
checkout before blaming a branch. A PR that removes or adds a twin may need
`parity_ledger.py --refresh-derived --base upstream/main` (as #2617 did).

## The fork, exactly

- **Branches:** `main` (mirror of `upstream/main` `6ce65730`), `handbook` (this), `dreamt-psg`, `live-hr-ended`,
  `ios-deleted-sleep`, `ios-sync-reminder` (one per open PR), `testing-stack` `b6202262` (`main` + those four),
  `testing-build` `3772b938` (the stack + `fork/ships-template`).
- **Tags:** `fork/ships-template`, `testing-latest`, plus upstream's own. **Release:** one, `testing-latest`. Local
  only: `backup/handbook-pre-scrub` (the handbook before the 1 Oct history scrub; never push it).
- **Worktrees (local):** `~/Developer/noop` (`main`), `~/Developer/noop/dist` (`handbook`), and one per PR branch:
  `~/Developer/noop-dreamt`, `-banner`, `-deleted-sleep`, `-sync-reminder`. Build folders, logs and reports:
  `~/Library/Caches/noop-handbook/` (never `$TMPDIR/noop-*`): `verify/`, `builds/`, `his-nights/`, `dreamt/`
  (aggregates only), `*.out` run logs. All safe to delete. xcodegen rewrites `StrandiOS/Resources/Info.plist` (a
  `stalebattery` entry upstream's plist lacks): discard it, never commit it.
- **Local only:** `dist/private/` (event log, `usage.log`, PR drafts). Utku's logs and backup in `~/Downloads`
  (personal: never commit, never upload); copies go in the session scratchpad and are deleted after use (none exist
  now). Datasets in `~/datasets`: sleep-accel (2.2 GB) and DREAMT v2.2.0 (14 GB; restricted, aggregates only).
  Simulator `281E44EC` (iPhone 17 Pro): a Debug build of `ios-sync-reminder` over NOOP's demo data, with a seeded
  `lastSyncedAt` and one deletion marker (30 Sep, hidden); re-seed or reinstall Release `main` before measuring.

## Verified — the latest numbers

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
  ledger · ratchet · governance 127 · macOS with only the two `TodayCarryOverTests` · iOS build. Earlier: #2617 `4d3e6c89` (run alone), #2618 `194b0687`, #2619 `7e7cf01f`
  (1 Oct); #2612 `47254b18`, #2613 `29f43bb2` (then `ca008aba`, test comments only: its tests + doc lint re-run) —
  WhoopStore 631 · StrandAnalytics 2102–2103 · StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 127 ·
  macOS 2,254–2,260 with only the two `TodayCarryOverTests` · iOS build. Never run two verifies at once (shared build
  cache and test host; 1 Oct two overlapped and the result had to be redone).

## Next

1. "Next safe action" above.
2. `BACKLOG.md` in order (A: queued duplicate re-scores after #2646; B: cold passes; D: night start moved by later
   data; C: wake/REM; 9: iOS deletion markers missing from the backup).
3. Every change: measure before/after, `verify.sh` (alone), PR, rebuild `testing-stack`, ship, tell Utku "just update".
4. At the end of every session: README "End a session".
