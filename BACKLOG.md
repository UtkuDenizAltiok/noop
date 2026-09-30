# Backlog — making NOOP the best app for WHOOP straps

Ordered by value to Utku (a WHOOP 5.0 on an iPhone) and to every user. **A list is a poor predictor** (`RULES.md` 12):
real days and strap logs found every bug that mattered, so each item is checked against the code and upstream before
work starts, and the measurement comes first. Each item becomes ONE small PR. Lower usage means the same work done
cheaper, never less work (`RULES.md`, 28 Sep).

## Top of the list (end of 28 Sep 2026)

A. **Background re-scoring (battery).** Before: MetricKit 26 Sep, CPU 1 h 36 m a day; a 7–9 s re-score after nearly
   every ~10-min sync, ~15 CPU-min a day in the background (27–28 Sep log: 113 passes / 900 CPU-s). Done: the 30-min
   background spacing (Utku's yes; `rescore-spacing`, shipped; PR after his 29/30 Sep logs; replay 900 → 250 CPU-s);
   cheaper passes with identical results — #2574 (day fingerprint in one walk: warm pass −25%) and #2575 (stager
   twiddle table: cold pass −10%), both found with Time Profiler on his backup (`tools/rescore-profile/`). Open: the
   fingerprint is still the largest warm cost (25%: one R-R walk per night, a table lookup per row; a covering index
   was rejected for its disk and write cost); re-reading today's 54 h R-R window each pass (17%) could be kept across
   passes (option 1) — decide from his logs whether that is still worth its complexity; by-name GRDB column reads cost
   ~4% (`String.lowercased`), a small positional-read change. Upstream's own 28 Sep strap-log fix also lands in these
   logs: read the MetricKit day lines before claiming a number.
