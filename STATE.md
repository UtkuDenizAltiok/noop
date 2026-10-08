# State

Updated **8 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — next work

- [ ] **Active deep-research improvement — cancelled Stress loads:** investigate and repair stale publication
  after a newer refresh or lifecycle/device cancellation, on Apple and Android. Source `8e94d559` shows Apple
  `StressView` publishing results from `runUnescalated` without checking cancellation; Android's four
  `runCatching` boundaries can swallow cancellation before state writes. Controlled Apple replay now confirms
  all seven late-load boundaries overwrite fresh state on original source; repaired source preserves all seven.
  Preserve all successful readouts, priority, two-phase rendering, timestamps, score math and data coverage.
  Completion: preregistered controlled races through production load paths, seen-to-fail matched tests,
  unchanged normal-result/parity controls, full local/Android verification, own PR and testing-build delivery.
  Latest request (8 Oct): apply the deep procedure more fully beyond the completed documentation task.
  Worktree `/Users/utk/.codex/worktrees/stress-load-cancellation/noop`, branch `codex/stress-load-cancellation`,
  local commit `49777b94` (not yet pushed; final verification pending).
  Six Swift/eight Kotlin tests added. Apple seen-to-fail completed: removing cancellation checks failed four
  regression cases (six assertions); suppressing valid results failed both normal controls. Restored source
  digest matched exactly and all ten focused Stress/Unescalated tests passed; original warnings remain.
  Android negative regression run `37783143070`, head `905badc3566e2b971e83cf48812ee40b5588b1fe`, completed with successful build and 6645 tests/six skips, five expected new failures plus one existing
  source-text tripwire invalidated by the wrapped mode call. Update that guard to assert preference forwarding
  and selected-mode scoring, retaining its purpose; remove one new needless-cast warning. Check with `gh run view 37783143070 --repo UtkuDenizAltiok/noop`.
  Checkout: cache `stress-load-cancellation-2026-10-08/android-regression`, branch
  `codex/stress-load-cancellation-regression`. Utku warned before deliberate failures; next control-only
  mutant follows after this run completes. Do not duplicate either dispatch.
  Local source mutation job has finished, no live build remains; `{swift-no-cancellation,swift-no-valid-results,
  swift-restored}.{log,exit}`, matching `swift-source-{before,after}.sha256` and completion marker retained.
  Parity preflight: no new ledger finding; authoritative full verification still pending.
  Local one-concern consolidation completed with byte-identical production tree; prior tips in local safety
  tags `backup/pre-stress-{squash,wiring}` and verified `pre-{squash,wiring}.bundle` files. First full verify
  at `82d8d0ae`: packages 632/2135/327 (one import skip), source/i18n/ledger/ratchet, 127 governance and iOS
  build passed. Mac: 2273/two existing skips, sole failure in the Apple text-dependent wiring guard; six new
  cancellation tests passed. Corrected matched Apple/Android guards and needless Kotlin cast in `49777b94`.
  Production sources are identical to `82d8d0ae`; test corrections alone require final verification.
  Feature branch pushed once; normal Android CI `37786421064` at exact `49777b94`, now running.
  Apple wiring mutation completed: two tests, one expected assertion failure, source SHA restored exactly.
  Full final verification now active on clean `49777b94`; no repeated mutation required. Driver `private/stress-load-cancellation-2026-10-08/final-verify.sh`;
  task cache `final-verify.pid`, `final-verify-driver.log`, `final-verify.exit`, `swift-wiring-{negative,restore}`
  evidence. Foreground survival uncertain; inspect PID command/log before restarting. No shared builds overlap.
  Second Android negative run `37784315713` at `35acdba7`: APK built, six selected tests/four expected failures
  (three valid-work controls and disconnected preference), two other wiring controls passed. No crash. Both
  negative jobs are finished; no duplicate dispatch. Branch/worktree cleanup follows final positive evidence.
  Old/fixed simulator comparison planned on the same synthetic database: 7200 1-Hz HR rows, 7200 synthetic
  varying R-R rows, seven imported Stress points; no raw sensor rows existed beforehand. Back up the existing
  simulator DB before fixture insertion, retain both copies. Private `simulator-fixture.py` and cache input hashes;
  this tests rendering/normal-result preservation, not physiological truth or a phone race prevalence estimate.
  Old source checkout at cache
  `stress-load-cancellation-2026-10-08/old-ui`, base `8e94d559`. No release started.
  Spectral normalization/grid/time remains coupled and queued: stored historical R-R rows share record timestamps,
  so a replacement must validate timing provenance rather than treating those stamps as precise beat times.
