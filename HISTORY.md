# History

One line per event: what happened, what it found, the rule it produced. The lessons themselves live in `RULES.md` and
`WORKFLOW.md`; the detailed day-by-day record of the first journey is in this branch's git history before 24 Sep 2026
(`git log --before=2026-09-25 -- HISTORY.md` on the `handbook` branch).

## Journey 1 — the Lift Log and the Live HR banner (2–24 Sep 2026), finished

A gym log book built into NOOP for Utku, then the heart-rate Lock Screen banner. Seven gym sessions and nine strap logs
found every bug that mattered; each fix went upstream to `ryanbr/noop`, whose maintainers merged within hours:
- **9 Sep** #2029 catalog hygiene — the first contribution.
- **14–15 Sep** #2098 the Lift Log's storage (migration `v46-lift-log`, Room twin), #2099 the app; the maintainers added
  #2232 (Kotlin `LiftMetrics` twin) and #2233 (a parity repair our merge had needed).
- **22–23 Sep** #2386 strap log kept on disk within 2 MB; #2402 the standard-HR log line summarised; #2403 Lift Log
  rounds 3–6 (finish flow, max RPE, knock guard, restart survival, no work between taps, the Dynamic Island).
- **23 Sep, NOOP itself:** #2415 Live HR banner pushed only on change; #2416 manual workout one sample a second;
  #2417 707 lines of unused private code removed; #2418 the stress check-in takes each R-R packet once.
- **24 Sep** #2422 merged: live heart rate only while the strap measures it; the banner kept until its switch, "–"
  otherwise (Utku's decision after living with both versions); ryanbr's review answered. Utku's tests on the phone
  confirmed every case but one; the strap's WRIST_OFF dash waited ~2 min for iOS — fixed in **#2437** the same hour
  (a sink read another object's state inside a willSet: `RULES.md` 6), confirmed on his phone at 13:48.
- **Open at the close:** #2419 (Live notifications: one switch each), #2420 (MetricKit reports into the strap log),
  #2437.

The pattern worth remembering: the bugs that mattered were silent wrong data that passed every test and build — a
value that looks right on screen while being wrong underneath. A real session catches that; a suite does not
(`RULES.md` 3, 12). What found each Lift Log bug: `features/lift-log.md`.

## Journey 2 — NOOP, perfected (from 24 Sep 2026)

- **24 Sep, ~14:15** — Utku opened it: the whole of NOOP perfect, optimised, low usage on phone and strap, better
  algorithms and biometrics than WHOOP, clean code; me as owner and decider. The handbook was reorganised for it
  (branches `handbook`, `testing-stack`, `testing-build`; `RULES.md`, `WORKFLOW.md`, `BACKLOG.md` rewritten; the two
  finished features moved to `features/`). First survey: a 500 ms R-R filler stored as a real beat on WHOOP 5 (#2371)
  leads the backlog; half of all history syncs are an automatic follow-up that finds nothing.
- **24 Sep, 15:00–15:11** — Simulator baseline (Release, 120 demo days, `tools/usage.sh`): still screens cost nothing;
  Today 7 + 22 and Sleep 7 + 17 CPU-s a minute (NOOP + render server), all of it decorative loops.
- **24 Sep, 15:15–16:50** — The daytime sky: its breath moves ≤ 2 of 255 levels, yet it redrew at 20 fps. A first fix
  with `paused:` measured WORSE (render server 22 → 46); a plain still `Canvas` worked. `verify.sh` lost its logs
  mid-run: the macOS test host's `purgeImportTemp()` deletes `noop-*` in the shared temp folder (canary-proven);
  `verify.sh` moved to `~/Library/Caches/noop-handbook/`.
- **24 Sep, 16:30–17:03** — The hero rings: a ring since #1068 (draws `sim.level` only) but still a 60 fps loop, the
  whole sim and the tilt sensor. Stopped once filled: Today NOOP 6.8 → 1.7, Sleep 5–7 + 17–34 → 0.01 + 0.1. Turn cut
  off by an API error at 17:03; resumed 19:01.
- **24 Sep, 19:05–19:45** — The night check found the sky gate too loose (no star drawn until the brightest reaches
  opacity 0.02): the gate now follows the drawable stars. Sky + rings left the render server churning (15–51) with
  NOOP at 0: the header sync ring's paused timeline; drawn still, 0.07.
- **24 Sep, 20:20** — **PR #2444** "today: stop redrawing the sky and the rings while nothing moves" (3 commits: sky,
  hero rings, header sync ring + a census that no animation timeline is merely paused). Today by day 6.7 + 22.6 →
  0.00 + 0.11; night 6.3 → 2.0 in NOOP. Full `verify.sh` passed. Stack `3f88327f`, build **`37408cc`** shipped
  20:42 (run 36040916843; just update).
- **24 Sep, 23:25** — Utku: "I accept everything you say". Issue **#2446** filed upstream: the macOS app deletes other
  programs' `noop-*` items in the shared temp folder at launch. `BACKLOG.md` 4 (the empty follow-up sync) measured and
  dropped: two small commands and one or two replies in the same second.
- **25 Sep, ~00:05** — Full check-up after two cut-offs: GitHub and this Mac identical, the testing stack proven equal
  to upstream + our four PRs, all PRs green and mergeable; ~20 GB of measuring builds cleaned.
- **25–27 Sep** — Upstream took everything: #2419 via #2480 and #2437 via #2481 (26 Sep, rebased, authorship kept,
  ryanbr's doc corrections and long praise on top), **#2420 and #2444 merged 27 Sep**, and #2446 fixed upstream in
  #2453 (scratch in a folder named for the bundle; legacy scratch swept by exact prefixes). 15 PRs of ours merged.
- **28 Sep** — Utku's check of `37408cc`: all fine; three of my test steps described things the app does not do (ring
  vibration, pull-to-sync, visible stars). His logs: MetricKit 26 Sep = CPU 1 h 36 m in 23 h 28 m of background; a
  sync every ~9 min and a 7–9 s CPU re-score after most, each re-reading 30 h of raw data (`BACKLOG.md` A). His backup
  settled #2371: the 500 ms filler appears only below ~110 bpm, never at 110–130 (`BACKLOG.md` B). Fork tidied (four
  merged branches retired, `main` mirrored to `4cdae213`); `tools/rr-fill.py` opens WAL backups (immutable).
