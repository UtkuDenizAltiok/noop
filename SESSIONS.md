# NOOP sessions

Use these prompts in a Codex chat for `~/Developer/noop`. A **session means one chat**; the next session is a
**new chat with no previous conversation context**. It must recover from saved files and current evidence.
Send **Start** first. Once the chat is ready, send a specific task, **Deep improvement** or **Deep search**.
Send **Finish** when you want the active work completed and a handover prepared. This file is the single home
for these prompts and procedures; quote the canonical prompts exactly when giving them to Utku.

Start recovers and finishes eligible carryover work, then waits for Utku's next prompt. Deep improvement
authorizes choosing and delivering one new improvement. Deep search authorizes research and a saved recommendation.
Finish completes the active task and essential existing obligations before closing; it is not an immediate stop
or an instruction to clear the backlog. Explicitly parked/deferred work stays parked unless Utku resumes it.

## Start or resume — copy this

```text
Prepare this new NOOP chat in ~/Developer/noop. Read the app's AGENTS.md and dist/AGENTS.md, then follow dist/SESSIONS.md's start procedure. Assume no previous chat context; recover from the handbook and current evidence. Reconcile running jobs, unfinished work, PR feedback and delivery. Finish eligible unfinished work and essential follow-up carried over from the previous session, respecting parked tasks and my latest instructions. Do not choose or begin a new improvement, investigation or backlog task. Update and upload the handbook, explain any remaining blocker, then tell me the chat is ready and wait for my next prompt. End with simple numbered next steps for me.
```

## Deep research and improvement — copy this

```text
In this prepared NOOP chat, follow dist/SESSIONS.md's Deep research and improvement procedure. Under my delegated project ownership, think deeply, inspect the whole app and strap-to-score pipeline, search the web and current primary research, and decide what most deserves improvement. Consider original ideas and existing candidates; choose one bounded priority with strong user value and verifiable evidence. Preserve quality and finish implementation, required verification, PR and testing delivery where applicable. Keep PR feedback handled and the handbook organized, current and uploaded. Use the recovered session; do not start session preparation again. Explain what improved, what proves it and what remains uncertain. End with simple numbered next steps for me.
```

## Deep search — copy this

```text
In this prepared NOOP chat, follow dist/SESSIONS.md's Deep search procedure. Think deeply and investigate NOOP using current source, existing evidence, web search and primary research. Decide the most useful research question from my request or the project when I have not named one. Distinguish proven findings, hypotheses and missing evidence; save a clear recommendation and what would validate it. This prompt authorizes research, not a new app implementation or release. Keep PR feedback handled and the handbook organized, current and uploaded. Use the recovered session; do not start session preparation again. Explain plainly and end with simple numbered next steps for me.
```

## End and hand over — copy this

```text
Finish this NOOP session for a new chat with no previous conversation context. Follow dist/SESSIONS.md's end procedure. Do not stop immediately: finish the active task, its running jobs and essential existing follow-up, including required verification, PR responses and testing delivery where applicable. Do not open unrelated tasks or revive parked work. Park unfinished work only when safe completion is genuinely prevented, and preserve the exact reason and recovery action. Save code, evidence, decisions and job recovery details; mark completed, pending, deferred and blocked work honestly. Update and upload the handbook, verify the handover from saved files and current state, and leave one exact next safe action with its scope. Explain what is saved, what remains and whether a fresh chat is safe. End with simple numbered next steps for me.
```

## Deep research requirements

