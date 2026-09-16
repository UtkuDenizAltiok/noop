---
name: lift-log-upstream-prs
description: "Where the Lift Log stands upstream — #2098, #2099, #2232 (Kotlin twin) and #2233 (governance repair) merged; the follow-up and max-RPE branches are verified but unopened, waiting on Utku's gym test; the follow-up PR must carry the parity twin-map refresh. Full state in dist/STATE.md."
metadata:
  node_type: memory
  type: project
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-16T21:28:24.168Z
---

**The source of truth is `dist/STATE.md`** in the `lift-log-handbook` worktree. This memory keeps only the facts
that must survive if the handbook is missing (16 Sep 2026):

- Merged upstream: #2098 schema, #2099 app (with ryanbr's empty-session guard `fed714cb`), #2232 the
  maintainers' Kotlin `LiftMetrics` twin, #2233 their parity-governance repair (#2229 blamed #2099 for leaving
  that gate red).
- Follow-up on `lift-log-discard-and-edit` @ `1564578a` (one Save, discards as zeros fillable in Edit sets,
  add/remove in Edit sets, both Kotlin twins: `LiftMetrics` and `deleteLiftSets`). Max-RPE branch
  `lift-log-target-rpe` @ `858b8678` stacked on it, with a set left unrated saving the line's max RPE. Both
  pushed and green on their base `c430ca0b`; the phone's testing build `4fda4266` carries both (just update,
  no wipe), not yet gym-tested.
- 16 Sep evening: `upstream/main` `8576a2dd` is green on its own again. A test merge of the max-RPE branch into it
  passed the full `verify.sh` once `Tools/parity_ledger.py --refresh-derived` was applied. Without that refresh,
  each branch fails the ledger (`twin-map-authority-drift`) and two `RepositoryBaselineTests`, so **the follow-up
  PR must commit the refreshed `parity_twin_map.json`** after its PR-time rebase (`dist/NEXT_PR.md` step 3).
  The refresh moves only what our pairs `isPerformed` and `deleteLiftSets` add; the max-RPE branch adds no pair.
- Max RPE (1-10) per program line: typed in the editor or imported from the template's `Target max RPE`
  column, shown grey in the session, and a set left unrated saves it (Utku, 15-16 Sep). Its cost is stated in
  `dist/RULES.md` 34: a stored rating no longer proves he rated that set.
- Parity needs Python 3.12 (installed at `/opt/homebrew/bin/python3.12`); compare against the branch's own base,
  never the moving tip.
- ryanbr's 15 Sep 04:07 comment on #2099 is unanswered; the reply is drafted in `dist/NEXT_PR.md`. Nothing is
  posted without Utku's yes, after his gym test.

**Lesson:** start every session with `bash dist/tools/upstream-check.sh` — within hours the maintainer pushed to
our branch and merged it, merged a Kotlin twin of our Swift, and repaired a gate our merge had left red. A clean
textual merge is not a green one: test the merge in a throwaway worktree with `verify.sh` (`NOOP_REPO=<worktree>`).

See [[noop-lift-log-project]], [[lift-log-pr-communication]], [[lift-log-verify-before-claiming]].
