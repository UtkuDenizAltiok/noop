# NOOP — handbook

Everything behind this fork's work on NOOP that is not code: the purpose, the rules, how a change is made, measured,
verified, shipped and sent upstream, and where the work stands. The code lives in
[`UtkuDenizAltiok/noop`](https://github.com/UtkuDenizAltiok/noop), a fork of [`ryanbr/noop`](https://github.com/ryanbr/noop);
this handbook lives on its branch [`handbook`](https://github.com/UtkuDenizAltiok/noop/tree/handbook).

NOOP is an offline, on-device companion app for WHOOP straps: it pairs over Bluetooth, keeps everything on the phone
and computes recovery, strain, HRV and sleep itself. **The journey (since 24 Sep 2026): make the whole of NOOP the best
app for WHOOP straps** — correct, fast, low usage on the phone and the strap, clean code, and better measurements and
algorithms wherever evidence supports them. Product owner and tester: Utku Deniz Altiok (a WHOOP 5.0 on an iPhone).
Engineering: AI coding sessions (Claude Code) working with him — but nothing here depends on one person, machine or AI
model: these pages, the tools and the fork's branches are the whole project memory. The first journey (the Lift Log
and the Live HR banner, 2–24 Sep 2026) is finished; `features/` keeps what it built.

## Start a session — the prompt (any AI, any person)

Paste this as the first message of a new session, whoever you are and whatever AI you use; write a task under it, or
leave it out and the session continues with the next item.

> You are working on NOOP, an offline companion app for WHOOP straps (fork https://github.com/UtkuDenizAltiok/noop of
> ryanbr/noop). Our journey: make the whole of NOOP the best app for WHOOP straps — perfect, optimized, clean, sleek,
> efficient, fast and low usage (memory, CPU, GPU, battery) on both the strap and the iPhone, with better algorithms and
> biometrics wherever the evidence supports it. You are the owner and decider of the technical work. The project's
> complete memory is its handbook: the `handbook` branch of that fork, checked out locally at `~/Developer/noop/dist/`.
> Read `README.md`, then `STATE.md` (its "Now" section first), `RULES.md`, `WORKFLOW.md` and `BACKLOG.md`; trust these
> pages over anything you assume or remember. If you can run commands: on a new machine follow README "Set up on a new
> machine"; then, from `~/Developer/noop`, run `bash dist/tools/checkpoint.sh status --net` and
> `bash dist/tools/upstream-check.sh`, and if "Now" has open steps follow README "After an interruption" before
> anything else. If you cannot run commands, say so and give me the exact commands to run. Then tell me in a few plain
> sentences where things stand and what is next, and carry on with the next item unless I give you a task below. How
> we work: I am not a programmer — explain in plain language and make the technical decisions yourself; verify by
> running things, never by assuming; measure before and after every optimisation; write each long, public or
> hard-to-undo step into `STATE.md` "Now" before doing it and tick it after; ship every app change as a build on my
> GitHub releases page and tell me "just update" or "wipe" with its id; you may push our branches, reply on our PRs and
> open PRs for this journey's work once verified, but ask me before any new issue or any comment elsewhere; and before
> the session ends follow README "End a session".

## End a session — the prompt

When the conversation is nearly full (around 90%), or before stopping for the day, paste:

> We are near the end of this session. Follow `dist/README.md` → "End a session" now, then tell me it is safe to
> start a fresh session.

## The pages

| file | what it answers | changes |
|---|---|---|
| [`STATE.md`](STATE.md) | "Now": the work in flight, step by step; then our PRs, the fork, the build on Utku's phone, what is verified, what is next | every step that matters |
| [`RULES.md`](RULES.md) | the mandate, the settled decisions and the numbered engineering rules — break one and the change is wrong | rarely |
| [`WORKFLOW.md`](WORKFLOW.md) | how work is done: Utku, continuity, verification, reading a strap log, parity, PRs, builds, syncing, git, measuring usage | when a method changes |
| [`BACKLOG.md`](BACKLOG.md) | what to improve next, ordered by value, each with its evidence | when items move |
| [`HISTORY.md`](HISTORY.md) | what happened, one line per event, both journeys | one line per event |
| [`features/`](features) | finished features and the rules that keep them right: `lift-log.md` (the gym log book), `live-hr-banner.md` | when one changes |
| `tools/` | `checkpoint.sh` · `upstream-check.sh` · `verify.sh` · `ship-build.sh` · `backup.sh` · `strap-log.py` · `hr-timeline.py` · `oracle/` · `xcmerge.py` · `test-checkpoint.sh` — each explains itself in its first lines | when a method changes |
| `memory/` | Claude Code's own notes for this project, backed up by `backup.sh`; everything in them is also in these pages | via `backup.sh` |

The app repository's own `AGENTS.md` (read automatically by most AI coding tools) and `docs/CONTRIBUTING.md` hold
upstream's rules for all code; these pages add what this fork and Utku need.

## Working with any AI

- **What the AI needs:** to read files and run shell commands on a Mac with Xcode (Claude Code, Codex, Gemini CLI,
  Cursor, Aider and the like). A chat-only AI can read these pages — they are public — and plan, but a person then runs
  the commands it names.
- **The memory is these pages, never the AI's own.** An AI's built-in memory or chat history is a convenience at best;
  anything that matters is written here (`WORKFLOW.md` §2).
- **Tool-specific extras are optional and marked.** Claude Code: its notes in `memory/` (restored with
  `backup.sh --restore-memory`) and automatic checkpoints (`checkpoint.sh install-hooks`, installed on Utku's Mac). Any
  other tool: run `checkpoint.sh status --net` at the start and `checkpoint.sh save "what"` after each milestone.

## Set up on a new machine

```bash
git clone https://github.com/UtkuDenizAltiok/noop.git ~/Developer/noop && cd ~/Developer/noop
git remote add upstream https://github.com/ryanbr/noop.git && git fetch --all
git worktree add dist handbook                  # this handbook, in the app repo's gitignored dist/
git worktree add ../noop-<name> <branch>        # one per open PR listed in STATE.md
bash dist/tools/backup.sh --restore-memory      # Claude Code only
bash dist/tools/checkpoint.sh install-hooks     # Claude Code only, optional: automatic checkpoints (WORKFLOW.md §2)
```
Requires a Mac with Xcode (license accepted; after every Xcode update open Xcode once and agree, and install an iOS
Simulator runtime), `brew install xcodegen gh python@3.12`, and `gh auth login`. Python 3.12 is what the parity tools
need. No Android SDK is needed locally: Android runs in the fork's CI.

**Access.** Reading needs nothing. Pushing branches, shipping builds to the releases page and backing up this handbook
need write access to `UtkuDenizAltiok/noop` (Utku adds a collaborator). Opening upstream PRs needs a GitHub account.

## Every session

1. Read `STATE.md` — its "Now" section first — then `RULES.md`; `WORKFLOW.md` and `BACKLOG.md` when starting work.
2. `bash dist/tools/checkpoint.sh status --net`. If "Now" has open steps, follow "After an interruption" below before
   anything else. Then `bash dist/tools/upstream-check.sh`: the maintainers merge fast and fix things themselves.
3. Work, journal first (`WORKFLOW.md` §2): measure, change, verify (`verify.sh`), ship (`ship-build.sh`), and write
   each long, public or hard-to-undo step into "Now" before it starts; `checkpoint.sh save "what"` after each
   milestone.
4. After a milestone that took real work: bring `STATE.md` (and any page that changed) up to date, then
   `bash dist/tools/backup.sh "what changed"`. At the end, "End a session" below.

## End a session

Before a fresh session (`/clear`, a new chat, another person), so it can start from these pages alone:

1. **Park safely.** Start nothing new. A job still running (a build, CI, a verify) is either waited for or written into
   "Now" with its id and how to check it.
2. **Settle "Now" in `STATE.md`.** Each finished step becomes one line in `HISTORY.md`; an unfinished one stays
   unticked, saying what proves whether it happened; "Next safe action" says exactly where to resume. With nothing in
   flight, "Now" says so.
3. **Make the rest of `STATE.md` true:** our PRs, the testing stack and the build on Utku's phone, what is verified,
   what is next.
4. **Update any other page whose facts changed:** `RULES.md` (a new decision), `WORKFLOW.md` (a method), `BACKLOG.md`,
   `features/`. Claude Code only: its memory notes, if a lasting fact changed.
5. **Upload:** `bash dist/tools/backup.sh "what changed"`.
6. **Check:** `bash dist/tools/checkpoint.sh status --net` shows the journal as intended, nothing unsaved or not
   uploaded in the handbook, every worktree clean and pushed (or its state named in "Now"), and no stray job.
7. **Tell Utku** in plain words what was done, what is next, and that it is safe to start fresh.

## After an interruption

A usage limit, a server error, a compaction of the conversation, a crash or a new session: the work may have stopped
anywhere, and a summary of the conversation may be wrong. These pages and the tools, not recollection, say where it
stands. In order:

1. **See what is true:** `bash dist/tools/checkpoint.sh status --net` — the open journal steps, unsaved or unuploaded
   handbook changes, each worktree (branch, commit, pushed or not, uncommitted files, an unfinished rebase or merge,
   leftover safety refs), jobs still running, the last events, fork CI, the build on the releases page, our PRs.
2. **Settle each open step in "Now"** against that evidence (and `git log`, `gh pr list`, the release title): if it
   happened, tick it with its result; if not, it is still to do; if it is half-done, finish or undo that one step.
3. **Never repeat a public or outward step without evidence that it did not happen** — a push, a build, a PR, a
   comment, anything in Utku's name. A job still running is waited on, not restarted.
4. **Uncommitted code** in a worktree is read (`git diff`) before anything else touches that worktree.
5. **Still unsure?** The AI tool's own session history is the last resort (Claude Code's: `WORKFLOW.md` §3). Otherwise
   ask Utku.
6. Continue from "Next safe action", updating "Now" as you go.

## The rules that matter most

- **Offline, on-device, no invented numbers** (`AGENTS.md`). A figure is shown only when it was measured; an estimate
  says so.
- **Measure before and after.** No usage claim without a number (`RULES.md` 1, `WORKFLOW.md` §11).
- **A physiological number changes only with evidence** that tracks a varying truth, never one matching night
  (`RULES.md` 2).
- **Swift and Kotlin move together**, byte-identical, proven by an oracle (`AGENTS.md`, `WORKFLOW.md` §4).
- **Verify by running.** A test is seen to fail without its fix; the whole `verify.sh` loop passes; BLE behaviour is
  proven on a real strap (`WORKFLOW.md` §3).
- **Every change reaches Utku's phone** as a build on his releases page, and real use decides (`RULES.md` 12).
- **The memory is written down.** Each step that matters goes into `STATE.md` "Now" before it happens (`WORKFLOW.md` §2).
- **The fork stays exact** — a mirror `main`, a branch per open PR, the testing stack and build, this handbook — and
  this branch is public: nothing personal, no unapproved drafts (`WORKFLOW.md` §8).
