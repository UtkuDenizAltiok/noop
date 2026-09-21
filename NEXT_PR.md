# Next PR — ready to open

**One PR** for everything since #2099 merged (decided 21 Sep 2026). The work was built as three stacked branches,
but the fourth gym session changed how finishing treats a set that was done, which rewrites behaviour the first
branch introduced; one PR lets the maintainers review the final behaviour once, carry one parity refresh, and
merge once. Its commits stay separable by concern if they ask for smaller PRs. Nothing is posted until Utku says
yes.

**Writing style (Utku, 21 Sep):** simple, clear words — what changed since #2098 and #2099 merged, and why. No
sophisticated or AI-sounding phrasing.

**What Utku checks at the gym next** (build `592e17b` from `lift-log-gym-round-3`, the stack's tip):
- a set he ticks (Set done, or a strap double-tap) and leaves untyped saves its grey numbers; Finish asks only
  about sets he never started ("Sets not started: N");
- after Save, the program shows each exercise's heaviest set as its weight × reps;
- a second double-tap 5 s or more after the last one that worked is acted on; one sooner gives no buzz;
- the Lock Screen lights on every strap step while NOOP is not open on screen — including right after the screen
  dimmed. For any step that still does not light: was the phone face down? Was a Focus on?
- the Lock Screen banner: icon and numbers nearer the edges, heart rate above the clock, words cut less;
- no second "sync" banner appears during a session;
- save the strap log after the session; `tools/strap-log.py` now lists, per strap step, whether the Lock Screen
  was asked to light.

## Before opening

1. The gym session above. Replace `HARDWARE_ROUND_4` below with what it showed (or delete the sentence if all
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

After #2098 and #2099 were merged, I used the Lift Log in four real gym sessions (15–17 Sep, WHOOP 5.0). This PR is what those sessions showed: fixes for what went wrong, and a few small improvements. The commits follow the sections below.

### Finishing a session
- **One Save button.** Skip and Save session did the same thing, so Skip is gone.
- **A set you finished counts as done.** It saves the numbers you typed, or the grey numbers if you typed nothing. The finish screen now only asks about sets you never started: complete them, or discard them.
- **Discarded sets are kept as 0 kg × 0 reps.** They are left out of every figure, and you can still fill them in under Edit sets if the discard was a mistake.
- **Nothing done, nothing saved.** If no set was done and the rest are discarded, no session and no workout are saved. This is your guard from #2099 (`fed714cb`), kept.
- **The program follows the session.** At Save, each exercise in the program takes the weight and reps of its heaviest set (more weight first, then more reps). Warm-ups and discarded sets don't count. A changed set count is still asked about.

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
- **More room for the text**: the heart rate sits above the timer, and the icon and numbers are closer to the edges.
- A double-tap **lights up the Lock Screen**, so you can see where you are without unlocking. Each double-tap writes one line to the strap log saying whether it asked iOS to light the screen.
- **One banner during a session**: the sync banner (#2272) doesn't start while a session is running, the same way the heart-rate banner already steps aside.

### Typing
- **One tap moves from one box to the next.** Before, the first tap on the reps box only closed the keyboard.

### Behind the scenes
- A set with 0 reps counts nowhere: `LiftMetrics.isPerformed`, and the same rule in the SQL of `liftSetCounts` and `lastLiftSets` (`reps <> 0`), with a test that the two agree.
- Android: `LiftMetrics.kt` (#2232) follows the change, with its oracle regenerated from the real Swift packages, and `deleteLiftSets` has its Kotlin twin in `DeviceRegistryDao`. Android has no Lift Log screens, so nothing else there changes.
- `Tools/parity_twin_map.json` is refreshed with `parity_ledger.py --refresh-derived` for the two new twin pairs (not edited by hand).
- Outside the Lift Log's own files: `FrameRouter` hands a double-tap on before it starts the sync; `AppModel`'s double-tap handler type is `@MainActor`; `SyncLiveActivityController` gets a `holdsBackNewBanner` hook; and `StrandiOSApp` wires them up.
- No schema change.

## Type of change

- [x] Bug fix
- [x] New feature
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## How it was tested

- **Four gym sessions on a WHOOP 5.0 (15–17 Sep).** Checked there: one Save, discarded sets shown as 0 / 0 under Edit sets, adding and removing sets, the warning before a save that files nothing, the grey max RPE, one-tap typing, the next-set line and the timer stopping at 0:00. In the last session the strap sensed 28 double-taps and all 28 reached the app. HARDWARE_ROUND_4
- **Every new test was seen to fail without its fix**, then pass with it.
- `swift test`: WhoopStore 609, StrandAnalytics 2030, StrandImport 327 — 0 failures.
- `xcodebuild test` (macOS): 2066 tests; only the two date-format `TodayCarryOverTests` fail, the same as on `main` on this machine.
- Android CI (build + unit tests, including the regenerated oracle): green.
- Parity with Python 3.12: ledger, ratchet and governance tests (124) all pass.
- iOS simulator, before and after: one-tap typing, the Lock Screen timer, the banner layout.
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
