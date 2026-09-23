# Next PR — opened

**The Lift Log follow-up PR is open: [#2403](https://github.com/ryanbr/noop/pull/2403)** (23 Sep 2026, head
`8b05e0bb`, from `lift-log-follow-ups` rebased onto `751fa1d8`). Its text is on GitHub, which is now the copy that
counts; this page keeps only what is still to do and how the body was built, for the next PR.

- **Do not open it again.** A comment on it gets ONE reply after it; a change of ours goes into an edit of the
  description (`WORKFLOW.md` §5).
- **How this body was built**, for the next one: what changed since the last merge, in the order a lifter meets it,
  in plain words (Utku, 21 Sep); the gym sessions and what each showed; every new test seen to fail without its fix;
  the package, macOS, iOS and Android CI numbers; the parity refresh as its own commit, never a hand edit.
- **Still to check on the next build** (`1c34d6cd`, or whatever `STATE.md` names): the Dynamic Island's layout, the
  Lock Screen lighting as promptly late in a session as early, and — Utku's own question, rule 48 — walking away
  until the strap disconnects, then coming back mid-session.

## Reply on #2099, after ryanbr's 15 Sep 04:07 comment

Optional, and only with Utku's yes. Why it exists: #2099 is merged and closed, but ryanbr's last comment there
(he pushed the empty-session guard `fed714cb` himself) ends by asking whether we would rather keep performed sets
with their timing. Nobody answered. Round 4 is exactly that choice, so one short reply answers him and points to
the new PR. #2403 is now open, so it can be posted whenever he says yes (nothing has been posted).

```markdown
Thanks for the guard, and for merging. You asked whether I'd rather keep performed sets with their timing: after more gym sessions, yes. In #2403 a set that was done always counts as done, with the numbers typed or the grey ones, and the finish screen only asks about sets never started. Your guard stays: if no set was done and the rest are discarded, nothing is saved, and the finish screen says so before Save.
```

## The separate PRs, not the Lift Log's

[#2386](https://github.com/ryanbr/noop/pull/2386) (the strap log kept on disk) merged 22 Sep;
[#2402](https://github.com/ryanbr/noop/pull/2402) (the standard-HR line summarised) is open and green. Their text
lives on GitHub and their state in `STATE.md`. A comment on it gets one reply after it; a later change of ours
goes into a description edit (`WORKFLOW.md` §5).
