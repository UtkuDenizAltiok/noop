# State

Updated **7 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — next work

The [sensor/biometric audit](audits/biometric-pipeline-2026-10-07/README.md), first quality repair and testing release
are complete. [PR #2722](https://github.com/ryanbr/noop/pull/2722) is open/mergeable at `b6e53f38`, with all 17
upstream checks green; no review/comment. The new verified release is `01b55ac2`, described below. Do not repeat
its verification, publication or shipping. Completed evidence is in History and the audit.

- [ ] Phone: Utku installs **JUST UPDATE** through AltStore over the existing app and confirms `01b55ac2` installed.
  No wipe. A fresh `.noopbak` enables source/coverage and exact metric replay; keep it private.
- [ ] Next engineering task: reproduce/refuse unusable optional baselines consistently in Charge, explanations and
  trace. This is independently reproducible without personal data; use the audit's test plan and one new PR worktree.
  Then jointly repair spectral units/resolution/timing. Other candidates/evidence gaps live in Backlog and the audit.
- [ ] Continue the five PR review/merge lifecycles after checking current heads. Backup issue #2720 remains parked
  awaiting maintainer storage direction under the existing specific approval; no duplicate report or approval request.

Private audit evidence: `private/session-2026-10-07-biometric-audit/`. No personal backup or accessible PSG reference
was available. Synthetic checks establish arithmetic/input-contract correctness, not physiological accuracy.
Temporary regression branch, stack checkout/branch and safety tags are removed. Old staging tips remain in verified
cache bundle `/Users/utk/Library/Caches/noop-handbook/pre-biometric-staging-20261007.bundle`. No known NOOP build/watch
remains; the final network handover check follows the upload.

## Phone

Fresh delete-first AltStore installation of **`6de9d6d`** was reported complete on 6 Oct. The 7 Oct phone log
now confirms app **12.0.0 (435)**, WHOOP 5/MG link establishment, live HR, completed history offloads and continued
background collection overnight. Mac awake/context setup was reported complete; no repeat setup is needed.
The verified update **`01b55ac2`** is ready. Install **JUST UPDATE** through AltStore over the existing app;
no deletion, migration change or fresh start is required. The downloaded IPA checksum matches GitHub and its
identity is `com.noopapp.noop`, display name **NOOP**, version **12.0.0 (435)**. The version number is unchanged,
so that header alone cannot prove the new build is installed; obtain Utku’s installation confirmation.

**Sync-stopped reminder confirmed on the phone:** the log scheduled it for about 00:31; Utku reported seeing
it around **00:32 on 7 Oct**. The log then shows an app launch at 00:35. Do not repeat the three-hour test.
Whether opening cleared the delivered line has not been separately observed.

A normal overnight log is now available in ignored `private/session-2026-10-07-backup/strap-log.txt`.
No personal export was needed for the synthetic deletion-backup investigation. A full `.noopbak` is now useful
for the sensor/biometric replay: More → Settings → Advanced → Backup & restore → Export…. Keep it private.
The new install has little history;
this log alone is not a like-for-like battery or sleep-accuracy comparison with the older installation.

Later: deleted-sleep list (delete a night, let undo expire, recompute clears the marker, Hide keeps suppression) and
ended-banner check (after roughly 8 h, open NOOP and check one banner). Do these after fresh data exists.
Utku's recent nights were atypical, sometimes strap-off/swiped away: infer gaps from logs rather than asking him to
keep a diary. Compare staging changes on the same nights, never one night against another.

## PRs — checked 7 Oct

| Upstream PR | Branch / head | Evidence and next action |
|---|---|---|
| [#2722](https://github.com/ryanbr/noop/pull/2722) | `codex/hrv-sdnn-quality` / `b6e53f38` | Local full verify + fork Android passed; All 17 upstream checks green; no review/comment. Included in verified `01b55ac2`. Await maintainer. |
| [#2613](https://github.com/ryanbr/noop/pull/2613) | `dreamt-psg` / `ca008aba` | 17 checks green, clean merge; no review/comment. Await maintainer. |
| [#2660](https://github.com/ryanbr/noop/pull/2660) | `ios-deleted-sleep` / `e9ee598e` | 6 checks green; fresh delete unhides, recompute names the 21-day limit. [Review answered](https://github.com/ryanbr/noop/pull/2660#issuecomment-6016821944). Await maintainer. |
| [#2661](https://github.com/ryanbr/noop/pull/2661) | `ios-sync-reminder` / `7f9fc7aa` | 6 checks green; unset default OFF, saved choices survive. [Review answered](https://github.com/ryanbr/noop/pull/2661#issuecomment-6017174678). Await maintainer. |
| [#2717](https://github.com/ryanbr/noop/pull/2717) | `codex/docs-navigation` / `3ecf43c5` | Documentation index/current-history separation; 3 checks green. Await maintainer. |

All five PRs are open and mergeable. #2613 is 86 commits behind but merges cleanly;
it needs no speculative rebase.
24 PRs merged, including #2659 on 4 Oct; the dated list and validation are in [History](HISTORY.md).
Before any PR action, recheck its current head, reviews and CI. Drafts/evidence stay in ignored `private/`.

## Git and latest release

- `main`, `origin/main`, `upstream/main`: **`8e94d559be273ec8d74832fe5db78898be83cc11`**; exact mirror, remote
  upstream tip rechecked during shipping.
- `testing-stack`: **`0768710f18b33938d6d637f7bd5ec03bbd8d80cc`**, base `8e94d559` plus #2613/#2660/#2661/#2722.
  Local combined iOS build passed. Fork Android **37596595347** and all 11 Swift jobs **37596598246** passed.
- `testing-build`: **`01b55ac2deff1732c0ea9e2488d669bd5b0e5ec7`** (local and remote).
- [Latest release](https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest): **`01b55ac2`**, base
  **12.0.0**, run **37597587148**, release **405571964**. Ship tool finished `shipped 01b55ac2`; four required jobs
  passed (cleanup intentionally skipped). All five nonempty assets uploaded; release target and local/remote tag
  exactly equal testing-build; IPA HTTP 200, downloaded ZIP/plist identity/size/SHA-256 verified against GitHub’s
  asset digest. Metadata: `private/release-{metadata,assets,run,ipa}-01b55ac2.json`.
- Earlier installed release: **`6de9d6d`**, 6 Oct; its prior metadata remains in `private/release-*-6de9d6d.*`.
- Code worktrees: root `main`; siblings `noop-dreamt`, `noop-deleted-sleep`, `noop-sync-reminder`; managed
  `/Users/utk/.codex/worktrees/docs-navigation/noop` and `/Users/utk/.codex/worktrees/hrv-spectral-power/noop`
  (`codex/hrv-sdnn-quality` / `b6e53f38`). All code is clean/pushed; handbook is this `dist` worktree.
- Fork refs are the intended main/handbook/one per open PR/testing-stack/build, template/testing tags and upstream
  versions. No throwaway remote regression branch or scratch checkout. No safety refs/stash or running NOOP job remains.

## Local evidence and resources

Full SDNN verification on 7 Oct at `b6e53f38`: 632/2139/327 package tests, all lint/i18n/parity gates,
127 governance, 2267 Mac tests and iOS build passed (one import/two Mac skips). Fork Android full suite passed;
regression-only discovery count 6641/six skips, unchanged test roster. Exact eight-case raw Double-bit oracle passed
on both platforms. Logs: cache `verify/b6e53f38/` and the private biometric audit folder.

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

At resume, reconcile current PR reviews/merges and phone installation/data evidence, then implement the unusable
optional-baseline contract in Charge using the audit's preregistered synthetic test plan. No further user decision
is needed for routine implementation/verification/PR/release work. A private full backup helps actual-data replay;
independent reference recordings remain necessary for any physiological accuracy claim. No repeat three-hour
reminder check, wipe, completed report or completed release.
