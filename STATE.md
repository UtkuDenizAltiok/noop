# State

Updated **8 Oct 2026**. ChatGPT/Codex owns project execution under [Rules](RULES.md).

## Now — session resumed, 8 Oct 2026

- [ ] **Active — HRV cleaning neighbour-buffer reuse.** Selected after the preregistered pilot:
  **137,267 exact original/candidate cases passed** (cleaned Double bits and every gap flag); seven alternating
  Swift `-O` trials show **30.7–31.7% lower cleaning CPU**, including 300/36,000/108,000 intervals with and without
  artefacts. [Plan](audits/hrv-clean-buffer-2026-10-08/preregistered.md), [pilot summary](audits/hrv-clean-buffer-2026-10-08/pilot-summary.json).
  Implement only per-call neighbour-array reuse in `rejectEctopic` / `cleanRRGapAware`, on both platforms.
  Preserve sorting/math/thresholds, all inputs/results/adjacency, visual quality and freshness. No phone-energy,
  physiological-accuracy or spectral-repair claim. Source worktree `/Users/utk/.codex/worktrees/hrv-clean-buffer/noop`, branch `codex/hrv-clean-buffer`,
  base `8e94d559`. Swift production hash exactly equals the measured pilot candidate. Two new matched
  original-output tests added on each platform; initial Swift run passed both. Local plain/gap buffer-reset
  mutations are running sequentially with automatic byte-identical restoration. Expected-failing Android
  mutation CI has been announced to Utku before any dispatch; temporary ref/job not created yet.
  Cache: `~/Library/Caches/noop-handbook/hrv-clean-buffer-2026-10-08/`; private reports: `private/hrv-clean-buffer-2026-10-08/`.
  Recovery complete: nine existing PR heads unchanged, expected 3/6/17/18-check rosters green; no unanswered
  maintainer reviews. No running build, dirty source, stash/safety ref or Git operation. Committed source **`c71b48af5f07c94f92b8a7fb1af14506f2b0a10d`** (four intended files).
  Both local reset mutations failed their test assertions without crashes, each restored to the exact production
  hash. Next actions journaled before execution: launch one full local verify at this committed head; push
  the feature branch; create/push one temporary Android reset-mutation branch with only the two new tests selected,
  dispatch Android CI there, record its ID/head/build+test result, then retire it after exact restoration.
  Full local verify actually started under **PID 4426**, command
  `bash ~/Library/Caches/noop-handbook/hrv-clean-buffer-2026-10-08/run-verify.sh`, independently detached;
  completion is `full-verify.exit` plus `all steps passed` in `full-verify.log`. PID 4298's shell-background
  attempt exited before creating a verify log; checked inactive before replacement, so no overlap occurred.
  Negative Android run **37826824779**, head **`d27bfb0c01e978347f47dc5d7578733d78dbad1c`**, branch
  `codex/hrv-clean-buffer-regression`, cache worktree `hrv-clean-buffer-2026-10-08/android-regression`.
  Completed with the expected failure: APK build success, exactly two selected tests/two
  `ComparisonFailure` assertions, zero extra tests. Patch/log/job metadata retained; source/workflow restored
  byte-identical to feature files. Retiring the temporary remote/local branch and cache checkout next. Readback command: `gh run view 37826824779 --repo UtkuDenizAltiok/noop --json headSha,status,conclusion,jobs`.
  Final full Android run
  **37828040856** completed successfully on feature **`c71b48af`** after that verified negative result; exact head and actual APK+full-unit steps passed. Logs retained. Combined candidate is clean/detached **`c13e8873e3e06c234abbe757dbcfcc5a997962e7`**
  at `~/Library/Caches/noop-handbook/hrv-clean-buffer-2026-10-08/staging-noop`, old stack parent `6c815151` plus
  the new change. Its changed-path set exactly equals the old stack union four new source/test paths; no
  parked wording included. Prior stack/build/tag bundle has been independently imported, exact tips matched
  and full fsck passed. Full local verify exited **0 / all steps passed**: 632 store, 2137 analytics,
  327 import (one existing skip), all source/i18n/parity gates, 127 governance, 2267 Mac tests (two existing
  skips) and iOS build. Generated Info.plist restored; feature clean/pushed. Stronger final benchmark completed
  with full output consumption and exact 137,267-case preservation; final results retained in the audit.
  Launch combined iOS build only now that verify and benchmark have exited; script/log/exit files in task cache. Combined build PID **9340**, command
  `bash ~/Library/Caches/noop-handbook/hrv-clean-buffer-2026-10-08/run-staging-ios.sh`; independent session, log
  `staging-ios.log`, completion `staging-ios.exit` and `BUILD SUCCEEDED`. Verify PID command before acting.
  Simulator walkthrough will use the existing DEBUG `--demo-screen stress` entry, never a consent change or
  source injection. Preserve installed app/data/preferences before install; restore them and shutdown afterward.
  Simulator UI app/CUA is unavailable here; use the handbook's simctl screenshot workflow, report that boundary. Before any future testing-ref rewrite, preserve old stack/build/tag tips in
  `hrv-clean-buffer-2026-10-08/pre-testing.bundle` and independently import/fsck them. Journaled preparation may
  create a detached combined candidate from the unchanged current stack plus `c71b48af`; it must exclude the
  parked wording work and pass its local iOS build, combined Android and eleven Swift jobs before shipping.
  The full verify currently owns shared Xcode caches; no combined build will overlap it.
  PR publication is now journaled: local/fork verification passed on `c71b48af`,
  description in `private/hrv-clean-buffer-2026-10-08/pr-body.md`, title
  `perf(hrv): reuse neighbour buffers without changing cleaned intervals`, one concern/four files. Create once,
  record URL/number and attach it, read back exact head/body, then require stable expected upstream roster
  (17 jobs for Packages+Android) and actual build/test steps. Published and attached [PR #2742](https://github.com/ryanbr/noop/pull/2742), exact `c71b48af`/body
  read back; expected 17 upstream checks registered/pending.
  Combined iOS build **c13e8873** exited 0 / BUILD SUCCEEDED; generated Info.plist restored. Old stack/build/tag
  independently bundled/recovered/fsck verified. Current remote testing refs/upstream tip rechecked unchanged.
  Next public actions journaled: local safety tags for both old testing refs, pinned-lease push of tested `c13e8873`
  to testing-stack, synchronize local branch, dispatch exactly one combined Android and one 11-job Swift run.
  Record IDs/head and actual job/step results before any ship action; last verified release at dispatch was c8eb1cd0; the workflow moves the testing tag before assets are built. Testing-stack local/remote now **c13e8873**;
  combined Android run **37829415471**, combined Swift run **37829420443** (eleven jobs), both **completed successfully** at that head; Android APK/unit steps and every
  one of the eleven Swift build/test jobs read back and passed (Backfill remains build-only). Upstream PR roster
  has 16 successes/one in progress at exact feature head; keep checking through delivery.
  Next public action journaled: run handbook `ship-build.sh testing-stack` once, producing testing-build as
  c13e8873 plus the unchanged template-upload commit, using pinned lease. Preserve run/build/release IDs as they
  appear. Require four actual release jobs, five nonempty assets, matching target/ref/tag, HTTP200 and downloaded
  IPA SHA256/ZIP/plist/widget/background-capability verification before claiming delivery. Launch independently
  with cache `run-ship.sh`, logs `ship.log`, final `ship.exit`; no duplicate dispatch if interrupted.
  Ship monitor PID **13389**, exact command `bash ~/Library/Caches/noop-handbook/hrv-clean-buffer-2026-10-08/run-ship.sh`;
  independently detached, survives chat closure. Testing-build local/remote **`ef6216f8bc8076bb62277b700666ffb8c9c99531`**,
  testing-stack c13e8873 plus unchanged template workflow; release run **37830619829**. Run readback:
  `gh run view 37830619829 --repo UtkuDenizAltiok/noop --json status,conclusion,headSha,jobs`.
  Monitor log `ship.log`, terminal marker `ship.exit` and `shipped ef6216f8`; independent downloadable asset
  verification script `private/hrv-clean-buffer-2026-10-08/verify-release.py ef6216f8bc8076bb62277b700666ffb8c9c99531 37830619829`.
  Completion needs that script's stored release/IPA reports as well as the successful monitor. New testing
  ref publication is complete; built/downloadable/installed remain separate pending states. The final upstream
  check still running is universal macOS build/test; all other sixteen checks passed.
  Local safety tags `backup/pre-hrv-clean-stack` (6c815151) / `backup/pre-hrv-clean-build` (c8eb1cd0) retained
  until final shipping/readback; independent bundle/recovery proves retiring them later is safe.
  Simulator smoke rendered Stress's existing missing-data state. It is no numeric or hardware evidence.
  Original app reinstalled; after an unavailable simctl `kill` binary, exact host cfprefsd PID/command was
  verified/signalled and original snapshot recopied. After shutdown, database logical dump and preference
  bytes match. Report `private/hrv-clean-buffer-2026-10-08/simulator-restoration.json`; original snapshots retained. Initial harness compile
  failed on fixture type inference, corrected before measurement; retained `pilot-compile-error.log` is harness
  evidence, not a product test failure. Measurement follow-up preregistered before execution: consume every returned value/adjacency flag through
  a non-inlined digest to prevent unused-field elimination; same workloads/trials, retain count-only pilot.
  Run it only after local verify exits, before the combined build. No PR or release/public action yet.

**Latest priority:** English is the only language Utku cares about; language/copy/translation improvements are
his lowest priority. The settled instruction lives in [Rules](RULES.md#settled-decisions). The saved Stress wording
work stays parked, not delivered or discarded. This resumed session owns only the bounded HRV buffer improvement.

- [ ] **Parked, incomplete — Stress spectral explanations.** Source worktree
  `/Users/utk/.codex/worktrees/stress-spectral-explanations/noop`, branch `codex/stress-spectral-explanations`,
  clean and pushed at **`0285a675cd89cec8e5e1557ae14d35d352d4f7df`**. This changes five labels/explanations and
  their resources across twelve files; it makes no numeric/algorithm/transport/storage change. Research,
  preregistration, exact source proof, results and limitations are in the
  [saved audit](audits/stress-spectral-explanations-2026-10-08/README.md).
  Full local verification ended **all steps passed** at this head; fork Android **37816053441** completed
  successfully with actual debug-build and unit-test steps checked. Both local job PIDs (5148 verify, 11107
  combined iOS build) exited. No PR exists for this change; zero upstream check-runs means unpublished, not green.
  Both changed spectral branches retained observed numbers (ratio 2.3, HF-only 0); the English footer was fully
  visible. Original/fixed headline snapshots varied (1.1/1.2), with preferences not restored identically for every
  original run. The exact cause and complete same-effective-input headline comparison are unresolved. Do not
  claim complete runtime equivalence or spend more on locale QA. No new verification/publication/release was
  started after Utku requested closure.
  A clean, **local-only detached** combined candidate remains at **`ec329949618bcd43975100dc310306f146e4b4a0`**,
  `~/Library/Caches/noop-handbook/stress-spectral-explanations-2026-10-08/staging-noop`. Its local iOS build passed;
  it has not had combined Android/Swift CI or testing delivery. Relevant unchanged package/tool/test/build input
  trees are recorded for possible future evidence reuse, not a claim that candidate CI ran. Keep this checkout.
  Old testing refs remain `6c815151` / `c8eb1cd0`; neither was moved. The independently imported/fsck-verified
  `pre-testing.bundle` and recovery repository are retained in the same cache.
- [ ] **Pending external review:** all nine existing own PRs remain open/mergeable at their recorded heads, with
  their expected green rosters and no unanswered maintainer review, rechecked at 21:08 TRT. One friendly,
  distinct benefit/review request tagging `@ryanbr` on each is complete and read back; #2738/#2661 bodies also
  reflect confirmed phone observations. Do not post again. URLs/text/readbacks are retained in
  `private/review-requests-2026-10-08/`; closure metadata in
  `private/stress-spectral-explanations-2026-10-08/session-close-pr-state.json`.
- [ ] **Queued, not started — spectral numeric correctness:** units/grid/missing-time reconstruction together,
  including packed/coarse record timestamps. This remains a higher-value candidate than wording; reassess current
  upstream and retained varying-signal evidence before choosing a bounded repair. Other priorities remain in Backlog.

**Prior closure snapshot (21:08 TRT):** twelve code worktrees are clean: root plus ten named source branches are pushed; the
one detached combined candidate above is local-only. Main/origin/upstream remain `8e94d559`. No running local
build/watch/release, queued/running task CI, unfinished Git operation or stash. No new PR, release dispatch,
testing ref movement or safety tag. The source commit and current handbook are on the fork; private fixtures,
logs, screenshots, drafts, bundles and the combined candidate depend on this Mac. Public backup does not upload them.

**Temporary simulator state restored:** device `DCAA8034-6801-4D1F-8FD9-B42B2F424B6F` has the previous cached
Stress-cancellation app reinstalled; original database matches its saved logical dump, original app preferences
match, content size is back to `large`, device shut down. This is logical SQLite equality, not byte-identical WAL
layout. Restoration was verified again after shutdown. Report:
`private/stress-spectral-explanations-2026-10-08/simulator-restoration.json`. Original snapshots remain in cache;
no physical-phone changes or legal-consent changes were made.

Completed cancellation delivery, installed-build confirmation and owner invitations are in [History](HISTORY.md).
There is no external blocker to preserving this handover. The unfinished wording work is paused by Utku's
closure/priority instruction; pending scientific reference/data needs remain separate. No phone test/export needed.

## Phone

**Hardware confirmed by Utku, 8 Oct:** WHOOP 5.0 and iPhone 16. He offers useful real-life tests with simple
steps. On 8 Oct he explicitly confirmed installing today's latest update **`c8eb1cd0`** through AltStore
before checking Stress, and reported seeing nothing wrong. No repeat installation or check is requested.
This repair preserves the layout and calculation formulas; it prevents a cancelled older load from replacing
newer results. "Leave and return" meant using the back arrow to return to the More list, then tapping Stress
again, within NOOP. It did not mean force-closing the app, reinstalling or removing the strap. Advanced readouts
can legitimately be absent when their data gates are unmet. Installation is established by his explicit answer;
the version header alone cannot identify `c8eb1cd0`. If a readout later unexpectedly clears or returns to older
data, report what was seen and save a contemporaneous strap log
(More → App → Test Centre → Strap log → Save…). No repeat wipe/reminder/diary.
Normal-night observation and personal export stay deferred until useful; no new request for either.

**8 Oct 19:30 supplied log review complete:** original privately preserved byte-for-byte (SHA256
`8dff66467538c49717fb7a46816fd39d1b0e4669bd10a0d4981c55fd7d6275fa`); nine retained app sessions,
oldest head clipped. Latest history completion at 19:28:12, successful link at 19:28:39, three successful live
flushes through 19:29:50 and completed scoring. No recorded live-flush failure or expired scoring assertion.
Earlier timeouts/reconnect pause and Bluetooth-off period precede successful resumed history downloads; do not
claim an uninterrupted connection or infer why processes restarted. Details and personal timeline remain in
`private/session-2026-10-08-phone-stress/analysis.json`. There are no Stress-specific screen-publication lines;
the log cannot prove the race was triggered/prevented or what was drawn. A full `.noopbak` is not needed for this
fix or this log review. No new code/CI/release action was started. Clearer change/test explanations are now in Rules.

Fresh delete-first AltStore installation of **`6de9d6d`** was reported complete on 6 Oct. The 7 Oct phone log
now confirms app **12.0.0 (435)**, WHOOP 5/MG link establishment, live HR, completed history offloads and continued
background collection overnight. Mac awake/context setup was reported complete; no repeat setup is needed.
Newest verified update **`c8eb1cd0`** is delivered and installation is confirmed by Utku. Its IPA is
`com.noopapp.noop`, display name NOOP, 12.0.0 (435), widget retained; its delivery instruction was just update
over the existing app through AltStore. No migration change/fresh start was required. Neither previous
`e722e0c4`, `01b55ac2` nor `f60718a9` was separately confirmed installed. Same-version headers cannot identify
testing commits; the explicit user confirmation above establishes this latest installation.

**Sync-stopped reminder confirmed on the phone:** the log scheduled it for about 00:31; Utku reported seeing
it around **00:32 on 7 Oct**. The log then shows an app launch at 00:35. Do not repeat the three-hour test.
Whether opening cleared the delivered line has not been separately observed.

A normal overnight log is now available in ignored `private/session-2026-10-07-backup/strap-log.txt`.
No personal export was needed for either synthetic investigation. A full `.noopbak` may help a future sensor/
biometric replay; export remains deferred until that work needs it. Its path is More → Settings → Advanced →
Backup & restore → Export…. Keep it private; no export request is active.
The new install has little history;
this log alone is not a like-for-like battery or sleep-accuracy comparison with the older installation.

Later: deleted-sleep list (delete a night, let undo expire, recompute clears the marker, Hide keeps suppression) and
ended-banner check (after roughly 8 h, open NOOP and check one banner). Do these after fresh data exists.
Utku's recent nights were atypical, sometimes strap-off/swiped away: infer gaps from logs rather than asking him to
keep a diary. Compare staging changes on the same nights, never one night against another.

## PRs — checked 8 Oct

| Upstream PR | Branch / head | Evidence and next action |
|---|---|---|
| [#2738](https://github.com/ryanbr/noop/pull/2738) | `codex/stress-load-cancellation` / `63e19100` | Seven Apple cancellation boundaries plus three Android reads; all six exact-head checks/actual steps passed, full/quick local and both Android stages passed, original/fixed production-path replay and simulator controls. No new review; verified testing release `c8eb1cd0` delivered; latest installation confirmed by Utku and normal Stress appearance reported. Android core remains #2725's separate work. |
| [#2737](https://github.com/ryanbr/noop/pull/2737) | `codex/network-privacy-docs` / `a4f14442` | Source-backed canonical network inventory and linked guide corrections; all three exact-head checks passed, all six published blobs/body matched local verification, no unanswered maintainer review. Documentation only; no app release. Await maintainer. |
| [#2729](https://github.com/ryanbr/noop/pull/2729) | `codex/charge-baseline-usability` / `3e59a667` | Optional-baseline score/driver/trace eligibility; full local verify and final Android passed, exact original-math oracle. All 17 upstream checks passed on the exact head; no unanswered maintainer review. Independently verified update `e722e0c4` delivered. Await maintainer. |
| [#2724](https://github.com/ryanbr/noop/pull/2724) | `codex/rhr-one-pass` / `14783994` | One-pass resting-HR floor/diagnostic; exact original oracle, measured CPU/memory reduction. All 18 upstream checks green. Feature Android/final source gates and combined CI passed; release `f60718a9` fully delivered/independently verified. Await maintainer. |
| [#2722](https://github.com/ryanbr/noop/pull/2722) | `codex/hrv-sdnn-quality` / `b6e53f38` | Local full verify + fork Android passed; All 17 upstream checks green; no unanswered maintainer review. Included in verified `01b55ac2`. Await maintainer. |
| [#2613](https://github.com/ryanbr/noop/pull/2613) | `dreamt-psg` / `ca008aba` | 17 checks green, clean merge; no unanswered maintainer review. Await maintainer. |
| [#2660](https://github.com/ryanbr/noop/pull/2660) | `ios-deleted-sleep` / `e9ee598e` | 6 checks green; fresh delete unhides, recompute names the 21-day limit. [Review answered](https://github.com/ryanbr/noop/pull/2660#issuecomment-6016821944). Await maintainer. |
| [#2661](https://github.com/ryanbr/noop/pull/2661) | `ios-sync-reminder` / `7f9fc7aa` | 6 checks green; unset default OFF, saved choices survive. [Review answered](https://github.com/ryanbr/noop/pull/2661#issuecomment-6017174678). Await maintainer. |
| [#2717](https://github.com/ryanbr/noop/pull/2717) | `codex/docs-navigation` / `34c9eeac` | Guide index/current-history separation plus four completed execution recipes retired; designs/manual checks and 120 other pages preserved. All three exact-head checks passed; final title/body updated and read back. Documentation only; no app release needed. Await maintainer. |

All nine PRs are open and mergeable with their full green rosters. #2613 is 86 commits behind but merges cleanly;
it needs no speculative rebase.
24 PRs merged, including #2659 on 4 Oct; the dated list and validation are in [History](HISTORY.md).
Before any PR action, recheck its current head, reviews and CI. Drafts/evidence stay in ignored `private/`.

## Git and latest release

- `main`, `origin/main`, `upstream/main`: **`8e94d559be273ec8d74832fe5db78898be83cc11`**; exact mirror, remote
  upstream tip rechecked during shipping.
- `testing-stack`: **`6c81515138d5c3b573e2029609fcf6ff919ddfc4`** (local/remote), base `8e94d559` plus
  #2613/#2660/#2661/#2722/#2724/#2729/#2738. Combined local iOS build passed, Android **37791822785** actual
  build/unit steps passed and Swift **37791827346** all eleven jobs passed at that exact head.
- Current `testing-build` and local/remote `testing-latest`: **`c8eb1cd028701123517e8bb56fad5c093d99ba03`**,
  stack plus template-upload workflow only. Successful run **37793338186**, release **406928323**. Meta,
  Android, iOS and macOS actual build/package jobs passed; conditional cleanup skipped. Monitor exited 0 with
  `shipped c8eb1cd0`. All five uploaded assets nonempty; target/tag/build refs agree. IPA HTTP200, **21,955,109
  bytes**, ZIP CRC valid; SHA256 `6b4595e0dc98226e30d17d8e27395580e676f80d4f92ce5a3f13602e11794e42` matches GitHub.
  `com.noopapp.noop`, NOOP 12.0.0 (435), widget `com.noopapp.noop.widgets` retained, watch stripped; background
  modes/task capabilities retained. Reports `private/stress-load-cancellation-2026-10-08/release-*.json`,
  IPA cache `stress-load-cancellation-2026-10-08/release-c8eb1cd0/NOOP-ios-unsigned-v12.0.0.ipa`.
- Prior verified release/build (superseded): **`e722e0c4b6e8dd82c913d180e776fe4889be0b8e`**,
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
  `63e19100`. New saved wording worktree `/Users/utk/.codex/worktrees/stress-spectral-explanations/noop` is
  `codex/stress-spectral-explanations` / `0285a675`; the detached local-only staging candidate is documented in Now.
  Entries reinstalled for all twelve code worktrees.
- Fork refs are the intended main/handbook/one per open PR/testing-stack/build, template/testing tags and upstream
  versions. No throwaway regression branch/stash or safety tag; the local-only scratch candidate in Now is retained. Old stack `858d8c99` and
  build `e722e0c4` independently recovered from task-cache `pre-testing.bundle` into `pre-testing-recovered.git`,
  both tips matched and full fsck passed before retirement.
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
no unanswered maintainer review. No app build, release or phone action required. Private recovery/source hashes/inventories/
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
The temporary spectral fixtures were removed by verified restoration of the original database/preferences; previous app reinstalled and content size restored. Synthetic UI evidence is described in the saved spectral audit.
Xcode 27.0, XcodeGen, gh, Python 3.12 available; Android tests run in fork CI. The new phone log is retained privately;
personal backups and sleep-accel / restricted DREAMT datasets remain absent on this Mac. Obtain raw data when an analysis needs it; never tune from old aggregates.
Docs #2717: exact head `34c9eeac7649136ff79b1bd2e209abc90e2a85b3`, three required upstream checks passed
(source `37750786309`, i18n `37750786251`, Tools Python `37750786331`). Actual CI test totals: 234 capture,
50 repository acceptance, two legacy R-R, 153 core Tools. Local source hygiene/protocol arithmetic/163 source
references/i18n passed. 123 remaining Markdown pages checked with no new broken local targets; GitHub rendering
and four exact history blobs verified. Both original design bodies and 120 other pages retained; app source/tests/
tools/workflows/config unchanged. Final PR title/body read back exactly; open/mergeable, no unanswered maintainer review.
Private evidence: `private/organisation-audit/doc-simplification-2026-10-08.json`; HTML/CI log in cache
`doc-simplification-2026-10-08/`. Earlier navigation verification remains in History and the same private audit.
Handbook entry points to canonical procedures; start/end prompts and complete setup section preserved; handbook
local-link/fence checks and all checkpoint/installer regression checks passed.

## Next safe action

Create/recover the HRV buffer worktree from current upstream, apply the measured reuse only, and finish matched
original-output oracle tests, mutation checks and the full verification/delivery procedure. Existing parked
wording work, phone deferrals and completed owner invitations remain unchanged.
