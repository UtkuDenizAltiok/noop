# Backlog

Verified against the code at `lift-log-follow-ups` (`65b804a6`, 22 Sep 2026). The open follow-up PR
(`NEXT_PR.md`) goes first; after it, each item is its own small PR. **This list is a poor predictor** — the gym
sessions found the bugs that mattered and this list predicted almost none. Ask what happened at the gym first.

## NOOP itself (not the Lift Log) — found 23 Sep 2026

- **The Live HR banner with the strap off the wrist** — the main open item; everything is in `LIVE_HR.md`.
- **iOS stress check-in reads each R-R packet 1–2×** — FIXED, merged as #2418.
- **MetricKit, local only** — done as #2420 (open).
- **`BLEManager.uploadTimer` / `uploadIntervalSeconds`** are dead: declared and cancelled, never started (not
  `private`, so the cleanup PR's scan did not reach them).
- **Android #2270 (OutOfMemoryError in `LiquidRender.wavePolygon`)** needs a heap profile of a session on a device;
  the issue itself says the 16-byte allocation is the victim, not the cause. Not doable without an Android device.
- **Android's HR smoothing window counts LiveState emissions** (`AppViewModel.ingestHr`, window 5), not packets or
  seconds, while iOS uses a 10-s median; any field changing (a sync chunk, an event) refills it. Display only; a
  behaviour choice, so a question for the maintainers rather than a silent change.
- **A second cleanup (#2417 was welcomed and merged):** internal (not `private`) app code no Swift file references —
  `Collector.bufferedCount`, `ImuSessionFileStore.prepareForRead`, `BLEManager.uploadTimer`/`uploadIntervalSeconds`,
  `captureRawAccel`, `clearEcgRawDataGate` (its Settings row died with the 5/MG card), `NavRouter.openTrends`/
  `openLiveSession`, `AppModel.cycleAwarenessHidden` (the views read the key through `@AppStorage`),
  `BiofeedbackPrefs.clearLockedPace`/`useResonancePace`, `SleepView.napMaxHours`, `BatteryGuidedCapture.currentStatus`,
  `CoachBriefScheduler.widgetBriefText`/`widgetBriefDate`, `AICoach.clearKey`/`aiCoachPrivacyNote`,
  `Profile.avatarImage`, `Repository.hasAnyHistory`/`dismissedSleepManagementWindows`/`allowSleepReDetection`/
  `availableKeys`/`numericJournalSeries`, `BehaviorStore.recalibrateChargeBaseline`/`didRecalibrateCharge`,
  `JournalCatalog.setSortIndex`, `SkinTempBackfillWalker.totalAttempted`, `HealthKitBridge.foregroundCatchUp` (never
  called since June; app-active already runs `health.sync()`, so not a bug). Framework callbacks (Bluetooth,
  document picker, scene delegate, App Intents, HealthKit workout builder) look unused and must stay. Check each
  for an Android twin or a missing UI before removing: some may be features whose entry point was never built.
- Checked and clean (23 Sep): forced unwraps/`try!`/`as!` (none unguarded), network use (update check off by default,
  once a day; AI and Oura opt-in), widgets / Watch / notification dedup, formatter creation in hot paths, stale reads
  in `@Published`/`objectWillChange` sinks (only the pair #2416/#2418 fix), timer leeway (keep-alive exact on
  purpose, #1052), whole-number conversions of divisions (all guarded).
- **Idle CPU on Today is the Liquid animation** (~10–18% of a core, measured upstream). Deliberate and gated by Low
  Power Mode and "Reduce motion in NOOP"; a user who wants the battery can turn that on. Not a bug.

## Open, ordered by value

1. **A strength trend across sessions.** Per session there is best set, e1RM and volume "vs last time", but no
   view across sessions — the reason to keep a log book. Per exercise over time: working weight, best set, e1RM
   (labelled estimated, ≤ 12 reps). `idx_liftSet_device_exercise` already serves the read;
   `lastLiftSets(deviceId:exercise:before:)` is the one-session version. Any new figure needs its Kotlin twin.

   | question | number | weight involved? |
   |---|---|---|
   | Is this muscle getting enough to grow? | sets per muscle | no, deliberately |
   | Am I getting stronger? | best set, e1RM over time | yes |
   | Did I do more work than last time? | volume | yes |

2. **RPE coverage where the counts are.** The RPE card says how many working sets were rated. Still open: the
   sets-per-muscle card shows no coverage, and a mean from one or two ratings is drawn at full weight (below ~3
   rated sets, show coverage instead). Display only; counting must not change.
3. **Android screens** — ryanbr's #2327 (19 Sep): an Android user found the 11.8.0 notes announcing a log book
   Android does not have. The Kotlin figures exist (#2232); Compose screens and a DAO reading lift sets do not
   (so `liftSetCounts` / `lastLiftSets` have no Kotlin twin). Best done by someone who runs Android.
4. **N+1 reads.** `LiftSessionView.loadLastTime()` and `LiftSessionDetailSheet.load()` query `lastLiftSets` once
   per exercise. Fine at 5–8 exercises; a single windowed query if programs grow.
5. **Small smells.** `LiftSessionBar` puts a button inside a tappable bar (fine in the simulator; watch on
   device). The session bar is iOS-only, so a session started on macOS is invisible once its sheet closes.
6. **Android does not hand a double-tap on before its sync kick** (the Swift change of 16 Sep, `RULES.md` 36).
   Android has no Lift Log, so only its buzz-back and other double-tap actions would gain; unmeasured there.
   Say so in the PR rather than changing Kotlin BLE code nobody can test on a strap here.
7. **Removing an exercise added by mistake.** Today: Undo straight after, or discard its sets at finish (they stay
   in that session as 0 × 0, fillable under Edit sets) and answer "Keep as it was". Only if Utku asks.

**Not asked for — do not build unprompted:** exporting a program to a spreadsheet; merge-by-name on re-import. **Only if the maintainer asks:** split the spreadsheet import into its
own PR; trim comments; squash.

## Known costs, measured — not oversights

- **iOS closing NOOP in the background** — the 21 Sep kills were `cpu_resource_fatal`, and the Lift Log's
  per-second redraws were ours to remove (`RULES.md` 43). NOOP alone still costs ~6 CPU-s a minute idle on Today in
  the simulator, and one kill (09:17 on 21 Sep, previous build) may have had no session running: if a gym log still
  shows a background restart, ask for that day's Analytics Data files (Settings → Privacy & Security → Analytics &
  Improvements → Analytics Data: `NOOP Staging.cpu_resource_fatal-…` means CPU, `JetsamEvent…` memory). Upstream's
  area beyond the Lift Log; raise it only with Utku's yes, and with those files.
- **The session snapshot is JSON-encoded into UserDefaults on every change**, keystrokes included. Deliberate (a
  crash mid-rest keeps what was typed); a few KB per session. If sessions grow, write sets incrementally rather
  than dropping durability. The importer's 200-line cap is part of this bound.
- **`loadLastTime` issues one indexed query per distinct exercise**, off the main thread, once per open.
- **Importer bounds** — 8 MB file, 64 MB per decompressed part, 5000 rows, 50 programs, 200 lines each, 50
  warnings — are pinned by tests; change them together.