- [ ] **Next bounded priority — spectral biometric correctness:** power units, grid resolution and discarded
  time together, following 7 Oct audit findings 2/3 and the timing row. No estimator implementation started. Use a preregistered finite
  domain with varying signals and independent power/timing references; preserve score paths outside the optional
  readout. Raw backup can support processing replay; human accuracy claims require independent references.
- [ ] **Phone observation offered by Utku (WHOOP 5.0 / iPhone 16):** installation/normal-night observation for
  `e722e0c4` remain unconfirmed; do the simple update/log check in Phone when he chooses. Personal backup export
  stays deferred until actual-data replay needs it; no wipe, repeated reminder test or diary.
- [ ] Continue eight PR review/merge lifecycles after checking current heads. All eight were open/mergeable with
  their expected green rosters and no unanswered review on 8 Oct. Backup issue #2720 stays parked awaiting
  maintainer storage direction under existing approval; no duplicate report or approval request.

**Completion checkpoint, 8 Oct:** all nine code worktrees clean/pushed, eight PRs open/mergeable with
their expected green checks and no unanswered review. No local build/test/release job, queued/running fork CI,
unfinished Git operation, stash or temporary safety ref. Remote upstream remains `8e94d559`.
No software/delivery blocker. Phone observation and independent physiological validation remain unproven.
Private evidence, cached logs, IPA and recovery bundles were located and depend on this Mac; no personal
backup/PSG dataset is available. Recovery/final privacy readbacks: ignored `private/network-privacy-2026-10-08/`.

## Phone

**Hardware confirmed by Utku, 8 Oct:** WHOOP 5.0 and iPhone 16. He offers real-life tests when useful and asks for
simple step-by-step instructions. Verified update `e722e0c4` is ready; installation/normal-night observation are
unconfirmed. When ready: update over the existing app via AltStore, wear normally for one night with NOOP in the
background, then open Today and save/send the strap log (More → App → Test Centre → Strap log → Save…). Report any
unexpected screen/collection behaviour; a calibrating Charge can be correct before enough valid baseline nights.
No repeat reminder/wipe/setup test. Personal backup export remains deferred until a replay needs it.

