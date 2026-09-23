# State

**Updated 23 Sep 2026, 12:00 — NOOP optimisation: #2415 and #2416 OPEN upstream; a cleanup PR and a stress fix prepared, waiting for Utku's yes.** The only file that
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
- [ ] Utku's yes to open it (he approved #2415/#2416 only)
**Fix PR 4 prepared (worktree `~/Developer/noop-stress`, branch `stress-rr-once-per-packet`, local only):** the iOS
stress check-in took each R-R packet 1–2× (two sinks, willSet); `RRPacketCursor` (keyed on `rrSeq`) in
`RRPacketObserver.swift`, used by `evaluateStress`. 3 tests; with the cursor broken they fail showing `800, 800, 801,
802, 802…`; restored byte-identical. Draft `dist/private/pr-stress-body.md` (VERIFY_LINE to fill).
- [x] `verify.sh` on `48b772b6` (on `34211e18`): all ok (macOS 2,110, only the two `TodayCarryOverTests`; iOS build) except the 3
  parity steps, identical to `main`'s failure
- [ ] Utku's yes to open it
- [x] testing build of ALL FOUR SHIPPED 12:04: `0ca931b` (= `ad1a31d0` + template; `ad1a31d0` = `34211e18` + #2415 +
  #2416 + cleanup + stress), run 35844909325, all jobs green. The tool said FAILED ("no .ipa") because `gh release
  view` lagged at 0 files; the release's own asset list holds all 5 and the .ipa downloads (HTTP 200, 21,619,098 B).
  `ship-build.sh` now reads that list and checks the download. Just update. Utku's build.
- [x] `verify.sh` on both: all ok except the 3 parity steps, whose failure is byte-identical to clean `main`'s
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
  `cleanup-unused-private-code` @ `a8bc8d35` (`~/Developer/noop-cleanup`, local), `stress-rr-once-per-packet` @
  `48b772b6` (`~/Developer/noop-stress`, local); `noop-optimisations` @ `ad1a31d0` = all four on `34211e18`, for
  Utku's testing build only (never a PR).
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

1. **Follow #2415 and #2416** (`WORKFLOW.md` §5): one reply after each comment; after a squash merge prove it equals
   the head, delete the branch and its worktree.
2. **With Utku's yes, open the cleanup PR and the stress PR** (drafts `dist/private/pr-cleanup-body.md`,
   `pr-stress-body.md`; strip the `Title:` line): push the branch to the fork, `gh pr create --repo ryanbr/noop`,
   record the number in "Now". Rebase first if `main` moved, and check the new commits touch none of their files.
3. **Upstream's parity gate is red on `main` itself** since `971d0d9f` (twin-map authority drift). Every branch's
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
