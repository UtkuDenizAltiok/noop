# HRV cleaning with less allocation — 8 Oct 2026

The two shared HRV cleaning paths now reuse a local neighbour buffer within a call, preserving the existing
range filter, local median, 20% rejection threshold, ordering and removed-beat adjacency. Swift and Kotlin
carry the same change. Source: `c71b48af5f07c94f92b8a7fb1af14506f2b0a10d`, based on `8e94d559`.
Feature verification is complete. Current testing delivery and review status live in [State](../../STATE.md).

## Assessment and boundary

This extends the existing [whole-pipeline audit](../biometric-pipeline-2026-10-07/README.md),
[whole-app assessment](../charge-baseline-usability-2026-10-08/README.md), and
[freshness assessment](../stress-load-cancellation-2026-10-08/README.md). Recovery rechecked current upstream,
all nine existing own PR heads/required rosters/reviews, worktrees, running jobs and release evidence.
Upstream remains `8e94d559`; no equivalent neighbour-buffer repair was found among current open PRs/issues.

| Area | Current evidence and decision |
|---|---|
| Strap/raw data/clock/storage | Retain CRC, write-before-ack, clock correction, source/unit/filler policies. Apple standard-HR parsing and both Android parsers still accept truncated energy fields or half an R-R word. A separate parser repair must preserve valid zero-interval notifications and ignored RFU flags, with matched fixtures and hardware validation. |
| Spectral HRV | Units/grid defects remain. Row overload discards timestamps; history packs several intervals at one coarse record time. Repairing timing by reading row timestamps directly would invent beat precision. Keep units/grid/rejected-time/record continuity together with varying-signal and independent-reference validation. No formula change here. |
| Time-domain HRV/sleep/respiration | Freshly traced ordinary/gap-aware cleaning consumers: nightly and spot HRV, sleep respiratory buckets, Stress index/spectrum, resonance and onset detector. Each cleaning call allocates a neighbour array per beat in addition to median sorting. Choose a measurable, output-preserving allocation reduction. Retain all physiology and quality gates. |
| Recovery/baselines | Existing #2729/#2722/#2724 already cover the confirmed eligibility/SDNN/RHR defects. No duplicate fixes or weight tuning. |
| CPU/radio/battery/RAM | Earlier evidence identifies larger cold-pass/fingerprint/disk costs, but raw personal replay is unavailable here. Reusing scratch work preserves coverage/freshness. Measure cleaning CPU only; no extrapolated device-energy or memory claim. |
| UI/accessibility/localization/privacy/maintenance | No layout, rendering, tokens, language or network changes. Prior verified UI/privacy PRs remain pending external review; parked wording work and user phone/data deferrals remain preserved. |
| Storage/backup | #2720 already owns deletion-marker restore discussion; no speculative archive format or migration. |

The selected change is small enough to verify against the exact original algorithm on a broad input domain.
It changes how scratch storage is managed, so it requires no scientific tuning or new sensor interpretation.

## Independent sources

