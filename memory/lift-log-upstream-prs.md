---
name: lift-log-upstream-prs
description: "Where the Lift Log stands upstream — #2098, #2099, #2232 (Kotlin twin) and #2233 (governance repair) merged; the follow-up is rebased but unverified (Xcode 27 license) and unopened. Full, current state lives in dist/STATE.md."
metadata:
  node_type: memory
  type: project
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-15T15:43:38.382Z
---

**The source of truth is `dist/STATE.md`** in the `lift-log-handbook` worktree. This memory keeps only the facts
that must survive if the handbook is missing (15 Sep 2026):

- Merged upstream: #2098 schema, #2099 app (with ryanbr's empty-session guard `fed714cb`), #2232 the
  maintainers' Kotlin `LiftMetrics` twin, #2233 their parity-governance repair (#2229 blamed #2099 for leaving
  that gate red).
- Follow-up on `lift-log-discard-and-edit` @ `1564578a` (one Save, discards as zeros fillable in Edit sets,
  add/remove in Edit sets, both Kotlin twins: `LiftMetrics` and `deleteLiftSets`). Max-RPE branch
  `lift-log-target-rpe` @ `858b8678` stacked on it, with a set left unrated saving the line's max RPE. Both
  pushed and verified (Xcode 27, Android CI green, ledger and ratchet clean against their base); the phone's
  testing build `4fda4266` carries both (just update, no wipe), not yet gym-tested.
- Parity governance is red on `upstream/main` itself (its authority does not reproduce after #2240), so neither
  PR touches `parity_twin_map.json`; the refresh goes in right after the PR-time rebase (`dist/NEXT_PR.md`).
- Max RPE (1-10) per program line: typed in the editor or imported from the template's `Target max RPE`
  column, shown grey in the session, and a set left unrated saves it (Utku, 15-16 Sep). Its cost is stated in
  `dist/RULES.md` 34: a stored rating no longer proves he rated that set.
- Parity needs Python 3.12 (installed at `/opt/homebrew/bin/python3.12`); compare against the branch's own base,
  never the moving tip.
- ryanbr's 15 Sep 04:07 comment on #2099 is unanswered; the reply is drafted in `dist/NEXT_PR.md`. Nothing is
  posted without Utku's yes, after his gym test.

**Lesson:** start every session with `bash dist/tools/upstream-check.sh` — within hours the maintainer pushed to
our branch and merged it, merged a Kotlin twin of our Swift, and repaired a gate our merge had left red.

See [[noop-lift-log-project]], [[lift-log-pr-communication]], [[lift-log-verify-before-claiming]].
