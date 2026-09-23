# State

**Updated 23 Sep 2026, 17:45 — #2415–#2418 MERGED; OPEN: #2419 (Live notifications), #2420 (MetricKit), #2422 (live HR truth + banner kept through drops/syncs; needs Utku's re-test). Build `26fbca0`.** The only file that
changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

**23 Sep, ~05:20 — Utku:** "ship the latest build". Also confirmed from his last real gym session (23 Sep, build
`1c34d6cd`): the Dynamic Island looks right and the Lock Screen lights up quickly, no problem. The walk-away test
(rule 48) is postponed, not dropped. **New direction:** the Lift Log is mostly finished; now optimise NOOP itself
(and the Lift Log) — same behaviour, cleaner, faster, no bloat, no delay, no crash, less battery for phone AND
strap — as SEPARATE upstream PRs, each only with his yes. Budget: his Claude Pro 5-hour window, up to 95%.
- [x] ship a build from `main` @ `94a71b04` — SHIPPED 05:13 and verified: `testing-latest` is "NOOP Staging — base
  11.8.0 · 2026-09-23 · 8351bc7", target `8351bc74` (parent `94a71b04`), `.ipa` + template present; run 35812381287.
  Just update. Utku's build is now `8351bc7` (Lift Log as merged + #2386 on-disk log + #2402).

**Optimisation PR 1 (local branch `live-hr-banner-pushes`, from `upstream/main` @ `94a71b04`, not pushed):** the
iOS Live HR banner was pushed every ~2 s all day while a strap is connected, even unchanged (it shows only bpm,
recovery, effort; bpm is a 10-s median). Now pushed only when it changes, else once a minute to stay ahead of its
120-s stale date — Android's notification rule since #216. `Strand/Data/LiveHRBannerPushPolicy.swift` + 5 tests.
- [x] tests seen to fail without the fix (2 of 5; steady hour 1,200 vs 60), restored byte-identical; commit `e2312c4c`;
  full `verify.sh` passed: WhoopStore 609 · StrandAnalytics 2044 · StrandImport 327 · lint · i18n · ledger · ratchet ·
  governance 124 · macOS 2,107 (only the two `TodayCarryOverTests`) · iOS build; no warnings in changed files.