- **28 Sep, ~10:00** — Utku: yes to background re-scores at most every 30 minutes, as its own upstream PR (he is not
  sure the maintainers want it). Session closed for a reset with everything recorded; build `0ad5ba9` on his page.
- **28 Sep, 10:10–10:55** — Background re-score spacing (`BACKLOG.md` A option 2) built on `rescore-spacing`
  (`d1f8c9bd`): one rule in `RescoreBackgroundPolicy.decide`; replay of his logs 900 → 250 CPU-s; tests seen to fail;
  verify passed bar upstream's parity drift. Fork `main` → `fcc384d2`; shipped `8fac9a2` (run 36398385255). PR waits
  on his 29 Sep strap log.
- **28 Sep, 11:00–12:10** — #2371 (`BACKLOG.md` B) built on `rr-whoop5-fill` (`b4b862e9`), both platforms: threshold
  refined to HR < 100 on his backup; 873 rows marked, nightly RMSSD +0.1–0.3%; tests seen to fail on both platforms
  (Android via a throwaway CI branch). PR waits on upstream's parity authority repair. Shipped `eeac53e` (spacing +
  #2371, run 36405967857).
- **28 Sep, ~12:40** — Upstream re-derived its parity authority (`0e524b38`); `rr-whoop5-fill` rebased, derived refresh
  committed (`87ea199a`), full verify passed every step, Android CI green: **PR #2569** opened (#2371).
