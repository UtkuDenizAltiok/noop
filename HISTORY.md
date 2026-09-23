# History

One line per event. What a session or review found, and the rule it produced, is what makes the rules
trustworthy — keep it.

## Upstream timeline

- **9 Sep 2026** — #2029 (catalog hygiene) merged: the first upstream contribution.
- **11 Sep** — first review round on #2098 (schema) and #2099 (app): Android delete list fixed; double-tap de-dup
  made a set; estimates labelled; work-vs-rest deleted; the CI template commit kept out of PRs as
  `fork/ships-template`.
- **14 Sep** — #2098 squash-merged; #2099 rebased with `--onto`. ryanbr confirmed and corrected his own
  "migration registered twice" (a grep counting a comment). #2099 cleared the 14 lift-log ledger entries (#2211).
- **15 Sep, early** — first gym session → three changes added to #2099 (program counts asked at finish; grey
  stays grey with one complete/discard question; editing finished sessions).
- **15 Sep 04:04–04:16 UTC** — ryanbr reviewed them, asked whether a face-down session with nothing typed should
  be emptied by a discard (it filed an empty session plus a workout with strain), pushed the guard `fed714cb`
  and merged #2099.
- **15 Sep** — second gym session (before the merge was seen) → one Save, discards kept as zeros, add/remove in
  Edit sets; built on `lift-log-discard-and-edit`.
- **15 Sep** — the maintainers merged #2232 (Kotlin `LiftMetrics` twin). Rebased onto it; the twin and its
  oracle now follow `isPerformed`.
- **15 Sep** — #2229 reported that #2099 left parity governance red on `main` (files added without an authority
  refresh; the check never runs on product PRs); #2233 repaired it. Governance tests added to `verify.sh`.
- **15 Sep** — fork cleaned to its exact layout; notes restructured into this handbook.
- **15 Sep** — Utku asked for a target max RPE per program line, as a safety ceiling shown grey in the session
  and imported from the template; built on `lift-log-target-rpe` (stacked on the follow-up).
- **16 Sep** — he then asked for grey to mean the same for RPE as for weight and reps: a set left unrated saves
  the line's max RPE. Accepted with its cost stated (a stored rating no longer proves he rated that set).
- **16 Sep** — adding a method to the Room DAO interface broke three Kotlin test doubles. The fork's testing
  build stayed green (its Android job assembles the app; it does not compile or run the unit tests), and only
  Android CI caught it — run it on every branch that touches `android/**`.
- **16 Sep** — Python 3.12 installed, so the parity ratchet ran for the first time. It named three new one-sided
  Swift declarations; two were avoidable (a helper and a constant, both inlined) and `deleteLiftSets` got its
  Kotlin twin ported ahead of its consumer. Ratchet errors: 0.
- **16 Sep, later** — upstream's `main` went green again (`8576a2dd`: #2259/#2267 parity-scan fixes, twin maps
  re-derived). On a test merge each branch then failed exactly one way — `twin-map-authority-drift` from its two
  new twin pairs — and the guarded refresh fixed it touching nothing else. So the PR carries that refresh; the
  earlier "leave the JSONs alone" plan only held while `main` itself did not reproduce.
- **16 Sep, 21:20–22:26** — third gym session, on build `4fda4266` (16 sets). Worked: the grey max RPE saved when
  left blank, one Save, discarded sets as 0 / 0 in Edit sets, adding and removing sets there, the orange warning.
  Found: weight → reps still took two taps; one double-tap "skipped two things" and 3–4 did not register; buzzes
  sometimes slightly late; the Lock Screen rest clock counted up past zero. Asked for: the Lock Screen to light on
  a strap step, and the next set instead of "0 of 16 sets". The exported log has the session from 21:54 on; in it
  the strap sensed 22 double-taps and all 22 were acted on, two of them knocks 3–4 s after a tap. All six built on
  `lift-log-gym-round-3` the same night, plus typed numbers missing from the bar (found in the simulator).
- **17 Sep** — Utku narrowed the light-up to "just light up" a dark Lock Screen (now: locked phone only, one
  update, sent at once) and ruled out any change to logging. He asked why the log had nothing from 21:15 to
  21:54, exactly his workout. Traced through `LiveState`: the app run started at 21:14:45 stopped logging at
  21:15:05 (its last ≤31 unsaved lines never written), a new run started at 21:20:24 as he began, and by the
  22:44 export that run's first half hour had been trimmed from its 5,000-entry log — 58% of it upstream's
  once-a-second heart-rate line, 44 entries the Lift Log's. Not a Lift Log fault; `tools/strap-log.py` now
  reports it. Open: why the 21:14:45 run stopped (closed by him, by iOS, or a crash).
