# Next PR — ready to open

**Maintained with the handbook.** The follow-up to #2099: branch `lift-log-discard-and-edit` on `UtkuDenizAltiok/noop`.
Nothing here is posted until Utku says yes, after a gym session on the testing build.

## Before opening

1. Utku's gym session on the current testing build (`STATE.md` names it). Replace `HARDWARE_LINE` below
   with what it showed; a problem found there is fixed, verified and re-shipped first.
2. `bash dist/tools/upstream-check.sh` — if `main` moved, rebase (`WORKFLOW.md` §7), then `bash dist/tools/verify.sh`,
   which includes ledger, ratchet and governance; if `LiftMetrics.swift` changed, regenerate the Kotlin oracle.
3. **Parity governance must be green, not just the ledger.** #2229: #2099 left `parity-governance` red on `main`
   (new files, authority not refreshed), and the check never runs on ordinary PRs. Wait for #2233 (the
   maintainers' fix), rebase, then run the job with Python 3.12 — `gh workflow run "Parity Governance CI"
   --ref lift-log-discard-and-edit` on the fork, or the unittest command in `parity-governance.yml` locally
   (this Mac's Python 3.9 adds 15 environment errors, identical on `main`). If our new twin pair
   (`isPerformed`) moves the authority, include the reviewed refresh `Tools/PARITY_GOVERNANCE.md` describes.
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
- **Android parity.** `LiftMetrics.kt` (#2232) follows in its own commit: `isPerformed` is `reps != 0` on both platforms, one function each so the ledger pairs them unambiguously. The oracle fixture gains a bench set at 0 reps that carries muscles and an RPE, so skipping the rule in `muscleCounts` or `rpeProfile` would show as an extra chest set or rating. The expected block is the stdout of the real `StrandAnalytics` and `WhoopStore` packages; every section this change cannot affect came back identical to the previous oracle. Android has no DAO reading lift sets, so the SQL rule has no Kotlin twin to change.

No schema change.

## Type of change

- [ ] Bug fix
- [x] New feature
- [ ] Refactor / cleanup
- [ ] Documentation
- [ ] CI / tooling

## How it was tested

- **Hardware — WHOOP 5.0:** HARDWARE_LINE
- **Tests seen to fail without the change:** zero-rep sets left out of the figures, the weekly SQL counts and the last-session read; discarding saves zeros; a removed set renumbers the rest; the face-down discard files nothing; the SQL rule matching `reps != 0` for a negative count. The Kotlin oracle's changed lines are ones the unchanged Kotlin produced differently.
- `swift test`: WhoopStore N_WS, StrandAnalytics N_SA — 0 failures.
- `xcodebuild test` (macOS): N_MAC tests; only the two locale-dependent `TodayCarryOverTests` fail, identically on `main` on this machine.
- Android CI (assemble + unit tests, the regenerated oracle included): green on the fork (no local Android SDK).
- iOS simulator walkthrough, checked against the database: discard → the summary hides the zeros and says nothing was performed → Edit sets shows them as 0 / 0 → add, fill in, remove, save (rows renumbered, the removed one deleted, the program unchanged). A session with nothing typed, then discarded, shows the warning and files no session, sets or workout.
- Parity ledger (`--no-baseline`) on this branch against `main`: no finding added.
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
