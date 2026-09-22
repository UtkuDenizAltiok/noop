# Next PR — ready to open

**One PR** for everything since #2099 merged (decided 21 Sep 2026). The work was built as three stacked branches,
but the fourth gym session changed how finishing treats a set that was done, which rewrites behaviour the first
branch introduced; one PR lets the maintainers review the final behaviour once, carry one parity refresh, and
merge once. Its commits stay separable by concern if they ask for smaller PRs. Nothing is posted until Utku says
yes.

**Writing style (Utku, 21 Sep):** simple, clear words — what changed since #2098 and #2099 merged, and why. No
sophisticated or AI-sounding phrasing.

**What Utku checks at the gym next** (build `f7638bf` from `lift-log-gym-round-3`, the stack's tip):
- the Lock Screen lights on every strap step while NOOP is not on screen — also after NOOP has been in the
  background a long time (iOS restarts it; the strap log now says "session picked up again" and "Lock Screen
  banner picked up again" when that happens);
- "Add exercise" at the bottom of the session: pick one used before, or type a new one and give it muscles; it
  joins with one set at 0 / 0; type the numbers, ⊕ adds sets; Finish asks "Update program" and the program then
  lists it with its sets and heaviest set;
- the minimised bar: icon near the left, heart rate over the clock at the right, words cut less; clocks read
  "0:45" like the Lock Screen;
- no background restarts of NOOP during the session (the strap log's `runs` report shows each one), and the
  battery drain over the session feels no worse than before;
- still true from round 4: done sets complete without asking; the program takes each line's heaviest set; a
  second double-tap under 5 s is ignored; no second "sync" banner;
- save the strap log right after the session (and right after anything odd — the phone keeps only the last
  three NOOP restarts); `tools/strap-log.py … steps` lists every step and whether it lit.

## Before opening

1. The gym session above. Replace `HARDWARE_ROUND_5` below with what it showed (or delete the sentence if all
   went well); a problem found there is fixed, verified and re-shipped first.
2. `bash dist/tools/upstream-check.sh`. If `main` moved: rebase the stack in order (`WORKFLOW.md` §7 — first
   `lift-log-discard-and-edit`, then `--onto` for `lift-log-target-rpe` and `lift-log-gym-round-3`), prove every
   commit is unchanged with `git range-diff`, then re-run the parity refresh
   (`Tools/parity_ledger.py --refresh-derived --base "$(git merge-base HEAD upstream/main)"`, Python 3.12). If
   the refresh changes the JSON again, commit it at the tip as "parity: re-derive the twin-map authority after
   rebasing onto …" — never a hand edit. Then `bash dist/tools/verify.sh`: every step must pass, governance
   included (it did on 21 Sep on `a56840bb`).
3. Create the PR branch from the tip and push it: `git branch lift-log-follow-ups lift-log-gym-round-3`, then
   `git push -u origin lift-log-follow-ups`. Run Android CI on it:
   `gh workflow run "Android CI" --repo UtkuDenizAltiok/noop --ref lift-log-follow-ups`.
4. The test counts below are from 21 Sep (`7bafa857`); update them if a rebase changed them. Re-read the whole
   diff once as a reviewer.
5. Open it and post the reply (below), in that order:
   ```bash
   gh pr create --repo ryanbr/noop --base main --head UtkuDenizAltiok:lift-log-follow-ups \
     --title "Lift Log: follow-ups from four gym sessions" --body-file <the PR body below, saved to a file>
   gh pr comment 2099 --repo ryanbr/noop --body-file <the reply below, with #FOLLOWUP filled in>
   ```
6. Once it is open, the three stacked branches are fully contained in `lift-log-follow-ups`: with Utku's yes,
   delete them from the fork (their commits live on in the new branch; keep a local bundle). Update `STATE.md`,
   `HISTORY.md`, then `bash dist/tools/backup.sh "follow-up PR opened"`.

## PR body

```markdown
## What this PR does

After #2098 and #2099 were merged, I used the Lift Log in five real gym sessions (15–21 Sep, WHOOP 5.0). This PR is what those sessions showed: fixes for what went wrong, and a few small improvements. The commits follow the sections below.

### Finishing a session
- **One Save button.** Skip and Save session did the same thing, so Skip is gone.
- **A set you finished counts as done.** It saves the numbers you typed, or the grey numbers if you typed nothing. The finish screen now only asks about sets you never started: complete them, or discard them.
- **Discarded sets are kept as 0 kg × 0 reps.** They are left out of every figure, and you can still fill them in under Edit sets if the discard was a mistake.
- **Nothing done, nothing saved.** If no set was done and the rest are discarded, no session and no workout are saved. This is your guard from #2099 (`fed714cb`), kept.
- **The program follows the session.** At Save, each exercise in the program takes the weight and reps of its heaviest set (more weight first, then more reps). Warm-ups and discarded sets don't count. A changed set count is still asked about.

### Adding an exercise during a session
- **"Add exercise"** at the end of the session: pick an exercise you have done before, or type a new one and choose its muscles (a new one is saved, like a name typed in the program editor). It joins the session with one set at 0 kg × 0 reps; type what you lift, and add sets with Add set. Undo removes it.
- **The program only changes if you say so.** Finish asks, in the same question as changed set counts, whether to keep it; "Update program" adds it at the end of the program with its sets and its heaviest set. Rest and max RPE are left for the program editor.

### Editing a finished session
- **Add and remove sets** under Edit sets. Set numbers are renumbered on Save, and only that session changes.
- A box showing **0 clears when you tap it**, so typing replaces the 0.

### Max RPE
- Each exercise in a program can have a **max RPE (1–10)**: the hardest a set should feel. Type it in the editor, or fill the new `Target max RPE` column in the template. The editor refuses values outside 1–10; the import leaves them blank and warns.
- The session shows it in grey in the RPE box, like the grey weight and reps, and a set you don't rate saves it.

### Strap double-tap
- **A second double-tap within 5 seconds is ignored.** The strap sometimes reports a second double-tap a few seconds after a real one (most likely a knock on the bar), which finished sets that had just started. The ignored tap gets no buzz and writes one line to the strap log.
- **The confirmation buzz comes right away.** A double-tap also starts a sync, and the sync request used to reach the strap first, so the buzz waited behind it (up to 2.8 s). Now the buzz goes first.

### Minimised bar and Lock Screen
- Shows **the next set** ("Next: Set 2 · Lat pulldown") instead of "0 of 16 sets done".
- The rest timer **stops at 0:00** instead of counting up again.
- Numbers you type into the current set show there too, not the grey plan.
- **More room for the text**: the heart rate sits above the timer, and the icon and numbers are closer to the edges — on the Lock Screen and in the app's bar alike.
- The app's running clocks read like the Lock Screen's ("0:45", "0:00", "1:05:00"), using NOOP's `ActiveWorkoutClock.clock`; before, the app said "45s" next to a Lock Screen "0:45".
- **A running session does no work between taps.** iOS closed NOOP for using too much CPU in the background (its crash reports: over 80% for a minute, redrawing screens). The session had a once-a-second timer that made every screen watching it redraw, even off screen, and the session sheet also redrew on every strap-log line and heartbeat. Now there is no timer: the rest warning and the rest's end are two one-shot timers, and the clocks and heart rate on screen are small views that update themselves. In the simulator, with the sheet open and nothing happening, NOOP's CPU went from 9.96 to 6.59 CPU-seconds a minute (6.29 with no session at all).
- **The session and its Lock Screen banner survive iOS closing NOOP.** iOS closed NOOP in the background and relaunched it four times in one session. The saved session came back only when the first screen appeared, and the banner's first update after a relaunch found no session and ended the banner iOS had kept; iOS does not allow a new one from the background, so the Lock Screen stayed dark until NOOP was opened. The session is now picked up when the app starts, and the banner is kept.
- A double-tap **lights up the Lock Screen**, so you can see where you are without unlocking. Each double-tap writes one line to the strap log saying whether it asked iOS to light the screen.
- **One banner during a session**: the sync banner (#2272) doesn't start while a session is running, the same way the heart-rate banner already steps aside.

### Typing
- **One tap moves from one box to the next.** Before, the first tap on the reps box only closed the keyboard.

### Behind the scenes
- A set with 0 reps counts nowhere: `LiftMetrics.isPerformed`, and the same rule in the SQL of `liftSetCounts` and `lastLiftSets` (`reps <> 0`), with a test that the two agree.
- Android: `LiftMetrics.kt` (#2232) follows the change, with its oracle regenerated from the real Swift packages, and `deleteLiftSets` has its Kotlin twin in `DeviceRegistryDao`. Android has no Lift Log screens, so nothing else there changes.
- `Tools/parity_twin_map.json` is refreshed with `parity_ledger.py --refresh-derived` for the two new twin pairs (not edited by hand).
- Following the PERF rule TodayView already states: no Lift Log screen watches `LiveState` or `AppModel` any more; the heart rate and the clocks are leaf views (`LiftLiveReadouts.swift`).
- Outside the Lift Log's own files: `FrameRouter` hands a double-tap on before it starts the sync; `AppModel`'s double-tap handler type is `@MainActor`; `SyncLiveActivityController` gets a `holdsBackNewBanner` hook; and `StrandiOSApp` wires them up and resumes a saved session in its `init` (it used to be `RootTabView`'s `.task`).
- The exercise-name suggestions and the muscle picker move from `LiftProgramItemSheet` into `LiftExercisePicking.swift`, shared by the program editor and the new Add exercise sheet; the program editor behaves as before.
- No schema change: an added exercise uses the existing `liftExercise` and `liftProgramItem` tables, and the crash snapshot gains one optional field.

## Type of change

- [x] Bug fix
- [x] New feature
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## How it was tested

- **Five gym sessions on a WHOOP 5.0 (15–21 Sep).** Checked there: one Save, discarded sets shown as 0 / 0 under Edit sets, adding and removing sets, the warning before a save that files nothing, the grey max RPE, one-tap typing, the next-set line and the timer stopping at 0:00. On 17 Sep the strap sensed 28 double-taps and all 28 reached the app. The 21 Sep session found the banner ending after iOS relaunched NOOP; the fix was checked in the simulator against ActivityKit's own log (the old build ends the banner two seconds after a relaunch; this one keeps updating the same banner). HARDWARE_ROUND_5
- **Every new test was seen to fail without its fix**, then pass with it.
- `swift test`: WhoopStore 609, StrandAnalytics 2030, StrandImport 327 — 0 failures.
- `xcodebuild test` (macOS): 2066 tests; only the two date-format `TodayCarryOverTests` fail, the same as on `main` on this machine.
- Android CI (build + unit tests, including the regenerated oracle): green.
- Parity with Python 3.12: ledger, ratchet and governance tests (124) all pass.
- iOS simulator, before and after: one-tap typing, the Lock Screen timer, the banner and bar layout, adding an exercise through to the saved program (read back from the database), and the banner kept across a killed and relaunched app.
- Both app targets build. Every new text is translated into all ten languages.

## Checklist

- [x] Swift package tests pass for any package I touched (`swift test` in `Packages/<name>`)
- [x] Android unit tests pass if I touched `android/` (via Android CI — no local Android SDK)
- [ ] No new build warnings introduced — `onChange(of:perform:)` is used once more, in Edit sets: the single-parameter form the macOS 13 target needs, as in #2099
- [x] UI changes use only `StrandDesign` tokens
- [x] No hardcoded hex frame bytes; protocol facts live in the schema / decoders
- [x] Follows the conventions in `docs/CONTRIBUTING.md`
- [x] I did not commit generated output (`Strand.xcodeproj/`) or any secrets/keystores

## Related issues

Follows #2098 and #2099 (merged as `4453a089`, keeping its guard `fed714cb`) and #2232 (the Kotlin `LiftMetrics` twin). Touches #2272's sync banner only so it doesn't start during a gym session. Does not address #2327 (no Android UI).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Reply on #2099, after ryanbr's 15 Sep 04:07 comment

Optional, and only with Utku's yes. Why it exists: #2099 is merged and closed, but ryanbr's last comment there
(he pushed the empty-session guard `fed714cb` himself) ends by asking whether we would rather keep performed sets
with their timing. Nobody answered. Round 4 is exactly that choice, so one short reply answers him and points to
the new PR. Post it right after the PR opens.

```markdown
Thanks for the guard, and for merging. You asked whether I'd rather keep performed sets with their timing: after more gym sessions, yes. In #FOLLOWUP a set that was done always counts as done, with the numbers typed or the grey ones, and the finish screen only asks about sets never started. Your guard stays: if no set was done and the rest are discarded, nothing is saved, and the finish screen says so before Save.
```

## The separate strap-log PR (branch `strap-log-on-disk`)

Not part of the Lift Log PR: it changes NOOP's own strap log, on iOS and Android. Utku asked for it on 22 Sep after
the log missed the window he wanted, and said yes to opening it the same day, on condition that it is lean, cheap on
battery and removes nothing he wants. Three commits on `upstream/main` `a56840bb`: `2bfef51e` (the change),
`8b2edc62` (drops the archive's unused `clear()`) and `300b6c27` (the ring's keys `nonisolated`: the branch had
added four Swift 6 warnings). Before opening: `gh pr list --repo ryanbr/noop --head
strap-log-on-disk --state all` must be empty. The body, as it goes up (verified on `300b6c27`):

**Title:** Strap log: keep every line on disk, across restarts, within 2 MB

```markdown
## What this PR does

The strap log is what people attach to bug reports, and it lost exactly the part that explains a restart:

- it lived in memory and was copied to UserDefaults (SharedPreferences on Android) only every 32 lines, so the last
  lines before the OS killed the app were gone;
- each restart kept only the last 1,000 lines of the run before it, and only the last three runs;
- the current run kept only its newest 5,000 lines, about 50 minutes since the once-a-second heart-rate line (#1767).

On 21 Sep iOS closed NOOP four times in 28 minutes of one gym session (background CPU), and the log saved afterwards
began half an hour after the moment it was saved for.

Now every line is appended to a file as it is logged: one file per app run, in 256 KB pieces, and past 2 MB in all
(about 20,000 lines, some three hours with a strap streaming) the oldest pieces are deleted. The log keeps every
run, and every line of it, within 2 MB, however often the app restarts. Files: `<AppSupport>/OpenWhoop/strap-log`
(iOS: the store's `completeUntilFirstUserAuthentication` class, so lines logged while the phone is locked are
written; excluded from backup) and `filesDir/strap-log` on Android.

Exports look as before: the earlier runs oldest first, under the same "previous app session, N line(s), rolled at
…" header ("head clipped" when a run's start was deleted), then `===== current app session =====` and this run,
now the whole run rather than its newest 5,000 lines. The log tools read it unchanged. The old ring's lines are
carried over once and its keys removed.

It also costs less than before. Measured on a Mac over 20,000 lines: 33 ms of CPU and 1.6 MB written, where the
old mirror took about 370 ms of CPU in the app (plus cfprefsd's share) and re-saved 93 MB. Android's old mirror
copied up to 5,000 lines every 32.

Not changed: what is logged and its redaction; the in-memory buffer behind the Live log card and the Test Centre
readouts; Android's opt-in detailed capture (#1121), which keeps its own file. The one new cost is memory while a
Test Centre guided mode is on: its row rebuilds the export on every line, so the older part is rendered once and
kept (at most the 2 MB budget).

## Type of change

- [x] Bug fix
- [ ] New feature
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## How it was tested

- `StrapLogArchiveTests` (7): a line survives a kill without a close; four restarts keep every run in order, each
  "rolled at" the next one's start; a run longer than a piece exports whole, with an export in the middle; past
  the budget the oldest go first and a clipped run says so; an export before the first line carries the run
  before; an empty log exports nothing; the old ring is carried over once, ahead of every run. Breaking the file
  write, the clipped header or the ring's order each fails them.
- `StrapLogArchiveTest` (Kotlin): the same behaviour, and two cases whose expected text is the Swift archive's own
  output, pasted verbatim. Android CI: green on the branch tip, https://github.com/UtkuDenizAltiok/noop/actions/runs/35692959668.
- Locally on the branch: package tests (WhoopStore 606, StrandAnalytics 2027, StrandImport 324), doc-comment lint,
  i18n audit, parity ledger, ratchet and governance (124 tests), the macOS app tests (2,043 tests; the only failures are the two
  `TodayCarryOverTests`, which fail on `main` too under a German region) and the iOS app build.
- iOS Simulator (iOS 26.5), on the first commit's build (the two after it change nothing that runs): NOOP killed
  with `kill -9` six seconds after launch; its file held all four lines, and Test Centre → Strap log → Copy after
  the relaunch showed that run and the two before it, each whole under its header.
- Not run on a strap: this changes where the log is written, not anything sent or received over Bluetooth.

## Checklist

- [x] Swift package tests pass for any package I touched (none touched; all three run)
- [x] Android unit tests pass if I touched `android/` (Android CI)
- [x] No new build warnings introduced (the two in `LiveState.logSafeDeviceName` are on `main` too)
- [x] UI changes use only `StrandDesign` tokens (no UI change)
- [x] No hardcoded hex frame bytes; protocol facts live in the schema / decoders
- [x] Follows the conventions in `docs/CONTRIBUTING.md`
- [x] I did not commit generated output (`Strand.xcodeproj/`) or any secrets/keystores

## Related issues

Refs #510, #1263, #1468
```
