# NOOP Lift Log — handbook

Everything behind the Lift Log that is not code: what it is, the rules it must keep, how a change is made,
verified, shipped and sent upstream, and where the work stands. The code lives in the app repository
[`UtkuDenizAltiok/noop`](https://github.com/UtkuDenizAltiok/noop) (a fork of
[`ryanbr/noop`](https://github.com/ryanbr/noop)); this handbook lives on its branch `lift-log-handbook`.

The Lift Log is a gym log book inside NOOP, the offline WHOOP companion app: programs, a set-by-set session
sheet advanced by a double-tap on the strap, a Lock Screen Live Activity, and a few honest figures. Product
owner and gym tester: Utku Deniz Altiok. Engineering so far: Claude Code sessions working with him — but nothing
here depends on one person, machine or AI tool: these pages, the tools and the fork's branches are the whole
project memory.

## Start here

| file | what it answers | changes |
|---|---|---|
| [`STATE.md`](STATE.md) | where things stand upstream and on the fork, what is blocked, what is next | every session |
| [`RULES.md`](RULES.md) | the numbered invariants and the settled decisions — break one and the feature is wrong | rarely |
| [`WORKFLOW.md`](WORKFLOW.md) | how work is done: Utku, verification, parity, PRs, builds, syncing, git hygiene | when a method changes |
| [`FEATURE.md`](FEATURE.md) | what the Lift Log does, and every file behind it on both platforms | with features |
| [`NEXT_PR.md`](NEXT_PR.md) | the prepared upstream PR, its reply, and the pre-flight checklist | per PR |
| [`BACKLOG.md`](BACKLOG.md) | verified open work, ordered by value | when items move |
| [`HISTORY.md`](HISTORY.md) | what happened upstream, and what each real gym session found | one line per event |
| `tools/` | `upstream-check.sh` · `verify.sh` · `ship-build.sh` · `backup.sh` · `strap-log.py` · `oracle/` · `xcmerge.py` | when a method changes |
| `memory/` | Claude Code's memory files for this project, backed up by `backup.sh`. Plain Markdown: any agent may read them; everything in them is also in these pages | via `backup.sh` |

## Set up on a new machine

```bash
git clone https://github.com/UtkuDenizAltiok/noop.git ~/Developer/noop && cd ~/Developer/noop
git remote add upstream https://github.com/ryanbr/noop.git && git fetch --all
git worktree add dist lift-log-handbook     # this handbook, in the app repo's gitignored dist/
bash dist/tools/backup.sh --restore-memory  # Claude Code only
git checkout lift-log-gym-round-3           # or whatever STATE.md's "Work branch" says
```
Requires a Mac with Xcode (license accepted; after every Xcode update open Xcode once and agree, and install an
iOS Simulator runtime), `brew install xcodegen gh python@3.12`, and `gh auth login`. Python 3.12 is what the
parity tools need; macOS ships 3.9, which runs only `strap-log.py`. No Android SDK is needed: Android runs in the
fork's CI.

**Access.** Reading needs nothing. Pushing branches, shipping builds to the releases page and backing up this
handbook need write access to `UtkuDenizAltiok/noop` (Utku adds a collaborator). Opening upstream PRs needs a
GitHub account and Utku's yes (`WORKFLOW.md` §1, §5).

Verified 17 Sep 2026: a fresh clone of `lift-log-handbook` from GitHub carries the eight pages, `tools/` and
`memory/` (408 KB), `STATE.md` names the current build, and `tools/strap-log.py` runs from it on macOS's own
Python — nothing else is needed to pick the work up.

## Every session

1. Read `STATE.md`, then `RULES.md`; skim `WORKFLOW.md` if the task touches something new.
2. `bash dist/tools/upstream-check.sh` — the maintainers merge fast and add twins of our code.
3. Work. Verify with `bash dist/tools/verify.sh`. Ship with `bash dist/tools/ship-build.sh`.
4. Before stopping: bring `STATE.md` (and any file that changed) up to date, then
   `bash dist/tools/backup.sh "what changed"`.

## Starting a fresh AI session

Paste this as the first message:

> You are continuing work on the NOOP Lift Log in `~/Developer/noop`. Before anything else read
> `dist/README.md`, `dist/STATE.md` and `dist/RULES.md`, then run `bash dist/tools/upstream-check.sh` and
> follow `dist/WORKFLOW.md`. I am not a programmer: explain in plain language, make the technical decisions
> yourself, verify by running things rather than assuming, keep changes inside the Lift Log, ship every change
> as a build on my GitHub releases page and tell me "just update" or "wipe" with the build's id, and post
> nothing publicly without my yes. Before the session ends, update `dist/STATE.md` and the other pages the work
> changed, then run `bash dist/tools/backup.sh`.

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
- **The fork stays exact** — a mirror `main`, the stacked work branches, the build branch, this handbook — and this
  branch is public: nothing personal, no unapproved drafts (`WORKFLOW.md` §8).
