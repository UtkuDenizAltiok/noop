# HRV cleaning with less allocation — 8 Oct 2026

The two shared HRV cleaning paths now reuse a local neighbour buffer within a call, preserving the existing
range filter, local median, 20% rejection threshold, ordering and removed-beat adjacency. Swift and Kotlin
carry the same change. Source: `c71b48af5f07c94f92b8a7fb1af14506f2b0a10d`, based on `8e94d559`.
Verification and delivery are pending until the actual results are recorded in [State](../../STATE.md).

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
measurement, the original/reuse order alternates across seven trials and counts feed a retained checksum.

Direct original/candidate comparisons passed **137,267 cases**, including all 137,257 length-0...6 sequences
from the seven-value boundary alphabet, nonfinite/range/threshold/end-window fixtures and long inputs.
Every cleaned Double bit and every adjacency flag was compared directly, not merely through a hash.
The matched package/JVM tests pin [20 original Swift stdout rows](expected-original.txt), generated by
[Oracle.swift](Oracle.swift). FNV digests there cover raw Double words and every adjacency bit; they supplement
the direct exhaustive comparison and catch future drift on either platform.

| Intervals / input | Original CPU, both cleaning calls | Reuse CPU | Reduction |
|---|---:|---:|---:|
| 300, clean | 0.05984 ms | 0.04089 ms | 31.7% |
| 300, mixed artefacts | 0.05837 ms | 0.04024 ms | 31.1% |
| 36,000, clean | 7.04093 ms | 4.82830 ms | 31.4% |
| 36,000, mixed artefacts | 6.83543 ms | 4.70147 ms | 31.2% |
| 108,000, clean | 21.45360 ms | 14.64480 ms | 31.7% |
| 108,000, mixed artefacts | 21.15790 ms | 14.66820 ms | 30.7% |

All trial data: [pilot-results.txt](pilot-results.txt); medians: [pilot-summary.json](pilot-summary.json).
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
Negative Android CI and full local/fork verification are in progress; they are not yet passed evidence.
