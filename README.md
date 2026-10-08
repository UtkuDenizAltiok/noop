# NOOP handbook

Project memory for [UtkuDenizAltiok/noop](https://github.com/UtkuDenizAltiok/noop), forked from
[ryanbr/noop](https://github.com/ryanbr/noop). Local path: `~/Developer/noop/dist`; Git branch: `handbook`.

**Start here: [session prompts and procedure](SESSIONS.md).** Use the start prompt to continue, the deep research prompt
for a thorough improvement session, and the end prompt to hand over.

| Need | Read |
|---|---|
| Work in flight, PRs, release and phone checks | [State](STATE.md) — Now first |
| Authority, product decisions and engineering rules | [Rules](RULES.md) |
| Verification, GitHub, shipping and measurement | [Workflow](WORKFLOW.md) |
| Next investigations and their evidence | [Backlog](BACKLOG.md) |
| Sensor pipeline, biometric defects and runnable evidence | [7 Oct audit](audits/biometric-pipeline-2026-10-07/README.md) |
| Whole-app priorities and optional Charge baseline repair | [8 Oct audit](audits/charge-baseline-usability-2026-10-08/README.md) |
| Deeper assessment and cancelled Stress load regression | [Freshness audit](audits/stress-load-cancellation-2026-10-08/README.md) |
| Parked Stress interpretation change and unfinished verification | [Saved spectral audit](audits/stress-spectral-explanations-2026-10-08/README.md) |
| Source-backed network/privacy guide reconciliation | [Network audit](audits/network-privacy-2026-10-08/README.md) |
| HRV cleaning allocation measurement and exact preservation | [Buffer audit](audits/hrv-clean-buffer-2026-10-08/README.md) |
| Completed work and dated test results | [History](HISTORY.md) |
| Feature contracts | [Lift Log](features/lift-log.md), [Live HR banner](features/live-hr-banner.md) |
| Agent entry | [AGENTS.md](AGENTS.md) |
| Commands and analysis helpers | [tools/](tools/) |

## File organisation

- **App checkout:** upstream source and docs; `main` stays an exact upstream mirror. See the app's `AGENTS.md` and `docs/`.
- **PR worktrees:** one per open PR, identified in State and `git worktree list`. Existing worktrees are siblings of the
  app checkout; Codex-managed worktrees may live under `~/.codex/worktrees/`. Install local entries after adding one.
- **Handbook:** these public Markdown pages, `features/` contracts, `audits/` and `tools/`. Local and GitHub copies are the same
  branch. One subject has one authoritative home; use links instead of repeating instructions or active status.
- **Private evidence:** ignored `dist/private/` for drafts, raw logs and local reports. Health data and datasets stay
  local. No separate agent-memory files.
- **Generated files:** build products and reports under `~/Library/Caches/noop-handbook/`. Retain useful logs; completed
  DerivedData can be removed and rebuilt. Never commit generated Xcode projects, caches or local instruction files.

Keep Now limited to unfinished work, State to current facts, Backlog to unbuilt candidates and History to completed
milestones. Preserve rule numbers, feature invariants and useful evidence when shortening pages. Existing app doc
paths are public links: improve navigation before moving or deleting them.
