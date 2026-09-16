# Next PRs — ready to open

Three PRs, in order: **1. the follow-up** (below, ready), **2. target max RPE** and **3. from the third gym
session** (both at the end, drafted). Open each only after the one before merges, rebased `--onto upstream/main`.

**What Utku checks at the gym next** (build from `lift-log-gym-round-3`, the third branch below):
- typing: with the keyboard open in the KG box, ONE tap on the REPS box puts the cursor there;
- a double-tap within 8 s of the last one that worked does nothing and gives no buzz — tap again after a moment;
  ordinary taps should buzz promptly, including while the strap is syncing;
- Lock Screen: the rest clock stops at 0:00; the bottom line reads "Next: Set 2 · Lat pulldown", and at the last
  set of an exercise it names the next exercise; the bar inside the app shows the same line;
- with the phone locked and dark, a double-tap lights the screen and nothing else (it goes dark again on the
  phone's own timer); it does not light while the phone is unlocked. Does the phone vibrate with it?
- numbers typed into the set being lifted show on the bar and the Lock Screen;
- save the strap log after the session as usual.

**Confirmed on 16 Sep** (third gym session, build `4fda4266`): everything PR 1 and PR 2 below change — one Save,
discarded sets as 0 / 0 in Edit sets, adding and removing sets there, the warning before an empty Save, and the
grey max RPE saved when a set is left unrated. The HARDWARE_LINE for each is filled in below.

**Maintained with the handbook.** The follow-up to #2099: branch `lift-log-discard-and-edit` on `UtkuDenizAltiok/noop`.
Nothing here is posted until Utku says yes, after a gym session on the testing build.

## Before opening

1. Utku's gym session on the current testing build (`STATE.md` names it). Replace `HARDWARE_LINE` below
   with what it showed; a problem found there is fixed, verified and re-shipped first.
2. `bash dist/tools/upstream-check.sh` — if `main` moved, rebase (`WORKFLOW.md` §7), then `bash dist/tools/verify.sh`,
   which includes ledger, ratchet and governance; if `LiftMetrics.swift` changed, regenerate the Kotlin oracle.
3. **Parity, in this order** (Python 3.12): rebase onto the latest `upstream/main` FIRST, then
   `Tools/parity_ledger.py --refresh-derived --base "$(git merge-base HEAD upstream/main)"`, then the ledger, the
   ratchet (same base) and the governance tests — all must be green — and commit the refreshed
   `Tools/parity_twin_map.json` in the PR, in its own commit. Never hand-edit it.
   **The refresh is required, not optional.** The branch adds two twin pairs (`isPerformed`, `deleteLiftSets`),
   which move the authority: functions +4, function_pairs +2, file_pairs +1, unpaired_files −2. Without the
   refresh the ledger reports `twin-map-authority-drift|function_pairs` and two `RepositoryBaselineTests` fail —
   exactly how #2099 left `main` red (#2229), and the check never runs on ordinary PRs.
   Verified 16 Sep on test merges with `upstream/main` `8576a2dd` (green on its own again after #2259/#2267 and
   upstream's re-derived maps): for EACH branch the refresh changes only those four counts, leaves
   `parity_ledger_baseline.json` untouched, and doc lint, i18n, ledger, ratchet and governance (124 tests) pass.
   Refresh only AFTER the rebase: a snapshot taken against an older base is stale on arrival.
4. Fill the counts and the CI lines from those runs. Re-read the diff once more as a reviewer.
5. Open it and post the reply (below), in that order:
   ```bash
   gh pr create --repo ryanbr/noop --base main --head UtkuDenizAltiok:lift-log-discard-and-edit \
     --title "lift log: one Save, discarded sets kept as zeros to edit, and add or remove sets when editing" \
     --body-file <this PR body saved to a file>
   gh pr comment 2099 --repo ryanbr/noop --body-file <the reply, with #FOLLOWUP filled in>
   ```
6. Update `STATE.md` and `HISTORY.md`, then `bash dist/tools/backup.sh "follow-up opened"`.

## PR body

```markdown
## What this PR does

Follow-up to #2099, from a gym session on its last build (15 Sep) that ran shortly before it merged.

- **One Save button.** Finishing had Skip and Save session, and both saved the same way. Skip is gone; session RPE stays optional.
- **Discarded sets stay editable.** "Discard them" now keeps the unfinished sets as 0 kg × 0 reps instead of dropping them, so a discard made by mistake can be filled back in under Edit sets.
- **A set with 0 reps was not performed.** `LiftMetrics.isPerformed` leaves it out of every figure, and `WhoopStore.liftSetCounts` and `lastLiftSets` apply the same rule in SQL (`reps <> 0`), so it never counts toward a muscle or becomes the next session's grey numbers. This also stops a set typed as 0 reps from counting, which it did before. A set with no rep count still counts, and the SQL and in-memory counts stay pinned to agree, a negative count included.
- **The empty-session guard from #2099 is kept** and now reads "no set counts" (`LiftSessionController.anyPerformed`), since a discard no longer leaves an empty list. A session run face-down with nothing typed, then discarded, still files no session, sets or workout, and the finish sheet now says so before Save.
- **Edit sets can add and remove sets.** An added set takes the exercise's muscles and no timing; the last set can be removed (each exercise keeps one), set numbers are renumbered on Save, and removed rows go through the new `deleteLiftSets`. Only that session changes, never the program. A field holding 0 empties when focused, so typing replaces the 0.
- **The session summary shows only performed sets**, and says so when there are none.
- **`deleteLiftSets` has its Kotlin twin.** `DeviceRegistryDao` already holds the lift tables' delete queries, so the by-id delete joins them, ported ahead of its consumer as #2232 did for the figures. With it the ratchet reports no error and the ledger no new finding. The two new twin pairs (`isPerformed`, `deleteLiftSets`) move the parity authority, so the PR carries the guarded refresh of `Tools/parity_twin_map.json` (`--refresh-derived`, not a hand edit); `parity_ledger_baseline.json` is unchanged.
- **Android parity.** `LiftMetrics.kt` (#2232) follows in its own commit: `isPerformed` is `reps != 0` on both platforms, one function each so the ledger pairs them unambiguously. The oracle fixture gains a bench set at 0 reps that carries muscles and an RPE, so skipping the rule in `muscleCounts` or `rpeProfile` would show as an extra chest set or rating. The expected block is the stdout of the real `StrandAnalytics` and `WhoopStore` packages; every section this change cannot affect came back identical to the previous oracle. Android has no DAO reading lift sets, so the SQL rule has no Kotlin twin to change.

No schema change.

## Type of change

- [ ] Bug fix
- [x] New feature
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## How it was tested

- **Hardware — WHOOP 5.0:** a 16-set gym session on a testing build carrying this branch (16 Sep): one Save; "Discard them" kept the sets as 0 / 0 under Edit sets, where they could be filled in; adding and removing sets there; the warning before a Save that would file nothing.
- **Tests seen to fail without the change:** zero-rep sets left out of the figures, the weekly SQL counts and the last-session read; discarding saves zeros; a removed set renumbers the rest; the face-down discard files nothing; the SQL rule matching `reps != 0` for a negative count. The Kotlin oracle's changed lines are ones the unchanged Kotlin produced differently.
- `swift test`: WhoopStore N_WS, StrandAnalytics N_SA — 0 failures.
- `xcodebuild test` (macOS): N_MAC tests; only the two locale-dependent `TodayCarryOverTests` fail, identically on `main` on this machine.
- Android CI (assemble + unit tests, the regenerated oracle included): green on the fork (no local Android SDK).
- iOS simulator walkthrough, checked against the database: discard → the summary hides the zeros and says nothing was performed → Edit sets shows them as 0 / 0 → add, fill in, remove, save (rows renumbered, the removed one deleted, the program unchanged). A session with nothing typed, then discarded, shows the warning and files no session, sets or workout.
- Parity, with Python 3.12, against this branch's base: the ledger reports no new finding, the ratchet no error, and the governance tests pass (N_GOV) with the refreshed twin map, which changes only the counts the two new pairs account for. The one-sided declarations the ratchet named were resolved rather than declared as debt — two inlined, and `deleteLiftSets` given its Kotlin twin.
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

Follows #2099 (merged as `4453a089`), keeping its empty-session guard (`fed714cb`), and #2232 (the Kotlin `LiftMetrics` twin).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Reply on #2099, after ryanbr's 15 Sep 04:07 comment

```markdown
Thanks for the guard and for taking it. You were right about the workout: an hour discarded to nothing should not come back as a Strength Training entry with a strain on it.

The second gym session (15 Sep, on `af27d0a1`) ran before I saw your comment:

- The finish questions, grey numbers staying grey, editing a finished session and the double-tap log lines all worked.
- 3 taps did not register. The new log lines show the strap never reported them, while all 16 taps it did report were acted on and buzzed within 3 s, so those were on the strap side.

That session also asked for a change that meets your question from the other side: a discard made by mistake should be recoverable. #FOLLOWUP keeps discarded sets as 0 kg × 0 reps, which every figure leaves out and Edit sets can fill back in. Your guard stays, reading "no set counts" rather than "no set saved": a face-down session with nothing typed, then discarded, still files no session, sets or workout, and the finish sheet now says so before Save. It also keeps #2232's Kotlin twin in step, with the oracle regenerated from the Swift packages.
```

## PR 2 — target max RPE (open after the follow-up merges)

Title: `lift log: a max RPE per exercise, shown grey in the session and read from the template`

```markdown
## What this PR does

A max RPE (1–10) for each program line: the hardest a set should feel, so a lifter knows where to hold back and avoid injury. Asked for after real gym sessions.

- **Program editor:** a "Max RPE (1–10)" field on each exercise line, refused outside the scale; the program list shows "max RPE 8".
- **Session:** the RPE field shows the ceiling as a grey number (before, the previous set's rating), and grey means the same here as for weight and reps: a set the session keeps and nobody rated saves it, a typed rating wins, a discarded set saves none, and a previous set's rating is never copied onto another set. The trade is stated plainly: a stored rating no longer proves the lifter rated that set.
- **Spreadsheet import:** the template gains a `Target max RPE` column that only accepts 1–10; the importer also reads `Max RPE` and `RPE`, and a value outside the scale imports without a ceiling and a warning naming the row. The import preview and guide show it.
- **No schema change:** `liftProgramItem.targetRpe` already existed on both platforms and nothing filled it; its description now says what it holds. No Kotlin logic reads it yet.

## How it was tested

- **Hardware — WHOOP 5.0:** a 16-set gym session (16 Sep): the max RPE showed grey in the session, and a set left unrated saved it.
- `swift test`: StrandImport N_SI (new: the column and its spellings, out-of-range warnings, the shipped template's header and 1–10 validation); the out-of-range test was seen to fail without the range check.
- `xcodebuild test` (macOS): N_MAC; `testAMaxRpeFillsAnEmptyRatingLikeEveryOtherGreyNumber` and `testADiscardedSetTakesNoMaxRpe` pin where the plan's number does and does not reach a set.
- Template regenerated with `Tools/make_lift_program_template.py`. Both app targets build; four new strings in all ten locales.

Follows #FOLLOWUP.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## PR 3 — from the third gym session (open after PR 2 merges)

Branch `lift-log-gym-round-3`, stacked on `lift-log-target-rpe`, five commits that map onto separate PRs if the
maintainers prefer small ones (the fourth and fifth belong with the third):

1. `d83e9c79` **one tap moves between fields** — `KeyboardDismiss.swift` only.
2. `236b4a2b` **a strap knock is held back, and the buzz goes out before the sync** — `LiftSessionController`
   (`isKnock`, synchronous strap handler, log line), `FrameRouter` (DOUBLE_TAP handed on before
   `onSyncTrigger`), `AppModel` (the override type), tests. BLE-path: say what the hardware showed, and that
   Android is unchanged (no Lift Log there; its buzz-back would gain but is unmeasured).
3. `7b993bd5` **the next set, a rest clock that stops at 0:00, typed numbers on the bar, the Lock Screen lights
   on a strap step** — engine `upcomingSlot`, `nextLine`, `setNumbers`, bar, Live Activity, alert, strings.
4. `3de2ad29` **the light-up narrowed** (Utku, 17 Sep): a locked phone only, on the first update the step sends.
5. **cleanup**: the bar resolves the session once per render; the banner's unused program name is gone.

Evidence to quote: the 16 Sep strap log (22 of 22 sensed double-taps acted on; knocks at +3 s and +4 s; the four
1.0–2.8 s buzzes were the taps that kicked a sync), the simulator before/after for typing and the 0:00 clock, and
the next gym session's result. No Kotlin logic changes: nothing in PR 3 touches `Packages/**` or `android/**`.
