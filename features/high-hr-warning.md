# High heart rate warning — design and worker brief

Asked for by Utku on 12 Nov 2026. Designed by the architect chat the same day (research only, no app code
written). **Status: designed, not built.** A worker implements this page exactly; the architect reviews the diff
against it before it ships to the phone.

## 1. What Utku asked for

- The wearer enters a heart rate and a duration (his example: 110 bpm for 90 seconds).
- If the heart rate was higher than that for that long, the band warns by **vibrating two buzzes every 5 seconds**.
- Judge it on an **average**, not "above 110 on every one of the 90 seconds", so a wrong reading cannot break it.
- A feature the wearer **switches on and off**. It is not always running.

## 2. What it does, in plain words

While the switch is on, NOOP keeps the average of the live heart rate over the chosen time. When that average is
above the limit, the strap buzzes twice, and again every 5 seconds, until the heart rate is back under the limit.
One odd reading (a spike or a dropout) cannot start it and cannot stop it. With the switch off it does nothing
and costs nothing.

## 3. Facts the design rests on (checked in code and the handbook, 12 Nov)

| Fact | Where | What it means here |
|---|---|---|
| A WHOOP 5.0 sends a standard heart-rate reading about once a second while worn and connected, also with NOOP in the background; the realtime toggle does not decide it | `features/live-hr-banner.md` §3 (four strap logs) | The warning needs **no new Bluetooth traffic to listen**. It must NOT arm the realtime stream. |
| `LiveState.heartRate` is published **only when the value changes** | `BLEManager.parseStandardHR`: `if state.heartRate != m.hr { state.heartRate = m.hr }` | A `$heartRate` or `$bpm` sink does not fire on a steady heart rate, so it cannot keep an average or a 5-second rhythm. The warning needs a hook that runs on **every** readable reading. |
| Every readable reading passes `state.noteReadableHeartRate()` (two call sites: `BLEManager.parseStandardHR`, `FrameRouter` realtime frames) | `Strand/BLE/LiveState.swift` | That function is the one funnel to hook. It has an early `return` (timer throttle): the hook call goes at its **top**. |
| The buzz: `AppModel.buzz(loops:)` → `ble.send(.runHapticsPattern, payload: [2, loops, 0, 0, 0])`; on a 5/MG `send` remaps it to the maverick notify buzz, where `loops: N` gives N buzzes (hardware-confirmed, #926) | `AppModel.swift`, `HapticPayloads.swift` | "Two buzzes" is **one existing command with loops 2**. No new command, payload or opcode, so the BLE safety contract's issue-first rule for new commands does not apply. Only the schedule is new (as with the Haptic Clock). |
| A buzz needs the **encrypted** link: `live.bonded && live.encryptedBond`. On a 5/MG `bonded` alone also goes true from the live-heart-rate shortcut while the strap is not really paired (#69), e.g. a strap still owned by the WHOOP app; heart rate flows either way | `LiveState.encryptedBond`, `AppModel.canBuzz`, `BiofeedbackController.canBuzz` | Heart rate can be over the limit while no buzz can be sent. Gate on the existing `canBuzz` rule (plus `connected`), never on `bonded` alone, and let the screen and the log say when no buzz went out. (Corrected 12 Nov: the first draft gated on `bonded` only; worker 2 caught it.) |
| iOS suspends NOOP between Bluetooth events; each reading wakes it; timers do not fire while suspended | Rules 4, 5, 7 | No timer. The 5-second rhythm is decided **on reading arrival**. Wired at process start (`AppModel.init`), never from a screen. |
| A swiped-away NOOP is not relaunched for Bluetooth | `features/live-hr-banner.md` §6.3 | The warning cannot work then. The screen says so. |
| Off the wrist the strap sends WRIST_OFF then goes silent; back on, about 2–10 s of 0 bpm | same page | Unreadable readings never reach the hook. Silence means no buzz (nothing triggers one). |
| Upstream's nearest sibling is HR-zone coaching (`AppModel.coachZone`, one buzz on entering zone 5) | `AppModel.swift` | Different feature (fixed zone, edge-triggered, no average, no repeat). Leave it alone; do not merge the two. |

## 4. Decisions (architect, 12 Nov)

1. **Average rule.** Time-weighted average of the readings in the last *duration* seconds. Each reading counts for
   the time since the reading before it, capped at 3 s; the oldest reading in the window counts for 1 s.
2. **Start.** Warn when all are true: at least *duration* seconds since readings (re)started; readings cover at
   least 80 % of the window; the average is **above** the limit (strictly); the recent heart rate (median of the
   last 10 s) is above the limit.
3. **Stop quickly.** The buzzing stops when the recent heart rate (10-s median) is at or below the limit, about
   6 seconds after the wearer really slows down, even though the long average is still high. Reason: the buzz is
   feedback to slow down; buzzing for another 45 s after the wearer has slowed (what a pure 90-s average does)
   teaches nothing. If the heart rate climbs back while the average is still high, the buzz returns at once.
4. **Rhythm.** First buzz at once, then every 5 s, never closer than 4.5 s (the half second absorbs the
   once-a-second arrival of readings, so the rhythm is 5 s and not 6).
5. **The buzz.** One command, `loops: 2` (the app's standard double buzz). Fallback only if the hardware check
   (§9) shows the two buzzes blur into one: two `loops: 1` commands 650 ms apart (the `LiveSessionHaptics.push`
   shape).
6. **Its own switch is the only gate.** Default OFF. It does not depend on the "Wrist alerts" master switch
   (`notif.masterEnabled`): a wearer who turns this warning on has asked for it, and a second hidden switch would
   make it silently do nothing.
7. **No new Bluetooth traffic** except the buzz itself. No realtime arm, no keep-alive, no acknowledged write.
8. **Honest screen.** It shows what NOOP is doing right now (waiting, measuring, watching, buzzing, or cannot
   reach the strap) and when it cannot work.
9. **Visible while on.** Today shows a small row while the switch is on (both Simple mode and the full view),
   one tap from the switch, because a forgotten warning buzzes all through a workout.
10. **Platforms.** iOS and the Mac app (shared code) on the fork first. Android and an upstream proposal come
    later (§10): nobody here can test Android on a strap, and upstream wants an issue first.
11. **Not a medical alarm.** The screen says it is a training and pacing aid.
12. **Not in v1:** auto-off timer, quiet hours, a phone notification, double-tap to snooze, the `.noopbak` keys,
    Android. Listed in §10.

## 5. The pure engine — `Strand/Data/HighHRAlertEngine.swift` (new)

Foundation only. No UserDefaults, no clock, no BLE. Tested by `StrandTests/HighHRAlertEngineTests.swift`.

```swift
struct HighHRAlertEngine {
    struct Config: Equatable { var thresholdBpm: Int; var windowSec: Int }
    enum Phase: Equatable { case measuring, below, alerting }
    struct Decision: Equatable {
        let phase: Phase
        let averageBpm: Double?   // nil until at least one reading is in the window
        let recentBpm: Int?       // median of the last 10 s
        let buzz: Bool            // send the double buzz now
    }
    static let validBpm = 30...220
    static let maxHoldSec = 3.0
    static let oldestReadingSec = 1.0
    static let minCoverage = 0.8
    static let recentSec = 10.0
    static let repeatSec = 5.0
    static let repeatToleranceSec = 0.5
    static let buzzLoops: UInt8 = 2

    mutating func ingest(bpm: Int, at now: TimeInterval, config: Config) -> Decision
    mutating func reset()
}
```

`ingest`, in order:
1. `bpm` outside `validBpm`: change nothing, return the previous decision with `buzz: false`.
2. `now` earlier than the newest stored reading (clock moved back): `reset()` first.
3. Drop readings with `t <= now - windowSec`. If none are left, `armedAt = now`.
4. Append `(now, bpm)`.
5. Weights: oldest reading `oldestReadingSec`; every other `min(t[i] - t[i-1], maxHoldSec)`.
   `covered = min(sum of weights, windowSec)`; `average = sum(weight × bpm) / sum(weights)`.
6. `recent` = median of the readings with `t > now - recentSec` (sorted, element at `count / 2`, the same
   convention as `AppModel.ingestHR`).
7. `full = (now - armedAt >= windowSec) && (covered >= minCoverage × windowSec)`.
8. `alerting = full && average > threshold && recent > threshold`.
9. `buzz = alerting && (lastBuzzAt == nil || now - lastBuzzAt >= repeatSec - repeatToleranceSec)`; when true set
   `lastBuzzAt = now`. `lastBuzzAt` is kept across a short stop, so buzzes are never closer than 4.5 s.
10. Phase: not `full` → `.measuring`; else `alerting` → `.alerting`; else `.below`.

Cost: at most a few hundred additions a second while on; nothing while off (it is not called).

**Tests to write (readings once a second, limit 110, window 90 s unless said). Each must be seen to fail once
(Workflow §3).**
- Steady 120 from t = 0: no buzz through t = 89; first buzz at t = 90; next at 95, 100; none at 91–94.
- Steady 100 with one reading of 200 at t = 50: never alerts (average 101.1 at t = 90).
- Steady 120 with ten scattered readings of 60: still alerts at t = 90 (average 113.3).
- Alternating 105 / 125: alerts at t = 90 (average 115). It never needed every reading above the limit.
- Average exactly 110: no alert (strictly above).
- Stop: steady 120 to t = 200, then 95: still alerting at t = 205, stopped at t = 206, while the average is
  still above 110.
- Return: after that stop, 120 again from t = 220: alerting again at t = 224, and the buzz there is at least
  4.5 s after the previous one.
- Gap: 120 for t = 0…60, silence, 120 again from t = 101: `.measuring` at t = 101 (coverage 52 of 90 s) and no
  buzz until coverage is back to 72 s (the first buzz is at t = 172).
- Ten readings of 60 inside the last 10 s of an alert do stop it (the recent median is then 60): a real drop
  ends the buzz, a few scattered misreads do not.
- Long silence (all readings aged out): the next reading re-arms; no alert for a full window after it.
- Readings of 0 and 250: ignored, decision unchanged, never a buzz.
- A reading with an earlier time than the last: resets, no crash, `.measuring`.
- Two readings a second (both sources active): the same average and the same first-buzz time as once a second.
- Window 10 s (the shortest) and 600 s (the longest) each alert at the right second.

## 6. Settings and the monitor

**`Strand/Data/HighHRAlertPrefs.swift` (new):** keys `highHrAlert.enabled` (Bool, default false),
`highHrAlert.thresholdBpm` (Int, default 110, clamp 40…220), `highHrAlert.windowSec` (Int, default 90, clamp
10…600, steps of 5). One `static func current(_ d: UserDefaults = .standard)` returns
`(enabled, HighHRAlertEngine.Config)` already clamped; one `durationText(_ sec: Int) -> String` gives "45 s",
"1 min 30 s", "2 min" (localized) and is the ONLY place a duration is turned into words (the card, its summary
and the Today row all use it, so they cannot disagree). Not added to the `.noopbak` whitelist (a two-platform
contract; later, with Android).

**`Strand/App/HighHRAlertMonitor.swift` (new):** `@MainActor final class HighHRAlertMonitor: ObservableObject`,
owned by `AppModel` (`let highHRAlert`), **not** a new `@Published` on `AppModel` (that would redraw every
screen that observes the model).
- `@Published private(set) var status: Status` where `Status` is `.off`, `.waiting`, `.measuring`,
  `.below(average: Int)`, `.alerting(average: Int, buzzDelivered: Bool)`. Assign only when the value differs.
- `func ingest(bpm: Int, now: Date = Date())`: reads `HighHRAlertPrefs.current()`; off → if status is not `.off`
  reset the engine and set `.off`, then return (one defaults read per reading is the whole cost while off);
  on → `engine.ingest`, then on `decision.buzz` call `sendBuzz()` (a closure `AppModel` supplies) and note
  whether it could be sent.
- `func heartRateCleared()`: if on, status `.waiting` (the engine keeps its readings; they age out).
- `func settingsChanged()`: called by the card when the switch or a value changes: off → reset + `.off`;
  on → `.waiting` until the next reading. Logs the on/off line.
- Injected `log: (String) -> Void` and `sendBuzz: () -> Bool` so tests need no AppModel.

**Wiring (all at process start, in `AppModel.init`):**
- `LiveState`: add `public var onReadableHeartRate: ((Int) -> Void)?` and change `noteReadableHeartRate()` to
  `noteReadableHeartRate(bpm: Int)`, calling the hook as its **first** line. Update both call sites
  (`BLEManager.parseStandardHR` passes `m.hr`; `FrameRouter` passes its `hr`) and the two calls in
  `LiveHeartRateReadabilityTests`.
- `live.onReadableHeartRate = { [weak self] bpm in guard let self, self.live.worn else { return };
  self.highHRAlert.ingest(bpm: bpm) }`
- In the existing `live.$heartRate` sink: `if hr == nil { self.highHRAlert.heartRateCleared() }` (use the value
  the sink is handed, Rule 6).
- `sendBuzz = { [weak self] in guard let self, self.live.connected, self.canBuzz else { return false };
  self.buzz(loops: HighHRAlertEngine.buzzLoops); return true }` — `canBuzz` is `AppModel`'s existing
  `live.bonded && live.encryptedBond`; reuse it, do not write the condition a second time.

**Strap-log lines (always on, changes only, never one per buzz), via `live.append(log: AppModel.stamped(…))`:**
- `High HR warning: on (above 110 bpm for 90 s)` / `High HR warning: off`
- `High HR warning: over the limit (90-s average 113, now 118); buzzing every 5 s`
- `High HR warning: back under the limit (now 104, 90-s average 112) after 7 buzzes`
- `High HR warning: over the limit but no buzz was sent (strap not connected or not fully paired)` (once per
  episode)
- `High HR warning: paused, no live heart rate`

Check whether `BLEManager.send` writes a log line for every command. If it does, an hour of buzzing adds about
720 lines to the 2 MB strap log; report the line count in the hand-back so the architect can decide.

## 7. The screen — `Strand/Screens/HighHRAlertView.swift` (new, iOS + Mac)

`HighHRAlertCard` (the control) and `HighHRAlertView` (a `ScreenScaffold` titled "Heart rate warning" holding
the card; takes an optional `onClose` so it also works as a sheet). Design tokens only. Bound to the three keys
with `@AppStorage`; observes `model.highHRAlert` in a leaf view for the status line only.

Final English copy (every string needs all nine locales, see Simple mode → "How to work"):
- Title: **High heart rate warning**
- Blurb: "Your strap buzzes twice, every 5 seconds, while your heart rate stays above the limit you set. NOOP
  judges it on your average, so one odd reading can't set it off or stop it."
- Switch: "Warn me"
- Row: "Above" — value "110 bpm" (stepper, step 1, 40–220)
- Row: "For at least" — value from `durationText` (stepper, step 5 s, 10 s–10 min)
- Summary (always shown): "Buzzes when your average heart rate over the last %@ is above %lld bpm, and stops a
  few seconds after your heart rate drops back under it."
- Status (only while on):
  - "Waiting for a live heart rate from your strap."
  - "Measuring. The first warning can come after %@ of readings."
  - "Watching. Your average over the last %@ is %lld bpm."
  - "Above your limit: average %lld bpm. Your strap is buzzing."
  - "Above your limit, but NOOP can't reach your strap to buzz it right now."
- Button: "Feel the buzz" (sends one double buzz; disabled unless connected and `canBuzz`, the same gate as
  `sendBuzz`)
- Notes: "Works while NOOP is open or running in the background with your strap connected. It can't warn you if
  you swipe NOOP away, turn Bluetooth off or leave the strap out of range." · "Each buzz uses a little strap
  battery, so switch the warning off when you don't need it." · "A training and pacing aid, not a medical alarm."

**Where it appears:**
- iOS More: `MoreDestination.heartRateWarning` → `HighHRAlertView()`. Rows: Simple list, "Daily tools", after
  Alarms (as a `SimpleMoreEntry` case when Simple mode roadmap step 1 is already on the branch; a plain
  `MoreRow` otherwise); full list, "App", after Alarms. Row title "Heart rate warning", icon
  `bell.and.waves.left.and.right`.
- `AutomationsView` (iOS and Mac): the same `HighHRAlertCard` after `coachingCard`. Same view, same keys, so the
  two places cannot disagree.
- Today: `HighHRAlertTodayRow`, a self-hiding leaf placed right after `ActiveWorkoutIndicatorSection()` in
  `LiquidTodayView` (pinned, both modes), and in the classic `TodayView` too if it has the same pinned spot
  (report it if it does not). Driven by
  `@AppStorage` only (no live observation): bell icon, "High heart rate warning is on", "Above %lld bpm for %@",
  chevron; tap opens `HighHRAlertView` as a sheet.

## 8. Worker brief (copy this to an Opus 5.5 chat)

```text
You are an implementation worker for NOOP in ~/Developer/noop. Read AGENTS.md, dist/AGENTS.md and dist/RULES.md, then implement dist/features/high-hr-warning.md exactly (sections 4 to 7). Do not redesign it: if the code contradicts the page, stop and report what you found instead of improvising. Work on a new branch feat/high-hr-warning created from the tip of feat/simple-mode, in its own worktree (git worktree add ~/Developer/noop-hrwarn -b feat/high-hr-warning feat/simple-mode, then bash dist/tools/codex-setup.sh). Follow "How to work" in dist/features/simple-mode.md for builds, translations (all nine locales), doc-comment lint and test-helper naming. Verify before you finish: NOOPiOS simulator build, Strand macOS build, StrandTests (every new test seen to fail once), Tools/i18n_audit.py --ci upstream/main, Tools/doc_comment_lint.py, the Tools unittest suite, and a simulator look at the card, the Today row and both More lists in Simple mode and the full view. Commit and push the branch. Do NOT touch testing-stack, testing-build or any upstream PR, and do not open a PR. Hand back: the commit ids, the exact test counts, anything you could not verify (the buzz itself cannot be verified without a strap), and every place where you had to deviate from the page and why.
```

## 9. Checks on Utku's phone (after the build ships; about 10 minutes)

The buzz and the background behaviour can only be proven on the strap (`AGENTS.md`). Set the limit **below** the
current heart rate so nothing strenuous is needed.
1. **It buzzes, and it is two buzzes.** More → Heart rate warning → "Feel the buzz". Expected: two clear
   buzzes. If it feels like one long buzz, say so (decision 5's fallback).
2. **It starts on time.** Sitting, set "Above" about 10 below the heart rate shown on Live, "For at least" 30 s,
   switch on. Expected: "Measuring", then a double buzz after about 30 s, repeating every 5 s.
3. **It stops.** Raise the limit to 20 above the current heart rate. Expected: the buzzing stops within a few
   seconds and the screen says "Watching".
4. **Background.** Limit below the heart rate again, lock the phone, put it down for two minutes. Expected: the
   buzzing continues. Then switch the warning off.
5. **The reading stays honest.** While it buzzes, watch the heart rate on Live for a minute: it should stay
   near the resting value. If it jumps around only while buzzing, the motor is disturbing the sensor and the
   design needs a pause after each buzz.
Then save a strap log (More → All features → App → Test Centre → Strap log → Save…) and send it: the
"High HR warning:" lines show every start and stop to the second.

## 10. Later, only if wanted

- An "off after 1 / 2 / 4 / 8 hours" choice, if he forgets it on.
- Double-tap the strap to pause the warning for a few minutes.
- A phone notification as a second channel when the strap cannot be reached.
- Android: Kotlin twin of the engine (oracle-pinned, `WORKFLOW.md` §4), Compose card, `.noopbak` keys on both
  platforms; cannot be strap-tested here, so say so.
- Upstream: open an issue first describing the feature and the hardware evidence from §9; move the engine to
  `Packages/StrandAnalytics` with its Kotlin twin in the same PR.
