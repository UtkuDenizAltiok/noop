# The Live HR banner — feature reference

NOOP's heart-rate Live Activity on the Lock Screen and in the Dynamic Island, and the live heart rate with the strap off
the wrist or out of reach. Finished 24 Sep 2026: PR [#2422](https://github.com/ryanbr/noop/pull/2422) (merged) and
[#2437](https://github.com/ryanbr/noop/pull/2437), every case confirmed on Utku's phone. This page is what anyone changing
NOOP's live heart rate, Bluetooth or banners needs: what Utku decided, what iOS allows, what his WHOOP 5.0 does, what
the code does, and how it was proven. The rule, in short, is at the end.

## 1. What Utku wants

- A heart rate only while the strap is measuring it — on Today, the Live screen, the Lock Screen and the Dynamic Island.
- **24 Sep (his decision, replacing 23 Sep's "no banner with the strap off"):** NOOP must NOT close the banner when it
  sees no heart rate or loses the strap — "if it can re-open the notification banner it shouldn't close"; closing it
  and needing NOOP opened to get it back is illogical, even after walking away for 30 s. Show "–" instead. Whoever wants
  it gone turns it off in Settings → Live notifications (#2419).
- Banners that are reliable (not "sometimes there, sometimes gone until I open the app") and quick.
- The Lift Log banner always during a session; one switch per live notification; a switch only hides (#2419).
- Low usage: no extra CPU, memory, battery on the phone or the strap.
- "Make everything perfect, optimized, clean, sleek and efficient."

## 2. The iOS rules every design must live with

1. **Only an app on screen may START a Live Activity.** A banner ended in the background is gone until NOOP is opened.
   (Push-to-start needs an APNs server; NOOP is offline — not an option.)
2. **A running banner can be updated or ended from the background — but only while NOOP is running.**
3. **NOOP runs in the background only when something wakes it:** a Bluetooth notification (a reading, an EVENT such as
   WRIST_OFF) or a connect / disconnect, state restoration, a background task. Between wakes iOS suspends it within
   seconds, and its timers do not fire.
4. **A woken app may ask for ~30 s more** (`beginBackgroundTask`).
5. **The stale date is iOS's own clock.** Each update may carry one; when it passes iOS marks the banner stale and redraws
   it with NOOP's widget code (`NOOPLiveActivity.shownBpm` → "–") without waking NOOP — in a non-waking batch, **two
   minutes** after the push for a 30-s stale date (simulator, 23 Sep). Not yet seen on a real phone.
6. **iOS ends any Live Activity about 8 hours after it was started.** NOOP renews it when opened (§4 commit 10).
7. **Swiping NOOP away** discards its screen (`reason=termination` in the log) and ends the process; the banner stays on
   the Lock Screen, frozen, until its stale date draws the dash. iOS started NOOP again in the background at 03:01:24 on
   24 Sep, 5 min after a 02:56 close (what woke it is not in the log); opening NOOP always brings it back.

## 3. What Utku's WHOOP 5.0 does (four strap logs; private, not kept — facts only)

| log (saved) | what it showed |
|---|---|
| 23 Sep 15:56 | switches work alone and together; a plausible HR every second until NOOP closed the link |
| 23 Sep 17:00 | "3 unreadable samples (last 0 bpm, contact **unsupported**)" cleared the HR; later a strap-off = silence with the link up; the banner froze at 93 |
| 23 Sep 21:33 | every strap-off in the background = minutes of no traffic; each clear came from the zeros sent when the strap went back ON |
| 24 Sep 11:24 (build `13f96c7`, Utku's four tests) | **"Strap: WRIST_OFF; live heart rate cleared" at 10:48:03 — WRIST_OFF named, live, ~1 s after removal**, but no banner line followed and he saw the dash only ~2–3 min later: the banner read AppModel's median inside the willSet before AppModel reset it (fixed in #2437). Back on: "Strap: WRIST_ON" 10:53:35, number in ~10 s. Walk away: "–" at the drop 11:09:57, number 1 s after the reconnect 11:17:15. Swiped away 10:57:24: banner kept, "–" by 10:59 (iOS), picked up + number 1 s after opening at 10:59:34. Switch: ended 11:01:08, started 11:02:15 |
| 24 Sep 03:29 (build `c146351`) | **01:33:35 the strap's console: "wear-detection moving from on-body to off-body"; 01:33:37 an EVENT reached NOOP** (a sync attempt, "rate-limited"); NOOP was running on screen until 01:36:57, and the ten-second silence clear that would have fired at ~01:33:47 found the heart rate already gone → **WRIST_OFF arrives live, ~2 s after removal**. An event also arrived at each strap-on as readings resumed (01:26:28, 01:37:42, 02:26:27, 03:25:52). He saw "91" at 01:34 (the dash push lost to the 2-s spacing — fixed); 02:56:03 NOOP closed (`reason=termination`), 03:01:24 started again in the background, readings from 03:01:26, the banner "–" at 03:01 (NOOP logged nothing about the banner, so why is not provable; now it logs) |

So, on this strap and firmware:
- **Off the wrist it sends WRIST_OFF (~2 s), then goes silent** — no 0 bpm, no contact flag (always `unsupported`), link up.
- **Back on, an event arrives, then 0 bpm for ~2–10 s** while it finds the pulse, then real values.
- **Normal gaps between readings are ≤ 2 s.** Link timeouts recover fast (1, 1 and 18 s on 23 Sep).
- The realtime-HR toggle does not decide whether standard HR flows while worn.

`python3 dist/tools/hr-timeline.py <log> [--from HH:MM:SS] [--to HH:MM:SS]` prints the timeline, including app runs
starting and closing and, from the next build, every "Live HR banner:" and "Strap: WRIST_…" line.

## 4. What the code does: #2422 (11 commits, merged 24 Sep as `9c99138d`) and #2437

Reworked 24 Sep on commit 6: the old commits 7 (end after 30 s link down) and 8 (end on screen with no HR) were dropped.
Head `cf97a93c` **MERGED 24 Sep 03:22 UTC as `9c99138d`** (proven equal); the branch and worktree are gone. The
description is `dist/private/pr-2422-body.md`; ryanbr's review and our reply are summarised in `HISTORY.md`. Utku read
the final cases back on 24 Sep and approved them.

| # | what |
|---|---|
| 1 | 3 unreadable samples / WRIST_OFF clear the live HR (`LiveHeartRateReadability`); only readable samples reach it; AppModel's median reads the value being written; `clearLiveHeartRate` clears R-R first |
| 2 | the skin-contact flag logged when it changes (`unsupported` on a 5.0) |
| 3 | 10 s with no readable sample clears it — only while NOOP is awake |
| 4 | `LiveHRBannerLifecycle`: the banner kept through a dropped link and a background sync; no background start requests |
| 5 | Today's big number = live HR only |
| 6 | 30-s stale date, the widget draws "–" when stale, a steady number re-pushed every 15 s |
| 7 | **kept until its switch**: started on open with the link up, before any reading ("–"); a banner iOS ended or the user swiped away starts again on open; "on screen" from the scene phase |
| 8 | **number ↔ dash pushed at once** (`LiveHRBannerPushPolicy`, `reading:`) — the 01:34 "91" |
| 9 | **fed from process start** (`LiveActivityController.follow` in `StrandiOSApp.init`), not the view; the switch acts at once |
| 10 | **renewed on open when > 1 h old** (new first, then the old ends) — iOS's 8-h limit restarts |
| #2437 | **read once the change has landed** (`LiveHRBannerInputs.settled`): the banner's own sink read AppModel's median inside the willSet, before AppModel reset it, so WRIST_OFF sent no dash (24 Sep 10:48) |
| 11 | **always-on lines**: "Live HR banner: started / picked up / renewed / ended / gone / – / heart rate again / iOS did not start it"; "Strap: WRIST_ON / WRIST_OFF [during a sync][; live heart rate cleared]" (`FrameRouter.handleWrist`) |

## 5. What it does, situation by situation (all confirmed on Utku's phone, 24 Sep)

| situation | banner | how fast | proven |
|---|---|---|---|
| strap worn | number, pushed on change (≥ 2 s apart), re-pushed every 15 s when steady | — | yes (logs) |
| strap off (any app state NOOP is awake or woken in) | WRIST_OFF → "–" | ~1 s | WRIST_OFF proven (11:24 log); **yes** with #2437 (13:48:08: WRIST_OFF and the dash sent in the same second; seen 5–7 s later) |
| strap off, no WRIST_OFF, NOOP asleep | iOS draws "–" at the stale date | ~2 min | simulator |
| strap back on | number again by itself | seconds | yes (logs) |
| link down (walk away), any length | "–" at once, **kept**; number again on reconnect | at once | **yes** (11:24 log: 7 min away) |
| NOOP on screen, strap off | "–", **kept** | — | tests |
| NOOP swiped away | iOS keeps the banner; "–" by its stale date; picked up and fed when NOOP runs again | ~2 min | **yes** (11:24 log) |
| iOS's 8-h limit / swiped off the Lock Screen | gone; started again at the next open | — | code only |
| Lift Log session | HR banner steps aside (ended) for the gym banner, started again when NOOP is on screen after | — | earlier builds |
| switch off / on | ended at once / started at once (NOOP on screen) | at once | **yes** (11:24 log) |

## 6. Open ideas — only if measured or asked

1. **Push rate:** 15-s re-pushes while steady exist only to beat a 30-s stale date. With WRIST_OFF handled live the
   stale date is only a backstop, so a 60-s stale date would halve those pushes (120 an hour). ryanbr raised the push
   count in his #2422 review; decide from MetricKit / a day's log, one small PR.
2. **The Lift Log banner's own heart rate** reads `model.bpm ?? hr` inside its `onReceive` (the same willSet read
   #2437 fixed for this banner) and has no stale handling: strap off mid-session keeps its last number. Utku wears
   the strap at the gym; fix only if it shows.
3. **Swiped away:** iOS does not relaunch a force-quit app for Bluetooth, so the banner stays "–" until NOOP is
   opened. By design (Utku asked, 24 Sep); never work around it with background location or similar.

## 7. How to test

- **Unit tests (StrandTests, macOS):** `LiveHeartRateReadabilityTests`, `LiveHRBannerLifecycleTests`,
  `LiveHRBannerPushPolicyTests`, `FrameRouterWristEventTests`, `LiveHRBannerInputsTests`.
- **Simulator harness (never commit it):** in a throwaway worktree, push one banner update with a hard-coded value from
  the scene-phase `.active` branch; open NOOP from the home screen; press Home; read `liveactivitiesd`'s log (`Created
  activity`, `Ending activity`, `Marking activities stale`) and screenshot the island (`WORKFLOW.md` §3).
- **On the phone:** §6.1, then the strap log.

## 8. Files

`Strand/BLE/LiveHeartRateReadability.swift` · `Strand/BLE/LiveState.swift` (`clearLiveHeartRate`,
`noteReadableHeartRate`, the silence timer) · `Strand/BLE/BLEManager.swift` (`parseStandardHR`) ·
`Strand/BLE/FrameRouter.swift` (`handleWrist`) · `Strand/App/AppModel.swift` (the two sinks, `ingestHR`) ·
`Strand/Data/LiveHRBannerLifecycle.swift` · `Strand/Data/LiveHRBannerPushPolicy.swift` ·
`Strand/Data/LiveHRBannerInputs.swift` (#2437) ·
`StrandiOS/Widgets/LiveActivityController.swift` (`follow`, `appBecameActive`, the log lines) ·
`StrandiOS/App/StrandiOSApp.swift` (`init` wiring) · `StrandiOSWidgets/NOOPLiveActivity.swift` (`shownBpm`) ·
`Strand/Liquid/LiquidTodayView.swift` (`LiquidLiveHR`) · `StrandiOS/Widgets/LiftLiveActivityController.swift`
(`isShowing`) · tests as above.

## The rule (was RULES.md 49)

49. **A heart rate is shown only while the strap is measuring it, on every surface, and the Live HR banner stays until
    its switch removes it** (#2422, 23–24 Sep 2026, four strap logs; Utku, 24 Sep: NOOP closing the banner "when it sees
    no HR" is illogical when only opening NOOP can bring it back — show "–"; the switch is how to be rid of it). A WHOOP
    5.0 taken off the wrist sends WRIST_OFF about 2 s later (inferred, 24 Sep log; the new line will name it) and then
    goes SILENT with the link up; back on, an event reaches NOOP as readings resume (WRIST_ON, presumably) and 0 bpm
    follows for a few seconds while it finds the pulse. The app clears the live heart rate on WRIST_OFF,
    three unreadable samples, ten seconds of silence while awake, or a dropped link (`LiveState.clearLiveHeartRate`,
    R-R first); Today's big number is the live heart rate or nothing. The banner shows the number or "–", and the
    change between them is pushed at once (`LiveHRBannerPushPolicy`: a dash held back by the 2-s spacing and never
    retried left "91" standing, 24 Sep); its 30-s stale date lets iOS draw the dash (~2 min, without waking NOOP) when
    NOOP is asleep or closed. NOOP ends it ONLY for its switch (acting at once) or the Lift Log banner on screen (40) —
    never for a dropped link, a strap off the wrist, a sync, nothing to show on screen, or a timer
    (`LiveHRBannerLifecycle`). iOS lets only an app on screen START one: it starts when NOOP is on screen with the strap
    connected, before any reading if need be; one iOS ended (its ~8-h limit) or the user swiped away starts again at the
    next open; one older than an hour is renewed at an open (new first, then the old one ends), so the 8-h limit
    restarts. It follows the strap from process start (`LiveActivityController.follow` in `StrandiOSApp.init`), never
    from a screen, like 41, and it reads what it shows once a change has landed (`LiveHRBannerInputs.settled`, #2437):
    read inside a `@Published` willSet, AppModel's median was still the old number when WRIST_OFF cleared the heart
    rate, and the dash waited ~2 min for iOS (24 Sep, 10:48). Each step of its life and each WRIST_ON / WRIST_OFF leaves an always-on strap-log line
    ("Live HR banner: …", "Strap: WRIST_OFF …"). Never requested from the background.
