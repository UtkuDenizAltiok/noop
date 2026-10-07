# NOOP sessions

Use these prompts in a Codex chat for `~/Developer/noop`. Add a specific task after the start prompt when needed.
Ending a session means preparing a handover for a new chat with a fresh context window. That new chat must recover
from the handbook and current evidence. Use the canonical prompts below exactly when giving start/resume or end instructions.

## Start or resume — copy this

```text
Continue NOOP in ~/Developer/noop. Read the app's AGENTS.md and dist/AGENTS.md, then follow dist/SESSIONS.md. Reconcile saved state before acting, choose and finish the next task under our mandate. Explain plainly and end with simple numbered next steps for me.
```

## End and hand over — copy this

```text
Close this NOOP session using dist/SESSIONS.md's end procedure. Preserve unfinished work, update and upload the handbook, verify the handover and report any blocker. End with simple numbered next steps for me.
```

## Start procedure

1. Read the app's `AGENTS.md`, then this handbook's `AGENTS.md`, State (Now first), Rules, Workflow and Backlog.
   README is the file map. Read feature contracts only when changing their behaviour.
2. From the app root, run `bash dist/tools/checkpoint.sh status --net`, then `bash dist/tools/upstream-check.sh`.
3. Reconcile every open Now step against actual code, PRs, reviews, CI, releases and logs. Read uncommitted code diffs.
   Mark each step complete, pending or partial. Never repeat a push, PR, reply, release or job because chat history is missing.
4. Choose the next task from State and current evidence; Utku's supplied task takes precedence. Journal long, public or
   hard-to-undo actions in Now before acting, including branch/head, run or PR ID and the evidence that proves completion.
5. Checkpoint milestones with `bash dist/tools/checkpoint.sh save "what changed"`. Keep useful evidence in `private/`
   or the cache, referenced from State. Save and upload explicitly; no hidden memory copies or hooks.

## After an interruption

Follow the start procedure. An unticked step may already have happened: verify before resuming. For a compact local
brief, run `bash dist/tools/checkpoint.sh brief`; the event log is `dist/private/events.log`. Name running jobs and
how to check them. Wait for the actual completion output: verification ends with `all steps passed` or failed steps;
shipping ends with `shipped <id>` or a failure. Chat history is a last resort.

## End procedure

1. Stop new work. Park unfinished code and keep private files; record branch, commit, unsaved/unpushed changes,
   remaining verification and any running job with its check command.
2. Make State true: unfinished work in Now, completed milestones in History, one exact next safe action. Update Rules,
   Workflow, Backlog or feature contracts only where their facts changed.
3. Run `bash dist/tools/checkpoint.sh save "what changed"`, then `bash dist/tools/backup.sh "what changed"` to upload.
   Backup folds local checkpoints into one public milestone.
4. Run `bash dist/tools/checkpoint.sh status --net`. Confirm clean/pushed worktrees and no stray jobs, or record each
   exception. A failed save/push is not a backup: retain a local checkpoint and report the blocker and resume action.
5. Tell Utku what is saved and whether a fresh chat is safe. End with one to three simple numbered actions. If none
   is needed, say "No action needed" and name the next work. Prepare handover before a known limit.

## One-time Mac setup

Use full Xcode with its license/first launch complete and an iOS Simulator runtime. Install `xcodegen`, `gh` and
`python@3.12` with Homebrew; sign in with `gh auth login`. Android validation runs in fork CI; no local SDK is required.

```bash
git clone https://github.com/UtkuDenizAltiok/noop.git ~/Developer/noop
cd ~/Developer/noop
git remote add upstream https://github.com/ryanbr/noop.git
git fetch --all
git worktree add dist handbook
# Restore each open PR's worktree from State, then:
bash dist/tools/codex-setup.sh
gh auth status
git push --dry-run origin main
bash dist/tools/checkpoint.sh status --net
bash dist/tools/upstream-check.sh
bash dist/tools/verify.sh --quick
```

Set the Git author to the account contributing. Fork write access is needed for pushes/releases; public read access
is enough for inspection. Re-run `codex-setup.sh` after adding a worktree; it preserves unrelated overrides. Local
`AGENTS.override.md` entries load upstream rules and this handbook without changing the app's tracked instructions.
[Official instruction discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

For unattended work, keep the Mac plugged in with its lid open. In Codex Settings (`⌘,`) → General, enable **Prevent
sleep while running** and **Show context window usage**. `/status` shows chat context and account limits separately.
For native UI checks, set macOS Lock Screen's AC display-off timer to Never and disable an automatic screen saver;
retain the password policy. A closed lid requires Apple's supported external-display setup. Codex's UI tool cannot
control Codex itself; do not claim a setting is enabled from advice alone. Current user-reported setup is in State.
[Codex settings](https://learn.chatgpt.com/docs/reference/settings),
[commands](https://learn.chatgpt.com/docs/reference/slash-commands),
[Mac sleep settings](https://support.apple.com/en-euro/guide/mac-help/mchle41a6ccd/mac),
[closed-lid setup](https://support.apple.com/en-us/102282).
