# Live HR on the Lock Screen — the strap-off / strap-on problem

The open work at the end of 23 Sep 2026. Utku's verdict then: **"not good at the moment"** — it needs more. This page
is everything a fresh session needs to continue it: what he wants, what iOS allows, what his WHOOP 5.0 actually does
(from three strap logs), what PR [#2422](https://github.com/ryanbr/noop/pull/2422) does today, what is proven and what
is not, and where to go next. Rule 49 in `RULES.md` is the short version.

## 1. What Utku wants (his words, 23 Sep)

- A heart rate only while the strap is measuring it — on Today, the Live screen, the Lock Screen and the Dynamic Island.
- With the strap **off the wrist but still connected**: ideally **no heart-rate banner at all** ("if HR there show, if
  not show nothing, so no usage"). He meant this case when he asked; he also said a **disconnected** strap should
  obviously show none.
- Banners that are **reliable** (not "sometimes there, sometimes gone until I open the app") and **quick**: on → off
  took "around 5 minutes or maybe not even works"; off → on took about 10 s and was fine.
- The Lift Log banner always during a session; one switch per live notification; a switch only hides, never changes
  what NOOP measures or records (#2419).
- Low usage: no extra CPU, memory, battery on the phone or the strap.

## 2. The iOS rules every design must live with

1. **Only an app on screen may START a Live Activity.** A banner ended in the background is gone until NOOP is opened.
   (Push-to-start needs an APNs server; NOOP is offline — not an option.)
2. **A running banner can be updated or ended from the background — but only while NOOP is running.**
3. **NOOP runs in the background only when something wakes it:** a Bluetooth notification or a connect / disconnect,
   state restoration, a background task. Between wakes iOS suspends it within seconds, and its timers do not fire.
   Proof: build `26fbca0` had a 10-s silence timer, and the 21:06–21:33 log shows it never fired in the background.
4. **A woken app may ask for ~30 s more** (`beginBackgroundTask`). #2422 commit 7 uses it for the link grace
   (simulator: dash at the drop 22:30:13, ended 22:30:44, NOOP in the background).
5. **The stale date is iOS's own clock.** Each update may carry one; when it passes iOS marks the banner stale and
   redraws it with NOOP's widget code (`NOOPLiveActivity.shownBpm` → "–") without waking NOOP. iOS runs this as a
   **non-waking** task: for a 30-s stale date ActivityKit logged `Earliest nonwaking date from task "Marking activities
   stale"` **two minutes** after the push (simulator, 21:49:49 → 21:51:49; the island turned "♥ 93" → "♥ –" by 21:52).
   Not yet seen on a real phone.
6. **iOS ends any Live Activity after about 8 hours.**

## 3. What Utku's WHOOP 5.0 does (three strap logs, 23 Sep)

The logs themselves are private (personal health data) and were not kept; these facts were read from them.

| log (saved) | what it showed |
|---|---|
| 15:56 | switches work alone and together; the strap sent a plausible HR every second until NOOP closed the link at 15:50:12 — no off-wrist case in it |
| 17:00 | 16:02:51 "3 unreadable samples (last 0 bpm, contact **unsupported**)" cleared the HR; the 16:53–17:00 test: last reading 16:54:16, a burst ~16:57, then **silence with the link up** and syncs working — the banner froze at 93; Today's big number showed 91 (a banked average, fixed in commit 5) |
| 21:33 | every strap-off in the background (21:14:12→21:16:00, 21:21:01→21:23:26, 21:31:52→21:32:47) = **minutes of no traffic at all**; each clear (21:09:18, 21:16:04, 21:23:30, 21:32:51) came from **zeros sent when the strap went back ON**; 4 clears, 0 "no readable sample for 10 s" lines |

So, on this strap and firmware:
- **Off the wrist it goes silent** — no 0 bpm, no contact flag (always `unsupported`), the link stays up.
- **Back on, it sends 0 bpm for ~2–10 s** while it finds the pulse, then real values.
- **Normal gaps between readings are ≤ 2 s** (92 one-minute windows, syncs included).
- **Link timeouts recover fast:** 1, 1 and 18 s (17:00 log: 15:49:46, 16:13:13→16:13:31, 16:51:35→16:51:36).
- Whether it sends **WRIST_OFF / WRIST_ON live is unknown** — `FrameRouter` acts on them but does not log them.
- The realtime-HR toggle does not decide whether standard HR flows while worn (readings flowed 21:17–21:21 with it off).

`python3 dist/tools/hr-timeline.py <log> [--from HH:MM:SS] [--to HH:MM:SS]` prints this kind of timeline from a log.

## 4. What PR #2422 does (8 commits, branch `live-hr-off-wrist`, worktree `~/Developer/noop-offwrist`)

| # | commit | what |
|---|---|---|
| 1 | stop showing a heart rate the strap is not measuring | 3 unreadable samples (0 / out of range / contact not detected) clear the live HR (`LiveHeartRateReadability`); WRIST_OFF clears it; only readable samples reach the live HR and R-R (storage unchanged); AppModel's median reads the value being written (willSet), `clearLiveHeartRate` clears R-R first; the banner shows "–" instead of freezing |
| 2 | log the skin-contact flag when it changes | rare-event line — showed `unsupported` on a 5.0 |
| 3 | clear after 10 s with no readable sample | `LiveState.noteReadableHeartRate` + one dispatch timer — works only while NOOP is awake (foreground) |
| 4 | keep the banner through a dropped link or a background sync | `LiveHRBannerLifecycle`; no more ends on every drop and every 15-min background sync (the "random" banners); no background start requests; offered at foreground |
| 5 | Today's big number = live HR only | no banked average drawn like a live reading |
| 6 | let iOS draw the dash when readings stop | 30-s stale date (was 120), widget draws "–" when stale, steady number re-pushed every 15 s; no timed end; no sync stand-aside |
| 7 | end it when the link stays down 30 s | dash at the drop, ended after 30 s inside the woken app's background time; `appActive` passed from the scene phase |
| 8 | no banner while not measuring and NOOP on screen | ended in the foreground (NOOP can restart it); kept as iOS's dash in the background |

Verified: `verify.sh` all steps on `29ac0446` + commit 8 (2,133 macOS tests), each new rule's test seen to fail without
it; simulator proofs for commits 6 and 7. **Not yet on hardware: commits 6–8** (build `c146351`, shipped 22:55).

## 5. What it does now, situation by situation (build `c146351`)

| situation | banner | how fast | proven |
|---|---|---|---|
| strap worn | number, pushed on change (≥ 2 s apart), re-pushed every 15 s when steady | — | yes (logs) |
| strap off, NOOP on screen | cleared after 10 s silence → **banner ended** | ~10 s | tests only |
| strap off, NOOP in the background | NOOP asleep → **iOS draws "–"** | ~2 min (iOS batch) | simulator only |
| … then strap back on (background) | zeros wake NOOP → brief "–" → number again | seconds | yes (21:33 log, old build) |
| … or NOOP opened with the strap still off | overdue silence clear → banner ended | at once | tests only |
| link down | "–" at once; **ended if still down after 30 s** | 30 s | simulator |
| Lift Log session | HR banner steps aside (ended) for the gym banner | — | earlier builds |
| switch off | ended, never started | — | yes |

## 6. What is still not good, and where to go next

1. **Strap off in the background never removes the banner, and its "–" takes ~2 min.** Utku wants none. Removing it
   needs NOOP awake at that moment, and nothing wakes it: the strap is silent.
2. **First step next session — find out if a 5.0 sends WRIST_OFF live.** Add an always-on, rare-event log line in
   `FrameRouter` for WRIST_ON / WRIST_OFF (both routes), ship, ask Utku to take the strap off with NOOP in the
   background, read the log with `hr-timeline.py`. If it does, that event WAKES NOOP at the moment of removal and the
   banner can be handled at once (dash, or end) with no extra cost. If it does not, the options are below.
3. **Option: stay awake a few seconds after each reading.** Hold a background task while readings flow (renewed per
   reading), so the 10-s silence timer can fire in the background: "–" within ~10 s instead of ~2 min, still coming
   back by itself on the wrist. Unknown: how much time iOS really grants a Bluetooth-woken app, whether renewing is
   allowed, and the battery cost — measure on the phone (MetricKit's daily line, #2420, and the strap log), never
   assume. A task left running past its time gets the app killed.
4. **The product choice in the background is Utku's:** "–" that comes back by itself on the wrist, or no banner that
   comes back only when NOOP is opened (iOS rule 1). He leaned to "none" (23 Sep); the build does "–" in the
   background and "none" on screen. Ask him again after he tests `c146351`, with this trade-off in plain words.
5. **Hardware-check commits 6–8** on `c146351`: strap off in the pocket (dash in ~2 min? number back on the wrist?),
   strap off then open NOOP (banner gone?), walk away until the link drops (gone after 30 s?). Then add the result to
   #2422's description.
6. **Push rate:** 15-s re-pushes while steady (≤ 240 an hour) exist only to beat a 30-s stale date. If the phone, like
   the simulator, applies staleness at ~2 min anyway, a 60-s stale date gives the same dash with half the pushes.
7. **The Lift Log banner's own heart rate** has no stale handling (strap off mid-session keeps its last number).
   Out of scope so far; Utku wears the strap at the gym.

## 7. How to test

- **Unit tests:** `LiveHeartRateReadabilityTests`, `LiveHRBannerLifecycleTests`, `LiveHRBannerPushPolicyTests`
  (StrandTests, macOS).
- **Simulator harness (never commit it):** in a throwaway worktree, push one banner update with a hard-coded value
  (and a simulated drop) from the scene-phase `.active` branch of `StrandiOSApp`; open NOOP from the home screen to
  trigger it (first launch does not); press Home; read `liveactivitiesd`'s log (`Created activity`, `Ending activity`,
  `Marking activities stale`) and screenshot the island (`WORKFLOW.md` §3).
- **Simulator settings:** edit the app container's preferences plist, not `simctl … defaults write` (`WORKFLOW.md` §3).
- **On the phone:** the test steps in section 6.5, then Utku saves the strap log; read it with `hr-timeline.py`.

## 8. Files

`Strand/BLE/LiveHeartRateReadability.swift` · `Strand/BLE/LiveState.swift` (`clearLiveHeartRate`,
`noteReadableHeartRate`, the silence timer) · `Strand/BLE/BLEManager.swift` (`parseStandardHR`) ·
`Strand/BLE/FrameRouter.swift` (WRIST_OFF clear, realtime readings) · `Strand/App/AppModel.swift` (the two sinks,
`ingestHR`) · `Strand/Data/LiveHRBannerLifecycle.swift` · `Strand/Data/LiveHRBannerPushPolicy.swift` (#2415) ·
`StrandiOS/Widgets/LiveActivityController.swift` · `StrandiOS/App/StrandiOSApp.swift` (`updateLiveHRBanner`) ·
`StrandiOSWidgets/NOOPLiveActivity.swift` (`shownBpm`) · `Strand/Liquid/LiquidTodayView.swift` (`LiquidLiveHR`) ·
`StrandiOS/Widgets/LiftLiveActivityController.swift` (`isShowing`) · tests as above.