- **28 Sep, ~13:00–13:45** — Utku's questions: GitHub failure emails (upstream's parity drift on the fork's `main`, my
  missing Room `41.json`, a deliberate seen-to-fail run), a macOS "quit unexpectedly" (my test crashed the test-host
  NOOP while its fix was off; fixed before any commit), closed #2419/#2437 in the PR bar (dismissed; merged via
  #2480/#2481). #2569 went conflicting on upstream's re-derivation: rebased, refreshed (`a5afb4c0`), all green again.
  He declined a local Android SDK and switching off the fork's parity check (`RULES.md`).
- **28 Sep, 14:30–16:45** — Utku: lower usage by cheaper work, not less work (the 30-min spacing stays). Profiled a
  re-score on his backup in the simulator (Time Profiler): `dayStreamFingerprint` was 44% of a warm pass. One-walk
  rewrite, both platforms, equivalence tests vs the replaced statement, seen to fail on both (Android via a
  pre-announced throwaway run): warm pass 1.6 → 1.2 s CPU. **PR #2574**. Found: iOS ends NOOP several times a day
  (each relaunch = a cold pass); the sleep stager over-predicts deep (+5 pp vs PSG, upstream's SleepPSG).
- **28 Sep, 17:00–19:30** — #2569 merged (tree == ours). Shipped `1ad5353` (spacing + #2574 + merged #2569). Cold-pass
  profile: `SleepStagerV2.respRegularity` recomputed ~45M cos/sin a night (13%): per-night twiddle table, bit-identical
  on both platforms, cold pass −10%: **PR #2575**. PhysioNet sleep-accel downloaded (Utku's yes); SleepPSG baseline
  reproduced (kappa 0.363, deep +5.17 pp); per-subject split on branch `psg-priors` (`9787f7ed`): the deep prior alone
  (0.18→0.15) helps 21/31 kappa, 19/31 deep error; the awake half repeats #437. On his nights deep ~30% → ~27%, REM
  31–40% of sleep (REM needs R-R truth to fix).
- **28 Sep, 19:30–20:30** — Utku: yes to proposing the deep prior and to asking about a REM dataset. Deep base prior
  0.18 → 0.15 on both platforms with pins, SleepPSG shipped config/variants/README updated (pooled kappa 0.363 → 0.371,
  deep bias +5.17 → +1.32 pp, wake/REM identical): **PR #2576**. REM truth options found: DREAMT (wrist IBI + accel,
  restricted: Utku must register and sign a DUA), MIT-BIH slpdb (18 OSA, 632 MB, open), HMC (151, 12.9 GB, open).
- **28 Sep, 20:30** — Shipped `769113c` (spacing + #2574 + #2575 + #2576; run 36462113779). All three open PRs green,
  no review yet. Session closed for a /clear: profiling harness kept in `tools/rescore-profile/`, throwaway worktrees
  removed, simulator demo data restored, STATE rewritten.
- **28 Sep, ~23:30** — Cleanup for a fresh agent: ~16 GB of throwaway builds, profiling traces, logs and the scratch
  copy of his backup deleted; merged-PR drafts removed from `private/`; simulator reinstalled clean from `main`;
  `BACKLOG.md` rewritten (live / watch / done), STATE rewritten; Utku chose DREAMT for REM (he registers and downloads).
- **29–30 Sep** — Utku registered at PhysioNet and downloaded DREAMT `data_64Hz` (100 participants, 14 GB) with a
  helper script; all 100 files verified against PhysioNet's SHA-256. Script deleted (it put the password on the
  command line; he chose not to worry about that password).
- **28–29 Sep** — Upstream merged #2575 (`f411030e`), #2576 (`bbeb20e8`) and #2574 (`5e204fab`); all three proven in by
  `merge-tree` on 30 Sep, their branches and worktrees retired, fork `main` mirrored to `7f396e98`.
- **30 Sep** — His strap logs of 29–30 Sep read: the 30-min spacing held (2.5–3.1 passes and 15–18 CPU-s an hour,
  from 6.8 and 54); a backgrounded pass costs ~8 s CPU against ~1.5 s in the foreground for the same work; MetricKit
  29 Sep CPU 1 h 10 m (26 Sep 1 h 36 m). **#2612** opened (the spacing, rebased on `7f396e98`, full verify green).
