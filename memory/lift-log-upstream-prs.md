---
name: lift-log-upstream-prs
description: "Where the Lift Log stands upstream — #2098, #2099, #2232, #2233 merged; three stacked branches on a56840bb (tip lift-log-gym-round-3 @ 65b804a6) to open as ONE PR (lift-log-follow-ups) with Utku's yes; a separate strap-log PR branch (strap-log-on-disk) also waits on his yes. Full state in dist/STATE.md."
metadata:
  node_type: memory
  type: project
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-16T21:28:24.168Z
---

**The source of truth is `dist/STATE.md`** in the `lift-log-handbook` worktree. This memory keeps only the facts
that must survive if the handbook is missing (21 Sep 2026):

- Merged upstream: #2098 schema, #2099 app (with ryanbr's empty-session guard `fed714cb`), #2232 the
  maintainers' Kotlin `LiftMetrics` twin, #2233 their parity-governance repair (#2229 blamed #2099 for leaving
  that gate red).
- Three stacked branches, rebased on `a56840bb` (21 Sep), to be opened as ONE PR from a new branch
  `lift-log-follow-ups` at the tip (decided 21 Sep: round 4 rewrote how finishing treats done sets, so separate
  PRs would review replaced behaviour). The first branch carries the parity refresh commit; with it the full
  `verify.sh` passes on the tip, governance included. Details and the PR body: `dist/NEXT_PR.md`.
- Round 4 (Utku, 21 Sep): knock window 5 s; a done set is complete without asking; each program line takes its
  heaviest done set at Save, automatically; the Lock Screen lights whenever NOOP is off screen (not gated on
  "locked"); each strap step logs its light-up; no sync banner during a session; banner layout.
- Round 5 (gym 21 Sep evening): iOS relaunched NOOP in the background 4x in 28 min and the root view's first push
  ENDED the Lock Screen banner (RULES 41: resume in `StrandiOSApp.init`); add an exercise mid-session (RULES 42);
  the bar laid out like the Lock Screen; running clocks via `ActiveWorkoutClock.clock`. 22 Sep: the 4 restarts were
  iOS `cpu_resource_fatal` kills (background CPU) — the session's once-a-second tick redrew SwiftUI app-wide; fixed
  with no tick at all (RULES 43, `65b804a6`), build `f7638bf`.
- A SEPARATE PR, not part of the Lift Log's: branch `strap-log-on-disk` (`2bfef51e`, on `a56840bb`, worktree
  `~/Developer/noop-strap-log`) — the strap log appended to disk per app run within 2 MB, Swift + Kotlin twin,
  replacing the 3 × 1,000-line ring. Utku asked for it 22 Sep; open it only with his yes (`dist/NEXT_PR.md`).
- Max RPE (1-10) per program line: typed in the editor or imported from the template's `Target max RPE`
  column, shown grey in the session, and a set left unrated saves it (Utku, 15-16 Sep). Its cost is stated in
  `dist/RULES.md` 34: a stored rating no longer proves he rated that set.
- Parity needs Python 3.12 (installed at `/opt/homebrew/bin/python3.12`); compare against the branch's own base,
  never the moving tip.
- ryanbr's 15 Sep 04:07 comment on #2099 is unanswered; the reply is drafted in `dist/NEXT_PR.md`. Nothing is
  posted without Utku's yes.

**Lesson:** start every session with `bash dist/tools/upstream-check.sh` — within hours the maintainer pushed to
our branch and merged it, merged a Kotlin twin of our Swift, and repaired a gate our merge had left red. A clean
textual merge is not a green one: test the merge in a throwaway worktree with `verify.sh` (`NOOP_REPO=<worktree>`).

See [[noop-lift-log-project]], [[lift-log-pr-communication]], [[lift-log-verify-before-claiming]].
