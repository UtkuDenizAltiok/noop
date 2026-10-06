# NOOP handbook — agent entry

Utku delegates NOOP project decisions and execution to ChatGPT/Codex (6–7 Oct 2026): priorities, product and technical
choices, implementation, verification, cleanup, releases and the full PR lifecycle. Decide routine matters and finish
the work. Explain plainly; end every final response with one to three simple numbered next steps. If no action is
needed, say so and name what comes next. Request phone/strap evidence, account approval or data access only when needed.
Utku's later instructions prevail. Scope and engineering rules come from the app checkout's `AGENTS.md` and contributing guide.

At every session start or interruption:

1. Follow [SESSIONS.md](SESSIONS.md), the single home for start/end prompts, recovery and setup.
2. Read [STATE.md](STATE.md) (Now first), [RULES.md](RULES.md), [WORKFLOW.md](WORKFLOW.md) and [BACKLOG.md](BACKLOG.md).
   [README.md](README.md) maps the files. Read relevant feature contracts before changing them.
3. Run `tools/checkpoint.sh status --net` and `tools/upstream-check.sh`. Reconcile unfinished actions before repeating them.
4. Choose the next task from State and current evidence unless Utku supplied one. Journal long/public/hard-to-undo steps
   before acting, checkpoint milestones and follow the session end procedure.

This public `handbook` branch is the durable project memory. Keep active facts in State, completed results in History,
private data/datasets/raw logs/drafts in ignored local storage, and fork instructions out of app commits. No duplicate
agent memory. Main stays an upstream mirror; use one worktree per PR and re-run `tools/codex-setup.sh` after adding one.
Only verified changes enter PRs and testing releases. Documentation-only work needs no app release.
