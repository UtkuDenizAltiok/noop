# NOOP sessions

Use these prompts in a Codex chat for `~/Developer/noop`. Add a specific task after the start prompt when needed.
Use the deep research prompt when you have time and usage available for a thorough improvement session.
Copy the short entry prompt for the session you want; its detailed procedure is in this same file. No separate saved copy is required.
Ending a session prepares a handover for a **new chat with a fresh context window**. That chat recovers from the
handbook and current evidence, without depending on the old conversation. This file is the single home for session
instructions; quote the canonical prompts below exactly when giving them to Utku.

Work on one objective at a time. Finish it with evidence, or preserve an explicit unfinished state. Ending means
bringing existing work to a safe checkpoint and handing it over; it does not require finishing the whole backlog.

## Start or resume — copy this

```text
Continue NOOP in ~/Developer/noop. Read the app's AGENTS.md and dist/AGENTS.md, then follow dist/SESSIONS.md's start procedure. Recover from the handbook and current evidence without relying on previous chat context. Reconcile unfinished work and running jobs before acting. Respect my latest instructions and deferred tasks. Under our mandate, choose one bounded priority task and finish its required verification and delivery, or preserve exactly what prevents completion. Avoid unrelated new work and duplicate actions. Keep progress checkpointed and the handbook current. Explain plainly and end with simple numbered next steps for me.
```

## End and hand over — copy this

```text
Close this NOOP session for a new chat with a fresh context window. Follow dist/SESSIONS.md's end procedure. Stop opening new tasks; bring the current operation to a safe checkpoint without abandoning or expanding the work. Preserve code, evidence, decisions and running-job recovery details. Mark completed, pending and blocked work honestly. Update and upload the handbook, verify the handover from saved files and current state, and leave one exact next safe action. Explain plainly what is saved, what remains and whether a fresh chat is safe. End with simple numbered next steps for me.
```

## Deep research and improvement — copy this

```text
Continue NOOP in ~/Developer/noop. Read the app's AGENTS.md and dist/AGENTS.md, then follow dist/SESSIONS.md's start procedure and Deep research and improvement procedure. Preserve quality and finish one bounded, verified improvement.
```

## Deep research and improvement procedure

Follow the [start procedure](#start-procedure) first, then apply the following requirements.

Understand what NOOP actually does, how it works with the WHOOP strap, and how raw readings become stored data, biometrics, scores and user decisions. Use the available reasoning time, web search, network access, source inspection, logs, profiling and experiments for deep analysis. Read current primary research and official technical documentation, cite the sources supporting your conclusions, and distinguish established findings, hypotheses and untested ideas. Extend existing audits with new evidence rather than repeating completed investigations.

Think like the app's creator, responsible for making it the best possible app for WHOOP straps. Look beyond my suggestions, existing features and the backlog. Seek original, useful improvements and overlooked failure modes. Consider sensor interpretation, timestamps, missing data, artefacts, HR/HRV, respiration, sleep, recovery and strain; personal baselines, calibration, uncertainty and explanations; BLE, sync, background work and reliability; storage, backups and data integrity; phone and strap battery, CPU, GPU, RAM, disk and radio use; design, responsiveness, accessibility, localization, privacy, documentation, workflows and maintainability. These are starting points, not limits.

Efficiency must NEVER reduce quality. Preserve accuracy, data coverage, freshness, responsiveness, features and visual quality. Keep practical usage, setup and contribution guides complete when simplifying the project. Reduce wasted work and resource cost while preserving the intended results. Measure before and after on comparable inputs and workloads, check regressions, and distinguish simulator, benchmark and real-device results. Scientific changes need independent references, representative validation and held-out data where applicable; a plausible formula or passing test alone cannot establish physiological accuracy. Preserve the app's offline and privacy commitments, safe device behavior and cross-platform parity.

After assessing the whole system, choose one bounded priority with the strongest combination of user value, evidence and feasible verification. Explain why it matters and define what will prove improvement before changing it. Under our existing project authority, implement it, finish the required tests, builds, parity checks, PR and testing delivery where applicable, and verify the actual outcome. If completion needs unavailable evidence or input, preserve exactly what is finished, what prevents completion and the next safe action. Record other promising ideas in the backlog with their evidence and validation needs.

I have a WHOOP 5.0 and iPhone 16 and can test in real life. When a useful test needs me, give simple steps, the expected result and what evidence to send, respecting deferred tasks. Keep progress checkpointed and the handbook current; prepare a recoverable handover before a context or usage limit. Finish by explaining what improved, what proves it, what remains uncertain, and one to three simple numbered next steps for me.

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
4. Recover the existing task first, including unfinished verification/delivery. Check an existing job before starting
   another; do not overlap shared verification/build caches. Utku's new request takes precedence. If the previous task
   truly needs external input, park it explicitly and choose one independent task under the mandate. Write the chosen
   objective, scope and evidence needed for completion in Now. Do not open several speculative investigations or PRs.
5. Follow Workflow for implementation, measurement, parity, verification and delivery. Journal long, public or
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
- **Next safe action:** one precise first action, including its success/failure branch and any genuinely required user
  input. Put later candidates in Backlog rather than presenting several competing next tasks.

## After an interruption

Follow the start procedure before repeating any action. For a compact local brief, run
`bash dist/tools/checkpoint.sh brief`; the event log is `dist/private/events.log`. Recover from retained files and
external records first; chat history is a last resort. A job may have completed after the saved snapshot. Verification
ends with `all steps passed` or failed steps; shipping ends with `shipped <id>` or a failure. Check the actual head,
expected job roster and assets under Workflow; a title, partial upload or stale tag is insufficient. If completion
cannot be established, keep it pending and inspect the existing action rather than blindly repeating it.

## End procedure

1. **Freeze scope and protect progress.** Stop opening tasks. Save an initial checkpoint if work is at risk. Finish the
   current operation to the nearest safe boundary when it is short and within existing authority: restore temporary
   mutations, resolve an already-understood edit, capture a result or finish a commit/upload already underway.
   Do not start a new investigation, full verification cycle, rebase or release merely to make closure look complete.
   If the next step is long, uncertain or needs external input, preserve it for resume. An explicit immediate-stop
   instruction takes precedence; protect what can be saved without continuing that work.
2. **Preserve source and evidence.** Inspect each affected worktree. Prefer a local commit for coherent owned edits;
   label unverified work as WIP. If a commit is unsuitable, preserve the diff and new files in a documented durable
   local snapshot. A diff alone omits untracked files; a Git bundle alone omits uncommitted files. Keep needed ignored
   data/evidence separately. Verify the saved commit/snapshot contains the intended edits and needed new files.
   Respect unrelated user edits. Do not publish unverified work or delete safety refs, scratch checkouts, private files
   or logs just to obtain a clean status. Record every dirty/local-only exception.
3. **Account for existing jobs.** Capture results that are ready. If a job is about to finish, allow a bounded wait;
   otherwise preserve its independent check command and completion criteria. For any job left running, record whether
   it can survive the old chat and how to recover its state. If survival is uncertain, say so; check whether the job is
   still active and inspect retained logs before restarting a local check. Do not assume an old tool session is accessible
   in the new chat, kill a valid job to tidy up, dispatch a duplicate or create a new watcher. Unrelated processes are
   left alone. Pending external work is compatible with a safe handover.
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
