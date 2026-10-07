# State

Updated **7 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — work in flight

No NOOP job running. The 7 Oct reconciliation and deleted-sleep backup investigation are complete. All four
PRs remain open, mergeable and green; no new review concern. Local/fork main now mirrors `8e94d559`.
The verified phone release stays `6de9d6d`; no update or wipe is needed for this investigation.

**Awaiting Utku's approval to publish a new upstream issue**, as required by Rules. Concrete draft:
`private/session-2026-10-07-backup/upstream-issue.md`. The proposal is a versioned deletion-state archive entry,
with explicit Apple-global versus Android-device scope, before any implementation. Reproduction passed 28
assertions through production Apple export/restore: fresh defaults lose suppression, same-device defaults retain
it. Raw data/profile/journal restore; Android's DB holds its markers. No production fix is claimed.
Evidence, unchanged-source hashes, the runnable harness and synthetic artifacts are retained privately/in the cache.

## Phone

Fresh delete-first AltStore installation of **`6de9d6d`** was reported complete on 6 Oct. The 7 Oct phone log
now confirms app **12.0.0 (435)**, WHOOP 5/MG link establishment, live HR, completed history offloads and continued
background collection overnight. Mac awake/context setup was reported complete; no repeat setup is needed.
The current investigation requires no app update or wipe.

**Sync-stopped reminder confirmed on the phone:** the log scheduled it for about 00:31; Utku reported seeing
it around **00:32 on 7 Oct**. The log then shows an app launch at 00:35. Do not repeat the three-hour test.
Whether opening cleared the delivered line has not been separately observed.

A normal overnight log is now available in ignored `private/session-2026-10-07-backup/strap-log.txt`.
No personal data export is needed for the synthetic backup investigation. The new install has little history;
this log alone is not a like-for-like battery or sleep-accuracy comparison with the older installation.

Later: deleted-sleep list (delete a night, let undo expire, recompute clears the marker, Hide keeps suppression) and
ended-banner check (after roughly 8 h, open NOOP and check one banner). Do these after fresh data exists.
Utku's recent nights were atypical, sometimes strap-off/swiped away: infer gaps from logs rather than asking him to
keep a diary. Compare staging changes on the same nights, never one night against another.

## PRs — checked 7 Oct

| Upstream PR | Branch / head | Evidence and next action |
|---|---|---|
| [#2613](https://github.com/ryanbr/noop/pull/2613) | `dreamt-psg` / `ca008aba` | 17 checks green, clean merge; no review/comment. Await maintainer. |
| [#2660](https://github.com/ryanbr/noop/pull/2660) | `ios-deleted-sleep` / `e9ee598e` | 6 checks green; fresh delete unhides, recompute names the 21-day limit. [Review answered](https://github.com/ryanbr/noop/pull/2660#issuecomment-6016821944). Await maintainer. |
| [#2661](https://github.com/ryanbr/noop/pull/2661) | `ios-sync-reminder` / `7f9fc7aa` | 6 checks green; unset default OFF, saved choices survive. [Review answered](https://github.com/ryanbr/noop/pull/2661#issuecomment-6017174678). Await maintainer. |
| [#2717](https://github.com/ryanbr/noop/pull/2717) | `codex/docs-navigation` / `3ecf43c5` | Documentation index/current-history separation; 3 checks green. Await maintainer. |

All four PRs are open and mergeable. #2613 is 86 commits behind but merges cleanly;
it needs no speculative rebase.
24 PRs merged, including #2659 on 4 Oct; the dated list and validation are in [History](HISTORY.md).
Before any PR action, recheck its current head, reviews and CI. Drafts/evidence stay in ignored `private/`.

## Git and latest release

- `main`, `origin/main`, `upstream/main`: **`8e94d559be273ec8d74832fe5db78898be83cc11`**; exact mirror.
- `testing-stack`: **`a5168502`**, base `9f98f811` plus #2613/#2660/#2661 (one upstream naming/packaging commit behind main). Combined iOS build passed; fork Android
  `37470127956` and all 11 Swift package/tool jobs `37470132381` passed on that head.
- `testing-build` and local/remote `testing-latest`: **`6de9d6dcea57ff2d7ea656279583255378452834`**.
- [Latest release](https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest): **`6de9d6d`**, base **12.0.0**,
  run **37471192603**, release **404744559**. Four required jobs passed; five nonempty assets verified (2 APKs, Mac ZIP,
  unsigned iOS IPA, Lift Log XLSX); tag/target exact and IPA HTTP 200. Metadata: `private/release-*-6de9d6d.*`.
- Worktrees: `~/Developer/noop` (`main`), `dist` (`handbook`), siblings `noop-dreamt`, `noop-deleted-sleep`,
  `noop-sync-reminder`, and `/Users/utk/.codex/worktrees/docs-navigation/noop` (`codex/docs-navigation`). All code clean/pushed.
- Only intended refs: main, handbook, one branch per open PR, testing-stack/build; tags `fork/ships-template`,
  `testing-latest` and upstream versions. One testing release. No safety refs/stash or running build at audit.

## Local evidence and resources

Full verification on 6 Oct: #2660 packages 632/2135/327, 127 governance tests, 2272 Mac tests and iOS build;
#2661 same packages/gates, 2271 Mac tests and iOS build. Two Mac skips, one import skip, zero failures. Both fresh
simulator walkthroughs passed; reminder delivery is now confirmed on the phone, deleted-list checks remain pending. Logs: cache `verify/<head>/` and feature review
folders. Older setup/test/measurement details: [verification archive](HISTORY.md#verification-archive--through-6-oct-2026).

Simulator `DCAA8034-6801-4D1F-8FD9-B42B2F424B6F` (iPhone 17 Pro, iOS 27.0): 120 synthetic days, no strap, shut down.
Xcode 27.0, XcodeGen, gh, Python 3.12 available; Android tests run in fork CI. The new phone log is retained privately;
personal backups and sleep-accel / restricted DREAMT datasets remain absent on this Mac. Obtain raw data when an analysis needs it; never tune from old aggregates.
Docs #2717: head `3ecf43c56e9f2a67f263b4ea1b18c256f5aaa823`; runs source `37532167137`, i18n `37532167155`,
Tools Python `37532167146` passed. Local 439 Python tests (one skip), link/anchor/render/source/i18n checks passed.
Recovery-tool sandbox: 28 checks passed. Private audit: `private/organisation-audit/` (original pages, inventories,
rendered HTML, PR/check snapshots and cache removal evidence). Completed DerivedData removed; logs retained.

## Next safe action

Publish the prepared deleted-sleep backup issue only after Utku approves; otherwise retain the draft. Recheck
upstream for duplicates immediately before posting. After the storage discussion, implement the agreed repair as
one verified app PR and ship a testing update. Until then, recheck existing PR reviews/merges at session start.
No completed build, release, install, review reply or three-hour reminder test needs repeating.
