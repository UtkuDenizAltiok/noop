# NOOP Lift Log — handbook

Everything behind the Lift Log that is not code: what it is, the rules it must keep, how a change is made,
verified, shipped and sent upstream, and where the work stands. The code lives in the app repository
[`UtkuDenizAltiok/noop`](https://github.com/UtkuDenizAltiok/noop) (a fork of
[`ryanbr/noop`](https://github.com/ryanbr/noop)); this handbook lives on its branch
[`lift-log-handbook`](https://github.com/UtkuDenizAltiok/noop/tree/lift-log-handbook).

The Lift Log is a gym log book inside NOOP, the offline WHOOP companion app: programs, a set-by-set session
sheet advanced by a double-tap on the strap, a Lock Screen Live Activity, and a few honest figures. Product
owner and gym tester: Utku Deniz Altiok. Engineering so far: AI coding sessions (Claude Code) working with him —
but nothing here depends on one person, machine or AI model: these pages, the tools and the fork's branches are
the whole project memory.

## Start a session — the prompt (any AI, any person)

Paste this as the first message of a new session, whoever you are and whatever AI you use. It works for someone
new to the project as well as for a fresh session after `/clear`; write your task under it, or leave it out to get
a status report first.

> You are working on the NOOP Lift Log, a gym log book inside NOOP (an offline WHOOP companion app). The project's
> complete memory is its handbook: the `lift-log-handbook` branch of https://github.com/UtkuDenizAltiok/noop, checked
> out locally at `~/Developer/noop/dist/`. Read `README.md`, then `STATE.md` (its "Now" section first), `RULES.md`
> and `WORKFLOW.md`; trust these pages over anything you assume or remember. If you can run commands: on a new
> machine follow README "Set up on a new machine"; then, from `~/Developer/noop`, run
> `bash dist/tools/checkpoint.sh status --net` and `bash dist/tools/upstream-check.sh`, and if "Now" has open steps
> follow README "After an interruption" before anything else. If you cannot run commands, say so and give me the
> exact commands to run. Then tell me in a few plain sentences where things stand and what is next, and do the task
> below if there is one. How we work: I am not a programmer — explain in plain language and make the technical
> decisions yourself; verify by running things, never by assuming; build exactly as narrow as I ask; write each
> long, public or hard-to-undo step into STATE.md "Now" before doing it and tick it after; ship every app change as
> a build on my GitHub releases page and tell me "just update" or "wipe" with its id; post nothing publicly (PR,
> comment, issue) without my yes; and before the session ends follow README "End a session".

## End a session — the prompt

When the conversation is nearly full (around 90%), or before stopping for the day, paste:

> We are near the end of this session. Follow `dist/README.md` → "End a session" now, then tell me it is safe to
> start a fresh session.

## The pages

| file | what it answers | changes |
|---|---|---|
| [`STATE.md`](STATE.md) | "Now": the work in flight, step by step; then where things stand upstream and on the fork, what is blocked, what is next | every step that matters |
| [`RULES.md`](RULES.md) | the numbered invariants and the settled decisions — break one and the feature is wrong | rarely |
| [`WORKFLOW.md`](WORKFLOW.md) | how work is done: Utku, continuity, verification, parity, PRs, builds, syncing, git hygiene | when a method changes |
| [`FEATURE.md`](FEATURE.md) | what the Lift Log does, and every file behind it on both platforms | with features |
| [`NEXT_PR.md`](NEXT_PR.md) | the prepared upstream PR, its reply, and the pre-flight checklist | per PR |
| [`BACKLOG.md`](BACKLOG.md) | verified open work, ordered by value | when items move |
| [`HISTORY.md`](HISTORY.md) | what happened upstream, and what each real gym session found | one line per event |
| `tools/` | `checkpoint.sh` · `upstream-check.sh` · `verify.sh` · `ship-build.sh` · `backup.sh` · `strap-log.py` · `oracle/` · `xcmerge.py` · `test-checkpoint.sh` — each explains itself in its first lines | when a method changes |
| `memory/` | Claude Code's own notes for this project, backed up by `backup.sh`. Plain Markdown; everything in them is also in these pages, so other tools can ignore them | via `backup.sh` |

The app repository's own `AGENTS.md` (read automatically by most AI coding tools) and `docs/CONTRIBUTING.md` hold
upstream's rules for all code; these pages add what the Lift Log and this fork need.

## Working with any AI

- **What the AI needs:** to read files and run shell commands on a Mac (Claude Code, Codex, Gemini CLI, Cursor,
  Aider and the like all can). A chat-only AI can read these pages — they are public on GitHub — and plan, but a
  person then runs the commands it names.
- **The memory is these pages, never the AI's own.** An AI's built-in memory or chat history is a convenience at
  best; anything that matters is written here (`WORKFLOW.md` §2).
- **Tool-specific extras are optional and marked.** Claude Code: its notes in `memory/` (restored with
  `backup.sh --restore-memory`) and automatic checkpoints (`checkpoint.sh install-hooks`, installed on Utku's Mac).
  Any other tool: run `checkpoint.sh status --net` at the start and `checkpoint.sh save "what"` after each
  milestone yourself — the same discipline, by hand.

## Set up on a new machine

```bash
git clone https://github.com/UtkuDenizAltiok/noop.git ~/Developer/noop && cd ~/Developer/noop
git remote add upstream https://github.com/ryanbr/noop.git && git fetch --all
git worktree add dist lift-log-handbook     # this handbook, in the app repo's gitignored dist/
git checkout lift-log-follow-ups            # or whatever STATE.md's "Work branch" says
bash dist/tools/backup.sh --restore-memory  # Claude Code only
bash dist/tools/checkpoint.sh install-hooks # Claude Code only, optional: automatic checkpoints (WORKFLOW.md §2)
```
Requires a Mac with Xcode (license accepted; after every Xcode update open Xcode once and agree, and install an
iOS Simulator runtime), `brew install xcodegen gh python@3.12`, and `gh auth login`. Python 3.12 is what the
parity tools need; macOS ships 3.9, which runs only `strap-log.py`. No Android SDK is needed: Android runs in the
fork's CI.

**Access.** Reading needs nothing. Pushing branches, shipping builds to the releases page and backing up this
handbook need write access to `UtkuDenizAltiok/noop` (Utku adds a collaborator). Opening upstream PRs needs a
GitHub account and Utku's yes (`WORKFLOW.md` §1, §5).


## Every session

1. Read `STATE.md` — its "Now" section first — then `RULES.md`; skim `WORKFLOW.md` if the task touches something new.
2. `bash dist/tools/checkpoint.sh status --net`. If "Now" has open steps, follow "After an interruption" below
   before anything else. Then `bash dist/tools/upstream-check.sh` — the maintainers merge fast and add twins of our
   code.
3. Work, journal first (`WORKFLOW.md` §2): write each long, public or hard-to-undo step into "Now" before it starts
   and tick it with its result when it ends; `bash dist/tools/checkpoint.sh save "what"` after each milestone.
   Verify with `bash dist/tools/verify.sh`. Ship with `bash dist/tools/ship-build.sh`.
4. After a milestone that took real work: bring `STATE.md` (and any page that changed) up to date, then
   `bash dist/tools/backup.sh "what changed"`. At the end, "End a session" below.

## End a session

Before a fresh session (`/clear`, a new chat, another person), so it can start from these pages alone:

1. **Park safely.** Start nothing new. A job still running (a build, CI, a verify) is either waited for or written
   into "Now" with its id and how to check it.
2. **Settle "Now" in `STATE.md`.** Each finished step becomes one dated line in `HISTORY.md`; an unfinished one
   stays unticked, saying what proves whether it happened; "Next safe action" says exactly where to resume. With
   nothing in flight, "Now" says so.
3. **Make the rest of `STATE.md` true:** the work branch and its commit, the build on Utku's phone, the PRs, what is
   verified, what is next.
4. **Update any other page whose facts changed:** `RULES.md` (a new decision), `FEATURE.md` (files), `WORKFLOW.md`
   (a method), `BACKLOG.md`, `NEXT_PR.md`. Claude Code only: its memory notes, if a lasting fact changed.
5. **Upload:** `bash dist/tools/backup.sh "what changed"`.
6. **Check:** `bash dist/tools/checkpoint.sh status --net` shows the journal as intended, nothing unsaved or not
   uploaded in the handbook, every worktree clean and pushed (or its state named in "Now"), and no stray job.
7. **Tell Utku** in plain words what was done, what is next, and that it is safe to start fresh.

## After an interruption

A usage limit, a server error, a compaction of the conversation, a crash or a new session: the work may have
stopped anywhere, and a summary of the conversation may be wrong. These pages and the tools, not recollection,
say where it stands. In order:

1. **See what is true:** `bash dist/tools/checkpoint.sh status --net` — the open journal steps, unsaved or unuploaded
   handbook changes, each worktree (branch, commit, pushed or not, uncommitted files, an unfinished rebase or merge,
   leftover safety refs), jobs still running, the last events (verify, ship, backup, checkpoints, interruptions),
   fork CI, the build on the releases page, our upstream PRs.
2. **Settle each open step in "Now"** against that evidence (and `git log`, `gh pr list`, the release title): if it
   happened, tick it with its result; if not, it is still to do; if it is half-done (a build running, a push that
   did not land), finish or undo that one step.
3. **Never repeat a public or outward step without evidence that it did not happen** — a push, a build, a PR, a
   comment, anything in Utku's name. A job still running is waited on, not restarted; a waiter left behind by the
   old session is stopped.
4. **Uncommitted code** in a worktree is read (`git diff`) before anything else touches that worktree.
5. **Still unsure?** The AI tool's own session history is the last resort (Claude Code's: `WORKFLOW.md` §3).
   Otherwise ask Utku.
6. Continue from "Next safe action", updating "Now" as you go.

## The rules that matter most

- **Offline, on-device, no invented numbers.** Effort stays heart-rate measured; every figure is arithmetic the
  user can redo; estimates say "estimated" (`RULES.md` 7, 23, 24).
- **Swift and Kotlin move together.** A change to the lift figures changes `LiftMetrics.kt` and regenerates its
  oracle from the real Swift in the same PR (`RULES.md` 33; `WORKFLOW.md` §4).
- **Verify by running.** A test is seen to fail without its fix; a rebase is proven to keep content; parity
  ledger, ratchet and governance are run, not assumed (`WORKFLOW.md` §3–4).
- **Real gym sessions find the bugs that matter.** Ship a build after every change — it must appear on the
  fork's releases page — and ask what happened before trusting any list (`HISTORY.md`).
- **The Lift Log is an addition to NOOP, built from NOOP's parts.** It uses NOOP's strap log, buzz, double-tap,
  workouts and design tokens rather than copies of them; upstream's fundamentals (logging, BLE plumbing beyond
  the double-tap path, other screens) are not changed for it; a request is built exactly as narrow as Utku
  words it (`RULES.md` settled decisions; `WORKFLOW.md` §1).
- **The memory is written down.** Each step that matters goes into `STATE.md` "Now" before it happens; nothing
  needed later lives only in a conversation, a scratch folder or an AI's own memory (`WORKFLOW.md` §2).
- **The fork stays exact** — a mirror `main`, the work branch, the build branch, this handbook, and a branch per
  open upstream PR — and this branch is public: nothing personal, no unapproved drafts (`WORKFLOW.md` §8).
