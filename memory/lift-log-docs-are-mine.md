---
name: lift-log-docs-are-mine
description: "I own the Lift Log handbook (dist/, the public lift-log-handbook branch): journal each step that matters in STATE.md \"Now\" BEFORE doing it, checkpoint.sh save after milestones, backup.sh at milestones; after ANY interruption (usage limit, server error, compaction, new session) run checkpoint.sh status --net and settle \"Now\" before acting."
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
- **Continuity (Utku, 22 Sep 2026, after a usage limit, a server error and a compaction left the handbook 7 h
  behind):** a session can stop anywhere, so the conversation is never the store. Before a long, public or
  hard-to-undo step, write it in `STATE.md` "Now" with what will prove it (commit, run id, PR number) and tick it
  after; `bash dist/tools/checkpoint.sh save "what"` after each milestone (local commit, instant); `backup.sh`
  after milestones, not only at the end. **After any interruption or compaction, first run
  `bash dist/tools/checkpoint.sh status --net` and follow README "After an interruption": settle every open step
  against evidence; never repeat a push, build, PR or comment without evidence it did not happen.** Utku
  installed the hooks on 22 Sep (`checkpoint.sh install-hooks`): a session starts with the recovery brief and the
  handbook is checkpointed after every reply. The auto-mode guard blocks the agent from Claude's settings (even
  reading them), so hook changes are always Utku's to run.
- Every session end: replace `STATE.md` with the truth, update whatever else changed (rules keep their numbers;
  events become one line in `HISTORY.md`), then `bash dist/tools/backup.sh "what changed"`.
- The branch is PUBLIC: drafts or anything personal go in `dist/private/` (ignored). Never commit `dist/` to a
  work branch. Settled science in `RULES.md` is not rewritten silently.

See [[noop-lift-log-project]], [[lift-log-verify-before-claiming]].
