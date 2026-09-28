# Backlog — making NOOP the best app for WHOOP straps

Started 24 Sep 2026 from Utku's logs of that day, the open upstream issues and a first code survey. Ordered by value to
him (a WHOOP 5.0 on an iPhone) and to every user. **A list is a poor predictor** (`RULES.md` 12): real days and strap
logs found every bug that mattered last time, so each item is checked against the code and upstream before work starts,
and the measurement comes first. Each item becomes ONE small PR.

## 0. First: a baseline (before any optimisation)

- **A normal day on the phone.** Build `3ad319d` carries #2420, so iOS's MetricKit day report lands in the strap log
  once a day (foreground/background time, CPU time, peak memory, disk writes, hangs, exit reasons). Ask Utku for the
  log of an ordinary day with NOOP left in the background, settings unchanged (a log holds about the last day, 2 MB;
  `WORKFLOW.md` §3): that line is the "before" for every battery claim, and the
  same log counts syncs, reconnects and pushes (`WORKFLOW.md` §11).
- **The simulator's numbers** — DONE 24 Sep (`STATE.md` "Verified"): still screens cost nothing; Today and Sleep cost
  7 + 22 and 7 + 17 CPU-s/min (NOOP + render server) from decorative loops redrawing unchanged pictures → #2444.

## Top of the list (28 Sep 2026, from Utku's logs of 25–28 Sep and his backup)

A. **Background battery: every post-sync re-score re-reads 30 h of raw data.** MetricKit, 26 Sep (build `37408cc`):
   foreground 1 m 54 s, background 23 h 28 m, **CPU 1 h 36 m**, disk writes 193 MB. In the 27–28 Sep logs a history
   sync starts every ~9 min (≈17 sessions/h with the auto-continue follow-ups) and ~7 re-scores/h follow
   (`trigger=post-offload`), each **7–9 s CPU at every hour of day and night** (median 2.1 s on 25 Sep → 7.4 s 27 Sep →
   8.4 s 28 Sep): ~20 CPU-min a day. One pass (28 Sep log, lines 9491–9539): `analyzeRecent windows hr[read=101325
   served=0] rr[read=73041 served=0 reuseOff=1]`, `sleep-detect … hr=101325 rr=73041 grav/skin/steps=101342
   window=30h`, prep 2.1 s, postLoop 0.87 s (score2 0.6 s), done 6.7 s, cost 6.9 s CPU, "scored 5 night(s)". So each
   pass reads ~475k rows (a 30 h window of five 1 Hz streams) and re-runs sleep detection with nothing reused
   (`served=0`). Work: read `IntelligenceEngine` / `Repository` re-score + `analyzeRecent` windows and the
   `served`/`reuseOff` reuse; make the window incremental (read only rows newer than the last pass) or skip a pass that
   cannot change a score; measure with the demo data (the simulator can replay a pass) and on the phone (the cost
   line + MetricKit). **Code pointers (28 Sep, `4cdae213`):** `SlidingStreamWindow` (StrandAnalytics) reuses rows only
   WITHIN one pass; each pass builds new windows (`IntelligenceEngine.swift` ~1855 logs them), and a WHOOP 5 R-R read
   passes `allowReuse: false` by design (transport choice is range-dependent). Options, in order: (1) keep the day
   window across passes and re-read only what an offload can have touched (`Backfill` logs the landed range/frontier);
   (2) space background post-offload passes ≥ 30 min unless a night just ended or the app is in front — **Utku said
   YES (28 Sep); do it first, as its own upstream PR** (`RULES.md` settled decisions); (3) both. **(2) built 28 Sep**
   (branch `rescore-spacing`, `d1f8c9bd`; one rule in `RescoreBackgroundPolicy.decide`, no "night just ended"
   exception: the delay is bounded by the spacing + one offload, and opening the app scores at once). Replay of his
   logs: 900 → 250 CPU-s (27–28 Sep). Shipped in `8fac9a26`; the PR waits on one night's log from his phone.
   Passes also re-score an in-progress night each time (the growing `totalSleepMin`), and cost ~7 s with the day
   cache warm (`reused=4/5`: prep 2.1 s + score 0.1 s + postLoop 0.9 s of a 6.7 s pass; ~3.6 s not broken out) —
   option (1) targets that. Upstream fixed a separate background cost on 28 Sep (the strap-log view rebuilt ~5,000
   rows per line: `d6d79693`, `2772e235`); check the next MetricKit day before claiming either.
