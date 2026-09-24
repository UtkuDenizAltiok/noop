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

## 1. Measurements that are wrong (biometrics — "better than WHOOP")

1. **A 500 ms R-R filler stored as a real heartbeat interval on WHOOP 5** — upstream #2371 (21 Sep, open, no PR, no
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
5. **How often NOOP syncs in the background on a normal day** — from the baseline log: triggers per hour (strap
   events, periodic, foreground, connect), each a radio exchange on both devices. Only then decide whether any trigger
   is redundant.
6. **The Live HR banner's steady re-push** every 15 s exists only to beat a 30-s stale date; with WRIST_OFF handled
   live (#2437), a 60-s stale date would halve it (`features/live-hr-banner.md` §6). Decide from the baseline log.
7. **The Liquid Today animation** — DONE in #2444 (24 Sep): the sky while no star can be drawn, the hero rings once
   filled (a ring since #1068, yet a 60 fps loop + the sim + the tilt sensor) and the paused header sync ring. Today by
   day 6.7 + 22.6 → 0.00 + 0.11; Sleep → 0.01 + 0.1. Still animating by design: the stars at night (~22 in the render
   server, full-screen sky), the heart-rate line while live, a ring filling. Next candidates, measure first: the
   night sky's cost (a smaller layer for the stars?), other screens with `LiquidTube`/`LiquidThread` loops.
7b. **Upstream issue to propose (ask Utku first):** `AppModel.purgeImportTemp()` assumes `temporaryDirectory` is
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