- **30 Sep** — DREAMT in `Tools/SleepPSG` (reader + section 8, R-R live for the first time against PSG): the RSA term is
  informative (AUC deep–REM 0.658) but twice too strong; `respWeight` 0.6 → 0.3 raises per-subject kappa for 61 of 100
  and lowers it for 28. His six nights (`tools/his-nights/`): REM 31.9 → 29.3 % of sleep. Utku's yes; **#2613** opened
  (two commits, both platforms, pins, golden regenerated; Android CI green).
- **1 Oct, night** — Utku away until Friday noon; asked for general optimisation. Findings: sync cadence is no radio
  lever (#1007); the midnight cold re-score is correct invalidation (refactor-only lever); REM emission variants on
  both PSG sets — none improves both, no change; re-score memory 77 MB steady / 144 MB peak on his data (MetricKit's
  358 MB is elsewhere, no kills). Handbook history scrubbed of three per-night lines (his "you decide").
  **#2617** cleanup (15 Swift + 5 Kotlin unreferenced declarations, parity debt down); **#2618** "Use my resonance
  pace" was read by nothing (iOS ignored it, Android always 5.5); screen sweep → **#2619** light-appearance night sky
  held still (its stars lift a pixel ≤ 1.34 levels; Today 2 + 22 → 0.01 + 0.02 CPU-s/min).
- **1 Oct, morning** — Utku saw two Live HR banners (09:48). His log (build 429 = `a8d25c1`, updated 30 Sep 23:50):
  a banner iOS ENDS (its 8-h limit at 08:45, or the app update at ~23:41) stays on the Lock Screen up to 4 h, frozen,
  beside the fresh one NOOP starts — fix planned (`features/live-hr-banner.md` §6.0). #2618's Kotlin test seen to fail
  on the fork (run 36837267848, 1 of 6,591), description edited. Backup copies deleted; session 3 handed over.
- **1 Oct, ~11:15** — Utku: YES to the silent swiped-away reminder and to iOS's deleted-sleep list (RULES, BACKLOG 0).
- **2 Oct** — ryanbr merged #2612 (30-min background re-score spacing), #2617 (dead code), #2618 (resonance pace),
  #2619 (still light-appearance sky), rebase merges, no comments; proven in by `merge-tree` 3 Oct, branches retired.
- **3 Oct, session 4** — Frozen Live HR banner fixed: simulator proof that iOS still lists an ended banner, drops any
  update to it ("zombie") and discards it on `end(nil, .immediate)`; before/after on the simulator (frozen 85 stacked
  over live 102 → one banner); PR **#2659**. His files read (2–3 Oct logs, backup, export): re-score ~24–32 CPU-s/h,
  cold relaunch + midnight passes 127 of 415 CPU-s, queued "forced" duplicates after offloads (BACKLOG A), MetricKit
  payloads empty, no frozen banner (renewed every open), 12 radio timeouts 03:06–03:21 (no action). His two yeses
  built, each with tests seen to fail, a simulator proof and a full verify: the iOS deleted-sleep list (**#2660**) and
  the silent sync reminder (**#2661**). Stack `b6202262` shipped as **`3772b93`** (run 37136378349); "just update".
- **3 Oct, 18:19** — Utku handed the project over: a friend continues with ChatGPT 6.1. Session 4 finished the work
  in flight and readied the handbook for any AI (README "Handover").
- **3 Oct, 13:51 and 19:34** — two usage-limit interruptions mid-work. Each time the journal ("Now"), `checkpoint.sh
  status --net` and the event log showed exactly what had completed (PR #2659 opened; ship `3772b93` verified at
  19:38), so nothing was repeated or lost. A waiting loop left behind by the second (it watched for a word the ship
  tool never prints) was stopped; `WORKFLOW.md` §2 now names each tool's last words. Handbook uploaded for the handover.