B. **#2371, the 500 ms filler — answered by Utku's backup (WHOOP 5.0, 28 Sep, `tools/rr-fill.py`):** exact 500 ms is
   13–15× its neighbours on both channels (v18 526 of 236,669; standard 383 of 207,227). By the strap's own HR that
   second: 70–90 bpm 40–46×, 90–110 bpm 12–14×, **110–130 bpm 0.9× (no excess)**; runs up to 10–11 in a row in
   history. So the strap never uses the filler at exercise rates, and a real 500 ms beat there is as common as its
   neighbours. Fix: mark `rrMs == 500` as suspect (`tsSuspect = 1`, read-filtered everywhere, raw row kept) when the
   strap's HR that same second is < 110, on the three WHOOP 5 ingest paths (v18 history, type-40 realtime, standard
   0x2A37) and their Kotlin twins, oracle-proven, plus a migration that marks existing rows the same way (a new
   versioned migration + Room twin + test). The PR carries these counts (no personal data beyond counts). Readers
   hurt today: `RhythmScreener` (ectopy counted on purpose) and `SleepStagerV2`'s RSA term.

## 1. Measurements that are wrong (biometrics — "better than WHOOP")

1. **A 500 ms R-R filler stored as a real heartbeat interval on WHOOP 5** — see B at the top (answered 28 Sep) — upstream #2371 (21 Sep, open, no PR, no
   comment). An exact `rrMs = 500` appears ~20× more often than its neighbours on both 5.0 transports (v18 history and
   the standard profile) and is stored as a real interval with `tsSuspect` NULL, so it enters HRV, stress and recovery.
   Utku's strap is a 5.0. Work: confirm on his own data (a `.noopbak` or the database of a build), find where both
   transports bank R-R (`Packages/WhoopProtocol`, `Packages/WhoopStore`, Android twins), decide flag vs drop with the
   maintainers' existing `tsSuspect` convention, both platforms, oracle-proven, and a test with the histogram's shape.
   **24 Sep:** not only hygiene — `RhythmScreener` keeps ectopy on purpose (a fake 500 among ~900 ms beats reads as an
   irregular beat) and `SleepStagerV2`'s RSA breathing term clamps 300–2000 only (a spike pushes deep → REM); the
   nightly HRV/Charge do filter it. The open question is whether the strap ALSO sends 500 as a real beat at ~120 bpm:
   `python3 dist/tools/rr-fill.py <backup.noopbak>` splits the spike by the strap's own HR that second. Waits on
   Utku's backup (More → Settings → Backup & restore → Export…).
2. **Android's live-HR smoothing counts emissions, not time** (`AppViewModel.ingestHr`, window 5) while iOS takes a
   10-s median: any unrelated state change refills Android's window. Display only; a parity question for the
   maintainers before a change.
3. **Deeper review of each score against the literature** — recovery, strain, HRV (RMSSD windowing, artefact
   rejection), resting HR, sleep staging, respiration, SpO2. One metric per session: read `StrandAnalytics` for it,
   find its tests and its open issues, compare with published methods, and propose only what evidence supports
   (`RULES.md` 2).

## 2. Battery and radio — phone and strap

