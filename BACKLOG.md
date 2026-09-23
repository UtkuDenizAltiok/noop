# Backlog

Verified against the code at `lift-log-follow-ups` (`65b804a6`, 22 Sep 2026). The open follow-up PR
(`NEXT_PR.md`) goes first; after it, each item is its own small PR. **This list is a poor predictor** — the gym
sessions found the bugs that mattered and this list predicted almost none. Ask what happened at the gym first.

## NOOP itself (not the Lift Log) — found 23 Sep 2026, not yet fixed

- **iOS stress check-in reads each R-R packet 1–2×.** `AppModel.evaluateStress` runs from the same two `@Published`
  sinks as `ingestHR` (`$heartRate`, `$rr`), inside `willSet`, so it appends the PREVIOUS packet's intervals to
  `rrBuf` once per packet plus once per heart-rate change, and advances the "slow" EMA baseline per call (0.98 per
  call ≈ 25 s memory at 2 calls/s). Android runs the same detector once per history offload on `rrRecent`. Fix
  direction: consume packets by `rrSeq` (`RRPacketObserver.swift`'s rule), once per packet. Only matters with the
  stress check-in enabled; a behaviour choice about the baseline's speed belongs to the maintainers.
- **`BLEManager.uploadTimer` / `uploadIntervalSeconds`** are dead: declared and cancelled, never started.
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
