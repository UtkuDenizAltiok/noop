---
name: noop-handbook-is-mine
description: "I own the NOOP handbook (dist/, public branch handbook): journal each long/public/hard-to-undo step in STATE.md \"Now\" BEFORE doing it, checkpoint.sh save after milestones, backup.sh at milestones; after ANY interruption run checkpoint.sh status --net and settle \"Now\" before acting."
metadata:
  node_type: memory
  type: feedback
  originSessionId: ed340050-008d-44ae-be66-66b9c198334f
  modified: 2026-09-24T12:36:30.104Z
---

Utku made me the owner of the documentation (2 Sep 2026) and of the whole journey (24 Sep 2026), and wants a handbook
that any fresh session, person or AI can start from.

**Why:** docs written from a compacted summary drift from what was built; on 22 Sep a usage limit, a server error and a
compaction left the handbook seven hours behind the work.

**How to apply:**
- The handbook is `dist/` = a worktree of the public branch `handbook`: README (start and end prompts), STATE, RULES,
  WORKFLOW, BACKLOG, HISTORY, `features/` (finished features: lift-log, live-hr-banner), `tools/`, `memory/`. On a new
  machine: `git worktree add dist handbook`, then `bash dist/tools/backup.sh --restore-memory`.
- **Journal first:** before a long, public or hard-to-undo step, write it in `STATE.md` "Now" with what will prove it
  (commit, run id, PR number) and tick it after; `checkpoint.sh save "what"` after each milestone; `backup.sh` after
  milestones and at the end.
- **After any interruption or compaction:** `bash dist/tools/checkpoint.sh status --net`, then README "After an
  interruption": settle every open step against evidence; never repeat a push, build, PR or comment without evidence
  it did not happen. "Continue" after an interruption is an instruction: finish the open steps and report.
- The hooks (installed by Utku 22 Sep) print the recovery brief at session start and checkpoint after every reply;
  hook changes are his to run — the auto-mode guard blocks me from Claude's settings files.
- Session end: README "End a session" — STATE.md true, finished steps one line in HISTORY.md, backup, status check.
- The branch is PUBLIC: drafts and anything personal go in `dist/private/` (ignored). zsh mangles `$VAR:r…` in
  `"$SHA:refs/…"` — write `${SHA}:refs/…` or run the command with `bash -c`.

See [[noop-project]], [[noop-verify-before-claiming]].
