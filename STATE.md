# State

**Updated 23 Sep 2026, 04:45 — #2403 IS MERGED. The Lift Log's seven-session follow-up is upstream.** The only file that
changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

Nothing in flight (23 Sep 04:50, end of session). #2403 merged; the reply on #2099 posted; #2402 open and green.
Utku's build is `1c34d6cd`; the next gym session has three things to look at (`## Confirmed at the gym`).

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |
| [#2386](https://github.com/ryanbr/noop/pull/2386) | strap log kept on disk across restarts, within 2 MB (not the Lift Log's) | merged 22 Sep 09:14 UTC, squash `a9717abc` (proven equal to `23bee21a` file by file); branch and worktree removed |
| [#2402](https://github.com/ryanbr/noop/pull/2402) | the standard-HR host-received line summarised, every refusal kept (not the Lift Log's; branch `hr-transport-summary`) | **open** since 23 Sep 00:40, head `5ce691ac`, rebased onto `751fa1d8`; all 19 checks green |
| [#2403](https://github.com/ryanbr/noop/pull/2403) | **the Lift Log follow-ups** from seven gym sessions, rounds 3–6 | **merged** 23 Sep 01:46 UTC, squash `3ada90c3` (proven equal to `8b05e0bb` over all 55 files); branch deleted |

- **`upstream/main` is `3ada90c3`** — our own merge (22 Sep evening; our merged `a9717abc` is in it, plus Android diagnostics, an
  Android chart fix, a macOS frame-loop fix and a design hex-parse fix — none touching Lift Log files).
  `lift-log-follow-ups` sits on `a56840bb` and merges cleanly; rebase before the PR. 11.8.0 shipped the Lift Log
  (Apple only). The fork's `main` mirrors upstream as of `29d90eb6` — re-mirror at the next sync.
- **Open upstream:** ryanbr's #2327 — the Lift Log has no Android UI (`BACKLOG.md` 3). Not ours to answer unasked.
- **Unanswered (optional):** ryanbr's last comment on merged #2099 (15 Sep 04:07) asks whether we would rather
  keep performed sets with their timing — round 4 did exactly that. A 3-sentence reply is drafted in `NEXT_PR.md`,
  to post right after the new PR opens, only with Utku's yes.

## Open work — none on the Lift Log itself

`#2403` merged on 23 Sep as `3ada90c3`, which is now `upstream/main`: rounds 3–6 are upstream. The squash was
proven identical to the submitted head over all 55 files, the branch is deleted from the fork and the app repo sits
on `main` again. The next Lift Log change starts a fresh branch from `upstream/main`.

What it carried: one Save and the finish flow (a done set counts as done, discards kept as 0 × 0, fillable in Edit
sets); max RPE per line; the knock guard and the buzz before the sync; the next-set line, the 0:00 rest clock and
typed numbers on the bar; the program taking each line's heaviest set; adding an exercise mid-session; the Lock
Screen light-up, the session and banner surviving an iOS restart, one banner during a session; no work between taps;
the Dynamic Island's layout; the banner's push rate; and stamped strap-log lines (`RULES.md` 5, 27, 28, 34–35,
38–45, 47).

- **Work branch:** none — `~/Developer/noop` is on `main` @ `3ada90c3`.
- **Testing build on Utku's phone:** `1c34d6cd`, NOOP 11.8.0, shipped 22 Sep ~23:45 and verified; gym-tested 23 Sep.
  Just update, no wipe. Built from `0da3998e`, whose content is what merged.

## The separate PRs, not the Lift Log's

- **#2386, merged 22 Sep** (squash `a9717abc`): the strap log appended to one file per app run — 256 KB pieces,
  2 MB for all runs, oldest deleted first — instead of the ring of 3 runs × 1,000 lines mirrored every 32 lines.
  Measured over 20,000 lines: 33 ms CPU and 1.6 MB written vs about 370 ms and 93 MB re-saved. Exports read exactly
  as before, so `strap-log.py` is unchanged. ryanbr's review found that lines refused before the first unlock after
  a boot were dropped at a segment boundary; they now wait in memory within the budget and reach disk once storage
  opens (`23bee21a`). Its Kotlin oracle harness is `tools/oracle/strap-log/`.
- **#2402, open and green** (`hr-transport-summary` @ `5ce691ac`, worktree `~/Developer/noop-hrlog`): upstream's
  once-a-second `standard-hr transport host-received` line was 52.8% of a session's log and so decided how much
  history #2386's 2 MB holds. A refusal is still written at once; the routine samples become one line a minute
  (count, span, widest gap, accepted / refused / pending); the window closes at a disconnect; full detail returns
  under the Test Centre's HRV or Connection mode. Replayed over the 22 Sep log: 3,938 lines → 67. Both twins,
  7 Swift tests + 4 Kotlin (2 oracle), the twin map re-derived.

Neither is in Utku's testing build: it holds the Lift Log branch plus the template commit.

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

#2403 is merged. #2402 (diagnostics) is open, green, and waits on the maintainers. The reply on #2099 was posted on
23 Sep with Utku's yes. Nothing is waiting to be opened, and nothing is blocked.

## Next

1. **Follow #2402** (the only open PR): read each comment, reply once after it (`WORKFLOW.md` §5). After a squash
   merge, prove the squash equals the head file by file, delete the branch from the fork and remove
   `~/Developer/noop-hrlog`. (#2403 was handled this way on 23 Sep.)
2. **Utku's next gym session on build `1c34d6cd`.** Check the Dynamic Island, the light-up timing late in a
   session, and the walk-away test (rule 48). Read his log with `dist/tools/strap-log.py` (`steps` first).
3. **Fix whatever it finds**, verify, ship (`bash dist/tools/ship-build.sh`), give him the release link and the
   build id, and say "just update" or "wipe".
4. **Only with his yes:** the reply on #2099 (`NEXT_PR.md`).
5. **Hooks (Claude Code) are installed** (22 Sep 08:22:55): SessionStart, UserPromptSubmit, Stop, PreCompact,
   StopFailure. A session starts with the recovery brief; the handbook is checkpointed after every reply. If a new
   Claude Code session shows no brief, tell Utku rather than touching Claude's settings (its guard forbids it).
6. At the end of every session: README "End a session".

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `3ada90c3`), `hr-transport-summary` (#2402), `lift-log-build`,
  `lift-log-handbook`. `lift-log-follow-ups` was deleted when #2403 merged. The stacked branches were deleted
  on 22 Sep (all contained in `lift-log-follow-ups`), and `strap-log-on-disk` once #2386 merged.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags. No `backup/*` tags remain.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- The repo's description and website field point newcomers to this handbook (22 Sep).
- CI caches: about 3 GB on `main`, shared by every build; GitHub expires unused ones after a week.
- Local only: worktrees `~/Developer/noop` (`lift-log-follow-ups`) and `~/Developer/noop/dist` (this handbook);
  `dist/private/` (the event log, and drafts). The retired-refs bundle of 15 Sep went to
  the Trash on 22 Sep: everything unique in it was superseded (the handbook's predecessor, an old stash, pre-rebase
  snapshots of merged work).
