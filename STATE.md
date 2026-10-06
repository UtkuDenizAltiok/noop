# State

Updated **7 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — work in flight

No agent work in flight. Documentation cleanup is complete; #2717 is published and all three expected upstream
checks passed. All four PRs are clean, pushed, mergeable and green; existing owner concerns are answered once.
Handbook consolidation, link/render/recovery checks and generated-cache cleanup are complete (History). No running
build/watch remains. Phone checks are pending, not failed; current app release stays `6de9d6d`.

## Phone

Fresh delete-first AltStore installation following the **`6de9d6d`** instructions reported complete on 6 Oct.
Mac awake/context setup also reported complete; actual unattended operation and phone build header are not yet observed.
No update or wipe is needed for this documentation task. Do not repeat completed setup.

Pending, phased checks (deferred by Utku until cleanup):

1. Finish profile/Bluetooth pairing with WHOOP 5.0; let the first sync finish on screen and check live HR/history.
2. More → App → Automations → **Remind me when syncing stops** ON, allow notifications; after a sync, swipe away once
   and check the silent **Strap not synced** line around 3 h later. Opening clears it. Then use normally in background.
3. Send a normal overnight log: More → App → Test Centre → Strap log → Save…. Say whether the reminder appeared.

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

All four PRs are open and mergeable. #2613 is 85 commits behind but merges cleanly;
it needs no speculative rebase.
24 PRs merged, including #2659 on 4 Oct; the dated list and validation are in [History](HISTORY.md).
Before any PR action, recheck its current head, reviews and CI. Drafts/evidence stay in ignored `private/`.

## Git and latest release

- `main`, `origin/main`, `upstream/main`: **`9f98f811a6849ebcc333f51c0b37917f8d1f437e`**; exact mirror.
- `testing-stack`: **`a5168502`**, that base plus #2613/#2660/#2661. Combined iOS build passed; fork Android
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
simulator walkthroughs passed; phone/strap delivery remains unproven. Logs: cache `verify/<head>/` and feature review
folders. Older setup/test/measurement details: [verification archive](HISTORY.md#verification-archive--through-6-oct-2026).

Simulator `DCAA8034-6801-4D1F-8FD9-B42B2F424B6F` (iPhone 17 Pro, iOS 27.0): 120 synthetic days, no strap, shut down.
Xcode 27.0, XcodeGen, gh, Python 3.12 available; Android tests run in fork CI. Personal backups/logs and sleep-accel /
restricted DREAMT datasets are absent on this Mac. Obtain new evidence before analysis; never tune from old aggregates.
Docs #2717: head `3ecf43c56e9f2a67f263b4ea1b18c256f5aaa823`; runs source `37532167137`, i18n `37532167155`,
Tools Python `37532167146` passed. Local 439 Python tests (one skip), link/anchor/render/source/i18n checks passed.
Recovery-tool sandbox: 28 checks passed. Private audit: `private/organisation-audit/` (original pages, inventories,
rendered HTML, PR/check snapshots and cache removal evidence). Completed DerivedData removed; logs retained.

## Next safe action

Recheck PR reviews/merges at the next session; answer new concerns once and fix/verify the relevant branch. Then
reproduce deletion-marker backup/restore with synthetic markers and fresh defaults (Backlog item 9), compare Android's
storage contract, and discuss a portable approach before implementing. Collect phone evidence when Utku is ready.
No completed build, release, install or review reply needs repeating.