- **17 Sep, 21:37–22:29** — fourth gym session, on build `954a53a8`. The strap sensed 28 double-taps and all 28
  reached the app; 2 were held back by the 8 s knock window and felt "unregistered". Four strap steps buzzed but
  did not light the Lock Screen: the light-up waited for iOS to report the phone locked, which it does ~10 s after
  the screen goes dark. NOOP restarted at 21:37:30 and again at 21:38:37 (cause not in the log). Utku asked for:
  5 s, done sets complete without asking, the program following each line's heaviest set, and the banner's words
  given more width.
- **21 Sep** — the stack rebased onto `a56840bb` (110 upstream commits: 11.8.0 shipped the Lift Log; #2272 added a
  sync banner; #2327 notes the Lift Log has no Android UI). All ten commits range-diff identical; the parity refresh
  committed on the first branch; full `verify.sh` green on the tip, governance included, for the first time. Round-4
  changes on top, and the plan changed to ONE PR for the whole stack. Utku confirmed one-tap typing and the 0:00
  clock from 17 Sep, and asked for the PR in simple, clear words.
- **21 Sep, 19:36–21:02** — fifth gym session, on build `592e17b` (round 4). The Lock Screen lit "perfectly" at
  first, then mostly stayed dark while buzzes and steps worked. The log (20:34:58 on; the three older runs' slots
  were used up) shows iOS closing NOOP and relaunching it in the background four times in 28 minutes, and every
  step after a background relaunch logging "no Lift Log banner is running" until he opened NOOP. Ours: the session
  came back when the first screen appeared, the banner's first push found none and ENDED the banner iOS had kept,
  and iOS refuses a new one from the background — proven in the simulator from ActivityKit's own log (rule 41).
  A tap/buzz/light-up delay he felt at 20:06–20:09 is outside the file. Asked for: adding an exercise during a
  session (rule 42), and the in-app bar laid out like the Lock Screen banner. The same night: all three built,
  in-app running clocks switched to NOOP's `ActiveWorkoutClock.clock` (they said "45s" beside the Lock Screen's
  "0:45"), and `tools/strap-log.py` gained a per-run "steps" report.
- **22 Sep** — Utku sent the iPhone's crash reports: four `cpu_resource_fatal` (20:34, 20:42, 20:58 during the
  session, 09:17 that morning on the previous build), no jetsam — iOS killed NOOP for background CPU (over 80% for
  60 s), its main thread redrawing SwiftUI views. Ours: a once-a-second tick published to the whole app shell and
  the sheet, and the sheet watching LiveState and AppModel. Fixed without a tick (rule 43); measured in the
  simulator; build `f7638bf`. He also asked why the log missed his window: the ring kept three runs of 1,000 lines
  and lost up to 31 lines at each kill. A separate PR branch `strap-log-on-disk` keeps every line on disk, all runs
  within 2 MB, on iOS and Android (Kotlin twin checked against the Swift output), waiting on his yes. Its first
  commit failed the parity ledger and governance: a test helper named `run(at:)` was credited, by the ledger's
  name-only call graph, as a caller of `StandardHRLifecycleFlush.run/2` (renamed `process(at:)`). Three stuck
  "wait for the build" loops of mine were `pgrep -f` matching their own command line — never wait on a process
  search whose pattern is in the waiting command.
