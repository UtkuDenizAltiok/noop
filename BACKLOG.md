# Backlog — making NOOP the best app for WHOOP straps

Ordered by value to Utku (a WHOOP 5.0 on an iPhone) and to every user. **A list is a poor predictor** (`RULES.md` 12):
real days and strap logs found every bug that mattered, so each item is checked against the code and upstream before
work starts, and the measurement comes first. Each item becomes ONE small PR. Lower usage means the same work done
cheaper, never less work (`RULES.md`, 28 Sep).

## Priority — 7 Oct 2026

The [sensor/biometric audit](audits/biometric-pipeline-2026-10-07/README.md) records production-source review and
runnable synthetic evidence. Daily SDNN's missing quality gates are repaired in green [PR #2722](https://github.com/ryanbr/noop/pull/2722) and shipped in `01b55ac2`. Next correctness
task: unusable respiratory/optional Effort baseline consumption in Charge, with score/driver/trace alignment and
usable-state preservation. Then repair spectral power units, grid resolution and discarded time together; no
physiological accuracy claim without independent truth. Standard-HR truncated fields and optical/ratio descriptions
are separate candidates. Source coverage and physiological tuning need a private raw backup/independent references.

Documentation/file organisation is complete; upstream #2717 is green and awaits merge. Phone checks live in
[State](STATE.md). **Item 9 is now reproduced** through production export/restore with synthetic data (28 assertions, 7 Oct).
The storage discussion is [issue #2720](https://github.com/ryanbr/noop/issues/2720), published with Utku’s approval;
implement after that choice is settled. No personal export is needed for it. Then choose from A/B/D/C using new logs or ground truth, not remembered results. Priorities are delegated to ChatGPT/Codex; correctness comes first, performance needs measurement.

## Performance and science evidence

A. **Background re-scoring (battery).** Before: MetricKit 26 Sep, CPU 1 h 36 m a day; 27–28 Sep log 113 passes / 900
   CPU-s in 16.6 h. After the 30-min spacing (#2612, opened 30 Sep) + #2574/#2575 (merged): 29–30 Sep logs 2.5–3.1
   passes and 15–18 CPU-s an hour; MetricKit 29 Sep CPU 1 h 10 m. A backgrounded pass costs ~8 s CPU against ~1.5 s in
   the foreground for the same work (every stage ~6×, same rows read; consistent with iOS's efficiency cores), so
   CPU-seconds overstate background energy; iOS's own energy numbers are the better judge. Open: the fingerprint is
   still the largest warm cost (25 %); keeping today's R-R window across passes (17 %) — with passes now ~2.5 an hour,
   worth it only if a measurement says so. By-name GRDB reads ~4 %.
   **3 Oct logs (build 429):** 39 passes / 362 CPU-s in 15 h (2 Oct) and 42 / 415 in 13 h (3 Oct), ~24–32 CPU-s an
   hour. **New finding — queued duplicates:** an offload that completes while a pass runs is queued (#899-A) and,
   when that pass ends, re-runs as a full `trigger=forced` pass with neither `skipIfUnchanged` nor the 30-min spacing
   (`IntelligenceEngine.analyzeRecent`'s `defer` re-arm; `RescoreBackgroundPolicy.decide` exempts `passInProgress`
   from spacing, #1681). Five such pairs on 2–3 Oct, ~40 CPU-s. Upstream PR #2646 (kavemang, merged 4 Oct at `f46671f6`) rewrites
   that very block: recheck the finding on current upstream before considering routing the re-arm through
   `RescoreBackgroundScheduler.run` when
   backgrounded (debt recorded, settled by the next offload past the spacing). Live HR flushes move the
   fingerprint every minute, so `newData=yes` nearly always and `skipIfUnchanged` alone would not help. Disk writes
   193–201 MB a day (MetricKit 26 and 29
   Sep) for a few MB of new rows: find what writes (strap log rewrites? WAL checkpoints?) before guessing.
   **7 Oct verified small optimisation:** [PR #2724](https://github.com/ryanbr/noop/pull/2724) computes resting-HR
   bins/diagnostic in one row walk, preserving the same results and gates. Seven alternating Swift `-O` trials:
   93.9–97.3% less CPU for dense eight-hour nights; 88.4% for sparse cadence. About **2.6 ms per night pair** saved,
   not a full-pass/phone-energy result. [Reproducible audit](audits/rhr-one-pass-2026-10-07/README.md).
   This does not resolve the larger fingerprint, relaunch/config-invalidation or disk-write costs above/below.
B. **Cold passes: midnight and relaunches** (29–30 Sep logs; 3 Oct: the 23:25 background relaunch cost 58.5 s, its
   queued twin another 34.4 s cold again — `configDropped(sleepConsistency)` after the first pass changed it — and
   midnight 34.1 s: 127 of the night's 415 CPU-s). The first pass after midnight reused 0 of 7 days (33 s CPU,
   53 s elapsed, backgrounded): the day rollover seems to invalidate every cached night; find which key moves (the
   window, a baseline, the day index) — the same scores, cheaper, is the aim. iOS's relaunch at 03:01 cost a cold
   pass of 20 s CPU with the background assertion EXPIRED mid-pass (iOS was about to suspend it). Two foreground
   relaunches cost ~5 s each. **A relaunch costs a cold pass.** iOS relaunches NOOP in the background after it ends
   (his swipes, mostly: asked
   28 Sep); the per-day reuse cache is in memory (`IntelligenceEngine.dayScanCache`), so the first pass re-scores every
   night (sim, his data: 4.4 vs 1.2 s CPU warm). Persisting that cache with its config signature would make a relaunch
   warm with the same scores (upstream named it the remaining lever in #1538). Worth it only if his logs show many
   relaunches. Also check: the termination flush logs no `flush-succeeded` (are the last ~10 s of live rows lost, or
   does history cover them?), and the 339 MB peak memory in the background (MetricKit 26 Sep).
C. **Sleep staging against PSG** (`Tools/SleepPSG`: PhysioNet sleep-accel and, since 30 Sep, DREAMT in `~/datasets/dreamt`,
   restricted: local only, aggregates only). Deep over-call: #2576 (deep prior 0.15). The RSA term: `dreamt-psg`
   (respWeight 0.6 → 0.3; DREAMT section 8: 61/28 subjects, Utku's yes 30 Sep). Still open: (a) REM stays over-called
   with the term off too (DREAMT REM/sleep 17.4 vs 14.0; his nights 27 % with the term off): the REM emission, the
   clock ramp or the transition rows — section 8 per stratum before any change, and never a base rate fitted to
   DREAMT (#437). (b) Wake is badly under-called on DREAMT (6.9 vs 25.1 % of the night; sleep-accel −4.9 pp) — the
   #437 trap on the other side: a clinical cohort's wake is not a healthy night's. (c) The per-night z-score blows a
   near-constant feature up to ±10 (the V2-flag synthetic night, sd 0.00016): a floor on the z-score's sd would stop
   a feature with no spread from voting at all; test it on DREAMT and sleep-accel before proposing.
   **Tried 1 Oct (do not repeat blind):** joint logistic REM-vs-light weights, both PSG sets: hrVar 0.35/0.34 (recipe
   0.6), move −0.28/−0.23 (−0.6), clock 2.24/2.19 (1.0), hr 0.87 vs 0.26 (cohorts disagree). Run through the recipe
   (local sections 9/10 on `noop-dreamt`, uncommitted): clock ×1.5–2 explodes REM (45–62 % of sleep); hrVar 0.35 fixes
   sleep-accel's REM share (27.6 → 23.7 vs 24.2) at neutral κ (16/14) but nothing on DREAMT; move −0.25 helps DREAMT
   (51/38), hurts sleep-accel (12/17). Per-epoch logistic weights do not transfer to the HMM. No REM change.
D. **A night's start moved 20 h later** (29–30 Sep log): a pass late in the evening re-detected the previous night
   67 min earlier (#1284 "heal", total sleep +29 min); the only new data was that evening's rows. Which start is right
   is ambiguous (the added hour looks like restless time in bed); that later data can move an earlier night's onset is
   the question. Reproduce on the 30 Sep backup (detection with the stream cut before vs after that evening) before
   anything; check upstream's own sleep-detection commits since 0c982899 (4a827f90, 7f1e42f7, b9e1a3ce).

## Next candidates

1. **A score reviewed against the literature, one per session** — recovery, strain, HRV (RMSSD windowing, artefact
   rejection), resting HR, respiration, SpO2. Read `StrandAnalytics` for it, its tests and open issues, compare with
   published methods, propose only what evidence supports (`RULES.md` 2); test against truth where a dataset exists.
2. **How often NOOP syncs in the background on a normal day** — triggers per hour (strap events, periodic, foreground,
   connect) from his logs; each is a radio exchange on both devices. Then decide whether any trigger is redundant.
3. **The Live HR banner's steady re-push** every 15 s exists only to beat a 30-s stale date; with WRIST_OFF handled live
   (#2437), a 60-s stale date would halve it (`features/live-hr-banner.md` §6). Decide from his logs.
4. **The night sky's render cost.** Light appearance: fixed in #2619 (its stars lift a pixel ≤ 1.34 levels; 1.9–2.2 +
   22.1 → 0.00 + 0.02 CPU-s/min). Dark appearance, by design (visible twinkle), 1 Oct 03:41: NOOP 1.97 + render 21.82
   CPU-s/min on Today. Lever: the twinkle at 10 fps instead of 20 (pow(sin,6) flares last ~0.5 s), ~half the cost —
   a visible-quality trade, Utku's call. Sweep 1 Oct (light, night): Trends/Sleep/Coach/More 0.00 + 0.01–0.02.
5. **A second dead-code cleanup** (#2417 removed 707 lines and was welcomed). Unreferenced on 24 Sep (`141cbd93`, whole-
   word grep, Swift app + packages / Android main), re-check each on today's `main` and Android (`RULES.md` 9):
   `Collector.bufferedCount`, `ImuSessionFileStore.prepareForRead`, `BLEManager.uploadIntervalSeconds`,
   `NavRouter.openTrends`/`openLiveSession`,
   `BiofeedbackPrefs.clearLockedPace`/`useResonancePace`, `SleepView.napMaxHours`, `BatteryGuidedCapture.currentStatus`,
   `CoachBriefScheduler.widgetBriefText`/`widgetBriefDate`, `AICoach.aiCoachPrivacyNote`, `Profile.avatarImage`,
   `Repository.hasAnyHistory`,
   `BehaviorStore.didRecalibrateCharge`, `JournalCatalog.setSortIndex`, `SkinTempBackfillWalker.totalAttempted`,
   `HealthKitBridge.foregroundCatchUp`. Live elsewhere (not dead): `uploadTimer`, `captureRawAccel`,
   `clearEcgRawDataGate`, `clearKey`, `availableKeys`, `recalibrateChargeBaseline`. On Android only
   (`cycleAwarenessHidden`, `numericJournalSeries`): likely iOS features without an entry point — verify the intended
   feature surface and preserve its behaviour before deciding whether to remove them.
   `periphery` (Homebrew) scans for unused Swift declarations.
5b. **Next cleanup round:** Android's animated `LiquidSky` composable has no call site (only `LiquidSkyStatic` is
   used); `NavRouter.openTrends` / `openLiveSession` and `BehaviorStore.didRecalibrateCharge` were KEPT on purpose
   (named hooks) — re-check only if their surfaces are dropped. The midnight cold re-score (`configDropped
   (sleepConsistency)`) is correct invalidation; cheaper only by splitting `analyzeDay` into a config-free part
   (streams, staging, HRV) and a cheap config-dependent score — a two-platform refactor, ~2 % of daily CPU for him,
   more for 21-night users (the pass risks iOS's background deadline, #1538).
6. **The macOS unit tests start the whole app, Bluetooth included** (28 Sep: `StrandTests` runs hosted in "NOOP
   Staging", which creates a `CBCentralManager` and opens a window on the developer's Mac; no connect seen). Candidate
   upstream PR: skip BLE start and windows when hosting unit tests. Check how upstream wants it first; build both apps.
7. **Android's live-HR smoothing counts emissions, not time** (`AppViewModel.ingestHr`, window 5; iOS takes a 10-s
   median). Display only; a parity question for the maintainers before a change.
8. **The largest files** (`BLEManager.swift` 7.4k lines, `TodayView.swift` 6.0k, `IntelligenceEngine.swift` 3.5k,
   `Repository.swift` 3.5k, `WhoopBleClient.kt` 8.7k): split only where it removes real duplication or bug risk.

9. **Apple deletion markers are missing from `.noopbak` (confirmed 7 Oct).** Production export/restore on
   `8e94d559` with a real migrated synthetic store: fresh defaults restore raw/profile/journal data but lose the
   suppression markers; same-device restores retain local markers, and unrelated destination markers also survive.
   Marker-only backups omit settings entirely. #2660's hidden-list choices are absent too; its backup code is identical.
   28 assertions passed; the exact finding is loss of the detector guard, which can permit a deleted night to return.
   Android keeps `dismissedSleep`/`managementVisible` in its database; source audit and a synthetic DB/container
   fixture confirm those travel together (Android runtime restore not run). Both platforms reject the other's full
   database, despite their common ZIP/settings contract. Preferred discussion direction: an optional versioned
   deletion-state archive entry, preserving Apple global versus Android device scope, atomically restoring both
   suppression and visibility, and keeping the profile whitelist unchanged. A database migration is the alternative
   and must explicitly address old id-free Apple spans. **No implementation before the storage discussion.**
   [Issue #2720](https://github.com/ryanbr/noop/issues/2720) is published with Utku's approval; storage direction is
   pending. Exact posted body and runnable evidence: ignored `private/session-2026-10-07-backup/`. No personal export needed.

10. **Android's Polish and Portuguese deleted-sleep strings** use the computer sense of "sleep" ("uśpienie",
    "suspensão"; one pt line keeps "sleep" in English); iOS has the corrected ones since `ios-deleted-sleep`. A small
    Android strings PR.
11. **MetricKit payloads came empty on 2–3 Oct** (begin = end, "exits: none"), after full ones on 26 and 29 Sep.
    Check whether a reinstall/update resets MetricKit's window before relying on it for a before/after.

## Upstream reliability to watch (help only with evidence from his logs)

- **#2387 / #1466** — syncs that take "ages" (iOS, WHOOP 4.0); the maintainers are on it (#2390 merged).
- **#2384** — Android live HR stops updating on a 5.0/MG. **#2270** — Android OutOfMemoryError in
  `LiquidRender.wavePolygon`. Android; no device here.

## Completed or rejected — do not repeat

These are historical findings; the release and active PRs live in State.

- **#2371, the WHOOP 5 500 ms R-R filler** — #2569 merged 28 Sep (HR < 100 from his backup; 873 rows marked).
- **The Liquid Today animation** — #2444 merged 27 Sep (Today by day 6.7 + 22.6 → 0.00 + 0.11 CPU-s/min).
- **`AppModel.purgeImportTemp()` deleting `noop-*` in the shared temp folder** — our #2446, fixed upstream in #2453.
- **The automatic follow-up offload after each history sync** — dropped 24 Sep: two small commands and one or two
  replies in the same second, guarding against a strap that stops mid-history (#364/#451); not worth a BLE change.
- **Checked and clean (23 Sep):** forced unwraps / `try!` / `as!` (none unguarded), network use (update check off by
  default; AI and Oura opt-in), widgets / Watch / notification dedup, formatters in hot paths, stale reads in
  `@Published` sinks (#2416/#2418/#2437), timer leeway (keep-alive exact on purpose, #1052), guarded divisions.
