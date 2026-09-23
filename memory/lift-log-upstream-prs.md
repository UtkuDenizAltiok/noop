---
name: lift-log-upstream-prs
description: "Where the Lift Log stands upstream — #2098, #2099, #2232, #2233, #2386 merged; the Lift Log follow-up #2403 and the diagnostics PR #2402 both MERGED 23 Sep; NOOP optimisation PRs #2415, #2416 open. Full state in dist/STATE.md."
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
- **#2403 MERGED 23 Sep** as `3ada90c3` (rounds 3-6: the finish flow, max RPE, knock guard, next-set line, adding
  an exercise mid-session, the Lock Screen light-up and restart survival, no work between taps, the Dynamic Island,
  the banner's push rate, stamped log lines). Squash proven equal over 55 files; branch deleted; the app repo sits
  on `main`. The reply on merged #2099 was posted the same night, with Utku's yes.
- **#2402 MERGED 23 Sep** as `94a71b04` (upstream's standard-HR log line summarised; not the Lift Log's). ryanbr
  rebased our branch himself before merging — proven same content; branch and worktree removed. #2386 merged 22 Sep.
  Build `8351bc7` (23 Sep, = upstream main) carries both. NOOP optimisation PRs OPEN since 23 Sep: #2415 (Live HR banner
  pushes) and #2416 (workout HR once a second); cleanup + stress PRs prepared, need his yes — see `dist/STATE.md`.
- Round 4 (Utku, 21 Sep): knock window 5 s; a done set is complete without asking; each program line takes its
  heaviest done set at Save, automatically; the Lock Screen lights whenever NOOP is off screen (not gated on
  "locked"); each strap step logs its light-up; no sync banner during a session; banner layout.
- Round 5 (gym 21 Sep evening): iOS relaunched NOOP in the background 4x in 28 min and the root view's first push
  ENDED the Lock Screen banner (RULES 41: resume in `StrandiOSApp.init`); add an exercise mid-session (RULES 42);
  the bar laid out like the Lock Screen; running clocks via `ActiveWorkoutClock.clock`. 22 Sep: the 4 restarts were
  iOS `cpu_resource_fatal` kills (background CPU) — the session's once-a-second tick redrew SwiftUI app-wide; fixed
  with no tick at all (RULES 43, `65b804a6`), build `f7638bf`.
- A SEPARATE PR, not part of the Lift Log's: **#2386, opened 22 Sep 2026 with Utku's yes** (branch
  `strap-log-on-disk`, head `23bee21a`, worktree `~/Developer/noop-strap-log`; ryanbr approving, his one finding
  fixed and replied to on 22 Sep) — the strap log appended to disk
  per app run within 2 MB, Swift + Kotlin twin, replacing the 3 × 1,000-line ring. Never open it again; follow its
  comments per [[lift-log-pr-communication]].
- Max RPE (1-10) per program line: typed in the editor or imported from the template's `Target max RPE`
  column, shown grey in the session, and a set left unrated saves it (Utku, 15-16 Sep). Its cost is stated in
  `dist/RULES.md` 34: a stored rating no longer proves he rated that set.
- Parity needs Python 3.12 (installed at `/opt/homebrew/bin/python3.12`); compare against the branch's own base,
  never the moving tip.
- ryanbr's 15 Sep 04:07 comment on #2099 was answered 23 Sep 03:48 with Utku's yes. Nothing is posted without
  his yes.

**Lesson:** start every session with `bash dist/tools/upstream-check.sh` — within hours the maintainer pushed to
our branch and merged it, merged a Kotlin twin of our Swift, and repaired a gate our merge had left red. A clean
textual merge is not a green one: test the merge in a throwaway worktree with `verify.sh` (`NOOP_REPO=<worktree>`).

See [[noop-lift-log-project]], [[lift-log-pr-communication]], [[lift-log-verify-before-claiming]].
