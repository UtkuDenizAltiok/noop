# Next PR — three open, nothing prepared

**Open on `ryanbr/noop` (24 Sep 2026), all green, no comments yet:** [#2419](https://github.com/ryanbr/noop/pull/2419)
(Live notifications switches), [#2420](https://github.com/ryanbr/noop/pull/2420) (MetricKit),
[#2422](https://github.com/ryanbr/noop/pull/2422) (live HR shown only while measured — its description promises the
hardware result of commits 6–8; add it when Utku's test log arrives, `LIVE_HR.md` §6.5). Their bodies are the
`dist/private/pr-*-body.md` drafts, kept current: edit the draft, then `gh pr edit <n> --body-file`. A change of ours
goes into the description, never a new "update" comment (`WORKFLOW.md` §5).

The Lift Log's last PR, [#2403](https://github.com/ryanbr/noop/pull/2403), merged 23 Sep as `3ada90c3`.
- **How this body was built**, for the next one: what changed since the last merge, in the order a lifter meets it,
  in plain words (Utku, 21 Sep); the gym sessions and what each showed; every new test seen to fail without its fix;
  the package, macOS, iOS and Android CI numbers; the parity refresh as its own commit, never a hand edit.
- **Still to check on the next build** (`1c34d6cd`, or whatever `STATE.md` names): the Dynamic Island's layout, the
  Lock Screen lighting as promptly late in a session as early, and — Utku's own question, rule 48 — walking away
  until the strap disconnects, then coming back mid-session.

## Reply on #2099, after ryanbr's 15 Sep 04:07 comment — POSTED 23 Sep 03:48, with Utku's yes

Kept as the record of what was said. ryanbr's last comment on merged #2099 (he pushed the empty-session guard
`fed714cb` himself) asked whether we would rather keep performed sets with their timing; round 4 is that choice.
Never post it again.

```markdown
Thanks for the guard, and for merging. You asked whether I'd rather keep performed sets with their timing: after more gym sessions, yes. In #2403 a set that was done always counts as done, with the numbers typed or the grey ones, and the finish screen only asks about sets never started. Your guard stays: if no set was done and the rest are discarded, nothing is saved, and the finish screen says so before Save.
```

## The separate PRs, not the Lift Log's

[#2386](https://github.com/ryanbr/noop/pull/2386) (the strap log kept on disk) merged 22 Sep;
[#2402](https://github.com/ryanbr/noop/pull/2402) (the standard-HR line summarised) merged 23 Sep. Their text
lives on GitHub and their state in `STATE.md`. A later comment on either gets one reply after it, with Utku's yes
(`WORKFLOW.md` §5).
