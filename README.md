# NOOP — our project handbook

The mission is to make NOOP the best WHOOP companion app: correct, reliable, efficient, optimised, clean and sleek,
with biometrics as close to measured truth as the evidence supports. NOOP runs offline and on the device. The work
covers the app, its algorithms, storage, connection, battery use and user experience; progress is judged by evidence
and real use.

Code: [UtkuDenizAltiok/noop](https://github.com/UtkuDenizAltiok/noop), forked from
[ryanbr/noop](https://github.com/ryanbr/noop). This handbook is on the fork's
[handbook branch](https://github.com/UtkuDenizAltiok/noop/tree/handbook), checked out at `~/Developer/noop/dist`.
The Lift Log and Live HR banner are finished features; their contracts live in `features/`.

## Working agreement — 6 October 2026

**ChatGPT/Codex owns the project work and decides its direction.** Utku has delegated prioritisation, product and
technical choices, implementation, verification, cleanup, releases and documentation. Decide routine matters and
complete the work. Explain what changed, why, what was verified and what Utku needs to do next in plain language.
Do not turn ordinary engineering or product choices into approval requests.

**Utku is our real-world tester and the source of user feedback.** He uses a WHOOP 5.0 and an iPhone, installs staging
builds with AltStore, and does not need to read code or use the terminal. Give him a short numbered sequence when his
phone, strap, direct observation or account approval is required. His later instructions and observed results prevail.
Record a changed decision with its reason so that future sessions do not revive an old choice.

Existing standing permission covers our branches, verified project PRs, replies on our own PRs, the handbook and
verified testing releases. Other public messages still require explicit authorisation. Upstream maintainers decide
what they merge; the fork can retain a justified product choice. Preserve upstream's scope, privacy, parity and
engineering rules. This agreement concerns this project; tool access comes from the current signed-in environment.

## The durable record

The handbook is the project memory, maintained locally and on GitHub. A new chat must be able to continue from these
files alone. There is no separate agent-memory copy to keep in sync. Removed duplicate memories remain recoverable
from Git history. The app checkout's `AGENTS.md` and `docs/CONTRIBUTING.md` hold upstream's rules.

| File | Purpose |
|---|---|
| [AGENTS.md](AGENTS.md) | Short instructions for ChatGPT/Codex; entry point for every session |
| [STATE.md](STATE.md) | Work in flight, PRs, branches, releases, verified evidence and the next action |
| [RULES.md](RULES.md) | Mandate, delegated authority, settled decisions and stable engineering rules |
| [WORKFLOW.md](WORKFLOW.md) | How to verify, measure, communicate, maintain Git and ship |
| [BACKLOG.md](BACKLOG.md) | Specific investigations and improvements, ordered using current evidence |
| [HISTORY.md](HISTORY.md) | Finished milestones and lessons, one line per event |
| [features/](features/) | Contracts for the finished Lift Log and Live HR banner |
| [tools/](tools/) | Checkpoint, backup, upstream checks, Codex setup, verification, shipping and measurement helpers |
| `private/` | Ignored local evidence and drafts; never uploaded |

## Start a session

Local Codex entry files are installed by `tools/codex-setup.sh` in every code worktree. They require reading both
upstream's `AGENTS.md` and this handbook's `AGENTS.md`, without adding fork instructions to the upstream mirror.
Codex's instruction-file discovery is described in [official OpenAI documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
Run the installer again after creating a new code worktree. A fresh clone on another machine needs the setup below.

1. Read this README, `STATE.md` (Now first), `RULES.md`, `WORKFLOW.md` and `BACKLOG.md`.
2. From `~/Developer/noop`, run `bash dist/tools/checkpoint.sh status --net` and `bash dist/tools/upstream-check.sh`.
3. If Now has unfinished steps, follow "After an interruption" before doing anything new.
4. Choose the next task from State, the backlog and current evidence. A task supplied by Utku takes precedence.
5. Journal each long, public or hard-to-undo step before acting; checkpoint after milestones; upload at meaningful milestones.

Utku can start a chat in the NOOP project with simply:

> Continue NOOP. Read the handbook, check the current state, choose the next task and carry it through. Explain plainly
> and give me the next steps when you need my phone or strap.

## Set up on a new machine

Use a Mac with Xcode, its accepted license, completed first-launch setup and an installed iOS Simulator runtime.
Install `xcodegen`, `gh` and `python@3.12` through Homebrew; sign in with `gh auth login`.
Android validation runs in the fork's CI; no local Android SDK is required for this workflow.

```bash
git clone https://github.com/UtkuDenizAltiok/noop.git ~/Developer/noop
cd ~/Developer/noop
git remote add upstream https://github.com/ryanbr/noop.git
git fetch --all
git worktree add dist handbook
# Add one sibling worktree per open PR in STATE.md, then:
bash dist/tools/codex-setup.sh
gh auth status
git push --dry-run origin main
bash dist/tools/checkpoint.sh status --net
bash dist/tools/upstream-check.sh
bash dist/tools/verify.sh --quick
```

Configure the Git author to the person whose account is contributing. Write access to the fork is required for
backups, branches and releases. A public read-only clone is enough for reading. Run the full verification and build
both Apple app targets when changing app code. Build folders and logs belong under `~/Library/Caches/noop-handbook`.

## After an interruption

1. Run `checkpoint.sh status --net`. Read Now against the actual Git state, jobs, CI, PRs and release assets.
2. Read every uncommitted code diff before touching it. Settle each open step with evidence: completed, pending or partly done.
3. Never repeat a push, PR, comment, release or long-running job merely because the conversation summary is incomplete.
4. Use `checkpoint.sh brief` for the local recovery brief. The event log is in ignored `private/events.log`.
5. Resume from the next safe action. Chat history is a last resort, not the project record.

## End a session

1. Park safely. Wait for running work or name it in Now with its ID and how to check it.
2. Move finished steps into History and make State true. Leave unfinished steps with clear evidence and the next action.
3. Update any rules, workflow, backlog or feature contracts whose facts changed.
4. Run `bash dist/tools/backup.sh "what changed"` to upload the handbook; it folds local checkpoints into one milestone.
5. Run `bash dist/tools/checkpoint.sh status --net`: clean/pushed worktrees, saved/uploaded handbook and no stray jobs,
   or explicitly record each exception in Now.
6. Tell Utku what is ready, what remains and the next action. Say when it is safe to start a fresh chat.

## What makes a change worth shipping

Correctness and data integrity come first. Reduce CPU, memory, rendering and radio cost while preserving results and
freshness. Validate physiological changes against ground truth across varied recordings, not one matching night.
Improve clarity and usability alongside those fixes. Clean up code when it removes real duplication or risk.
Keep Swift/Kotlin analytics and stored data byte-identical, build both Apple targets, and test strap behaviour on
hardware. App changes reach Utku as a verified testing release with "just update" or "wipe" and its build ID.
Handbook-only changes need no app release. The detailed evidence and procedures live in Rules and Workflow.
