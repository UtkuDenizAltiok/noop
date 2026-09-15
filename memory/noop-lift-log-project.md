---
name: noop-lift-log-project
description: "The NOOP Lift Log (gym log book) — Utku's feature going upstream to ryanbr/noop; start every session with the handbook in dist/ (worktree of branch lift-log-handbook): README, STATE, RULES."
metadata: 
  node_type: memory
  type: project
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-15T13:38:32.236Z
---

NOOP (`~/Developer/noop`; fork `UtkuDenizAltiok/noop`, upstream `ryanbr/noop`) is an offline WHOOP
companion app. The Lift Log is a gym log book built in it for Utku Deniz Altiok: programs, a set-by-set
session sheet, strap double-tap to finish a set, a Lock Screen Live Activity, and a few honest figures.
Its storage was merged upstream as #2098 on 14 Sep 2026 and the app as #2099 on 15 Sep 2026; later
changes go in follow-up PRs, currently branch `lift-log-discard-and-edit`.

**Start every session with the handbook in `dist/`** (a worktree of the public branch `lift-log-handbook`):
`dist/README.md`, `dist/STATE.md`, `dist/RULES.md`, then `bash dist/tools/upstream-check.sh` and `dist/WORKFLOW.md`.
The maintainers move fast, and since #2232 every Swift figure change must move its Kotlin twin in the same PR.

**Working arrangement.** Utku is not a programmer, does not read Swift and never uses the terminal. I
write all code, run all tooling, ship builds to his fork's Releases page and explain in plain language.
He tests at the gym on a WHOOP 5.0. His product judgement has corrected mine several times, so treat it
as authoritative. He wants me to decide technical questions myself, verify reviewers rather than obey
them, and keep this implementation unless a change is truly worth it. Time and tokens are not a
constraint for him; correctness is.

**This feature's bugs are silent wrong data, not crashes** — sets saving no numbers, 45.5 kg stored as
455, one figure computed two ways. All passed tests and builds; real gym sessions found them.

**The schema is now a shipped upstream migration (`v46-lift-log`, Room 40).** Any schema change is a new
migration with its Room twin, never an edit — the old "he wipes, so change the shape" freedom is gone.

See [[lift-log-upstream-prs]], [[lift-log-docs-are-mine]], [[lift-log-verify-before-claiming]],
[[lift-log-ship-the-build]], [[lift-log-pr-communication]].