B. **A relaunch costs a cold pass.** iOS relaunches NOOP in the background after it ends (his swipes, mostly: asked
   28 Sep); the per-day reuse cache is in memory (`IntelligenceEngine.dayScanCache`), so the first pass re-scores every
   night (sim, his data: 4.4 vs 1.2 s CPU warm). Persisting that cache with its config signature would make a relaunch
   warm with the same scores (upstream named it the remaining lever in #1538). Worth it only if his logs show many
   relaunches. Also check: the termination flush logs no `flush-succeeded` (are the last ~10 s of live rows lost, or
   does history cover them?), and the 339 MB peak memory in the background (MetricKit 26 Sep).
C. **Sleep staging against PSG** (`Tools/SleepPSG`, PhysioNet sleep-accel in `~/datasets`). Deep over-call: #2576
   (deep prior 0.15, Utku's yes). Still wrong: REM (+4.5 pp on PSG; 31–40 % of sleep on his nights) and wake (−4.9 pp;
   #348's awake prior fixes the pooled share but over-calls individuals, the #437 shape). REM hinges on the RSA R-R term,
   which sleep-accel cannot exercise: needs PSG with heartbeats. DREAMT (100 patients, wrist IBI + accel + PSG labels)
   is downloaded and verified in `~/datasets/dreamt/` (100 participants, 30 Sep). Its data use
   agreement forbids sharing: local only, never in the repo, results as aggregates.

## Next candidates

1. **A score reviewed against the literature, one per session** — recovery, strain, HRV (RMSSD windowing, artefact
   rejection), resting HR, respiration, SpO2. Read `StrandAnalytics` for it, its tests and open issues, compare with
   published methods, propose only what evidence supports (`RULES.md` 2); test against truth where a dataset exists.
2. **How often NOOP syncs in the background on a normal day** — triggers per hour (strap events, periodic, foreground,
   connect) from his logs; each is a radio exchange on both devices. Then decide whether any trigger is redundant.
3. **The Live HR banner's steady re-push** every 15 s exists only to beat a 30-s stale date; with WRIST_OFF handled live
   (#2437), a 60-s stale date would halve it (`features/live-hr-banner.md` §6). Decide from his logs.
4. **The night sky's render cost** (~22 CPU-s/min in the render server with the stars animating, #2444 left it by
   design): a smaller layer for the stars? Other screens with `LiquidTube`/`LiquidThread` loops. Measure first.
5. **A second dead-code cleanup** (#2417 removed 707 lines and was welcomed). Unreferenced on 24 Sep (`141cbd93`, whole-
   word grep, Swift app + packages / Android main), re-check each on today's `main` and Android (`RULES.md` 9):
   `Collector.bufferedCount`, `ImuSessionFileStore.prepareForRead`, `BLEManager.uploadIntervalSeconds`,
   `NavRouter.openTrends`/`openLiveSession`,
   `BiofeedbackPrefs.clearLockedPace`/`useResonancePace`, `SleepView.napMaxHours`, `BatteryGuidedCapture.currentStatus`,
   `CoachBriefScheduler.widgetBriefText`/`widgetBriefDate`, `AICoach.aiCoachPrivacyNote`, `Profile.avatarImage`,
   `Repository.hasAnyHistory`/`dismissedSleepManagementWindows`/`allowSleepReDetection`,
   `BehaviorStore.didRecalibrateCharge`, `JournalCatalog.setSortIndex`, `SkinTempBackfillWalker.totalAttempted`,
   `HealthKitBridge.foregroundCatchUp`. Live elsewhere (not dead): `uploadTimer`, `captureRawAccel`,
   `clearEcgRawDataGate`, `clearKey`, `availableKeys`, `recalibrateChargeBaseline`. On Android only
   (`cycleAwarenessHidden`, `numericJournalSeries`): likely iOS features without an entry point — ask before removing.
   `periphery` (Homebrew) scans for unused Swift declarations.
6. **The macOS unit tests start the whole app, Bluetooth included** (28 Sep: `StrandTests` runs hosted in "NOOP
   Staging", which creates a `CBCentralManager` and opens a window on the developer's Mac; no connect seen). Candidate
   upstream PR: skip BLE start and windows when hosting unit tests. Check how upstream wants it first; build both apps.
7. **Android's live-HR smoothing counts emissions, not time** (`AppViewModel.ingestHr`, window 5; iOS takes a 10-s
   median). Display only; a parity question for the maintainers before a change.
8. **The largest files** (`BLEManager.swift` 7.4k lines, `TodayView.swift` 6.0k, `IntelligenceEngine.swift` 3.5k,
   `Repository.swift` 3.5k, `WhoopBleClient.kt` 8.7k): split only where it removes real duplication or bug risk.

## Upstream reliability to watch (help only with evidence from his logs)

- **#2387 / #1466** — syncs that take "ages" (iOS, WHOOP 4.0); the maintainers are on it (#2390 merged).
- **#2384** — Android live HR stops updating on a 5.0/MG. **#2270** — Android OutOfMemoryError in
  `LiquidRender.wavePolygon`. Android; no device here.

## Done or dropped

- **#2371, the WHOOP 5 500 ms R-R filler** — #2569 merged 28 Sep (HR < 100 from his backup; 873 rows marked).
- **The Liquid Today animation** — #2444 merged 27 Sep (Today by day 6.7 + 22.6 → 0.00 + 0.11 CPU-s/min).
- **`AppModel.purgeImportTemp()` deleting `noop-*` in the shared temp folder** — our #2446, fixed upstream in #2453.
- **The automatic follow-up offload after each history sync** — dropped 24 Sep: two small commands and one or two
  replies in the same second, guarding against a strap that stops mid-history (#364/#451); not worth a BLE change.
- **Checked and clean (23 Sep):** forced unwraps / `try!` / `as!` (none unguarded), network use (update check off by
  default; AI and Oura opt-in), widgets / Watch / notification dedup, formatters in hot paths, stale reads in
  `@Published` sinks (#2416/#2418/#2437), timer leeway (keep-alive exact on purpose, #1052), guarded divisions.