- **22 Sep, morning** — Utku said yes to the strap-log PR (lean, battery-cheap, nothing he wants removed) and asked
  for the project to survive usage limits, server errors and compaction. Continuity: `STATE.md` "Now" became a
  write-ahead journal, `tools/checkpoint.sh` shows the ground truth after an interruption and saves locally, verify /
  ship / backup log events, `backup.sh` folds checkpoints, README gained "After an interruption"; Claude Code hooks
  are ready but only Utku can install them (the auto-mode guard blocks the agent from Claude's settings). The
  strap-log branch lost an unused `clear()` and four Swift 6 warnings it had added; measured, it costs about a
  tenth of the CPU of the mirror it replaces. Opened as #2386 at 08:10; all five upstream checks green.
- **22 Sep, 09:00** — Utku asked for a clean, final project that any AI can pick up. The three stacked branches
  became one, `lift-log-follow-ups` (all contained, the old names deleted); the fork's `main` re-mirrored
  (`29d90eb6`); a stale local `main` and tag tidied; the 15 Sep retired-refs bundle moved to the Trash (only
  superseded snapshots were unique to it). README now opens with a starter prompt for any AI and an end-of-session
  prompt, with "End a session" and "Working with any AI"; Claude-only parts are marked. A newcomer's setup from
  GitHub was run end to end, and the repo page links to the handbook.
- **22 Sep, evening (sixth gym session, 20:10–21:24, build `f7638bf`)** — the in-app bar, adding and removing an
  exercise all right. NOOP was NOT closed once (one app run from 19:46 to 21:25, and no crash report for the day):
  the CPU fix held in the field. Two findings: the Dynamic Island stretched with its clock adrift and no heart rate
  (rule 45), and after 20:42 the Lock Screen lit 5–10 s after a double-tap while the buzz stayed immediate,
  recovering by 21:00 — every alert left the app at once, so the wait was iOS's, and the app's share of it was 409
  heart-rate pushes (rule 44). Both fixed the same evening; #2386 merged that morning as `a9717abc`.
- **23 Sep, 03:40 — the Lift Log follow-up PR is open**, [#2403](https://github.com/ryanbr/noop/pull/2403), from
  `lift-log-follow-ups` rebased onto `751fa1d8` (every commit range-diff identical, the twin map re-derived as its
  own commit). It carries rounds 3–6: one Save and the finish flow, max RPE, the knock guard and the buzz before
  the sync, the next-set line and the 0:00 clock, adding an exercise mid-session, the Lock Screen light-up and the
  banner kept across an iOS restart, no work between taps, the Dynamic Island's layout, the banner's push rate and
  the stamped log lines. Seventh gym session the same night (02:28–02:53, build `1c34d6cd`): 24 steps, no tap
  refused by any guard, two taps Utku felt that never reached the app, and the reconnect path seen for real.
- **23 Sep, 00:40** — the separate diagnostics PR Utku asked for: upstream's standard-HR host-received line,
  written once a second, was 52.8% of a session's strap log and so decided how much history the on-disk log holds.
  Now a refusal is still written at once, the routine samples become one line a minute (count, span, widest gap,
  accepted / refused / pending), the window closes at a disconnect, and full detail returns under the Test Centre's
  HRV or Connection mode. Replayed over his log: 3,938 lines → 67. Opened as
  [#2402](https://github.com/ryanbr/noop/pull/2402) from `hr-transport-summary`. Three faults caught on the way:
  whole-file copying between branches reverted newer upstream code, a Kotlin property is not a function reference,
  and a constant name collided with one the parity ledger already pairs.
- **22 Sep, night** — Utku asked whether the Lift Log needs background machinery of its own, since NOOP keeps
  showing live HR with the app closed. It does not (rule 46): it rides NOOP's CoreBluetooth background mode, which
  both of that day's gym logs demonstrate. Looking for it found something else: the Lift Log's own strap-log lines
  carried no time of their own (98 in that session) — fixed (rule 47), build `1c34d6cd`. Left offered, not done:
  52.8% of a session's log is upstream's once-a-second standard-HR line, which is what limits how much history the
  new on-disk log holds.
- **22 Sep, 09:45** — ryanbr reviewed #2386: approving, with one finding — lines logged before the first unlock after
  a boot were dropped at the first segment boundary. Verified by a test that failed (and wider: held lines never
  reached disk later); fixed on both platforms in `23bee21a` (they wait in memory within the budget and are
  written once storage opens), a third oracle case; pushed, replied and the description updated with Utku's yes.

## What found what

| what was wrong | found by | rule |
|---|---|---|
| session walked back to a skipped machine | gym | 4 |
| completed sets saved no numbers (19 empty sets) | gym | 5 |
| "SET" header wrapped to "SE / T" | gym | shared 34 pt column |
| hidden HR readout read as a missing feature | gym | 6 |
| 45.5 kg stored as 455; `%.1f` rounding | gym | 11, 12 |
| phantom double-tap advance; de-dup caught only consecutive replays | gym, maintainer review | 22 |
| gym rest labelled with the sleep "Rest" key | code reading | 10 |
| weekly bar full and green at the floor | review | 15 |
| set count computed two ways, guards differed | review | 2, 3 |
| no way to log an unplanned set | Utku asked | 17, 18 |
| typing into a pending set was discarded | gym | 19 |
| no way to delete a session | gym | 13 |
| 51 of 205 strings never reached the catalog | pre-PR audit | 20, 21 |
| estimates read as measurements; work-vs-rest informed nothing | Discord review, Utku | 23, 24 |
| uncalled APIs kept alive | audit, parity ledger | 2, 25 |
| template allowed column inserts (inverted protection flags) | checking a claim | a test pins the lock |
| removing a set kept numbers typed into it | audit | 26 |
| grey numbers written in at "set done" had to be typed over | gym | 5, 28 |
| ⊕/⊖ rewrote the program on every tap | gym | 27 |
| a mistyped or missed number could not be fixed after finishing | gym | 30 |
| a double-tap that did not register left no evidence | gym | 29 |
| a saved session missing from the hub until reopened | simulator | 31 |
| a Save that could not be pressed still looked pressable | simulator | dim disabled buttons |
| Skip and Save session saved the same way | gym | 28 |
| a mistaken discard could not be undone; sets not addable/removable after finishing | gym | 30, 32 |
| a set typed as 0 reps still counted | audit | 32 |
| an all-untyped discard filed an empty session with a workout and strain | maintainer review | 32 |
| a session with nothing performed showed an empty list and a wrong message | simulator | 32 |
| typing into a 0 in Edit sets appended to it ("600") | simulator | 30 |
| SQL counted `reps > 0` where Swift counts `reps != 0` | audit | 32 |
| two same-arity `isPerformed` overloads made the twin claim ambiguous | parity ledger | 25 |
| a Swift figure change without its Kotlin twin, once #2232 landed | upstream moving | 33 |
| a product PR left parity governance red on `main` | maintainers (#2229) | 25 |
| weight → reps took two taps: the tap-outside gesture took back the focus it had just given | gym | `KeyboardDismiss` |
| a knock 3–4 s after a tap finished a set seconds old | gym, strap console log | 35 |
| the confirming buzz came 1–2.8 s late when the tap's event also kicked a sync | strap log | 36 |
| the Lock Screen rest clock counted up past zero | gym | 38 |
| "0 of 16 sets done" told a lifter nothing to act on | Utku asked | 37 |
| the bar showed the grey plan for a set whose numbers were typed | simulator | 5 |
| an exported strap log had lost the first half hour of the session | log analysis, Utku asked why | 29, `tools/strap-log.py` |
| strap steps that buzzed but did not light the Lock Screen (the "locked" gate lags ~10 s) | gym | 39 |
| two deliberate taps held back by an 8 s knock window | gym, strap log | 35 |
| after iOS relaunched NOOP in the background, its first push ended the Lock Screen banner | gym, strap log, ActivityKit log | 41 |
| the in-app clocks said "45s" / "0s" where the Lock Screen said "0:45" / "0:00" | simulator | 38 |
| an exercise not in the program could not be logged | Utku asked | 42 |
| iOS killed NOOP for background CPU: the session redrew every screen each second | crash reports (Analytics Data) | 43 |
| the handbook seven hours behind the work after a usage limit, a server error and a compaction | Utku | WORKFLOW §2 Continuity |
| four Swift 6 warnings added by the strap-log branch | reading its build log before opening the PR | — |
| done sets asked about at finish; the program not following the session | Utku asked | 27, 28 |
| a second, sync banner would appear mid-session once #2272 arrived | reading upstream | 40 |
| the Lock Screen's words cut short by the numbers' width | Utku asked (screenshot) | banner layout |
| a stacked timer spread across the banner | simulator | clock sized from a hidden "00:00" |

**Confirmed on hardware:** Lock Screen activity (HR, reps × weight, ticking seconds), carried values across
sessions, spreadsheet import on device, double-tap with confirm and rest buzzes; and on 16 Sep the max RPE grey
fill, one Save, discards as 0 / 0 in Edit sets, adding and removing sets there, and the warning before an empty
Save.

**The pattern worth remembering:** the bugs that mattered were silent wrong data that passed every test and
build — a value that looks right on screen while being wrong underneath. A real session catches that; a suite
does not.
