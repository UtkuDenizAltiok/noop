# State

Updated **8 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — next work

- [ ] **Stress freshness repair — software verified, testing delivery running.** Late cancelled Apple loads
  can no longer replace fresh Stress state at any of seven suspension boundaries; three corresponding Android
  reads propagate/check cancellation. Android core retry/cancellation remains external #2725, deliberately
  left unchanged. Successful data, math, coverage, priority, two-phase rendering and layout are preserved.
  Latest request (8 Oct): follow the deep research procedure more fully. Whole-system assessment, timing
  prerequisites, preregistered/exploratory cases, every failure/method correction and final evidence are in the
  [freshness audit](audits/stress-load-cancellation-2026-10-08/README.md).
  Source `/Users/utk/.codex/worktrees/stress-load-cancellation/noop`, branch `codex/stress-load-cancellation`,
  pushed `63e19100ced90540f1246806c33cb3312f9c808c`. PR [#2738](https://github.com/ryanbr/noop/pull/2738)
  published/attached; title/body/all eight blobs match local verification. All six exact-head PR checks and
  actual required steps passed, no review/comment. Final Android `37788525727` and final quick verification
  passed. Full Apple verification at `49777b94` is reused with exact identical input trees at final HEAD:
  632/2135/327 packages (one import skip), 127 governance, 2273 Mac tests/two existing skips, iOS build.
  Original/fixed simulator comparison passed on identical raw-row digests; original database restored and
  simulator shut down. No physiological/energy or real-phone claim.
  Combined stack `6c81515138d5c3b573e2029609fcf6ff919ddfc4` = existing six app PRs + fix. Parent tree equals
  old stack `858d8c99`; local/origin refs match. Combined local iOS build passed; Android `37791822785` and
  all eleven Swift jobs `37791827346` passed actual steps. Backfill is build-only. Temporary branches/worktrees
  retired, negative experiments and old source tips retained in verified cache bundles.
  **Release run `37793338186` is active at `c8eb1cd028701123517e8bb56fad5c093d99ba03`** (stack + template).
  `ship-build.sh` dispatched once; recover from task-cache `ship.pid`, `ship.log`, `ship.exit` and external run.
  Verify PID command before acting; foreground watcher survival across chat closure is uncertain, external CI
  survives. Do not repeat dispatch. Require actual four-job success, five nonempty assets, correct target/tag/
  refs, IPA HTTP200/CRC/app-widget identity/digest. Old release `e722e0c4` evidence/IPA retained. Current build
  is not yet verified or installed. **Just update** when verified; no wipe or stored-data compatibility change.
  Cache root `~/Library/Caches/noop-handbook/stress-load-cancellation-2026-10-08/`; private action metadata,
  scripts/body and input manifests `private/stress-load-cancellation-2026-10-08/`. Only local safety tags
  `backup/pre-stress-testing-{stack,build}` remain; retire after new release readback, with old tips recovered
  from `pre-testing.bundle`. No source/handbook work is unsaved; current handbook upload may lag checkpoints.
- [ ] **Phone/data observations remain deferred.** WHOOP 5.0 / iPhone 16; previous update `e722e0c4` was not
  confirmed installed. No repeat wipe, reminder test, diary or raw export. A short normal Stress check can be
  offered with the new verified update; installation and real-use freshness remain distinct from software proof.
- [ ] Continue nine own PR lifecycles after checking current heads; maintainers decide merges. Existing eight
  were open/green with no unanswered review, and new #2738 has six green checks. Backup issue #2720 stays parked
  awaiting maintainer storage direction. Spectral units/grid/discarded time remains one queued concern; validate
  packed/coarse timestamp provenance before implementing it. Later candidates live in Backlog.

**Recovery snapshot, 8 Oct:** ten code worktrees clean/pushed, main/upstream/origin remain `8e94d559`.
No unfinished Git operation/stash/local build. One existing external release and its foreground watcher are
running; do not treat the old completed privacy snapshot as current. Two documented testing safety refs remain.
Phone observation, personal raw backup and independent physiology datasets remain unavailable/deferred. All
large evidence/IPA/bundles depend on this Mac; private files are not uploaded with handbook checkpoints.

## Phone

**Hardware confirmed by Utku, 8 Oct:** WHOOP 5.0 and iPhone 16. He offers real-life tests when useful and asks for
simple step-by-step instructions. Replacement testing build `c8eb1cd0` is running; wait for asset verification
before offering its download. Last verified `e722e0c4` was not confirmed installed; normal-night observation
remains deferred. When ready: update over the existing app via AltStore, wear normally for one night with NOOP in the
background, then open Today and save/send the strap log (More → App → Test Centre → Strap log → Save…). Report any
unexpected screen/collection behaviour; a calibrating Charge can be correct before enough valid baseline nights.
No repeat reminder/wipe/setup test. Personal backup export remains deferred until a replay needs it.

Fresh delete-first AltStore installation of **`6de9d6d`** was reported complete on 6 Oct. The 7 Oct phone log
now confirms app **12.0.0 (435)**, WHOOP 5/MG link establishment, live HR, completed history offloads and continued
background collection overnight. Mac awake/context setup was reported complete; no repeat setup is needed.
Prior verified update **`e722e0c4`** was fully delivered; its cached evidence is retained. Its IPA is `com.noopapp.noop`, display name NOOP,
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
| [#2738](https://github.com/ryanbr/noop/pull/2738) | `codex/stress-load-cancellation` / `63e19100` | Seven Apple cancellation boundaries plus three Android reads; all six exact-head checks/actual steps passed, full/quick local and both Android stages passed, original/fixed production-path replay and simulator controls. No new review; testing release `c8eb1cd0` running. Android core remains #2725's separate work. |
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
- `testing-stack`: **`6c81515138d5c3b573e2029609fcf6ff919ddfc4`** (local/remote), base `8e94d559` plus
  #2613/#2660/#2661/#2722/#2724/#2729/#2738. Combined local iOS build passed, Android **37791822785** actual
  build/unit steps passed and Swift **37791827346** all eleven jobs passed at that exact head.
- Current `testing-build` local/remote: **`c8eb1cd028701123517e8bb56fad5c093d99ba03`** = stack + template
  upload workflow only. Release **406928323**, run **37793338186** still building; remote testing-latest/target
  already point there, local testing-latest remains `e722e0c4` until final force-fetch/readback. No completed
  asset/IPA verification or installation is claimed. Foreground ship recovery is in Now.
- Prior verified release/build (superseded while the replacement builds): **`e722e0c4b6e8dd82c913d180e776fe4889be0b8e`**,
  successful run **37743306160**, release **406540342**. Exact meta/Android/iOS/macOS jobs passed; conditional
  cleanup skipped. Ship monitor exited 0 with `shipped e722e0c4`. All five uploaded assets nonempty; release target,
  tag and refs agreed at its recorded verification. IPA HTTP 200, 21,953,533 bytes, all ZIP CRCs/plist identities passed;
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
  `codex/network-privacy-docs` / `a4f14442`; plus `/Users/utk/.codex/worktrees/stress-load-cancellation/noop`, `codex/stress-load-cancellation` /
  `63e19100`; entries reinstalled for all ten code worktrees.
- Fork refs are the intended main/handbook/one per open PR/testing-stack/build, template/testing tags and upstream
  versions. No throwaway regression branch/stash or scratch checkout remains. Two documented pre-testing safety tags
  remain until the active release verifies; their source is preserved in task-cache `pre-testing.bundle`.
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

Recover release run `37793338186` at exact build head `c8eb1cd0` before any action. Check task-cache ship PID's
command, `ship.log`/`.exit` and the external run. If running, wait on the existing action; if failed, inspect the
actual failed step and use Workflow's transient-failure rule; if completed, independently verify actual jobs,
release target/tag/refs, all five assets and downloaded IPA integrity/identity/digest. Then record delivery,
retire protected refs only after bundle recovery proof, upload handbook and run `checkpoint.sh status --net`.
PR #2738, feature/combined CI and simulator comparison are already complete; do not repeat them. Phone and
personal-data deferrals remain; give just-update instructions only after delivery verifies.
