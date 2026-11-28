# Sessions

How a working session on NOOP starts, runs and ends, for any agent (Claude, ChatGPT/Codex, Gemini, another) or a
person. A session recovers everything from this handbook, the repository and GitHub: never from an earlier
conversation. The owner copies one of the prompts below into a new session.

## Prompts (copy one)

**Continue NOOP** (the usual one):

```text
You are working on NOOP 13 in ~/Developer/noop (the app is in app/, the project handbook in handbook/). Read app/AGENTS.md, then handbook/AGENTS.md, handbook/STATE.md and handbook/RULES.md, and follow handbook/SESSIONS.md's start procedure. Then continue with the open work in STATE.md, in its order, one change at a time, each verified as handbook/WORKFLOW.md says, and ship each finished change to my phone. Think as a fitness coach, exercise physiologist, doctor and software developer: nothing deleted, everything scientific and verified with evidence, nothing invented. My private files in ~/Developer/noop/noop-private-utku/ may be read and used to improve NOOP, but never published. When I report something from my phone, fix that first. Keep the handbook true and uploaded, hand over before your context is full, and explain everything to me in plain everyday words; I am not a programmer.
```

**After the two weeks of wear** (from about 11 Dec 2026, when the owner has new files):

```text
You are working on NOOP 13 in ~/Developer/noop. Read app/AGENTS.md, then handbook/AGENTS.md, handbook/STATE.md and handbook/RULES.md, and follow handbook/SESSIONS.md's start procedure. I have worn my WHOOP 5.0 with NOOP for about two weeks. I put my developer file (noop-lab-….zip), and any strap log or backup, in ~/Developer/noop/noop-private-utku/inbox/. Start with step counting as handbook/features/steps.md decides: finish and verify the drafted change, then the rest of its plan, using my calibration windows from the developer file. Read my files as handbook/features/lab.md says, check data health first, then answer the open data questions in handbook/BACKLOG.md ("With his file") and improve NOOP's measurements for my WHOOP 5.0 with evidence; ship each verified change to my phone. Keep my data private: use it, never publish it. Explain everything to me in plain everyday words; I am not a programmer.
```

**Finish and hand over:**

```text
Finish this NOOP session for a new session that has no memory of this one. Follow handbook/SESSIONS.md's end procedure: finish the change in hand and its checks, ship what is finished, save evidence, make handbook/STATE.md true with one exact next safe action, run the privacy check, upload the handbook, and tell me plainly what is saved, what remains and whether a new session is safe.
```

## Start procedure

1. Read `app/AGENTS.md`, then this handbook's [AGENTS](AGENTS.md), [State](STATE.md) (Now and Next safe action
   first), [Rules](RULES.md) and [Workflow](WORKFLOW.md); [Backlog](BACKLOG.md) when choosing work.
2. From `~/Developer/noop/app`: `bash dist/tools/checkpoint.sh status --net`. It lists the handbook's state, every
   worktree (clean? pushed?), running jobs, recent GitHub runs and what the release holds.
3. Reconcile State with what you see (commits, runs, the release). A step not ticked may already have happened:
   find its evidence before repeating a push, a build or a release.
4. Look in `~/Developer/noop/noop-private-utku/inbox/` for files the owner added; read its `README.md` first.
5. Then work. Journal long or public actions before doing them with `bash dist/tools/checkpoint.sh event "…"`;
   save milestones with `checkpoint.sh save "…"`.

## End procedure

1. Finish the change in hand: tests seen to fail and passing, `verify.sh` all steps passed, Android CI for Kotlin,
   shipped to the phone with the release checked (Workflow → Builds). A queued job is not a finished one.
2. Preserve: every worktree committed and pushed, or its exception written in State with the reason.
3. Make State true: what changed, what is open in order, one exact next safe action; move finished events into
   History as one entry. Change Rules, Workflow or a feature page only where its facts changed.
4. `bash dist/tools/privacy-check.sh` (Workflow → Privacy), then `bash dist/tools/backup.sh "what changed"`, then
   `checkpoint.sh status --net`: the handbook equals `origin/handbook`, worktrees clean and pushed.
5. Tell the owner plainly what is saved, what remains and whether a new session is safe, with one to three numbered
   next steps.

## Setting the project up on a new Mac

Full Xcode with its first launch done and an iOS Simulator runtime; Homebrew `xcodegen`, `gh` (signed in with
`gh auth login`) and `python@3.12`. Android needs no local SDK (it is tested on GitHub).

```bash
mkdir -p ~/Developer/noop && cd ~/Developer/noop
git clone https://github.com/UtkuDenizAltiok/noop.git app
git -C app worktree add ../handbook handbook
ln -s ../handbook app/dist
mkdir -p noop-private-utku/inbox && ln -s ../noop-private-utku handbook/private
cd app && bash dist/tools/checkpoint.sh status --net && bash dist/tools/verify.sh --quick
```

The research dataset (PhysioNet sleep-accel, 0.6 GB, Open Data Commons Attribution) goes in
`~/Developer/noop/datasets/`; the download command is in `Tools/SleepPSG/README.md`. Commits use the owner's GitHub
noreply address (`git config user.email`), never a personal one.