4. **Every history sync costs two offload round trips.** In Utku's 13:56 log, 27 of 52 "Backfill: session started"
   were the automatic follow-up (#364/#451 "auto-continuing … re-kicking offload") that answers "reached the end of
   available history (trim=0xFFFFFFFF) - caught up" at once. Find whether the first transfer already tells us it
   reached the end (its "Historical Dump Complete" / trim), so the second exchange can be skipped when it cannot find
   anything. BLE: a strap test before any PR, 4.0 behaviour kept.
   **Measured 24 Sep, DROPPED:** the follow-up is two small commands (`→ Send Historical Data payload=00`, `→ Historical
   Data Result ack #1`) and one or two short replies, all inside the same second, with one re-score per sync either
   way (13:56 log, lines 1235–1243 and 2228–2236). A history transfer is hundreds of frames. It exists to catch a strap
   that stops mid-history (#364/#451); removing it saves a few packets and risks missed history on a 4.0 nobody here
   can test. Not worth a BLE change.
5. **How often NOOP syncs in the background on a normal day** — from the baseline log: triggers per hour (strap
   events, periodic, foreground, connect), each a radio exchange on both devices. Only then decide whether any trigger
   is redundant.
6. **The Live HR banner's steady re-push** every 15 s exists only to beat a 30-s stale date; with WRIST_OFF handled
   live (#2437), a 60-s stale date would halve it (`features/live-hr-banner.md` §6). Decide from the baseline log.
7. **The Liquid Today animation** — DONE in #2444 (merged 27 Sep): the sky while no star can be drawn, the hero rings once
   filled (a ring since #1068, yet a 60 fps loop + the sim + the tilt sensor) and the paused header sync ring. Today by
   day 6.7 + 22.6 → 0.00 + 0.11; Sleep → 0.01 + 0.1. Still animating by design: the stars at night (~22 in the render
   server, full-screen sky), the heart-rate line while live, a ring filling. Next candidates, measure first: the
   night sky's cost (a smaller layer for the stars?), other screens with `LiquidTube`/`LiquidThread` loops.
7b. **DONE: filed as #2446 (24 Sep), fixed upstream in #2453 (25 Sep):** `AppModel.purgeImportTemp()` assumes `temporaryDirectory` is
   NOOP's sandbox; on the unsandboxed macOS build it deletes any `noop-*` item in the user's shared temp folder
   (canary-proven 24 Sep). Low harm for users; real for developer tooling.

## 3. Clean code

8. **A second dead-code cleanup** (#2417 removed 707 lines of unused private code and was welcomed). Internal code no
   Swift file references, found 23 Sep: `Collector.bufferedCount`, `ImuSessionFileStore.prepareForRead`,
   `BLEManager.uploadTimer`/`uploadIntervalSeconds` (declared and cancelled, never started), `captureRawAccel`,
   `clearEcgRawDataGate`, `NavRouter.openTrends`/`openLiveSession`, `AppModel.cycleAwarenessHidden`,
   `BiofeedbackPrefs.clearLockedPace`/`useResonancePace`, `SleepView.napMaxHours`, `BatteryGuidedCapture.currentStatus`,
   `CoachBriefScheduler.widgetBriefText`/`widgetBriefDate`, `AICoach.clearKey`/`aiCoachPrivacyNote`,
   `Profile.avatarImage`, `Repository.hasAnyHistory`/`dismissedSleepManagementWindows`/`allowSleepReDetection`/
   `availableKeys`/`numericJournalSeries`, `BehaviorStore.recalibrateChargeBaseline`/`didRecalibrateCharge`,
   `JournalCatalog.setSortIndex`, `SkinTempBackfillWalker.totalAttempted`, `HealthKitBridge.foregroundCatchUp`.
   Re-check each against today's `main` and Android (`RULES.md` 9) — some may be features whose entry point was never
   built. A tool helps: `periphery` (Homebrew) scans for unused Swift declarations. **24 Sep census on `141cbd93`**
   (whole-word grep, Swift app + packages / Android main): all but `uploadTimer`, `captureRawAccel`,
   `clearEcgRawDataGate`, `clearKey`, `availableKeys`, `recalibrateChargeBaseline` appear only at their own
   declaration; `cycleAwarenessHidden` (8 Kotlin uses) and `numericJournalSeries` (7) are live on Android, so on iOS
   they are likely features without an entry point, not dead code — ask before removing.
9. **The largest files** — `BLEManager.swift` 7.4k lines, `TodayView.swift` 6.0k, `IntelligenceEngine.swift` 3.5k,
   `Repository.swift` 3.5k, `WhoopBleClient.kt` 8.7k. Size alone is not a defect; split only where it removes real
   duplication or a real bug risk, one concern per PR, never as a drive-by.

## 4. Reliability (open upstream, watch or help)

- **#2387 / #1466** — syncs that take "ages" (iOS, WHOOP 4.0); the maintainers are on it (#2390 merged). Utku has a 5.0:
  help only with evidence from his logs.
- **#2384** — Android live HR stops updating on a 5.0/MG. Android; no device here.
- **#2270** — Android OutOfMemoryError in `LiquidRender.wavePolygon`; needs a heap profile on a device.

## Checked and clean (23 Sep 2026)

Forced unwraps / `try!` / `as!` (none unguarded), network use (update check off by default, once a day; AI and Oura
opt-in), widgets / Watch / notification dedup, formatter creation in hot paths, stale reads in `@Published` sinks (the
pair #2416/#2418 fixed; #2437 the banner's), timer leeway (keep-alive exact on purpose, #1052), divisions converted to
whole numbers (all guarded). Re-scoring after a sync: upstream #2293 made it cheap (mostly 0.1 s of CPU a pass, mean 0.5 s, in the 24 Sep log).
