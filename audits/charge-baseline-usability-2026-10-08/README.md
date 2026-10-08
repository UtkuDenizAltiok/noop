# Whole-app priorities and optional Charge baselines — 8 Oct 2026

NOOP is a local wearable-data system: BLE transport and clock correction feed stored streams, source/quality
selection feeds nightly metrics, and personal baselines feed Charge/Effort/Rest and their explanations. A correct
screen depends on every earlier boundary. The [7 Oct pipeline audit](../biometric-pipeline-2026-10-07/README.md)
remains the source map; [Backlog](../../BACKLOG.md) holds measured resource costs and later investigations.

## What this review prioritises

| Perspective | Evidence and next direction |
|---|---|
| Signal/data integrity | Preserve CRC, clock, write-before-ack, WHOOP5 source/unit/filler gates. Source arbitration, gaps and sensor coverage need actual raw replay, then independent references for accuracy. |
| Scores/explanations | Fix the confirmed optional-baseline eligibility discrepancy below before adjusting physiological weights. HRV cold-start remains a required gate. |
| CPU/battery | Earlier logs identify fingerprints, cache invalidation/relaunch and disk writes as larger candidates. They are historical measurements; no new phone-energy number is available on this iPhone 16. Preserve freshness and results; profile the actual backup before optimising. |
| GPU/RAM/UI | Earlier simulator measurements identify visible night twinkle cost; changes to its quality remain a user choice. Current task changes no rendering. Inspect memory peaks and actual termination evidence before reducing retained work. |
| Scientific claims | Personal reference ranges and independent sleep truth matter. The studies below inform validation design; they do not validate NOOP's composite or justify new weights. |
| Real use | Utku confirmed WHOOP 5.0/iPhone 16 and offers simple real-life tests. A verified update and normal-night log/optional raw backup can establish capture, gaps, actual scoring inputs and resource behaviour. They cannot establish clinical accuracy. |

Fresh research checked on 8 Oct: [Vesterinen et al. 2016](https://pubmed.ncbi.nlm.nih.gov/26909534/)
used individual HRV reference criteria in a 40-runner training study. It supplies context for personal baselines,
not evidence for Charge's weights or the respiration/Effort terms. [Billman 2013](https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2013.00026/full)
explains why LF/HF does not directly quantify autonomic balance; the existing spectral/source-language candidates
remain separate concerns. [PhysioNet sleep-accel](https://physionet.org/content/sleep-accel/1.0.0/) supplies wearable
motion/HR with PSG sleep labels for independent validation. No dataset download, account action or tuning occurred.

## Confirmed software defect and bounded repair

Reviewed source base: `8e94d559`; fix head `3e59a667` on `codex/charge-baseline-usability`.
The `BaselineState` scorer already drops unusable resting-HR states, but converted respiratory and optional Effort
states directly into numeric driver baselines. An empty respiratory fold returns a synthetic centre, not a learned
personal baseline. Driver/trace consumers also read it directly. Apple `ChargeBreakdownWiring` prefiltered it,
so the stored headline could include a term the sheet omitted. The optional Effort API has the same reachable
library defect; current app callers do not supply that parameter, so a present-day phone effect is not claimed.

The fix applies the existing `usable` predicate: provisional/trusted stay eligible, calibrating/stale are omitted.
Respiration is resolved before building driver rows, every marginal calculation and trace terms/renormalisation.
Weights, baseline learning, HRV gate, valid scalar math, sampling, BLE and storage are unchanged. This establishes
input eligibility and consistent readouts, not physiological accuracy.

Re-measured synthetic example with trusted HRV50/spread8 and RHR60/spread4, HRV55, RHR58, rest0.85:

| Respiration (br/min) | Original Charge with empty baseline | Fixed / absent-baseline Charge |
|---|---:|---:|
| 10 | 92.617968 | 72.103474 |
| 14 | 87.993103 | 72.103474 |
| 18 | 81.063173 | 72.103474 |
| 22 | 71.432092 | 72.103474 |

These are four constructed-input algorithm outputs on a 0–100 scale, not human recovery measurements.
Regenerate on old/new checkouts with `run.sh <checkout> --example`.

## Prediction and verification

The [preregistered plan](preregistered.md) was saved before these new tests/measurements. Six matched platform tests
cover 625 score cases (25 baseline-state pairs × 25 optional-value pairs), all respiratory driver/trace status/value
cases, genuine empty/all-implausible folds and dominant-HRV cold-start. Original Swift: five tests failed, cold-start
control passed; Android original run [37739654819](https://github.com/UtkuDenizAltiok/noop/actions/runs/37739654819)
compiled the APK then failed exactly those five new tests (6643 tests, six skips). The temporary remote ref was retired.

70 targeted Swift tests passed after the fix. Disabling each of four gates separately made its regression fail;
all original source SHA-256 values were restored and all six tests passed again. The standalone original Swift
calculation, supplied only eligible inputs, produced [25 exact Double-bit oracle rows](expected-score-bits.txt).
Those stdout lines were copied verbatim into both-platform matrix tests. Final compiled Swift matches all 25;
all nine originally eligible baseline-pair controls are unchanged from original output.

```bash
bash dist/audits/charge-baseline-usability-2026-10-08/run.sh /path/to/fixed/app > /tmp/charge-bits.txt
diff dist/audits/charge-baseline-usability-2026-10-08/expected-score-bits.txt /tmp/charge-bits.txt
swift test --package-path /path/to/fixed/app/Packages/StrandAnalytics --filter RecoveryOptionalBaselineUsableTests
```

Full feature verification at `3e59a667` passed: 632/2141/327 package tests, all source/parity gates, 127 governance,
2267 Mac tests and iOS build (one import/two Mac skips). Final Android
[37740134786](https://github.com/UtkuDenizAltiok/noop/actions/runs/37740134786) passed its actual debug build and full
unit step including the exact oracle. No warnings in changed Swift/Kotlin files.
[PR #2729](https://github.com/ryanbr/noop/pull/2729) is published at that head with the verified description read back.
Combined stack `858d8c99` passed local iOS, Android `37742118268` and all 11 Swift jobs `37742121423`.
Testing update `e722e0c4` / [run 37743306160](https://github.com/UtkuDenizAltiok/noop/actions/runs/37743306160)
passed all four required jobs, uploaded five nonempty assets and passed independent tag/IPA ZIP/plist/digest checks.
Old tips were independently recovered before temporary refs/checkouts were retired. Installation is just update;
phone observation is unconfirmed. Current facts live in [State](../../STATE.md).
Retained private test/mutation/run logs: `private/session-2026-10-08-charge-baselines/`;
cache: `charge-baseline-usability/`. No personal health data is included in this audit.
