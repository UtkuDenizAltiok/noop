# State

**Updated 24 Sep 2026 ~04:35 — #2422 REWORKED to Utku's decision: the Live HR banner is never closed by NOOP; it shows
"–" and comes back by itself; only its switch removes it. Pushed (`cf97a93c`, 11 commits) and shipped as build
`412d1a6` (just update). OPEN: #2419, #2420, #2422. Read `LIVE_HR.md` first.** The only file that changes every
session. Replace, don't append — history goes in `HISTORY.md`.

## Now — work in flight

The write-ahead journal (`WORKFLOW.md` §2): each step that is long, public or hard to undo is written here BEFORE
it starts and ticked when it ends. After any interruption, check every unticked line against
`bash dist/tools/checkpoint.sh status --net` before redoing it. Empty when nothing is in flight.

Nothing is running (24 Sep ~04:35). Waiting on others:
- [ ] **Utku tests build `412d1a6`** (`LIVE_HR.md` §6.1: strap off in the pocket → "–" within seconds, back on → the
  number; walk away until the link drops and come back → kept as "–", then the number; swipe NOOP away and wait →
  "–", then fed again when NOOP runs) and sends the strap log. Proof: his message + log. Read it with
  `python3 dist/tools/hr-timeline.py <log>` — the new "Live HR banner: …" and "Strap: WRIST_…" lines answer each case —
  and add the result to #2422's description (an edit, not a comment).
- [ ] **#2422's upstream checks on `cf97a93c`**: `check` and `doc-comments` passed; the two app builds were still
  pending at 04:36. Check `gh pr checks 2422 --repo ryanbr/noop`; a red one is ours to fix.