Swift's official implementation documents clearing while retaining capacity, and Java 17 documents `ArrayList`
capacity and `clear`. The buffers remain local to one call; no cross-call cache or shared mutable state is added.
[Swift collection source](https://github.com/swiftlang/swift/blob/main/stdlib/public/core/RangeReplaceableCollection.swift),
[Java ArrayList](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/ArrayList.html).

The current 2026 HRV guideline recommends reporting device/input signal, recording length, cleaning and usable
data, with caution interpreting wearable measurements. Its publisher search index exposes these recommendations;
direct full-text opening failed in this session. No recommendation validates NOOP's Malik filter or its scores.
[Carter et al., 2026](https://journals.physiology.org/doi/full/10.1152/ajpheart.00041.2026).
[Clifford and Tarassenko, 2005](https://ora.ox.ac.uk/objects/uuid%3A2094c0f4-c392-4f68-99c8-cf15d15d2c61)
uses a controlled varying R-R generator to investigate spectral distortion. This supports retaining the coupled
spectral validation requirement, not a replacement estimator implemented here.
The official Heart Rate [Service](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/HRS_v1.0/out/en/index-en.html)
allows a variable R-R field including zero subfields, and the [Profile](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/HRP_v1.0/out/en/index-en.html)
requires collectors to ignore RFU flag bits. Those constrain the deferred parser task.

## Measurement and exact preservation

[Predictions/domain](preregistered.md) were saved before app changes. [measure.py](measure.py) extracts the
verbatim original and candidate production cleaning bodies and compiles them together with `swiftc -O`.
The pilot candidate changed only the buffer lifetime/reset; its full production Swift SHA256 equals the final
app file: `4d98e0a72f9436a08350df42068a4e78b3a8712a3c97c17eae9cb5897d227b36`.
The initial harness compile failed on a fixture type-inference ambiguity; it was corrected before any results.
No excluded cases or changed prediction. Darwin CPU time includes user+system; inputs are generated before
measurement, the original/reuse order alternates across seven trials and the pilot counts feed a retained checksum. Before final trials, consumption was strengthened to read all
returned Double words and adjacency flags through a non-inlined digest, with no local build running. Inputs,
iterations and ordering were unchanged. Retain the pilot separately; the table below reports this stronger
workload, including the identical output-consumer cost.

Direct original/candidate comparisons passed **137,267 cases**, including all 137,257 length-0...6 sequences
from the seven-value boundary alphabet, nonfinite/range/threshold/end-window fixtures and long inputs.
Every cleaned Double bit and every adjacency flag was compared directly, not merely through a hash.
The matched package/JVM tests pin [20 original Swift stdout rows](expected-original.txt), generated by
[Oracle.swift](Oracle.swift). FNV digests there cover raw Double words and every adjacency bit; they supplement
the direct exhaustive comparison and catch future drift on either platform.

| Intervals / input | Original CPU, both cleaning calls | Reuse CPU | Reduction |
|---|---:|---:|---:|
| 300, clean | 0.06263 ms | 0.04340 ms | 30.7% |
| 300, mixed artefacts | 0.06066 ms | 0.04223 ms | 30.4% |
| 36,000, clean | 7.35607 ms | 5.15093 ms | 30.0% |
| 36,000, mixed artefacts | 7.08273 ms | 4.91610 ms | 30.6% |
| 108,000, clean | 22.28900 ms | 15.48520 ms | 30.5% |
| 108,000, mixed artefacts | 21.17480 ms | 14.68060 ms | 30.7% |

Final trial data: [final-results.txt](final-results.txt); medians: [final-summary.json](final-summary.json).
The initial count-only [pilot](pilot-results.txt) and [summary](pilot-summary.json) are retained separately.
This is a compiled-Mac helper benchmark, not a phone/Android benchmark, simulator result, whole-pass saving,
peak-memory measurement or battery result. The eight-hour-sized pair saves about 2.1–2.2 ms on this Mac.
No work is skipped or delayed; sampling, storage, metric math, quality thresholds and UI are preserved.

Reproduce the final-source comparison and measurements:

```bash
python3 /absolute/path/to/handbook/audits/hrv-clean-buffer-2026-10-08/measure.py \
  /absolute/path/to/noop /absolute/path/to/cache \
  /absolute/path/to/handbook/audits/hrv-clean-buffer-2026-10-08
```

## Verification

Two new Swift preservation tests passed initially. Omitting each loop's reset separately made its corresponding
test fail assertions at case 10, then the complete source digest was restored each time. Large fixtures are not
run after the first mismatch, so deliberate faults do not turn into runaway neighbour growth or app-host crashes.
Negative [Android run 37826824779](https://github.com/UtkuDenizAltiok/noop/actions/runs/37826824779)
built the APK successfully and failed exactly both new tests with `ComparisonFailure` (two selected/two failed).
The source/workflow were restored byte-identical and the temporary remote/local branch/worktree retired.
Full local verify at `c71b48af` passed: 632 store, 2137 analytics, 327 import (one existing skip), all
source/i18n/parity gates, 127 governance, 2267 Mac tests (two existing skips) and iOS build. [Final feature Android](https://github.com/UtkuDenizAltiok/noop/actions/runs/37828040856) passed its
APK and full unit-test steps at exact `c71b48af`. [PR #2742](https://github.com/ryanbr/noop/pull/2742) was
published and its head/description read back exactly. All seventeen upstream checks at that head passed, with actual workflow job/steps verified. Combined candidate
`c13e8873` passed the local iOS build, [Android](https://github.com/UtkuDenizAltiok/noop/actions/runs/37829415471)
and [all eleven Swift jobs](https://github.com/UtkuDenizAltiok/noop/actions/runs/37829420443), with actual build/test
steps read back. Testing release `ef6216f8` / [run 37830619829](https://github.com/UtkuDenizAltiok/noop/actions/runs/37830619829)
completed all four required jobs (conditional cleanup skipped). All five nonempty assets, exact target/ref/tag,
IPA HTTP200, 21,955,171-byte size, ZIP CRC, app/widget identities and background capabilities passed independent
verification. IPA SHA256 `af24f640c967f542c19ac2c0477577e7b0491dafd9aa11b82f9e442fc487f091` equals GitHub's digest.
Old refs were independently recovered/fsck-verified before only this task's temporary checkout/tags were retired.
Installation is just update; user confirmation is pending. No special real-device test is required for this
allocation-only change; no BLE or measured phone-energy/accuracy claim is made.

The existing DEBUG `--demo-screen stress` entry rendered Stress's missing-data state in the iPhone 17 Pro /
iOS 27 simulator. No raw rows or consent preference were injected; this is launch/render smoke only, not
numeric, hardware or accuracy validation. Original app/data/preferences were restored and the simulator
shut down, with database logical-dump equality and preference-byte equality verified. The first screenshot
was captured before launch completed and showed SpringBoard; only the later settled screenshot is render
proof. A missing simulator `kill` executable interrupted cache invalidation; the exact host simulator
cfprefsd PID/command was checked, signalled and the snapshot recopied before the verified shutdown.