- [x] Utku's yes, 23 Sep ~10:50 ("I accept your opinions, you can continue") — to BOTH PRs.
**Opening both PRs (23 Sep ~10:55):** upstream moved to `266a8702` (11 commits, none touching our files or fixing the
same things). Backup tags `backup/banner-pre-rebase` (`e2312c4c`) and `backup/workout-pre-rebase` (`b7a6e710`), local.
- [x] rebased: PR 1 `228a65f0` (only the comment re-wrap differs from `e2312c4c`), PR 2 `3f3cfc19` (our lines' hash
  identical to `b7a6e710`). NOTE: upstream `main` @ `266a8702` itself FAILS the parity ledger/ratchet/governance
  (twin-map authority drift; upstream's scheduled Parity Governance run failed 04:32 UTC on `971d0d9f`) — proven on a
  clean checkout; not ours, never refresh the authority unasked (`WORKFLOW.md` §4). Say so in the PR bodies.
- PR 1 verify on `228a65f0`: all ok (WhoopStore 611 · StrandAnalytics 2048 · StrandImport 327 · lint · i18n · macOS
  2,112 with only the two `TodayCarryOverTests` · iOS build) EXCEPT the 3 parity steps, which fail on `main` too.
**Cleanup PR 3 prepared (worktree `~/Developer/noop-cleanup`, branch `cleanup-unused-private-code` @ `a8bc8d35`, on
`34211e18`, local only):** 707 lines of `private` code nothing uses, 11 files — mostly Settings' 5/MG research card,
orphaned by #1709 (29 Aug). verify on `187b264d` (same diff): all ok except the 3 parity steps (= main's failure);
the 2 newer upstream commits touch none of its files. Draft `dist/private/pr-cleanup-body.md`.
- [x] Utku's yes, 23 Sep ~12:15 ("Yes do it") — to BOTH the cleanup and the stress PR.
- [x] rebased onto `5783c499` (no overlap) → `87f03749`, pushed, OPENED **#2417** (23 Sep ~12:25)
**Fix PR 4 prepared (worktree `~/Developer/noop-stress`, branch `stress-rr-once-per-packet`, local only):** the iOS
stress check-in took each R-R packet 1–2× (two sinks, willSet); `RRPacketCursor` (keyed on `rrSeq`) in
`RRPacketObserver.swift`, used by `evaluateStress`. 3 tests; with the cursor broken they fail showing `800, 800, 801,
802, 802…`; restored byte-identical. Draft `dist/private/pr-stress-body.md` (VERIFY_LINE to fill).
- [x] `verify.sh` on `48b772b6` (on `34211e18`): all ok (macOS 2,110, only the two `TodayCarryOverTests`; iOS build) except the 3
  parity steps, identical to `main`'s failure
- [x] Utku's yes (see the cleanup PR above).
- [x] rebased onto `5783c499` (no overlap) → `725c163b`, pushed, OPENED **#2418** (23 Sep ~12:25)
- [x] testing build of ALL FOUR SHIPPED 12:04: `0ca931b` (= `ad1a31d0` + template; `ad1a31d0` = `34211e18` + #2415 +
  #2416 + cleanup + stress), run 35844909325, all jobs green. The tool said FAILED ("no .ipa") because `gh release
  view` lagged at 0 files; the release's own asset list holds all 5 and the .ipa downloads (HTTP 200, 21,619,098 B).
  `ship-build.sh` now reads that list and checks the download. Just update. Utku's build.
- [x] `verify.sh` on both: all ok except the 3 parity steps, whose failure is byte-identical to clean `main`'s
- **#2416: ryanbr CHANGES_REQUESTED (09:59 UTC).** Diagnosis confirmed; parity red on `main` is his to repair. Asks: a
  refused repeat is often a DIFFERENT bpm (the rate moved), so fold it into `peakHr` before returning (skip rescore
  + snapshot); note in the doc that `samples.last` dedupes a repeat, not an out-of-order arrival. We add: the SAVED
  workout's max also comes from `samples` on both platforms, so it must include `peakHr` too.
  - [x] `fb774dd2` on `workout-hr-once-a-second` (no force-push): Swift `recordSample` folds the peak + `savedPeak`;
    Kotlin inline fold + saved peak + peak grown by comparison. New test fails without the fold (120 ≠ 131); verify ok
    except ratchet + governance (= main's, the two tests ryanbr named). Pushed. Android CI 35851894720 GREEN.
  - [x] testing build `6adaf45` SHIPPED 13:25 and verified by the tool (asset list + .ipa HTTP 200): `noop-optimisations`
    @ `7ab1bacb` = `09c583bd` + #2416 (`3f3cfc19`, `fb774dd2`) + cleanup + stress (cherry-picks). Just update. Utku's build.
- [x] Utku's yes (23 Sep, afternoon): "You can reply you can push anything you want" — STANDING permission for replies
  on our PRs and pushes to our branches (recorded in RULES settled decisions).
- [x] #2416 reply POSTED (issuecomment-5794056842)
**Utku's new asks (23 Sep, afternoon):** (1) MetricKit, local only, "if it's not gonna cost any usage or memory — go
for it". (2) BUG: with the strap OFF his wrist the app sometimes still shows a heart rate, and sometimes the app shows
"—" while the Lock Screen / Dynamic Island banner still shows a number — not logical. (3) A small settings section for
everything NOOP streams to the Lock Screen / Dynamic Island, each with its own switch: he does NOT want the live HR
banner all the time (sitting, in bed, on the bus), but DEFINITELY wants the Lift Log session banner. Find what streams
in what conditions, optimise it, let people turn one off and keep another. Each its own PR.
**Fix A (branch `live-hr-off-wrist`, worktree `~/Developer/noop-offwrist`, from `38b56855`):** three faults — the
live HR was never cleared on unreadable samples (0 / out of range / contact not detected) → a run of 3 clears it
(`LiveHeartRateReadability`), WRIST_OFF clears at once; AppModel's median read old values in willSet → sinks pass
the written value, `clearLiveHeartRate` clears R-R before HR; the banner froze on a nil HR → shows the dash. 3 tests,
the order test fails with the old order (restored byte-identical).
- [x] `verify.sh` on `6d2cd162`: all ok (macOS 2,117 with only the two `TodayCarryOverTests`, iOS build) except the 2
  parity tests then red on `main` (repaired since in `44ef71eb`)
- [x] SHIPPED `445fe65` 14:47, verified (asset list + .ipa download): `noop-optimisations` @ `8b8b1392` = `8f064df7` + A + B + C.
  Just update. Utku's build.
**Utku 23 Sep ~16:00 (log `~/Downloads/noop-strap-log-260923-1556.txt`):** the switches work alone and together (log
15:48:26 "no Lift Log banner is running" with the Lift switch off; sync banners 15:50, 15:54). The OFF-WRIST path is
NOT shown by that log: the strap sent 91–104 bpm every second until NOOP closed the link at 15:50:12 ("Disconnected
(intentional)"); no unreadable-run line, no WRIST_OFF. So the fix is not yet hardware-validated. Added `bcdd258e`:
log the skin-contact flag when it changes. He also asked: are these ALL the live notifications (yes — three Live
Activity types, no AlarmKit / Now Playing); switches must only affect showing; shorter wording, "Live notifications".
→ `lockscreen-switches` commit 2 `54e70c3c` (Live notifications, short captions, switch-aware stand-aside): verify ALL
  passed; simulator shows the section; PUSHED to #2419, title + description edited.
- [x] SHIPPED `90394a7` (16:40), verified: `noop-optimisations` @ `27aa0d84` = `3ad25885` + A×2 + B×2 + C. Just update. Utku's build.
- [x] A rebased (`e3e76651` on `3ad25885`), verify ALL passed, OPENED **#2422** — says plainly the off-wrist path is not yet
  observed; ask Utku for a targeted off-wrist test log and edit the description with its answer
- [x] Utku's OFF-WRIST test (log `~/Downloads/noop-strap-log-260923-1700.txt`): the Lock Screen / island FROZE at 93. The
  log: at 16:02:51 the strap sent 0 bpm and the unreadable run cleared it (contact flag "unsupported" on a 5.0); in
  the 16:53–17:00 test it went SILENT instead (last sample 16:54:16, a burst ~16:57, then none; link up, syncs ok).
  Fixed in `b6b290f7` (10-s silence clears; longest normal gap in the log 2 s). He also reported the banners being
  "random" for days: the HR banner was ENDED on every link drop (3 timeouts in that log) and on EVERY sync, incl. the
  15-min background ones that show no sync banner; iOS then refuses a new one until NOOP is opened, and in the
  background every HR tick asked and was refused. Fixed in `83108026` (`LiveHRBannerLifecycle`, 5 tests). Both seen
  to fail with the old behaviour (silence test stays at 93), restored byte-identical.
- [x] verify #2422 @ `83108026` ALL passed; + `8fa291ae` (Today's big number = live HR only: Utku saw 91 with the strap off,
  the last banked 5-min average drawn like a live reading); pushed; title + description edited
- [x] #2419 @ `99abbcb7`: the superseded make-room rule removed; pushed; description edited
- [x] SHIPPED `26fbca0` (17:40), verified: `noop-optimisations` @ `a0ec2641`. Just update. Utku's build.
- [ ] Utku re-tests: strap off (dash within ~10 s everywhere, Today's big number gone), and a day of banners (the HR
  banner should survive link drops and background syncs). Then add the result to #2422's description.
- [x] PR opened as #2422 before the off-wrist log (Utku: "go with the PR"), saying so
**Switches B (branch `lockscreen-switches`, worktree `~/Developer/noop-lockscreen`, `680c2980`):** the Lift Log banner
FOLLOWED the live-HR switch (turning off the HR banner killed the gym banner too); now its own switch
(`UnitPrefs.liftLiveActivityEnabled`, default on) and all three (live HR, Lift Log, strap sync) in a new iOS
"Lock Screen & Dynamic Island" Settings section after Strap; 4 new strings × 9 languages.
- [x] `verify.sh` on `680c2980`: all ok (i18n gate passes the 4 new strings) except the 2 parity tests then red on main
- [x] simulator: section renders; HR switch off + Lift session → gym banner stays (ActivityKit: no end)
- [x] OPENED **#2419** (head `002a1240`)
**MetricKit C (branch `metrickit-daily-report`, worktree `~/Developer/noop-metrickit`):** one strap-log line per iOS
MetricKit report (daily metrics; crash/hang/CPU/disk/launch diagnostics); `MetricKitLine` pure + 4 tests (the
"not printed as zero" test fails when a missing value prints 0).
- [x] `verify.sh` on `6721e3b2`: ALL steps passed (parity green again)
- [x] OPENED **#2420** (head `d81f0cc1`)
- [x] **#2415 MERGED** 10:04 UTC as `f4600d0e` (proven equal to `228a65f0`, 3 files); branch deleted, fork main
  mirrored to `5783c499`.
- [x] pushed both to the fork and OPENED: **#2415** (Live HR banner, head `228a65f0`) and **#2416** (workout HR once a
  second, head `3f3cfc19`), 23 Sep ~11:40. Bodies: `dist/private/pr-*-body.final.md`. Follow them (`WORKFLOW.md` §5).
**Optimisation PR 2 (branch `workout-hr-once-a-second`, worktree `~/Developer/noop-workout`, from `94a71b04`, not
committed yet):** a manual workout recorded >1 HR sample per second with one `ts` on BOTH platforms (iOS: two
`@Published` sinks, `$heartRate` + `$rr`; Android: every LiveState emission), and `StrainScorer` credits a zero gap
with a full second, so Effort (live + saved) was inflated; calories are not (real gaps). Fix: one sample a second —
iOS `ActiveWorkout.recordSample`, Android inline guard in `captureWorkoutSample`. 2 StrandTests.
- [x] 2 tests pass; without the guard both fail (Effort 42.86 vs 35.3 over 20 min, every second twice), restored
  byte-identical (sha256). Committed in the worktree (see `git -C ~/Developer/noop-workout log -1`).
- [x] full `verify.sh` on `b7a6e710` passed: WhoopStore 609 · StrandAnalytics 2044 · StrandImport 327 · lint · i18n ·
  ledger · ratchet · governance 124 · macOS 2,104 (only the two `TodayCarryOverTests`) · iOS build
- [x] pushed to the fork (no PR) @ `b7a6e710`; Android CI 35813899964 GREEN — proof: `gh run list
  --repo UtkuDenizAltiok/noop --workflow "Android CI" --branch workout-hr-once-a-second`
- [x] testing build of both fixes SHIPPED 05:48 and verified: "NOOP Staging — base 11.8.0 · 2026-09-23 · 0f9f85b",
  from `noop-optimisations` @ `8accfd2a`, run 35814622686, `.ipa` + template present. Just update. Utku's build.
Draft PR bodies (private, unapproved): `dist/private/pr-live-hr-banner-body.md`, `pr-workout-samples-body.md`.
Found, not yet fixed: iOS `evaluateStress` gets each R-R packet 1–2× (same two sinks, reading the PREVIOUS packet
in willSet); Android runs it once per offload on `rrRecent`. Also dead code: `BLEManager.uploadTimer` never starts.
Survey so far (23 Sep): upstream already dedupes widgets, the Watch, Android's notification and Today's redraws;
the idle ~10–18% CPU on Today is the deliberate Liquid animation (gated by Low Power / "Reduce motion in NOOP").

Do not redo: the #2099 reply (posted 23 Sep 03:48).

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |
| [#2386](https://github.com/ryanbr/noop/pull/2386) | strap log kept on disk across restarts, within 2 MB (not the Lift Log's) | merged 22 Sep 09:14 UTC, squash `a9717abc` (proven equal to `23bee21a` file by file); branch and worktree removed |
| [#2402](https://github.com/ryanbr/noop/pull/2402) | the standard-HR host-received line summarised, every refusal kept (not the Lift Log's) | merged 23 Sep 02:10 UTC, squash `94a71b04`; ryanbr rebased it onto `3ada90c3` first (head `5c3c06f3`) — proven: same tree, our 9 code files line for line, only the twin map's hashes re-derived; branch and worktree removed |
| [#2403](https://github.com/ryanbr/noop/pull/2403) | **the Lift Log follow-ups** from seven gym sessions, rounds 3–6 | **merged** 23 Sep 01:46 UTC, squash `3ada90c3` (proven equal to `8b05e0bb` over all 55 files); branch deleted |
| [#2415](https://github.com/ryanbr/noop/pull/2415) | iOS Live HR banner pushed only when it changes (NOOP optimisation) | merged 23 Sep 10:04 UTC, squash `f4600d0e` (proven equal to `228a65f0`); branch deleted |
| [#2416](https://github.com/ryanbr/noop/pull/2416) | manual workout: one HR sample a second, both platforms | merged 23 Sep as `d990ef6e` (= `3f3cfc19` + `fb774dd2`, after ryanbr's peak review) |
| [#2417](https://github.com/ryanbr/noop/pull/2417) | cleanup: 707 lines of private code nothing uses | merged 23 Sep 11:16 UTC as `be060c2b` (+ ryanbr's comment follow-up `38b56855`) |
| [#2418](https://github.com/ryanbr/noop/pull/2418) | iOS stress check-in takes each R-R packet once | merged 23 Sep as `8f064df7` |

- **`upstream/main` is `94a71b04`** (#2402), on top of `3ada90c3` (#2403): everything of ours is in it — the Lift
  Log through round 6, the on-disk strap log (#2386) and the summarised standard-HR line (#2402). The fork's `main`
  and the app repo's `main` both sit on it (mirrored 23 Sep). 11.8.0 shipped the Lift Log (Apple only).
- **Open upstream:** ryanbr's #2327 — the Lift Log has no Android UI (`BACKLOG.md` 3). Not ours to answer unasked.
- **Answered:** ryanbr's 15 Sep question on merged #2099 — the reply was posted 23 Sep 03:48 with Utku's yes.

## Open work — none on the Lift Log itself

`#2403` merged on 23 Sep as `3ada90c3` (`upstream/main` builds on it): rounds 3–6 are upstream. The squash was
proven identical to the submitted head over all 55 files, the branch is deleted from the fork and the app repo sits
on `main` again. The next Lift Log change starts a fresh branch from `upstream/main`.

What it carried: one Save and the finish flow (a done set counts as done, discards kept as 0 × 0, fillable in Edit
sets); max RPE per line; the knock guard and the buzz before the sync; the next-set line, the 0:00 rest clock and
typed numbers on the bar; the program taking each line's heaviest set; adding an exercise mid-session; the Lock
Screen light-up, the session and banner surviving an iOS restart, one banner during a session; no work between taps;
the Dynamic Island's layout; the banner's push rate; and stamped strap-log lines (`RULES.md` 5, 27, 28, 34–35,
38–45, 47).

- **Work branches (NOOP optimisation, not the Lift Log), each its own worktree:** `live-hr-banner-pushes` @ `228a65f0`
  (#2415, `~/Developer/noop`), `workout-hr-once-a-second` @ `3f3cfc19` (#2416, `~/Developer/noop-workout`),
  `cleanup-unused-private-code` @ `87f03749` (#2417, `~/Developer/noop-cleanup`), `stress-rr-once-per-packet` @
  `725c163b` (#2418, `~/Developer/noop-stress`); `noop-optimisations` @ `7ab1bacb` (testing build only, never a PR).
  #2415's `live-hr-banner-pushes` is merged and deleted; `~/Developer/noop` is back on `main`.
- **Testing builds:** `8351bc7` (= `94a71b04`, the upstream app) shipped 23 Sep 05:13, verified, just update; then the
  `0f9f85b` (05:48), then `0ca931b` (12:04) from `noop-optimisations` = all four changes on `34211e18` — his current build. Both carry #2386 and #2402, so the
  strap log now keeps a whole session on disk.

## The separate PRs, not the Lift Log's

- **#2386, merged 22 Sep** (squash `a9717abc`): the strap log appended to one file per app run — 256 KB pieces,
  2 MB for all runs, oldest deleted first — instead of the ring of 3 runs × 1,000 lines mirrored every 32 lines.
  Measured over 20,000 lines: 33 ms CPU and 1.6 MB written vs about 370 ms and 93 MB re-saved. Exports read exactly
  as before, so `strap-log.py` is unchanged. ryanbr's review found that lines refused before the first unlock after
  a boot were dropped at a segment boundary; they now wait in memory within the budget and reach disk once storage
  opens (`23bee21a`). Its Kotlin oracle harness is `tools/oracle/strap-log/`.
- **#2402, merged 23 Sep** (squash `94a71b04`): upstream's
  once-a-second `standard-hr transport host-received` line was 52.8% of a session's log and so decided how much
  history #2386's 2 MB holds. A refusal is still written at once; the routine samples become one line a minute
  (count, span, widest gap, accepted / refused / pending); the window closes at a disconnect; full detail returns
  under the Test Centre's HRV or Connection mode. Replayed over the 22 Sep log: 3,938 lines → 67. Both twins,
  7 Swift tests + 4 Kotlin (2 oracle), the twin map re-derived.

Neither is in Utku's testing build `1c34d6cd`; a build from `main` would carry both.

## Verified

- **The tip `8b05e0bb` (the PR's head, rebased onto `751fa1d8`), full `verify.sh`, every step passed:** WhoopStore
  609 · StrandAnalytics 2041 · StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 · macOS tests
  2,102 (only the two `TodayCarryOverTests`) · iOS build. Android CI 35805029680 green. Every commit of the rebase
  range-diff identical to `backup/lift-pre-rebase`; the twin map re-derived as its own commit. #2403's own 19
  upstream checks pass.
- **The tip `0da3998e` (pre-rebase), full `verify.sh`, every step passed:** WhoopStore 609 · StrandAnalytics 2030 ·
  StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 · macOS tests 2,092 (only the two
  `TodayCarryOverTests`) · iOS build. `LiftBannerPushPolicy` 5 tests; breaking the interval or the presence floor
  each fails them. The island's before/after was built into the simulator twice (`WORKFLOW.md` §3).
- **The sixth gym session (22 Sep, 20:10–21:24, build `f7638bf`)**: ONE app run from 19:46 to 21:25 — iOS did not
  close NOOP once, and Utku found no crash report for the day, so rule 43's fix held in the field. 34 double-taps
  handled, 30 light-up alerts sent, 4 skipped with NOOP on screen; tap→buzz 0.26–0.74 s (0.63 s at 20:42, where he
  felt a delay). The log's window began at 20:35 — his build still has the 5,000-line screen buffer; `a9717abc`
  (merged) is what keeps the whole run, and it reaches him in the build after this one.
  A SECOND log he saved at 20:43 covers the rest (19:46:52–20:43:09, same single run): the session's first step was
  20:22:44 and 13 of 13 steps sent their alert, so the app behaved the same before and after 20:42, and nothing else
  happened there (no reconnect, no error — the window holds the ordinary once-a-second stream). That stream is also
  the measurement behind rule 44: 1,380 transport samples between 20:20 and 20:43, a sample a second, which is what
  the banner used to be pushed for every 10 s.
- **The tip `65b804a6` (round 5), full `verify.sh`, every step passed:** WhoopStore 609 · StrandAnalytics 2030 ·
  StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 (clean checkout) · macOS tests 2085 (only
  the two `TodayCarryOverTests`) · iOS build. `e4e391f7` (its controller file split by hand) built for iOS and
  passed its persistence and strap-tap tests on its own. No `android/**` or `Packages/**` change since `7bafa857`,
  so Android CI's green run 35576172501 on `7bafa857` still covers Android.
- **The CPU kills (22 Sep):** the four crash reports are `cpu_resource_fatal` (48 s of CPU in 49–60 s, "exceeding
  limit of 80% cpu over 60 seconds"), NOOP not frontmost in every sample; each report's heaviest stack is SwiftUI's
  view update (SwiftUICore / AttributeGraph; only 3–4 unsymbolicated samples each, so evidence that fits rather
  than proof). 09:17 was on the older build 11.7.0 (390); Utku does not remember whether a session ran — left open.
  Simulator, sheet open, nothing happening, CPU-seconds per minute of NOOP: 9.96 with the tick, 6.59 without, 6.29
  with no session at all. `LiftSessionTimingTests` (4) all failed with the tick put back, and the undo test alone
  failed with the rest timers left uncancelled.
- **Tests seen to fail without their fix (round 5):** five breaks at once — new lines never appended, the set count
  not forced to 1, the added flag not persisted, the resume not logging, the zero plan — each failed its own tests;
  restored byte-identical (sha256). Round 4 and earlier: `NEXT_PR.md`'s PR body.
- **Simulator (iPhone 17 Pro, `281E44EC`):** Add exercise through to the store — "Pec deck" (Chest, Front delts)
  added, 22.5 × 12 done, a second set added then discarded, "Update program": the program gained a last line of
  2 sets, 12 × 22.5 kg, no rest or max RPE; `liftExercise` gained the name and muscles; the weekly card counted
  Chest 1, Front delts 0.5. The program line editor (now on the shared picker) loads its muscles. The bar: heart
  rate over the clock at the right, "Ready for the next set — 9 x 60 kg" whole, clocks "23:15" / "0:59".
- **The restart bug, proven from ActivityKit's log** (`WORKFLOW.md` §3): with the gym build `7bafa857`, `kill -9`
  then relaunch ENDED the surviving banner 2 s after launch (then, on screen, created another); with the fix the
  same banner kept its updates, and the strap log read "session picked up again after NOOP restarted" and
  "Lock Screen banner picked up again". A true background relaunch cannot be made in the simulator; iOS's own
  log line "Requester is foreground" is the gate that refused the gym build's second banner.
- **The 21 Sep strap log** (`strap-log.py … steps`): runs relaunched by iOS in the background at 20:34:58 and
  20:58:46 lit 0 of 3 steps ("no Lift Log banner is running"); the run in which Utku had opened NOOP lit 4 of 4.
  Every tap a sync handed over again matches its live step, except one at 20:47:37 in six minutes the file lost.
  Taps were buzzed 0.46–0.47 s after the strap sensed them. 20:06–20:09 is not in the file (only the last three
  earlier runs are kept — the reason for `strap-log-on-disk`); why iOS closed NOOP is in the crash reports above.

## Confirmed at the gym

Rounds 1–5 confirmed by 21–22 Sep. **Round 6 (23 Sep 02:28–02:53, build `1c34d6cd`, the seventh session):** it
worked; 24 steps, tap→buzz 0.27–0.47 s, no tap refused by any guard. Two taps he felt never reached the app (the
strap console in that file covers only four, so whether the band sensed them cannot be told — probably physical).
Not yet confirmed on his phone: the Dynamic Island's new layout, whether the Lock Screen lights as promptly late in
a session as early, and a deliberate walk-away test (rule 48 — that session had no disconnect at all; the only drop
in the file is at 02:23:22, five minutes BEFORE it started). He saves the log right after a session; the on-disk
log (#2386) is merged upstream but reaches him only in a build made after it lands in `main`.

## Nothing is blocked

#2403 and #2402 are merged; the reply on #2099 is posted. Nothing of ours is open, waiting to be opened, or blocked.

## Next

1. **Follow #2416, #2417, #2418** (`WORKFLOW.md` §5): one reply after each comment, each with Utku's yes; after a
   squash merge prove it equals the head, delete the branch and its worktree (as #2415 on 23 Sep).
2. **Next candidates** (`BACKLOG.md` "NOOP itself"): the second cleanup once #2417 lands; MetricKit (his call).
3. **Upstream's parity gate was red on `main`** from `971d0d9f` until ryanbr's `44ef71eb` re-derived it (23 Sep) (twin-map authority drift). Every branch's
   ledger/ratchet/governance fail the same way; compare with a clean `main` checkout, say so in the PR, never refresh
   the authority ourselves. When `main` is repaired, re-run `verify.sh` on each open branch.
3. **Watch upstream** at every session start (`upstream-check.sh`).
4. **Utku's next gym session:** the walk-away test (rule 48), when he chooses. Island and light-up are confirmed.
   Read his log with `dist/tools/strap-log.py` (`steps` first); check its `runs` report once on the on-disk log.
5. **Hooks (Claude Code) are installed** (22 Sep 08:22:55): SessionStart, UserPromptSubmit, Stop, PreCompact,
   StopFailure. A session starts with the recovery brief; the handbook is checkpointed after every reply. If a new
   Claude Code session shows no brief, tell Utku rather than touching Claude's settings (its guard forbids it).
6. At the end of every session: README "End a session".

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `94a71b04`), `lift-log-build`, `lift-log-handbook`,
  `workout-hr-once-a-second` (next PR), `noop-optimisations` (testing build only). Deleted once
  merged and proven: `lift-log-follow-ups` (#2403) and `hr-transport-summary` (#2402) on 23 Sep,
  `strap-log-on-disk` (#2386) and the three stacked branches on 22 Sep.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags. No `backup/*` tags remain.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- The repo's description and website field point newcomers to this handbook (22 Sep).
- CI caches: about 3 GB on `main`, shared by every build; GitHub expires unused ones after a week.
- Local only: worktrees `~/Developer/noop` (`live-hr-banner-pushes`), `~/Developer/noop-workout`
  (`workout-hr-once-a-second`) and `~/Developer/noop/dist` (this handbook);
  `dist/private/` (the event log, and drafts). The retired-refs bundle of 15 Sep went to
  the Trash on 22 Sep: everything unique in it was superseded (the handbook's predecessor, an old stash, pre-rebase
  snapshots of merged work).
