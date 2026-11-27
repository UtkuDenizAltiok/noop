# NOOP handbook: entry for anyone working on NOOP

This is the project handbook of **NOOP 13**, an offline, on-device companion app for WHOOP 4.0 and 5.0/MG
straps (iOS, macOS, Android). It is written for whoever continues the work: a person or any AI agent (Claude,
ChatGPT/Codex, Gemini or another). Nothing here depends on one tool.

**What NOOP 13 is.** Utku Deniz Altiok's own continuation of NOOP 12.0.0 ([ryanbr/noop](https://github.com/ryanbr/noop),
PolyForm Noncommercial 1.0.0), maintained independently since 27 Nov 2026 at
[UtkuDenizAltiok/noop](https://github.com/UtkuDenizAltiok/noop). Every original credit and the license stay.
The original repository is no longer followed: no syncing, no new pull requests there.

**Read in this order:**
1. The app's [`AGENTS.md`](https://github.com/UtkuDenizAltiok/noop/blob/main/AGENTS.md) (on `main`): scope,
   architecture, the cross-platform parity contract, build and test commands, hard engineering rules.
2. [State](STATE.md): what is true now, and the one next safe action.
3. [Rules](RULES.md): the owner's standing decisions and the engineering rules (numbered; other pages cite them).
4. [Workflow](WORKFLOW.md): how to verify, keep both platforms identical, build and ship to the owner's phone.
5. [Sessions](SESSIONS.md): ready prompts and the start / finish procedure for a working session.
Then [Backlog](BACKLOG.md) for what to build next, [History](HISTORY.md) for what was done, and `features/` for
the contracts of individual features. [README](README.md) maps every file.

**Three things never to get wrong:** nothing personal of the owner is ever committed here (this branch is
public; private files live outside every repository, see Workflow → Privacy); a measurement or score changes
only with cited evidence and tests on both platforms (Rules 2–3); explain things to the owner in plain words
(he is not a programmer) and end with one to three simple numbered next steps.