Use the chat already prepared by Start. Do not rerun the complete start procedure for each prompt. Refresh the
specific source, PR or job facts that may have changed; use [interruption recovery](#after-an-interruption) when needed.
Apply these requirements to both deep modes, within the mode's authorized scope.

Understand what NOOP actually does, how it works with the WHOOP strap, and how raw readings become stored data, biometrics, scores and user decisions. Use the available reasoning time, web search, network access, source inspection, logs, profiling and experiments for deep analysis. Read current primary research and official technical documentation, cite the sources supporting your conclusions, and distinguish established findings, hypotheses and untested ideas. Extend existing audits with new evidence rather than repeating completed investigations.

Think like the app's creator, responsible for making it the best possible app for WHOOP straps. Look beyond Utku's suggestions, existing features and the backlog. Seek original, useful improvements and overlooked failure modes. Consider sensor interpretation, timestamps, missing data, artefacts, HR/HRV, respiration, sleep, recovery and strain; personal baselines, calibration, uncertainty and explanations; BLE, sync, background work and reliability; storage, backups and data integrity; phone and strap battery, CPU, GPU, RAM, disk and radio use; design, responsiveness, accessibility, localization, privacy, documentation, workflows and maintainability. These are starting points, not limits.

Efficiency must NEVER reduce quality. Preserve accuracy, data coverage, freshness, responsiveness, features and visual quality. Keep practical usage, setup and contribution guides complete when simplifying the project. Reduce wasted work and resource cost while preserving the intended results. Measure before and after on comparable inputs and workloads, check regressions, and distinguish simulator, benchmark and real-device results. Scientific changes need independent references, representative validation and held-out data where applicable; a plausible formula or passing test alone cannot establish physiological accuracy. Preserve the app's offline and privacy commitments, safe device behavior and cross-platform parity.

Utku has a WHOOP 5.0 and iPhone 16 and can test in real life. When a useful test needs him, give simple steps, the
expected result and what evidence to send, respecting deferred tasks. Keep progress checkpointed and the handbook
current; prepare a recoverable handover before a context or usage limit. Follow the shared PR routine below.

## Deep research and improvement procedure

Apply the [deep research requirements](#deep-research-requirements). Exercise delegated project ownership and
independent judgment: assess existing candidates and overlooked problems, then choose one bounded priority with
the strongest combination of user value, evidence and feasible verification. The backlog informs the choice;
it does not require finishing an old candidate or limit original ideas. Respect Rules' settled priorities.

Explain why the chosen change matters and define what will prove improvement before changing it. Record the
objective, scope and completion evidence in Now. Implement it and finish Workflow's required tests, builds,
parity checks, PR and testing delivery where applicable; verify the actual outcome. Do not stop at a proposal,
code edit or queued build. If completion genuinely requires unavailable evidence or input, preserve exactly what
is finished, what prevents completion and the next safe action. Record other useful ideas in Backlog with their
evidence and validation needs. Finish by explaining what improved, what proves it, what remains uncertain and
one to three simple numbered next steps.

## Deep search procedure

Apply the [deep research requirements](#deep-research-requirements). Investigate the question Utku names; if none
is named, choose one useful bounded question through independent judgment. Read current source and upstream work,
reuse retained audits and evidence, and search current primary research and official technical documentation.
Use read-only inspection and reversible local experiments as needed; preserve personal data and restore temporary
source/runtime mutations. Do not start a new app implementation, PR or release under this research-only prompt.

Finish with an evidence-backed answer: findings and citations, assumptions/limitations, the strongest recommended
next action and the validation needed before implementation. Save durable findings in the relevant existing audit
or one focused new audit, with concise State/Backlog links rather than copied reports. Upload the handbook and wait
for Utku's next prompt. Existing PR feedback remains governed by the shared routine below.

## Start procedure

1. Read the app's `AGENTS.md`, then this handbook's `AGENTS.md`, [State](STATE.md) (Now and Next safe action first),
   [Rules](RULES.md), [Workflow](WORKFLOW.md) and [Backlog](BACKLOG.md). [README](README.md) is the file map.
   Read feature contracts only when changing their behaviour. Later user instructions prevail; preserve standing
   decisions, approvals and deferred phone/data tasks. Ask only for input that is actually necessary.
2. From the app root, run `bash dist/tools/checkpoint.sh status --net`, then `bash dist/tools/upstream-check.sh`.
   If a check fails, distinguish unavailable evidence from a negative result; do not assume a missing action succeeded
   or failed. Make progress only where the available evidence is sufficient.
3. Reconcile every open Now step against actual worktrees, code diffs, refs, PRs, reviews, CI, release assets and logs.
   Inspect dirty/untracked files, stashes, safety refs and unfinished Git operations before changing them. Verify the
   head and expected checks, not merely a green badge or zero failures. Mark steps complete, partial, pending or blocked.
   An unticked step may already have happened: never repeat a push, PR, reply, release or job because context is missing.
4. Finish eligible carryover work: the previous active task's unfinished implementation/verification/delivery,
   recoverable jobs, new maintainer feedback and essential existing merge follow-up. Reconcile evidence before
   repeating an action, and check an existing job before starting another; do not overlap shared build caches.
   Explicitly parked/deferred work and unstarted candidates are not carryover obligations. Utku's latest request
   takes precedence. If completion truly needs unavailable input/evidence, record the exact blocker and recovery
   action; do not substitute a new independent task. If nothing eligible remains, proceed directly to readiness.
5. Follow Workflow for any carryover implementation, measurement, parity, verification and delivery. Journal long, public or
   hard-to-undo actions **before** acting, with worktree/branch/head, action/run/PR ID when available and the evidence
   that will prove completion. Update the record as IDs and results arrive. Reuse valid evidence for demonstrably
   unchanged relevant source and validation inputs; repeat checks only when changes, failures or unresolved concerns
   justify it. A queued job or published PR
   does not make unfinished tests, delivery or hardware validation complete.
6. Save milestones with `bash dist/tools/checkpoint.sh save "what changed"`; upload with
   `bash dist/tools/backup.sh "what changed"`. Also checkpoint a changed decision, failed step or safe pause, and prepare
   handover before a known context/usage limit. The handbook checkpoint saves handbook files, **not app source**;
   preserve source separately as described below. Keep raw personal data/drafts in ignored `private/` and large
   logs/builds in the cache, referenced from State. No duplicate agent memory or hidden hooks.
   Verify saved/current state, report completed carryover and any exact pending requirement, then say the chat is
   ready and **wait for Utku's next prompt**. Do not begin new research, fix a new issue or choose a backlog task
   merely because Start completed. Clearly label future candidates as requiring a task/deep prompt.

## PR care throughout the session

Check our PRs and new maintainer feedback at Start, before working on a PR branch or publishing, after long
verification/delivery jobs, and before Finish completes. During long work, check at useful boundaries rather than
waiting until the next chat or polling constantly. Workflow owns the PR lifecycle and reply format.
Read the actual comments, reviews and relevant threads; answer new maintainer feedback once and complete requested
fixes with their required verification under existing authority. Read back posted replies and record IDs, heads,
decisions and results. Reconcile merges with source proof and testing follow-up; do not repeat replies or rebuilds
from missing context. These are existing project obligations, not permission to open unrelated improvements.
Keep known external blockers explicit; do not pretend maintainer approval or phone observations happened.

## What the next chat must be able to recover

Keep the following applicable facts in State's Now and Next safe action, with completed events in History.
Use links to retained evidence rather than copying logs. Scale the record to the task; omit irrelevant fields.

- **Objective and boundary:** what is being fixed, why, what proves completion, and the current complete/partial/pending/
  blocked state. Preserve user decisions, approvals, deferrals and material assumptions with their reasons.
- **Source and preservation:** worktree path, branch and exact commit; dirty/untracked or unpushed work and where it is
  saved. Record any in-progress Git operation, safety ref/bundle and the condition for retiring it.
- **Verification and delivery:** tested head, actual passed/failed/skipped checks, evidence paths, remaining checks and
  unproven hardware/accuracy claims. For each unfinished public action, record its PR/run/release ID, head, result and
  readback evidence; distinguish published, built, downloadable and installed.
- **Running work:** job purpose, external run ID or local PID/command, worktree/head, durable log path, a check command
  usable in a new chat and the expected completion evidence. Old tool-session IDs alone are insufficient. Note whether
  the job can survive chat closure and what to do if it cannot; verify a PID's command before acting on it.
- **Next safe action:** one precise first action, including its success/failure branch, any genuinely required user
  input, and whether it is a carryover obligation for Start or a candidate awaiting a task/deep prompt. Put later
  candidates in Backlog rather than presenting several competing next tasks.

## After an interruption

Follow the start procedure before repeating any action. For a compact local brief, run
`bash dist/tools/checkpoint.sh brief`; the event log is `dist/private/events.log`. Recover from retained files and
external records first; chat history is a last resort. A job may have completed after the saved snapshot. Verification
ends with `all steps passed` or failed steps; shipping ends with `shipped <id>` or a failure. Check the actual head,
expected job roster and assets under Workflow; a title, partial upload or stale tag is insufficient. If completion
cannot be established, keep it pending and inspect the existing action rather than blindly repeating it.

## End procedure

1. **Freeze scope and finish existing work.** Finish is a request to complete and hand over, not to stop immediately.
   Save an initial checkpoint if work is at risk. Identify the active task, its jobs and already-known essential
   obligations that must finish in this session: protect source/data integrity, restore temporary mutations,
   handle actionable PR feedback and complete the active task's required verification/publication/testing delivery.
   Finish these under existing authority even when they require remaining edits, builds, a justified rebase or release.
   A task is not finished because code was written or a job was queued; establish its completion evidence.
   Do not start an unrelated investigation/improvement or revive parked work. "Important" means necessary to complete
   or safely hand over existing work, not a reason to pull the backlog into closure. An explicit immediate-stop
   instruction takes precedence; protect what can be saved without continuing that work.
2. **Preserve source and evidence.** Inspect each affected worktree. Prefer a local commit for coherent owned edits;
   label unverified work as WIP. If a commit is unsuitable, preserve the diff and new files in a documented durable
   local snapshot. A diff alone omits untracked files; a Git bundle alone omits uncommitted files. Keep needed ignored
   data/evidence separately. Verify the saved commit/snapshot contains the intended edits and needed new files.
   Respect unrelated user edits. Do not publish unverified work or delete safety refs, scratch checkouts, private files
   or logs just to obtain a clean status. Record every dirty/local-only exception.
3. **Finish jobs and resolve the active task.** Capture ready results, wait for the active task's jobs with bounded
   checks and progress updates, and fix relevant failures until required verification/delivery is complete. A long
   step is not by itself a reason to leave the task half done. Do not cut quality or claim completion to end the chat.
   Park only when safe completion is genuinely prevented: unavailable input/evidence/approval, an external outage,
   an unresolved dependency or an actual context/usage/execution limit. Record what was tried, the precise reason,
   what remains and the first recovery action. User-deferred tasks remain deferred. Pending maintainer review or
   unavailable phone validation can remain external requirements after implementation/testing delivery is complete.
   For any job necessarily left running, record its independent check command, completion criteria, whether it can
   survive chat closure and how to recover it. Verify the PID's command and retained logs before restarting; do not
   assume an old tool session is accessible, kill a valid job to tidy up, dispatch a duplicate or create a new watcher.
   Unrelated processes are left alone. Finish required closure work before creating the final handover.
4. **Make the handbook true.** Record the recovery facts above, the latest dated snapshot and one exact next safe
   action. Move completed milestones into History. Update Rules, Workflow, Backlog or feature contracts only where
   their facts changed; avoid contradictory copies. Distinguish a real blocker from a running job or deferred phone
   test. Unfinished work stays explicit instead of being declared complete or silently dropped.
5. **Save and upload.** Review the intended handbook diff for correctness and private data, then run
   `bash dist/tools/checkpoint.sh save "what changed"` and `bash dist/tools/backup.sh "what changed"`.
   Backup folds local checkpoints into one public milestone. Confirm successful upload; a local save or failed push
   is not a remote backup. Private files and local WIP are not uploaded by this handbook backup.
6. **Verify the handover.** Run `bash dist/tools/checkpoint.sh status --net`. Confirm handbook HEAD equals
   `origin/handbook`, no unsaved handbook changes, and clean/pushed app worktrees or each recorded exception. Reconcile
   the output with State, including jobs and safety refs. If a material fact changed, update and upload that correction.
   Retain a local checkpoint if upload/checking fails; report the exact limitation and recovery action rather than
   claiming a verified backup. Read Now and Next safe action from saved files as if the old chat were unavailable:
   another agent must be able to locate the work, establish what happened and continue without guessing or duplicating it.
7. **Close plainly.** Tell Utku what is saved/uploaded, what remains, any blocker and whether starting a fresh chat is
   safe. State any local-only dependency or unresolved handover risk. End with one to three simple numbered actions;
   if none is needed, say "No action needed" and name the next work. Then stop project work until a resume/new request.

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
