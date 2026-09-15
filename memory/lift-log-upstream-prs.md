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
- Follow-up on `lift-log-discard-and-edit` @ `0a55bc8c` (one Save, discards as zeros fillable in Edit sets,
  add/remove in Edit sets, Kotlin twin in step), rebased on `c430ca0b` and pushed. Max-RPE branch
  `lift-log-target-rpe` @ `8f6c8f3d` stacked on it, pushed. Both verified on Xcode 27 except parity; the
  phone's testing build `f854fa5d` carries both (just update, no wipe), not yet gym-tested.
- Second PR, stacked: `lift-log-target-rpe` — a max RPE (1-10) per program line, shown grey "≤8" in the
  session, never saved as a rating, read from the template's `Target max RPE` column (Utku, 15 Sep).
- Before either PR: install Python 3.12 (needs Utku's yes) and run the guarded parity authority refresh — the
  new `isPerformed` twin pair drifts `function_pairs` — plus ratchet and governance tests. Also open:
  `WhoopStore.deleteLiftSets` is a new Swift-only function (#2163: dispositions cannot settle
  `add-unpaired-function`).
- ryanbr's 15 Sep 04:07 comment on #2099 is unanswered; the reply is drafted in `dist/NEXT_PR.md`. Nothing is
  posted without Utku's yes, after his gym test.

**Lesson:** start every session with `bash dist/tools/upstream-check.sh` — within hours the maintainer pushed to
our branch and merged it, merged a Kotlin twin of our Swift, and repaired a gate our merge had left red.

See [[noop-lift-log-project]], [[lift-log-pr-communication]], [[lift-log-verify-before-claiming]].
