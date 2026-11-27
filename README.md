# NOOP handbook

The project memory of **NOOP 13** ([UtkuDenizAltiok/noop](https://github.com/UtkuDenizAltiok/noop)), kept on the
public `handbook` branch. Start with [AGENTS.md](AGENTS.md); it says what NOOP 13 is and the reading order.

| Need | Read |
|---|---|
| What is true now, and the next safe action | [State](STATE.md) |
| The owner's decisions and the engineering rules | [Rules](RULES.md) |
| Verifying, parity, builds for the owner's phone, privacy | [Workflow](WORKFLOW.md) |
| Ready prompts and the start / finish procedure | [Sessions](SESSIONS.md) |
| What to build next, with its evidence | [Backlog](BACKLOG.md) |
| What was done, by date | [History](HISTORY.md) |
| Simple mode: design v6, how each step was built, the science table | [Simple mode](features/simple-mode.md), its [diary](features/simple-mode-diary.md) |
| Feature contracts | [Lift Log](features/lift-log.md), [Live HR banner](features/live-hr-banner.md), [High heart rate warning](features/high-hr-warning.md), [Developer loop](features/lab.md) |
| Audits with runnable evidence (synthetic data) | [`audits/`](audits/) |
| Commands and helpers | [`tools/`](tools/) (`tools/retired/`: kept, no longer used) |

## The folders on the owner's Mac

```
~/Developer/noop/                 one folder for everything NOOP (a plain folder, not a repository)
  app/                            the app: clone of UtkuDenizAltiok/noop, branch main (public)
  app/dist -> ../handbook         a link, so instructions written as dist/... keep working from app/
  handbook/                       this handbook: a git worktree of the same repository, branch handbook (public)
  handbook/private -> ../noop-private-utku    the tools' local log and inbox (ignored by git)
  noop-private-utku/              the owner's private files: never committed, never published
  datasets/                       public research datasets (PhysioNet sleep-accel), re-downloadable
~/Library/Caches/noop-handbook/   build products and logs, rebuildable (Workflow → Caches)
```

Rules for this branch: one subject has one home and other pages link to it; State holds current facts only,
Backlog unbuilt candidates, History finished work; rule numbers never change (a retired rule is marked); nothing
personal of the owner is ever written here (Workflow → Privacy).
