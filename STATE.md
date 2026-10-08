# State

Updated **8 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — next work

**Active objective, 8 Oct 2026:** under Utku's renewed whole-app improvement mandate, repair optional Charge
baseline eligibility on both platforms. Source confirms the scorer passes unusable respiration/Effort states;
drivers/trace pass unusable respiration too, while the Apple UI already omits it. This can make readouts disagree.
Existing whole-pipeline audit and measured resource priorities remain the wider map; this task changes no weights,
sensor decoding, baseline learning, schema or BLE policy and makes no physiological accuracy/phone-energy claim.
Start recovery: previous RHR delivery complete, all code clean/pushed, no running jobs/stash/Git operation,
upstream `8e94d559`; current open PR/issue search finds no matching repair (#2583 is source-era baseline work).
Before measuring, record a finite-state missing/value matrix and usable-state preservation oracle. Completion:
regressions seen failing then passing, raw-bit Swift/Kotlin oracle, matching score/driver/trace, full local verify,
Android CI, verified upstream PR and combined testing build delivery. Source will live in one new PR worktree;
logs/audit in cache `charge-baseline-usability/` and ignored `private/session-2026-10-08-charge-baselines/`.
Worktree `/Users/utk/.codex/worktrees/charge-baseline-usability/noop`, branch `codex/charge-baseline-usability`,
committed/pushed head **`3e59a667`**, based on test-only commit `f1426a86`. Six new Swift tests ran: five regressions failed
(420 assertions) as predicted, HRV cold-start control passed; log `swift-original-red.log` in the private folder.
Android original run **37739654819** completed with debug compile success and exactly five expected new unit tests
failed among 6643 tests/six skips; `android-original-failures.log` and `android-original-run.json` retained privately.
Temporary remote `codex/charge-baseline-usability-regression` retired with pinned lease. Utku was told before this
intentional failure/email; no remaining regression branch or repeat dispatch needed.
The 25-case compiled original Swift oracle (with only eligible inputs supplied) is retained as
`eligible-original-score-bits.txt` and copied verbatim into both-platform matrix tests; the augmented Swift matrix
also failed on original code. Six production files now gate optional states; 70 targeted Swift tests passed.
All four local gate mutations failed their corresponding regression and restored exact SHA-256; all six new tests
passed after restoration. Evidence `mutation-results.json` and `swift-{targeted,restored}-green.log`.
Full local verification at exact `3e59a667` finished with **all steps passed** and `verify-result.json` exit 0:
632/2141/327 package tests, all source/parity gates, 127 governance, 2267 Mac tests and iOS build (one import/two
Mac skips). Durable `verify.out`/`verify-result.json`, full logs cache `verify/3e59a667/`; generated plist restored.
Final-head Android **37740134786** passed debug build and actual full unit-test step including the raw-bit oracle;
retained `android-final{,-run}.log/json`, no warnings in changed Swift/Kotlin files. No local verify remains running.
[PR #2729](https://github.com/ryanbr/noop/pull/2729) is published, exact body/head read back and attached;
open/mergeable at `3e59a667`. Expected upstream roster is **17** checks; initial readback has all 17 registered,
still running. Private PR body `private/pr-charge-baseline-usability-body.md` and `pr-published.json` retained.
Integration scratch `charge-baseline-usability/stack`, branch `codex/testing-stack-charge-20261008`, head
**`858d8c99`** = previously verified `testing-stack` (`979a2baf`) + both new commits, only eight added/changed files.
Old stack/build refs are preserved by local `backup/pre-charge-testing-{stack,build}-20261008` and complete-history
cache `charge-baseline-usability/pre-charge-staging.bundle` (verified, independent recovery required before retirement).
Integration iOS at exact `858d8c99` passed: `stack-ios-result.json` exit 0 and `stack-ios.log` BUILD SUCCEEDED;
independent runner PID 9970 is complete. Its tree exactly matches merge-tree of old testing-stack and the feature.
Generated Info.plist restored; exact `858d8c99` is now local/remote testing-stack, advanced with pinned lease.
Combined Android run **37742118268** and Swift run **37742121423** are active at that head; inspect these IDs,
require one actual Android build/unit job and all 11 expected Swift package/tool jobs to finish successfully.
Do not repeat dispatch. PR #2729 currently has 14/17 successes, three running jobs, no review/comment.
No testing release has started; ship only after combined checks pass and upstream is rechecked unchanged.
Simulator smoke check is starting from its confirmed shutdown state with existing synthetic data: install/launch
the combined Debug app, inspect a screenshot, then terminate/shut down. No strap/physiology claim.
The [8 Oct audit](audits/charge-baseline-usability-2026-10-08/README.md) records the wider system priorities,
primary-source research, preregistered domain and runnable old/new replay. Public runner compiled and matched all
25 expected rows. Four empty-respiration fixtures now all match absence exactly; 10 br/min original92.617968 versus
fixed72.103474 is a synthetic 0–100 algorithm result, not a wearer-accuracy claim. Actual-data/resource work remains
for a raw backup/normal-day log; no dataset download or new physiology tuning.

- [ ] **Finish this repair's PR and integration/testing delivery.** Optional-baseline implementation and both-platform
  verification are complete above. Then jointly repair spectral units/resolution/timing as a separate concern.
  Actual-data replay benefits from a private `.noopbak`; physiological accuracy claims require independent references.
- [ ] Phone installation/export remains **deferred by Utku**. When resumed, **JUST UPDATE** the verified
  `f60718a9` IPA through AltStore over the existing app, preserving history. No wipe or repeat reminder test.
- [ ] Continue seven PR review/merge lifecycles after checking current heads. The six previous PRs retain their
  expected green check rosters; #2729 is still running upstream checks and no unanswered review on 8 Oct. Backup issue #2720 has no response and remains
  parked awaiting maintainer storage direction under existing approval; no duplicate report or approval request.

No completion blocker. Retained local dependencies: ignored private reports/raw logs and cached verification logs,
IPA and recovery bundle on this Mac. No personal backup/PSG dataset is available.

## Phone

**Hardware confirmed by Utku, 8 Oct:** WHOOP 5.0 and iPhone 16. He offers real-life tests when useful and asks for
simple step-by-step instructions. Give a short observation procedure after the new build is verified; no repeat
reminder/wipe/setup test. No fresh phone log or personal export has been supplied yet.

Fresh delete-first AltStore installation of **`6de9d6d`** was reported complete on 6 Oct. The 7 Oct phone log
now confirms app **12.0.0 (435)**, WHOOP 5/MG link establishment, live HR, completed history offloads and continued
background collection overnight. Mac awake/context setup was reported complete; no repeat setup is needed.
The earlier verified update **`01b55ac2`** was not confirmed installed. New update **`f60718a9`** is fully delivered
and independently verified; installation/export are deferred by Utku. When phone work resumes, **JUST UPDATE** through AltStore over the
existing app, preserving history. No migration change/fresh start is required. Downloaded IPA identity is
`com.noopapp.noop`, display name NOOP, version 12.0.0 (435), with widget extension retained. A version
header alone cannot prove installation because that number does not change between these testing builds.

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

## PRs — checked 8 Oct

| Upstream PR | Branch / head | Evidence and next action |
|---|---|---|
| [#2729](https://github.com/ryanbr/noop/pull/2729) | `codex/charge-baseline-usability` / `3e59a667` | Optional-baseline score/driver/trace eligibility; full local verify and final Android passed, exact original-math oracle. 17 upstream checks registered, 14 passed/3 running at last check. Integration delivery tracked in Now. |
| [#2724](https://github.com/ryanbr/noop/pull/2724) | `codex/rhr-one-pass` / `14783994` | One-pass resting-HR floor/diagnostic; exact original oracle, measured CPU/memory reduction. All 18 upstream checks green. Feature Android/final source gates and combined CI passed; release `f60718a9` fully delivered/independently verified. Await maintainer. |
| [#2722](https://github.com/ryanbr/noop/pull/2722) | `codex/hrv-sdnn-quality` / `b6e53f38` | Local full verify + fork Android passed; All 17 upstream checks green; no review/comment. Included in verified `01b55ac2`. Await maintainer. |
| [#2613](https://github.com/ryanbr/noop/pull/2613) | `dreamt-psg` / `ca008aba` | 17 checks green, clean merge; no review/comment. Await maintainer. |
| [#2660](https://github.com/ryanbr/noop/pull/2660) | `ios-deleted-sleep` / `e9ee598e` | 6 checks green; fresh delete unhides, recompute names the 21-day limit. [Review answered](https://github.com/ryanbr/noop/pull/2660#issuecomment-6016821944). Await maintainer. |
| [#2661](https://github.com/ryanbr/noop/pull/2661) | `ios-sync-reminder` / `7f9fc7aa` | 6 checks green; unset default OFF, saved choices survive. [Review answered](https://github.com/ryanbr/noop/pull/2661#issuecomment-6017174678). Await maintainer. |
| [#2717](https://github.com/ryanbr/noop/pull/2717) | `codex/docs-navigation` / `3ecf43c5` | Documentation index/current-history separation; 3 checks green. Await maintainer. |

All seven PRs are open and mergeable. #2613 is 86 commits behind but merges cleanly;
it needs no speculative rebase.
24 PRs merged, including #2659 on 4 Oct; the dated list and validation are in [History](HISTORY.md).
Before any PR action, recheck its current head, reviews and CI. Drafts/evidence stay in ignored `private/`.

## Git and latest release

- `main`, `origin/main`, `upstream/main`: **`8e94d559be273ec8d74832fe5db78898be83cc11`**; exact mirror, remote
  upstream tip rechecked during shipping.
- `testing-stack`: **`858d8c99b192888e4311c941fb4cc96bfe65f9bc`** (local/remote), base `8e94d559` plus
  #2613/#2660/#2661/#2722/#2724/#2729. Local combined iOS build passed; fork Android **37742118268** and Swift
  **37742121423** are active. Prior stack `979a2baf` remains bundled/tagged until new delivery passes.
- `testing-build`: **`f60718a9d3daf51aadbec1505174a25d6cd37ed8`** (local and remote), successful run **37685742398**;
  release **406156870**. Exact `meta`/`android`/`ios`/`macos` jobs passed; conditional cleanup skipped as expected.
  All five uploaded assets are nonempty; release target, local/remote `testing-latest` tag and build refs agree.
  IPA HTTP 200, 21,953,254 bytes, all ZIP CRCs passed; SHA-256
  `41872d7c558ad1ebcdb31a6339ec78ea3795b1706b19f22063b8359f9ed18b1a` matches GitHub's digest.
  App `com.noopapp.noop`, NOOP 12.0.0 (435); widget `com.noopapp.noop.widgets` retained, watch removed.
  Evidence: ignored `private/release-{run,metadata,assets,tag,ipa,bundle-recovery,cleanup}-f60718a9.json`;
  downloaded IPA: cache `rhr-one-pass/release-f60718a9/NOOP-ios-unsigned-v12.0.0.ipa`.
- Prior verified release (superseded): **`01b55ac2`**, base
  **12.0.0**, run **37597587148**, release **405571964**. Ship tool finished `shipped 01b55ac2`; four required jobs
  passed (cleanup intentionally skipped). All five nonempty assets uploaded; release target and local/remote tag
  exactly equal testing-build; IPA HTTP 200, downloaded ZIP/plist identity/size/SHA-256 verified against GitHub’s
  asset digest. Metadata: `private/release-{metadata,assets,run,ipa}-01b55ac2.json`.
- Earlier installed release: **`6de9d6d`**, 6 Oct; its prior metadata remains in `private/release-*-6de9d6d.*`.
- Code worktrees: root `main`; siblings `noop-dreamt`, `noop-deleted-sleep`, `noop-sync-reminder`; managed
  `/Users/utk/.codex/worktrees/docs-navigation/noop` and `/Users/utk/.codex/worktrees/hrv-spectral-power/noop`
  (`codex/hrv-sdnn-quality` / `b6e53f38`), plus `/Users/utk/.codex/worktrees/rhr-one-pass/noop`
  (`codex/rhr-one-pass` / `14783994`) and `/Users/utk/.codex/worktrees/charge-baseline-usability/noop`
  (`codex/charge-baseline-usability` / `3e59a667`). All PR code is clean/pushed; handbook is this `dist` worktree.
- Fork refs are the intended main/handbook/one per open PR/testing-stack/build, template/testing tags and upstream
  versions. No throwaway remote regression branch/stash. Only the active Charge scratch and local safety refs
  recorded in Now remain; prior RHR scratch/refs are retired.
  The old stack `0768710f` / build `01b55ac2` remain recoverable from cache
  `rhr-one-pass/pre-rhr-staging.bundle`: both tips imported into an empty Git repository and full `git fsck` passed
  before cleanup. `codex-setup.sh` re-run successfully for all seven code worktrees.

## Local evidence and resources

RHR #2724 `14783994` is fully verified; full local run at `035b6ab1` and final-head source/parity/governance +
Android `37683254213` results are in [History](HISTORY.md) and the [RHR audit](audits/rhr-one-pass-2026-10-07/README.md).
Final Swift/app/tool inputs are byte-identical to the local full run. Logs: cache `verify/035b6ab1/` and
`rhr-one-pass/`. No phone CPU/battery or physiological accuracy claim.

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

Inspect existing combined Android **37742118268** and Swift **37742121423** at exact stack `858d8c99`, plus
PR #2729 at `3e59a667` with its 17-check roster. Wait for running jobs; require actual build/unit steps and all
11 Swift jobs to pass. If anything fails, inspect retained/external logs and preserve scratch/safety refs; do not
repeat dispatch. After success recheck upstream unchanged at `8e94d559`, journal and ship this stack once, then
verify assets/tag/IPA and retire only recorded temporary refs after independent bundle recovery. No ship run has
started yet. Earlier RHR delivery and feature verification are complete. Phone tests will be simple and offered
after the new release is verified; no wipe/reminder retest.
