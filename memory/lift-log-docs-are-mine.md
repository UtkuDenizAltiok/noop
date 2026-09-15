---
name: lift-log-docs-are-mine
description: "I own the Lift Log handbook (dist/, the public lift-log-handbook branch as a git worktree): keep STATE.md true every session and back it up, with memory, via dist/tools/backup.sh before the session ends."
metadata:
  node_type: memory
  type: feedback
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-15T13:37:42.209Z
---

Utku made me the owner of the Lift Log's documentation on 2 Sep 2026, and on 15 Sep asked for it to be a clean
handbook that fresh sessions — and anyone else improving his work — can start from.

**Why:** docs written from a compacted summary drift from what was built; only docs re-checked against the code
and updated before the session ends stay true.

**How to apply:**
- The handbook is `dist/` = a git worktree of the branch `lift-log-handbook` (README, STATE, RULES, WORKFLOW,
  FEATURE, NEXT_PR, BACKLOG, HISTORY, `tools/`, `memory/`). On a new machine:
  `git worktree add dist lift-log-handbook`, then `bash dist/tools/backup.sh --restore-memory`.
- Every session end: replace `STATE.md` with the truth, update whatever else changed (rules keep their numbers;
  events become one line in `HISTORY.md`), then `bash dist/tools/backup.sh "what changed"`.
- The branch is PUBLIC: drafts or anything personal go in `dist/private/` (ignored). Never commit `dist/` to a
  work branch. Settled science in `RULES.md` is not rewritten silently.

See [[noop-lift-log-project]], [[lift-log-verify-before-claiming]].
