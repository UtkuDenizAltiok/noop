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

## Top of the list (end of 28 Sep 2026)

A. **Background re-scoring (battery).** Before: MetricKit 26 Sep, CPU 1 h 36 m a day; a 7–9 s re-score after nearly
   every ~10-min sync, ~15 CPU-min a day in the background (27–28 Sep log: 113 passes / 900 CPU-s). Done so far:
   (2) the 30-min background spacing (Utku's yes; `rescore-spacing`, shipped; PR after his 29/30 Sep logs; replay
   900 → 250 CPU-s); cheaper passes with identical results — #2574 (day fingerprint in one walk: warm pass −25%) and
   #2575 (stager twiddle table: cold pass −10%), both from Time Profiler runs on his backup
   (`tools/rescore-profile/`). Open: the fingerprint is still the largest warm cost (25%: one R-R walk per night, a
   table lookup per row; a covering index was rejected: disk + write cost); re-reading today's 54 h R-R window each
   pass (17%) is option (1), cross-pass window reuse — decide from his logs whether it is still worth its complexity;
   by-name GRDB column reads cost ~4% (`String.lowercased`), a small positional-read change.
B. **DONE: #2371, the 500 ms filler** — PR #2569 merged 28 Sep (threshold HR < 100 from his backup; 873 rows marked).
C. **Sleep staging against PSG** (`Tools/SleepPSG`, PhysioNet sleep-accel in `~/datasets`). Deep over-call: #2576
   (deep prior 0.15, Utku's yes). Still wrong: REM (+4.5 pp on PSG; 31–40 % of sleep on his nights) and wake (−4.9 pp,
   but #348's awake prior over-calls individuals, the #437 shape). REM hinges on the RSA R-R term, which sleep-accel
   cannot exercise: needs PSG with heartbeats — DREAMT (best; Utku must register and sign) or MIT-BIH slpdb / HMC
   (open, no wrist motion). His choice pending.

## 1. Measurements that are wrong (biometrics — "better than WHOOP")

1. **DONE 28 Sep: the WHOOP 5 500 ms R-R filler** (#2371) — PR #2569 merged; see B at the top.
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

9b. **iOS ends NOOP several times a day; each restart costs a COLD re-score** (28 Sep log: runs ended 17:26, 19:06,
   22:00, each on `standard-hr transport flush-attempt reason=termination`, i.e. iOS told the app it was closing, and
   the strap's next event relaunched it in the background; 25 Sep: 10 runs in 19 h; MetricKit 26 Sep: "exits: normal
   4", peak memory 339 MB). A cold pass is ~3× a warm one (sim, his data: 4.4 vs 1.2 s CPU) because the per-day
   reuse cache lives in memory (`IntelligenceEngine.dayScanCache`). Ideas: (a) persist that cache (and its config
   signature) so a relaunch starts warm — same scores, upstream named it the remaining lever in #1538; (b) find why
   iOS ends the app (ask Utku whether he swipes NOOP away or AltStore refreshes it; the next MetricKit day lines);
   (c) the termination flush logs no "flush-succeeded" — check the last ~10 s of live rows are not lost (history
   offload should cover them); (d) 339 MB peak memory in the background — measure where (a cold pass holds whole
   windows).
10. **The macOS unit tests start the whole app, Bluetooth included** (seen 28 Sep: `StrandTests` runs hosted in
   "NOOP Staging", whose log shows a `CBCentralManager` created and a window opened on the developer's Mac). A test
   run should not touch real Bluetooth: on a desk near the strap it could compete with the phone for it (not
   observed; the logs show no connect). Candidate upstream PR: when hosting unit tests, skip BLE start and the
   windows. Check first how upstream wants it (issue or their test setup); app-target Swift, build both apps.

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