**Next safe action:** session start routine; then the two lines above. Nothing else is owed.
Standing permission (RULES settled decisions): replies on our PRs and pushes to our branches need no per-item yes.
Do not redo: the #2422 rework push and description edit (24 Sep ~04:12), ship `412d1a6` (run 35946344321), the #2099
reply (23 Sep 03:48), the #2416 reply (23 Sep ~13:35), any PR already open.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the Lift Log app | merged 15 Sep, `4453a089` |
| [#2232](https://github.com/ryanbr/noop/pull/2232) / [#2233](https://github.com/ryanbr/noop/pull/2233) | Kotlin `LiftMetrics` twin; parity repair (by the maintainers) | merged 15 Sep |
| [#2386](https://github.com/ryanbr/noop/pull/2386) | strap log kept on disk within 2 MB | merged 22 Sep, `a9717abc` |
| [#2402](https://github.com/ryanbr/noop/pull/2402) | standard-HR host-received line summarised | merged 23 Sep, `94a71b04` |
| [#2403](https://github.com/ryanbr/noop/pull/2403) | Lift Log follow-ups, rounds 3–6 | merged 23 Sep, `3ada90c3` |
| [#2415](https://github.com/ryanbr/noop/pull/2415) | iOS Live HR banner pushed only when it changes | merged 23 Sep, `f4600d0e` |
| [#2416](https://github.com/ryanbr/noop/pull/2416) | manual workout: one HR sample a second, peak kept (both platforms) | merged 23 Sep, `d990ef6e` |
| [#2417](https://github.com/ryanbr/noop/pull/2417) | cleanup: 707 lines of unused private code | merged 23 Sep, `be060c2b` (+ ryanbr's `38b56855`) |
| [#2418](https://github.com/ryanbr/noop/pull/2418) | iOS stress check-in takes each R-R packet once | merged 23 Sep, `8f064df7` |
| [#2419](https://github.com/ryanbr/noop/pull/2419) | Settings → **Live notifications**: one switch each (HR, Lift Log, sync); the Lift Log banner no longer follows the HR switch | **open**, head `99abbcb7`, 5/5 checks green, no comments |
| [#2420](https://github.com/ryanbr/noop/pull/2420) | iOS MetricKit reports → one strap-log line each (local only) | **open**, head `d81f0cc1`, green, no comments |
| [#2422](https://github.com/ryanbr/noop/pull/2422) | live HR shown only while the strap measures it; the banner kept until its switch turns it off (11 commits — `LIVE_HR.md` §4) | **open**, head `cf97a93c` (reworked 24 Sep), no comments; app-build checks pending at 04:36; hardware check pending |

- **`upstream/main` is `06083a0b`** (24 Sep: #2426 HRV of a refused main night, #2427 an HRV log line, a Today label
  fix — none touches a file of ours). All three open branches merge cleanly into it (checked 24 Sep ~04:35). The fork's
  `main` and the app repo's `main` mirror it.
- ryanbr repaired the parity gate on `main` (`44ef71eb`, 23 Sep), and it has drifted again: the fork's mirror push of
  `f15360da` (24 Sep 01:15 UTC, run 35942122664) FAILED Parity Governance on the same two tests
  (`test_checked_metadata_is_compact_v3_and_expands_losslessly`, `…inventory_and_baseline…`); upstream's own last run
  was green on the older `9d85ea8b`, and its scheduled run will show it. Upstream's, not ours — none of our branches
  touch the parity files. After a rebase onto it our `verify.sh` will fail those steps too: compare with a clean
  `main` checkout, say so in the PR, never refresh the authority ourselves (`WORKFLOW.md` §4, §7).
- **Open upstream, not ours to answer unasked:** #2327 (the Lift Log has no Android UI; `BACKLOG.md` 3).

## Open work

**1. The Live HR banner — `LIVE_HR.md`.** Reworked to Utku's 24 Sep decision (rule 49): never closed by NOOP, "–"
when nothing is measured, only its switch removes it. What remains is his test of `412d1a6` and, from its log, the
push-rate question (`LIVE_HR.md` §6.2).

**2. Follow #2419, #2420, #2422** (`WORKFLOW.md` §5): one reply after each review comment; after a squash merge prove
it equals the head, delete the branch and its worktree, re-mirror `main`, rebuild `noop-optimisations`.

**3. NOOP optimisation candidates** (`BACKLOG.md` "NOOP itself"): a second cleanup of internal code nothing calls;
Android #2270 needs a device.

**The Lift Log itself:** no open work; rounds 1–6 are upstream. The walk-away test (rule 48) is still Utku's to do.

- **Work branches (NOOP, not the Lift Log), each its own worktree, all clean and pushed:** `live-hr-off-wrist` @
  `cf97a93c` (#2422, `~/Developer/noop-offwrist`), `lockscreen-switches` @ `99abbcb7` (#2419, `~/Developer/noop-lockscreen`),
  `metrickit-daily-report` @ `d81f0cc1` (#2420, `~/Developer/noop-metrickit`). `~/Developer/noop` is on `main`.
- **`noop-optimisations` @ `21d514a3`** — the testing-build stack, never a PR: `upstream/main` `06083a0b` + #2422's
  11 commits (cherry-picked `3ad25885..live-hr-off-wrist`) + #2419's NET diff (`git diff $(git merge-base upstream/main
  lockscreen-switches) lockscreen-switches`; cherry-picked one by one its middle commit conflicts) + #2420. Check the
  stack's `git diff --stat upstream/main` lists only our files before shipping, and build it for iOS locally: a failed
  CI build leaves the release EMPTY (`WORKFLOW.md` §6).
- **Utku's build:** `412d1a6` (shipped 24 Sep 04:31, verified; just update) = that stack + the template commit.

## Verified

- **#2422 reworked (24 Sep):** full `verify.sh` on `5e579ac3` (the pushed head `cf97a93c` but for three comment lines),
  every step passed: WhoopStore 611 · StrandAnalytics 2049 · StrandImport 327 · doc lint · i18n · ledger · ratchet ·
  governance 124 · macOS tests 2,134 (only the two `TodayCarryOverTests`) · iOS build. Each of the new commits 7–10
  built alone (iOS app, macOS tests). Seen to fail, restored byte-identical: number↔dash made to wait (6 failures),
  renewal removed (3), wrist line removed (both wrist tests), the old link-down end put back (2 + 1). The build stack
  `21d514a3` built for iOS locally before shipping.
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

Three PRs wait on the maintainers; one hardware test (build `412d1a6`) waits on Utku. Nothing else is in flight.

## Next

1. **Session start** (README): status `--net`, `upstream-check.sh`, then the open lines in "Now".
2. **Utku's log of `412d1a6`** → `hr-timeline.py` → #2422's description; then `LIVE_HR.md` §6.2 (push rate) if the
   phone's stale timing allows.
3. **Follow the three open PRs**; rebuild `noop-optimisations` and ship after any merge or change.
4. **Hooks (Claude Code) are installed** (22 Sep): a session starts with the recovery brief; the handbook is
   checkpointed after every reply. If a new session shows no brief, tell Utku rather than touching Claude's settings.
5. At the end of every session: README "End a session".

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `06083a0b`), `lift-log-build` (the build branch, `412d1a6e`),
  `lift-log-handbook`, `live-hr-off-wrist` (#2422), `lockscreen-switches` (#2419), `metrickit-daily-report` (#2420),
  `noop-optimisations` (testing stack). Every merged PR's branch was deleted once its squash was proven equal.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags. No `backup/*` tags remain.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- Local only: worktrees `~/Developer/noop` (`main`), `~/Developer/noop-offwrist`, `~/Developer/noop-lockscreen`,
  `~/Developer/noop-metrickit`, `~/Developer/noop/dist` (this handbook); `dist/private/` (the event log, PR drafts
  `pr-*-body.md`; `pr-2422-body.md` is #2422's description as posted 24 Sep). Utku's strap log of 24 Sep 03:29 is in
  `~/Downloads` (personal — never commit it); its facts are in `LIVE_HR.md` §3.
- Simulator `281E44EC` (iPhone 17 Pro): NOOP installed from a test build; its app-container setting
  `liveActivity.enabled` = true; an old test Lift Log session is still running in it (harmless).
