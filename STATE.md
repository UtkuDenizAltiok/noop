# State

**Updated 22 Sep 2026, 23:10 (#2386 merged; the sixth session's island and light-up fixes shipped as `a01bf3fd`).** The only file that
changes every session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

Nothing in flight (22 Sep 23:10). The sixth session's two findings are fixed, verified and shipped as `a01bf3fd`;
waiting on Utku's seventh session and then his yes for the follow-up PR.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |
| [#2386](https://github.com/ryanbr/noop/pull/2386) | strap log kept on disk across restarts, within 2 MB (not the Lift Log's) | merged 22 Sep 09:14 UTC, squash `a9717abc` (proven equal to `23bee21a` file by file); branch and worktree removed |

- **`upstream/main` is `039dd939`** (22 Sep evening; our merged `a9717abc` is in it, plus Android diagnostics, an
  Android chart fix, a macOS frame-loop fix and a design hex-parse fix — none touching Lift Log files).
  `lift-log-follow-ups` sits on `a56840bb` and merges cleanly; rebase before the PR. 11.8.0 shipped the Lift Log
  (Apple only). The fork's `main` mirrors upstream as of `29d90eb6` — re-mirror at the next sync.
- **Open upstream:** ryanbr's #2327 — the Lift Log has no Android UI (`BACKLOG.md` 3). Not ours to answer unasked.
- **Unanswered (optional):** ryanbr's last comment on merged #2099 (15 Sep 04:07) asks whether we would rather
  keep performed sets with their timing — round 4 did exactly that. A 3-sentence reply is drafted in `NEXT_PR.md`,
  to post right after the new PR opens, only with Utku's yes.

## Open work — one branch, ONE PR

`lift-log-follow-ups` @ `65b804a6`, on `a56840bb` (one commit behind `upstream/main`; merges cleanly), to be opened as
ONE PR (`NEXT_PR.md`; the reason is at its top). One commit per concern, in three parts that were stacked
branches until 22 Sep:

1. up to `631f411f` — one Save; discards as 0 × 0 fillable in Edit sets; add / remove sets in Edit sets; SQL
   mirrors `reps != 0`; Kotlin twins of `LiftMetrics` and `deleteLiftSets`; and the parity refresh commit
   (`631f411f`: functions +4, function_pairs +2, file_pairs +1, unpaired_files −2).
2. up to `0c9c72e9` — max RPE per program line (`RULES.md` 34).
3. up to `e8dcd181` — rounds 3 to 6: one-tap field focus; knock guard (now 5 s) and buzz before the sync;
   next-set line, 0:00 rest clock, typed numbers on the bar; done sets complete without asking; the program takes
   each line's heaviest set; the Lock Screen lights whenever NOOP is off screen and logs each step; no sync banner
   during a session; banner layout (`RULES.md` 5, 27, 28, 35–40). Round 5 (21–22 Sep): the session is resumed as
   NOOP starts and the banner kept across iOS restarts (`e4e391f7`, rule 41); the bar laid out like the banner
   (`03919c22`); adding an exercise during a session (`c7d38cee`, rule 42); running clocks via
   `ActiveWorkoutClock.clock` (`69a3cb0d`, rule 38); a running session does no work between taps (`65b804a6`,
   rule 43) — the cause of iOS's four CPU kills on 21 Sep. Round 6 (22 Sep night): the Dynamic Island carries the
   heart rate and keeps its clock to the edge (`ee3b6201`, rule 45); the banner is pushed for a heart rate only
   every 30 s and ≥ 2 bpm, and the app builds nothing per tick (`e8dcd181`, rule 44).

- **Work branch:** `lift-log-follow-ups` @ `e8dcd181` (checked out in `~/Developer/noop`).
- **Testing build on Utku's phone:** `a01bf3fd` = `e8dcd181` + the template commit, NOOP 11.8.0, shipped 22 Sep
  ~23:05 and verified (target commit, `.ipa`, template). Just update, no wipe. Not yet gym-tested; `f7638bf` was,
  on 22 Sep (the sixth session).

## A separate PR, not the Lift Log's: #2386 (`strap-log-on-disk`)

Utku asked for it on 22 Sep (the saved log missed his window) and said yes to opening it, on condition that it is
lean, cheap on battery and removes nothing he wants. Opened 22 Sep 08:10 as
[#2386](https://github.com/ryanbr/noop/pull/2386), four commits on `a56840bb`: `2bfef51e` the change, `8b2edc62`
drops an unused `clear()`, `300b6c27` removes four Swift 6 warnings the branch had added, `23bee21a` answers
ryanbr's review (lines refused before the first unlock after a boot wait in memory and reach disk once storage
opens). ryanbr is approving. The strap log is
appended to one file per app run (256 KB pieces, 2 MB for all runs, oldest deleted first) instead of the
UserDefaults / SharedPreferences ring of 3 runs × 1,000 lines mirrored every 32 lines. Measured over 20,000 lines:
33 ms CPU and 1.6 MB written vs about 370 ms and 93 MB re-saved. Exports read exactly as before, so `strap-log.py`
is unchanged. Its text is on GitHub; its Kotlin test's oracle harness is `tools/oracle/strap-log/`.
Worktree `~/Developer/noop-strap-log`. A comment gets one reply after it; our own later changes go into a
description edit (`WORKFLOW.md` §5). Not in Utku's testing build (it holds the Lift Log branch only).

## Verified

- **The tip `e8dcd181`, full `verify.sh`, every step passed:** WhoopStore 609 · StrandAnalytics 2030 ·
  StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 · macOS tests 2,090 (only the two
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

Everything up to round 3 (Utku, 21 Sep). From round 4, on 21 Sep evening: the light-up works while NOOP runs
("perfectly working until some time"); the rest of round 4 was not reported on. Round 5 waits on the next session.
Ask him then about each item on `NEXT_PR.md`'s checklist, and whether the strap log's `runs` report shows any
background restart. Until `strap-log-on-disk` is in his build, he saves the log right after a session, and midway
through one longer than about 45 minutes (the screen's buffer holds about 50).

## Nothing is blocked

The Lift Log PR is written (`NEXT_PR.md`, plain words, round 5 and the CPU fix included) and waits on one gym session
on this build and his yes. #2386 waits on the maintainers.

## Next

1. **Utku's next gym session on build `f7638bf`.** The checklist is at the top of `NEXT_PR.md`. Read his log with
   `dist/tools/strap-log.py` (the `steps` report first).
2. **Fix whatever it finds**, verify, ship (`bash dist/tools/ship-build.sh`), give him the release link and the build
   id, and say "just update" or "wipe".
3. **Only with his yes:** `NEXT_PR.md` "Before opening" — rebase onto `upstream/main` (`039dd939`; it moved four
   commits, none in Lift Log files), refresh parity, verify, Android CI, open the ONE PR from
   `lift-log-follow-ups`, post the reply on #2099.
4. (Done 22 Sep: #2386 merged, proven, cleaned up.)
5. **Hooks (Claude Code) are installed** (Utku, 22 Sep 08:22:55): SessionStart, UserPromptSubmit, Stop, PreCompact,
   StopFailure. A session starts with the recovery brief; the handbook is checkpointed after every reply. If a new
   Claude Code session shows no brief, tell Utku rather than touching Claude's settings (its guard forbids it).
6. At the end of every session: README "End a session".

## The fork, exactly

- Branches: `main` (mirror of `upstream/main` as of `29d90eb6`), `lift-log-follow-ups`, `lift-log-build`,
  `lift-log-handbook`. The stacked `lift-log-discard-and-edit`, `lift-log-target-rpe` and `lift-log-gym-round-3`
  were deleted on 22 Sep (all contained in `lift-log-follow-ups`), and `strap-log-on-disk` once #2386 merged.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags. No `backup/*` tags remain.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- The repo's description and website field point newcomers to this handbook (22 Sep).
- CI caches: about 3 GB on `main`, shared by every build; GitHub expires unused ones after a week.
- Local only: worktrees `~/Developer/noop` (`lift-log-follow-ups`) and `~/Developer/noop/dist` (this handbook);
  `dist/private/` (the event log, and drafts). The retired-refs bundle of 15 Sep went to
  the Trash on 22 Sep: everything unique in it was superseded (the handbook's predecessor, an old stash, pre-rebase
  snapshots of merged work).