Fresh delete-first AltStore installation of **`6de9d6d`** was reported complete on 6 Oct. The 7 Oct phone log
now confirms app **12.0.0 (435)**, WHOOP 5/MG link establishment, live HR, completed history offloads and continued
background collection overnight. Mac awake/context setup was reported complete; no repeat setup is needed.
Latest verified update **`e722e0c4`** is fully delivered. Its IPA is `com.noopapp.noop`, display name NOOP,
12.0.0 (435), widget retained; install over the existing app through AltStore to preserve history. No migration
change/fresh start is required. Neither previous `01b55ac2` nor `f60718a9` was confirmed installed. The same
version header cannot prove this update was installed; use the newly downloaded release IPA and AltStore completion.

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
| [#2737](https://github.com/ryanbr/noop/pull/2737) | `codex/network-privacy-docs` / `a4f14442` | Source-backed canonical network inventory and linked guide corrections; all three exact-head checks passed, all six published blobs/body matched local verification, no review/comment. Documentation only; no app release. Await maintainer. |
| [#2729](https://github.com/ryanbr/noop/pull/2729) | `codex/charge-baseline-usability` / `3e59a667` | Optional-baseline score/driver/trace eligibility; full local verify and final Android passed, exact original-math oracle. All 17 upstream checks passed on the exact head; no review/comment. Independently verified update `e722e0c4` delivered. Await maintainer. |
| [#2724](https://github.com/ryanbr/noop/pull/2724) | `codex/rhr-one-pass` / `14783994` | One-pass resting-HR floor/diagnostic; exact original oracle, measured CPU/memory reduction. All 18 upstream checks green. Feature Android/final source gates and combined CI passed; release `f60718a9` fully delivered/independently verified. Await maintainer. |
| [#2722](https://github.com/ryanbr/noop/pull/2722) | `codex/hrv-sdnn-quality` / `b6e53f38` | Local full verify + fork Android passed; All 17 upstream checks green; no review/comment. Included in verified `01b55ac2`. Await maintainer. |
| [#2613](https://github.com/ryanbr/noop/pull/2613) | `dreamt-psg` / `ca008aba` | 17 checks green, clean merge; no review/comment. Await maintainer. |
| [#2660](https://github.com/ryanbr/noop/pull/2660) | `ios-deleted-sleep` / `e9ee598e` | 6 checks green; fresh delete unhides, recompute names the 21-day limit. [Review answered](https://github.com/ryanbr/noop/pull/2660#issuecomment-6016821944). Await maintainer. |
| [#2661](https://github.com/ryanbr/noop/pull/2661) | `ios-sync-reminder` / `7f9fc7aa` | 6 checks green; unset default OFF, saved choices survive. [Review answered](https://github.com/ryanbr/noop/pull/2661#issuecomment-6017174678). Await maintainer. |
| [#2717](https://github.com/ryanbr/noop/pull/2717) | `codex/docs-navigation` / `34c9eeac` | Guide index/current-history separation plus four completed execution recipes retired; designs/manual checks and 120 other pages preserved. All three exact-head checks passed; final title/body updated and read back. Documentation only; no app release needed. Await maintainer. |

All eight PRs are open and mergeable with their full green rosters. #2613 is 86 commits behind but merges cleanly;
it needs no speculative rebase.
24 PRs merged, including #2659 on 4 Oct; the dated list and validation are in [History](HISTORY.md).
Before any PR action, recheck its current head, reviews and CI. Drafts/evidence stay in ignored `private/`.

## Git and latest release

- `main`, `origin/main`, `upstream/main`: **`8e94d559be273ec8d74832fe5db78898be83cc11`**; exact mirror, remote
  upstream tip rechecked during shipping.
- `testing-stack`: **`858d8c99b192888e4311c941fb4cc96bfe65f9bc`** (local/remote), base `8e94d559` plus
  #2613/#2660/#2661/#2722/#2724/#2729. Local combined iOS build passed. Fork Android **37742118268** passed its
  actual build/unit job; Swift **37742121423** passed all 11 expected package/tool jobs at that exact head.
- Current `testing-build` and local/remote `testing-latest`: **`e722e0c4b6e8dd82c913d180e776fe4889be0b8e`**,
  successful run **37743306160**, release **406540342**. Exact meta/Android/iOS/macOS jobs passed; conditional
  cleanup skipped. Ship monitor exited 0 with `shipped e722e0c4`. All five uploaded assets nonempty; release target,
  local/remote tag and build refs agree. IPA HTTP 200, 21,953,533 bytes, all ZIP CRCs/plist identities passed;
  SHA-256 `f1cb7aac015d5458b7f72ff9a148eb9b5a6712baa4a8bcded09e8f977685fa74` matches GitHub's digest.
  `com.noopapp.noop`, NOOP 12.0.0 (435), widget `com.noopapp.noop.widgets` retained, watch stripped.
  Reports: ignored `private/release-{run,metadata,assets,tag,ipa,ipa-prefetch,bundle-recovery,cleanup}-e722e0c4.json`;
  IPA cache `charge-baseline-usability/release-e722e0c4/NOOP-ios-unsigned-v12.0.0.ipa`.
- Prior verified `f60718a9` (superseded), successful run **37685742398**;
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
  New documentation worktree `/Users/utk/.codex/worktrees/network-privacy/noop` is
  `codex/network-privacy-docs` / `a4f14442`; local entries reinstalled for all nine code worktrees.
- Fork refs are the intended main/handbook/one per open PR/testing-stack/build, template/testing tags and upstream
  versions. No throwaway regression branch/stash, local safety refs or scratch checkout remain.
  The old stack `979a2baf` / build `f60718a9` are recoverable from cache
  `charge-baseline-usability/pre-charge-staging.bundle`: independently imported into an empty Git repository and
  full fsck passed before cleanup. `codex-setup.sh` re-run for all eight code worktrees.
  The old stack `0768710f` / build `01b55ac2` remain recoverable from cache
  `rhr-one-pass/pre-rhr-staging.bundle`: both tips imported into an empty Git repository and full `git fsck` passed
  before cleanup. `codex-setup.sh` re-run successfully for all seven code worktrees.

## Local evidence and resources

Network/privacy #2737 `a4f144428e6b7f4c74344a39c0b9c9f8aa51f945`: one canonical direct-HTTP inventory;
Android permission, update default/payload, Custom keyless AI, consent/brief/chart and sandbox claims corrected.
Platform-service traffic is separate. [Source-backed audit](audits/network-privacy-2026-10-08/README.md).
Local source hygiene/i18n passed with Python 3.12. 126 Markdown pages have no new missing local targets;
seven new fragment links resolve, three legacy anchors retained and all six changed pages rendered by GitHub.
120 other Markdown files and source/tests/tools/workflows/config trees unchanged. All six remote document blobs
and PR title/body matched the verified local files. Exact-head check-runs roster: all three complete/success;
Source `37777649489`, i18n `37777649539`, Tools Python `37777649601` actual job/steps passed. Tools ran
234 capture (one existing skip), 50 repository acceptance, two legacy R-R and 153 core tests. Open/mergeable,
no review/comment. No app build, release or phone action required. Private recovery/source hashes/inventories/
validator/readbacks: `private/network-privacy-2026-10-08/`; HTML and CI logs: cache `network-privacy-2026-10-08/`.
No packet-capture, third-party retention, hardware, energy or physiological-accuracy claim.

Charge #2729 `3e59a667`: six new tests, 625 score cases, 25 compiled original-math raw-bit oracle rows on both
platforms, four seen-to-fail/restored mutations and 70 targeted tests. Full verify: 632/2141/327 packages,
127 governance, 2267 Mac tests and iOS build (one import/two Mac skips), all steps passed. Final Android
`37740134786` passed actual build/unit steps; original `37739654819` failed exactly five expected new tests
among 6643/six skips after successful compile. No new warnings in changed files. Source and numeric replay:
[8 Oct audit](audits/charge-baseline-usability-2026-10-08/README.md); private `session-2026-10-08-charge-baselines/`;
cache `verify/3e59a667/` and `charge-baseline-usability/`. Simulator launch rendered initial disclaimer, not a Today
score walkthrough; screenshot retained, app terminated/simulator shut down. No strap claim from simulator.

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

Simulator `DCAA8034-6801-4D1F-8FD9-B42B2F424B6F` (iPhone 17 Pro, iOS 27.0), no strap, shut down.
Previously seeded 120 synthetic days; current availability was not established by the 8 Oct disclaimer-only launch.
Xcode 27.0, XcodeGen, gh, Python 3.12 available; Android tests run in fork CI. The new phone log is retained privately;
personal backups and sleep-accel / restricted DREAMT datasets remain absent on this Mac. Obtain raw data when an analysis needs it; never tune from old aggregates.
Docs #2717: exact head `34c9eeac7649136ff79b1bd2e209abc90e2a85b3`, three required upstream checks passed
(source `37750786309`, i18n `37750786251`, Tools Python `37750786331`). Actual CI test totals: 234 capture,
50 repository acceptance, two legacy R-R, 153 core Tools. Local source hygiene/protocol arithmetic/163 source
references/i18n passed. 123 remaining Markdown pages checked with no new broken local targets; GitHub rendering
and four exact history blobs verified. Both original design bodies and 120 other pages retained; app source/tests/
tools/workflows/config unchanged. Final PR title/body read back exactly; open/mergeable, no review/comment.
Private evidence: `private/organisation-audit/doc-simplification-2026-10-08.json`; HTML/CI log in cache
`doc-simplification-2026-10-08/`. Earlier navigation verification remains in History and the same private audit.
Handbook entry points to canonical procedures; start/end prompts and complete setup section preserved; handbook
local-link/fence checks and all checkpoint/installer regression checks passed.

## Next safe action

Inspect Android regression run `37783143070` and task-cache local verification PID/log before acting. If still
running, recover it; if complete, capture actual build/test results and continue the recorded normal-control
mutation followed by restored verification. Active source is `codex/stress-load-cancellation`; do not repeat
existing PR/release actions. Phone and personal-data tasks remain deferred.
