# Next PR — ready to open

**One PR** for everything since #2099 merged (decided 21 Sep 2026). The work was built as three stacked branches,
but the fourth gym session changed how finishing treats a set that was done, which rewrites behaviour the first
branch introduced; one PR lets the maintainers review the final behaviour once, carry one parity refresh, and
merge once. Its commits stay separable by concern if they ask for smaller PRs. Nothing is posted until Utku says
yes.

**What Utku checks at the gym next** (build from `lift-log-gym-round-3`, the stack's tip):
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

1. The gym session above. Replace `HARDWARE_ROUND_4` below with what it showed; a problem found there is fixed,
   verified and re-shipped first.
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
4. Fill the counts and the CI line from those runs; re-read the whole diff once as a reviewer.
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

Follow-ups to #2099 from four real gym sessions (15–17 Sep) on a WHOOP 5.0, each one found by lifting with the previous build. Grouped by what a lifter sees; the commits follow the same lines.

**Finishing and editing a session**
- **One Save button.** Finishing had Skip and Save session, and both saved the same way.
- **A set that was done is complete.** A set ticked by Set done or a strap double-tap saves what was typed into it, and a field left blank takes the grey number the sheet showed. Finishing asks "complete or discard" only about sets never started. A session with no set done and the rest discarded still files no session, sets or workout — your guard from #2099 (`fed714cb`), now reading "no set counts".
- **Discarded sets stay editable.** "Discard them" keeps never-started sets as 0 kg × 0 reps instead of dropping them, so a discard made by mistake can be filled back in under Edit sets.
- **A set with 0 reps was not performed.** `LiftMetrics.isPerformed` is `reps != 0`, and it leaves such a set out of every figure; `WhoopStore.liftSetCounts` and `lastLiftSets` apply the same rule in SQL (`reps <> 0`), pinned to agree with the in-memory count, a negative count included. This also stops a set typed as 0 reps from counting.
- **Edit sets can add and remove sets.** An added set takes the exercise's muscles and no timing; the last set can be removed (each exercise keeps one); set numbers are renumbered on Save; removed rows go through the new `deleteLiftSets`. Only that session changes. A field holding 0 empties when focused, so typing replaces the 0.
- **The program follows the session.** At Save each program line takes the weight and reps of its heaviest set done that session — more weight first, then more reps — so a lighter back-off set does not pull the working weight down. Warm-ups, discarded zeros and sets completed at finish without being started move nothing. A changed set count is still asked about.

**A max RPE per exercise**
- A program line can carry a max RPE (1–10): the ceiling a set should not pass, so a lifter knows where to hold back. Typed in the line editor (refused outside the scale) or read from the template's `Target max RPE` column (the importer also reads `Max RPE` and `RPE`, and warns and leaves it blank outside 1–10). The session shows it grey in the RPE field, and grey means the same as for weight and reps: a set nobody rated saves it; a typed rating wins; a discarded set saves none; a previous set's rating is never copied onto another. The trade is stated: a stored rating no longer proves the lifter rated that set. No schema change — `liftProgramItem.targetRpe` existed and nothing filled it.

**The strap double-tap**
- **A knock is not a tap.** The strap's own sensor log showed double-taps 3–4 s after the one that started a set — the arm going onto the bar — each finishing a set seconds old. A strap double-tap under 5 s after the last one the session acted on is held back, with no buzz and one strap-log line; a rest that is already over (a line planned with no rest) is exempt, and the on-screen button is never held back.
- **The buzz goes out before the sync.** A DOUBLE_TAP event also kicks a sync, and `FrameRouter` did that before handing the tap on; the session then buzzed from a `Task`. The strap received "send historical data" first and started the transfer before playing the buzz, so those taps buzzed 1.0–2.8 s late where most came in under one. `FrameRouter` now hands the tap on first and the session buzzes synchronously. Wrist and other events keep their order. Android has no Lift Log and is unchanged.

**The bar and the Lock Screen**
- The set coming up replaces "3 of 19 sets done": "Next: Set 2 · Lat pulldown", on one line, the set number first so a narrow line cuts the name. It is where the taps go (`LiftSessionEngine.upcomingSlot` is `slotAfter` with the current set counted as done).
- The Lock Screen rest clock stays at 0:00 once the rest is over, as the in-app bar does, instead of counting up again.
- Numbers typed into the set being lifted show on the bar and the Lock Screen, not the grey plan behind them.
- The banner gives its width to the words: icon and numbers nearer the edges, the heart rate stacked over the clock.
- A strap step lights a dark Lock Screen — an ActivityKit alert on the update the step sends anyway, with a bundled silent sound, sent whenever NOOP is not the app on screen — and each step leaves one strap-log line saying whether it asked iOS to light.
- One banner during a session: NOOP's live-HR banner already stood aside for the session's; the strap-sync banner (#2272) now starts none mid-session either (`SyncLiveActivityController.holdsBackNewBanner`).

**Typing**
- With the keyboard open, one tap on another field moves the cursor there. The tap-outside-to-dismiss gesture used to take the focus straight back, so moving from weight to reps took two taps.

**Parity**
- `LiftMetrics.kt` (#2232) follows `isPerformed`, one function per platform so the ledger pairs them; the oracle fixture gains a 0-rep bench set carrying muscles and an RPE, and the expected block is the stdout of the real `StrandAnalytics` and `WhoopStore` packages (every section this cannot affect came back identical). `deleteLiftSets` has its Kotlin twin in `DeviceRegistryDao`, ported ahead of its consumer. The two new twin pairs move the authority, so the PR carries the guarded refresh of `Tools/parity_twin_map.json` (`--refresh-derived`, not a hand edit); `parity_ledger_baseline.json` is unchanged.

No schema change.

## Type of change

- [x] Bug fix
- [x] New feature
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## How it was tested

- **Hardware — WHOOP 5.0, four gym sessions.** 15 Sep: the finish questions, grey numbers staying grey, editing a finished session. 16 Sep (16 sets): one Save; discards kept as 0 / 0 and filled in under Edit sets; adding and removing sets there; the warning before a Save that would file nothing; the grey max RPE saved when a set is left unrated. 17 Sep: the next-set line on the Lock Screen (his screenshot); its strap log showed all 28 double-taps the strap sensed reaching the app, two of them held back as knocks. HARDWARE_ROUND_4
- **Tests seen to fail without the change:** zero-rep sets left out of the figures, the weekly SQL counts and the last-session read; the SQL rule matching `reps != 0` for a negative count; a removed set renumbering the rest; done sets complete without asking and only never-started sets zeroed; the heaviest-set rule and its exclusions; the importer's 1–10 range; the max RPE filling an unrated set but never a discarded one; the knock window, pinned at 5 s; the tap handed on before its sync; the synchronous buzz; the next set named during a set and during its rest; typed numbers on the bar; one Lock Screen light-up per strap step. The Kotlin oracle's changed lines are ones the unchanged Kotlin produced differently.
- `swift test`: WhoopStore N_WS, StrandAnalytics N_SA, StrandImport N_SI — 0 failures.
- `xcodebuild test` (macOS): N_MAC tests; only the two locale-dependent `TodayCarryOverTests` fail, identically on `main` on this machine.
- Android CI (assemble + unit tests, the regenerated oracle included): N_ANDROID.
- iOS simulator, before and after: one tap moving between fields in the session, Edit sets and the program editor; the Lock Screen clock reading 0:00 after a rest where the old build climbed; the next-set line; the banner with a working set's count-up, a rest's countdown and a finished rest. Edit sets and the discard flow were walked through against the database.
- Parity, with Python 3.12: ledger, ratchet (against this branch's base) and governance tests all pass (N_GOV).
- Both app targets build. Every new string has all ten locales.

## Checklist

- [x] Swift package tests pass for any package I touched (`swift test` in `Packages/<name>`)
- [x] Android unit tests pass if I touched `android/` (via Android CI — no local Android SDK)
- [ ] No new build warnings introduced — `onChange(of:perform:)` is used once more, in Edit sets: the single-parameter form the macOS 13 target needs, as in #2099
- [x] UI changes use only `StrandDesign` tokens
- [x] No hardcoded hex frame bytes; protocol facts live in the schema / decoders
- [x] Follows the conventions in `docs/CONTRIBUTING.md`
- [x] I did not commit generated output (`Strand.xcodeproj/`) or any secrets/keystores

## Related issues

Follows #2099 (merged as `4453a089`), keeping its empty-session guard (`fed714cb`), and #2232 (the Kotlin `LiftMetrics` twin). Touches #2272's sync banner only to keep it from starting during a gym session. #2327 (no Android UI) is not addressed here.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Reply on #2099, after ryanbr's 15 Sep 04:07 comment

```markdown
Thanks for the guard and for taking it. You were right about the workout: an hour discarded to nothing should not come back as a Strength Training entry with a strain on it.

The next gym sessions (15–17 Sep) went into #FOLLOWUP, and they met your question from the other side. A discard made by mistake should be recoverable, so discarded sets are kept as 0 kg × 0 reps, which every figure leaves out and Edit sets can fill back in; and a set that was done now counts as done, with its grey numbers, so only sets never started are asked about. Your guard stays, reading "no set counts": a session with no set done and the rest discarded still files no session, sets or workout, and the finish sheet says so before Save.

On the taps: the strap logs showed every double-tap the strap sensed reaching the app (16 of 16, 22 of 22, 28 of 28). The ones felt as missed were either never sensed by the strap or, later, held back on purpose as knocks under 5 s.
```
