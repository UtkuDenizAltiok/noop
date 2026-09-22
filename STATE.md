# State

**Updated 22 Sep 2026, 08:25 (strap-log PR #2386 opened; continuity tools in place).** The only file that changes every session. Replace, don't append — history goes in
`HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

Nothing in flight (22 Sep 08:25). Waiting on Utku: `install-hooks` or `remove-hooks` (Next, 4), and his next gym
session on build `f7638bf`.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |
| [#2386](https://github.com/ryanbr/noop/pull/2386) | strap log kept on disk across restarts, within 2 MB (not the Lift Log's; branch `strap-log-on-disk`) | **open** since 22 Sep 08:10, head `300b6c27`; all five checks green (both app builds, Android, doc lint, i18n) |

- **`upstream/main` is `a56840bb`** (21 Sep). 11.8.0 shipped the Lift Log (Apple only). The fork's `main` mirrors it.
- **Open upstream:** ryanbr's #2327 — the Lift Log has no Android UI (`BACKLOG.md` 4). Not ours to answer unasked.
- **Unanswered (optional):** ryanbr's last comment on merged #2099 (15 Sep 04:07) asks whether we would rather
  keep performed sets with their timing — round 4 did exactly that. A 3-sentence reply is drafted in `NEXT_PR.md`,
  to post right after the new PR opens, only with Utku's yes.

## Open work — one stack, ONE PR

Three stacked branches, rebased on `a56840bb` 21 Sep (every commit range-diff identical), to be opened as ONE PR
from a new branch `lift-log-follow-ups` at the tip (`NEXT_PR.md`; the reason is at its top):

1. `lift-log-discard-and-edit` @ `631f411f` — one Save; discards as 0 × 0 fillable in Edit sets; add / remove
   sets in Edit sets; SQL mirrors `reps != 0`; Kotlin twins of `LiftMetrics` and `deleteLiftSets`; and the
   parity refresh commit (`631f411f`: functions +4, function_pairs +2, file_pairs +1, unpaired_files −2).
2. `lift-log-target-rpe` @ `0c9c72e9` — max RPE per program line (`RULES.md` 34).
3. `lift-log-gym-round-3` @ `65b804a6` — rounds 3, 4 and 5: one-tap field focus; knock guard (now 5 s) and buzz
   before the sync; next-set line, 0:00 rest clock, typed numbers on the bar; done sets complete without asking;
   the program takes each line's heaviest set; the Lock Screen lights whenever NOOP is off screen and logs each
   step; no sync banner during a session; banner layout (`RULES.md` 5, 27, 28, 35–40). Round 5 (21 Sep night,
   four commits on `7bafa857`): the session is resumed as NOOP starts and the banner kept across iOS restarts
   (`e4e391f7`, rule 41); the bar laid out like the banner (`03919c22`); adding an exercise during a session
   (`c7d38cee`, rule 42); running clocks via `ActiveWorkoutClock.clock` (`69a3cb0d`, rule 38); and, 22 Sep, a
   running session does no work between taps (`65b804a6`, rule 43) — the cause of iOS's four CPU kills on 21 Sep.

- **Work branch:** `lift-log-gym-round-3`
- **Testing build on Utku's phone:** `f7638bfe` = `65b804a6` + the template commit, NOOP 11.8.0. Releases page:
  "NOOP Staging — base 11.8.0 · 2026-09-21 · f7638bf" (Pre-release), `.ipa` uploaded 22:46 UTC on 21 Sep, verified
  (target commit, `.ipa`, template). Just update, no wipe (the snapshot's new field is optional). Not yet
  gym-tested. (`3cfd3d0`, the build before it, lacked `65b804a6`.)

## A separate PR, not the Lift Log's: #2386 (`strap-log-on-disk`)

Utku asked for it on 22 Sep (the saved log missed his window) and said yes to opening it, on condition that it is
lean, cheap on battery and removes nothing he wants. Opened 22 Sep 08:10 as
[#2386](https://github.com/ryanbr/noop/pull/2386), three commits on `a56840bb`: `2bfef51e` the change, `8b2edc62`
drops an unused `clear()`, `300b6c27` removes four Swift 6 warnings the branch had added. The strap log is
appended to one file per app run (256 KB pieces, 2 MB for all runs, oldest deleted first) instead of the
UserDefaults / SharedPreferences ring of 3 runs × 1,000 lines mirrored every 32 lines. Measured over 20,000 lines:
33 ms CPU and 1.6 MB written vs about 370 ms and 93 MB re-saved. Exports read exactly as before, so `strap-log.py`
is unchanged. The PR body is `NEXT_PR.md`'s last section; its oracle harness is `tools/oracle/strap-log/`.
Worktree `~/Developer/noop-strap-log`. A comment gets one reply after it; our own later changes go into a
description edit (`WORKFLOW.md` §5). Not in Utku's testing build (it holds the Lift Log branch only).

## Verified

- **The tip `65b804a6`, full `verify.sh`, every step passed:** WhoopStore 609 · StrandAnalytics 2030 ·
  StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 (clean checkout) · macOS tests 2085 (only
  the two `TodayCarryOverTests`) · iOS build. `e4e391f7` (its controller file split by hand) built for iOS and
  passed its persistence and strap-tap tests on its own. No `android/**` or `Packages/**` change since `7bafa857`,
  so Android CI's green run 35576172501 on `7bafa857` still covers Android.
- **The CPU kills (22 Sep):** the four crash reports are `cpu_resource_fatal` (48 s of CPU in 49–60 s, "exceeding
  limit of 80% cpu over 60 seconds"), NOOP not frontmost in every sample; each report's heaviest stack is SwiftUI's
  view update (SwiftUICore / AttributeGraph; only 3–4 unsymbolicated samples each, so evidence that fits rather
  than proof). 09:17 was on the older build 11.7.0 (390), maybe not in a session (ask Utku).
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

The PR is written (`NEXT_PR.md`, plain words, round 5 and the CPU fix included) and waits on one gym session on
this build and his yes. The strap-log PR waits only on his yes.

## Next

1. **Utku's next gym session on this build.** The checklist is at the top of `NEXT_PR.md`. Read his log with
   `dist/tools/strap-log.py` (the `steps` report first).
2. **Fix whatever it finds**, verify, ship (`bash dist/tools/ship-build.sh lift-log-gym-round-3`), give him the
   release link and the build id, and say "just update" or "wipe".
3. **Only with his yes:** `NEXT_PR.md` "Before opening" — rebase if `main` moved, refresh parity, verify, create
   `lift-log-follow-ups`, Android CI, open the ONE PR, post the reply on #2099; then, with his yes, delete the
   three stacked branches from the fork.
4. **Utku:** `bash ~/Developer/noop/dist/tools/checkpoint.sh install-hooks` (or `remove-hooks`). Until one runs,
   the app repo's `.claude/settings.local.json` holds a one-off PROBE hook written before Claude Code's auto-mode
   guard stopped the agent touching Claude's settings: PostToolUse on Bash, appending a line to the 22 Sep session's
   scratchpad. It loads at the next session start and fails harmlessly once that scratchpad is gone. Either
   command replaces or removes it; the agent may not.
5. **#2386:** follow its checks and comments; after a squash merge, prove the squash equals the head, then delete the
   branch from the fork and remove `~/Developer/noop-strap-log`.
6. Keep this file true and run `bash dist/tools/backup.sh "what changed"` before the session ends.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `a56840bb`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-gym-round-3`, `lift-log-build`, `lift-log-handbook`, `strap-log-on-disk`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags. No `backup/*` tags remain.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- Retired refs removed 15 Sep sit in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle` on Utku's Mac,
  LOCAL ONLY — nothing in it is needed (its content is merged upstream or the maintainers' old prototypes).
