# Backlog

Verified against the code at `lift-log-gym-round-3` (`7bafa857`, 21 Sep 2026). The open follow-up PR
(`NEXT_PR.md`) goes first; after it, each item is its own small PR. **This list is a poor predictor** — six gym
sessions found the bugs that mattered and this list predicted almost none. Ask what happened at the gym first.

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
3. **`LiftFormat.duration` has no hours branch** — 75 minutes reads "75:23" on the bar, sheet and Lock Screen.
   Copy the `H:MM:SS` idiom from `Strand/App/ActiveWorkoutClock.swift`; consider upstream's clock-format
   setting (#1822).
4. **Android screens** — ryanbr's #2327 (19 Sep): an Android user found the 11.8.0 notes announcing a log book
   Android does not have. The Kotlin figures exist (#2232); Compose screens and a DAO reading lift sets do not
   (so `liftSetCounts` / `lastLiftSets` have no Kotlin twin). Best done by someone who runs Android.
5. **N+1 reads.** `LiftSessionView.loadLastTime()` and `LiftSessionDetailSheet.load()` query `lastLiftSets` once
   per exercise. Fine at 5–8 exercises; a single windowed query if programs grow.
6. **Small smells.** `LiftSessionBar` puts a button inside a tappable bar (fine in the simulator; watch on
   device). The session bar is iOS-only, so a session started on macOS is invisible once its sheet closes.
7. **Android does not hand a double-tap on before its sync kick** (the Swift change of 16 Sep, `RULES.md` 36).
   Android has no Lift Log, so only its buzz-back and other double-tap actions would gain; unmeasured there.
   Say so in the PR rather than changing Kotlin BLE code nobody can test on a strap here.

**Not asked for — do not build unprompted:** adding an exercise mid-session; exporting a program to a
spreadsheet; merge-by-name on re-import. **Only if the maintainer asks:** split the spreadsheet import into its
own PR; trim comments; squash.

## Known costs, measured — not oversights

- **The session snapshot is JSON-encoded into UserDefaults on every change**, keystrokes included. Deliberate (a
  crash mid-rest keeps what was typed); a few KB per session. If sessions grow, write sets incrementally rather
  than dropping durability. The importer's 200-line cap is part of this bound.
- **`loadLastTime` issues one indexed query per distinct exercise**, off the main thread, once per open.
- **Importer bounds** — 8 MB file, 64 MB per decompressed part, 5000 rows, 50 programs, 200 lines each, 50
  warnings — are pinned by tests; change them together.
