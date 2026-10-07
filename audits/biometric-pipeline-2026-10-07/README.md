# Sensor, connection and biometric audit — 7 Oct 2026

NOOP has useful protections for corrupted packets, wrong units, lost writes and mixed sources. The audit found
one missed quality check in daily SDNN, two defects in the optional spectral readout, a missing-baseline problem
in Charge, and incomplete-field acceptance in the standard heart-rate parser. Daily SDNN is the first verified
repair, [upstream PR #2722](https://github.com/ryanbr/noop/pull/2722). No recovery or sleep weights were fitted to one
wearer or changed to make scores look better.

This is a review of the main WHOOP → stored readings → biometric calculations → scores → Apple Health path,
with the Android twins checked where relevant. It is not a claim to have audited every line, every device or every
firmware. Arithmetic checks can prove calculation and input-contract defects. They cannot establish that NOOP
measures sleep, recovery or physiology more accurately than WHOOP.

## Scope and evidence

- Source reviewed: app `8e94d559be273ec8d74832fe5db78898be83cc11`, 7 Oct 2026.
- Methods: production source/caller inspection, pre-recorded predictions, synthetic recordings through actual
  Swift calculations, regression tests run without and with the fix, Android fork CI, and raw Double-bit oracles.
- The synthetic replay contains no personal readings. [Harness](Audit.swift), [runner](run.sh),
  [baseline output](baseline-output.txt). It copies the two app-target/internal helpers to expose their pure
  functions and imports the unchanged packages; it makes no numerical changes to either helper.
- Reproduce on an isolated checkout of the source above:

  ```bash
  NOOP_REPO=/absolute/path/to/noop bash /path/to/handbook/audits/biometric-pipeline-2026-10-07/run.sh
  ```

  The runner prints the input commit and retains SHA-256 hashes beside its build. Running it on the repaired
  branch should change the refused SDNN cases to no value. Other recorded defects are not repaired by that PR.
- An existing private phone log establishes collection behavior, not sample-level accuracy. No personal raw
  backup, simultaneous ECG/respiration reference or accessible PSG dataset was present for this audit.
- Predictions were recorded before each targeted measurement. The first spectral prediction described eight
  combinations; execution covered four timestamp/frequency pairs at two amplitudes, plus nine public raw-RR
  cases. The packet replay used eight 8-bit-HR cases; it did not exercise the preregistered 16-bit edge cases.
  These narrower executed domains are reported explicitly. The long-record fixture was rerun after a recorded
  method correction to mean-remove its inputs, matching the helper precondition; all six cases and their domain
  remained unchanged, and the result persisted. Original and corrected local outputs were retained.

Production source anchors on the reviewed commit:
[SDNN index and quality gates](https://github.com/ryanbr/noop/blob/8e94d559be273ec8d74832fe5db78898be83cc11/Packages/StrandAnalytics/Sources/StrandAnalytics/HRVAnalyzer.swift),
[spectral power](https://github.com/ryanbr/noop/blob/8e94d559be273ec8d74832fe5db78898be83cc11/Packages/StrandAnalytics/Sources/StrandAnalytics/HRVFreqDomain.swift),
[Charge baseline conversion](https://github.com/ryanbr/noop/blob/8e94d559be273ec8d74832fe5db78898be83cc11/Packages/StrandAnalytics/Sources/StrandAnalytics/RecoveryScorer.swift),
[standard HR parser](https://github.com/ryanbr/noop/blob/8e94d559be273ec8d74832fe5db78898be83cc11/Strand/BLE/StandardHeartRate.swift),
[scored R-R source reads](https://github.com/ryanbr/noop/blob/8e94d559be273ec8d74832fe5db78898be83cc11/Packages/WhoopStore/Sources/WhoopStore/Reads.swift).

## From the strap to the screen

| Stage | Relevant code | What was checked |
|---|---|---|
| WHOOP envelope and clock | `WhoopProtocol/Framing.swift`, `HistoricalStreams.swift`, `FrameRouter.swift` | Complete envelope checks, family-specific CRC/header rules, rejection before state updates, clock plausibility. |
| Standard live HR/R-R | `StandardHeartRate.swift`, `Collector.swift`, `Whoop5RR.swift` | Flag/length parsing, BLE tick conversion, WHOOP 5 raw-word exception, source labels and contact events. |
| History and storage | `Backfiller.swift`, `RawHistoryArchive.swift`, `WhoopStore/Reads.swift`, `Whoop5RRReadPolicy.swift` | Persistence before trim acknowledgement, retained unknown records, suspect flags, source selection and within-second ordering. |
| HRV | `HRVAnalyzer.swift`, `SleepStager.swift`, `HRVFreqDomain.swift`, `SpotHrvReading.swift` | RMSSD/SDNN definitions, cleaning, windows, timestamps, banking/coverage checks and spectral units. |
| Nightly vitals | `AnalyticsEngine.swift`, `PrimarySessionRestingHR.swift`, `SleepStager.swift` | Primary sleep selection, five-minute RHR floor, RSA breathing, temperature wear gates and raw SpO2 separation. |
| Sleep | `SleepStager.swift`, `SleepStagerV2.swift`, `ScoreConfidence.swift` | Detection versus staging, normalization, sparse motion, session coverage and reference contamination. |
| Scores and baselines | `RecoveryScorer.swift`, `ChargeDrivers.swift`, `StrainScorer.swift`, `Baselines.swift`, `ChargeBaselines.swift` | Missing terms, baseline eligibility, weights, HR duration integration, units and explanation consistency. |
| Export and display | `HealthKitBridge.swift`, `StressView.swift`, Kotlin screens and analytics twins | Genuine SDNN export, retraction on missing SDNN, optional spectral lenses and claims the UI makes. |

The package names in the table refer to `Packages/.../Sources/...`; Apple app files are under `Strand/` or
`StrandiOS/`. Kotlin twins live under `android/app/src/main/java/com/noop/`.

## Confirmed calculation and contract defects

### 1. Daily SDNN bypasses its documented quality checks

**CONFIRMED, synthetic recordings and reachable production caller.** `AnalyticsEngine.avgSDNNDaily` calls
`HRVAnalyzer.sdnnIndex` and persists its result as `avgSdnn`. The result documentation requires timestamp-aware
SDNN consumers to apply both existing gates: beat spread/coverage and beat-value accuracy. The index applied neither.

The controlled five-minute fixture has 300 intervals, timestamps 0…299 s, RR values repeating
1000/1010/1020/1030 ms. It exercises the established quality rules without changing their thresholds.

| Input | Existing spread/value verdict | Before | Repair |
|---|---|---:|---:|
| Clean control | Both pass | 11.199020501841618 ms | Same exact bits |
| Every beat delivered twice | Both refuse | 11.189668499791464 ms | No value |
| Six intervals banked on each coarse timestamp | Spread passes; values refuse | 11.199020501841618 ms | No value |
| Clean first segment + duplicated second segment | Second segment refuses | 11.194344500816541 ms | Clean segment only |

The duplicate fixture does not demonstrate an inflated SDNN; uniform duplication slightly lowers the sample SD
through its denominator. It demonstrates that a refused capture still supplied a measurement. Banked values
can look entirely plausible, which is why a plausibility bound on the final number cannot replace the input gate.

The repair stable-sorts each segment, runs both existing checks, and averages only qualifying SDNN segments.
Raw readings stay stored. Clean recordings keep their sample-SD formula. No recovery, strain, sleep-stage or
RMSSD weights change. `HealthKitBridge` already exports genuine `avgSdnn` only and retracts an old export when it
becomes absent; the earlier RMSSD-as-SDNN export bug is already fixed upstream.

Four regression tests exist on both platforms. Before the repair, the three bad-input tests failed on Swift and
Android; the clean control passed. An eight-case oracle checks exact Double bits for clean, duplicate, banked,
mixed, shifted, reversed, insufficient and empty inputs. Its expected block comes from actual Swift stdout,
not a handwritten Kotlin approximation. Full local checks passed on `b6e53f38`: 632 store / 2,139 analytics /
327 import tests, source/i18n/parity checks, 127 governance tests, 2,267 Mac tests and iOS build (one import and
two Mac skips). [Android CI](https://github.com/UtkuDenizAltiok/noop/actions/runs/37595282200) passed the full suite on that same head. The preceding regression run printed
6,641 tests with six skips; the test methods are unchanged on the repaired head. Current PR/release status is recorded in State.

**Limit:** these tests establish quality-contract compliance. They do not estimate ECG accuracy or how often the
fault occurs on a real wearer. Unmeasurable/under-covered cases retain the existing gate policy; thresholds were
not tightened without evidence. The new rule applies when a daily metric is recomputed; this library change
does not rewrite already stored historical rows by itself.

### 2. Spectral powers lose amplitude and have the wrong claimed units

**CONFIRMED, four fixed-time pairs and nine public raw-RR cases.** `lombScarglePower` divides squared harmonic
projections by the input variance. Both scale by amplitude squared, so amplitude cancels. At identical times,
doubling the signal produced a power ratio of **1.000000000**, although absolute power must scale by four.
The result therefore does not satisfy its documented ms² contract. SciPy distinguishes unnormalized harmonic
power from normalized periodograms, and Astropy explains the corresponding unit differences.
[SciPy](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.lombscargle.html),
[Astropy](https://docs.astropy.org/en/stable/timeseries/lombscargle.html).

At a synthetic 800 ms base interval and 120 s recording, the public path gave HF values
0.622532563 / 0.622531943 / 0.622529510 for 10 / 20 / 40 ms modulations. These outputs are normalized integrals,
not validated absolute ms² powers. Expected harmonic variances are 50 / 200 / 800 ms² before estimator effects.
Their nearly unchanged outputs corroborate the exact fixed-time scaling failure.

This path feeds optional advanced Stress readouts; it does not feed the main Charge/Effort/Rest scores. A common
normalization factor cancels in LF/HF, so the amplitude defect alone does not establish that the ratio is wrong.
Other defects below can affect it. The existing optional SciPy fixture checks a ratio and cannot validate
absolute units by itself.

### 3. The fixed spectral grid misses narrow long-record peaks

**CONFIRMED, six controlled harmonics.** A 0.005 Hz grid was used for all record lengths. The same 20 ms amplitude, mean-removed as the
production caller requires, returned these normalized HF integrals:

| Recording length | 0.250 Hz, on the grid | 0.253 Hz, between grid points |
|---|---:|---:|
| 200 s | 0.500000000 | 0.496698853 |
| 400 s | 1.000000000 | 0.095506759 |
| 800 s | 2.000000000 | 0.124618042 |

The signals carry the same amplitude; frequency and duration strongly move the reported integral. A spectral
peak narrows with record length, so a fixed grid can sample its height or miss it. The UI can send a full day's
R-R into this helper, making this relevant beyond five-minute fixtures.
[Astropy frequency-grid guidance](https://docs.astropy.org/en/stable/timeseries/lombscargle.html).

**Required repair:** validate normalization and frequency resolution together. Include off-grid sinusoids,
irregular cadence, mixed bands, gaps, sample-rate changes and record-length changes; compare to an independent
implementation and known signal energy. Evaluate bounded windows versus an adaptive grid. Simply increasing the
full-day grid can make runtime grow sharply; simply restoring amplitude leaves the duration/grid error intact.
No spectral production change is included in the SDNN repair.

### 4. An empty respiratory baseline can influence Charge

**CONFIRMED, four synthetic rate inputs.** `Baselines.foldHistory([], respCfg)` returns an unusable state with
zero valid nights and a synthetic midpoint. The `BaselineState` overload of `RecoveryScorer.recovery` filters
unusable RHR baselines but passes respiration and optional Effort baselines straight through. `ChargeDrivers`
likewise filters RHR only, despite its stated omission rule for uncalibrated inputs.

With trusted synthetic HRV/RHR baselines, hrv55 ms, rhr58 bpm and sleepPerf0.85, an absent respiratory baseline
returns Charge **72.103474/100**. Supplying the empty respiratory state returns **92.617968**, **87.993103**,
**81.063173** or **71.432092** at rates 10/14/18/22 breaths/min, and emits an extra driver. These are algorithm
outputs on constructed inputs, not measured human recoveries.

This is a stronger next correctness candidate than changing recovery weights. Before repair, trace every
headline, driver and diagnostic consumer, include calibrating/provisional/trusted/stale states and missing values,
and prove cold-start omission and usable-state preservation with both-platform tests. The optional Effort
baseline has the same source shape but was not exercised by this replay; its impact remains **INFERRED**.
This audit did not alter Charge.

### 5. Standard HR parsing accepts incomplete flagged fields

**CONFIRMED, synthetic bytes.** `[8,60]` and `[8,60,1]` declare energy but omit its complete two-byte field;
the Apple parser accepts both. `[16,60,232,3,1]` accepts the first R-R word and silently drops the odd trailing
byte. The full packet should be structurally validated before the reading is emitted. Android has analogous
length/loop behavior in its parser and needs matched regression fixtures before a shared repair.

Do not reject `[16,60]` merely for having zero intervals: the standard permits zero R-R subfields. Preserve all
valid HR widths, contact flags, optional-field combinations and WHOOP 5 raw-word handling.
[Bluetooth Heart Rate Service specification](https://www.bluetooth.com/wp-content/uploads/Files/Specification/HTML/HRS_v1.0/out/en/index-en.html).

This is a defensive decoding candidate. It was not established as a fault in the wearer's real packets; changing
the parser would require a phone/strap log after update as well as fixture and build evidence.

## Other reviewed areas and remaining measurement questions

| Area | Source finding and confidence | Appropriate next evidence |
|---|---|---|
| CRC/clock/acknowledgement | **CONFIRMED by source:** the router gates the complete envelope; historical extraction rejects corrupt/implausible records; history persistence failures hold trim acknowledgement. Existing protections should be preserved. | Corruption/write-failure tests and actual logs; compile success cannot prove radio behavior. |
| WHOOP 5 R-R units | **CONFIRMED by source:** historical and live WHOOP 5 words use the canonical millisecond policy; ordinary standard BLE uses 1/1024 s conversion. Existing provenance and 500 ms filler quarantine remain. The historic validation figures in comments were not re-measured here. | Raw frame/ECG or simultaneous-channel replay before any unit change. Never infer units from one plausible HRV. |
| Source arbitration | **CONFIRMED by source:** WHOOP 5 selects one eligible channel for the whole read, preferring historical channel5 over standard7. WHOOP4/Oura select per hour. **INFERRED:** partial WHOOP5 history may withhold live-only intervals. | Per-channel coverage, overlap, ordering and paired scores on an actual backup. Do not blend sources blindly or treat all stored rows as scored beats. |
| RMSSD and cleaning | **CONFIRMED by source:** cleaning skips successive differences across rejected intervals, but a beat missing before storage is absent from the index sequence and its wall-clock gap is not tested by nightly window RMSSD. The over-count gate already exists. | Dropout/ectopic fixtures, then independently annotated beat truth and real gap prevalence. Do not import the banked-value gate into RMSSD without its own evidence. |
| Spectral time axis | **CONFIRMED by source:** cleaned intervals are cumulatively summed and rejected/missing time disappears; wall-clock gaps from the timestamp overload are discarded. **INFERRED impact:** this can distort frequencies when intervals are removed or reception has gaps. | Timestamp-preserving replay with known gaps and ECG timing; keep this coupled to the spectral repair. |
| Resting HR | **CONFIRMED by source:** primary longest sleep protects against nap replacement; five-minute bins require five samples and plausible mean, but if none qualify the code falls back to ungated bin minima. Whole-session mean exists as a shadow metric. | Sparse/dropout fixtures, raw sample cadence, then simultaneous ECG across people and nights. A sample count is not elapsed-time coverage. |
| Respiration | **CONFIRMED by source:** RSA uses timing/banked-value gates and excludes windows crossing clock splices; it estimates breaths/min from pulse modulation, not a direct respiratory sensor. Device-provided Oura respiration has precedence. | Variable breathing-rate truth, not a stable plausible output or another consumer score. Inspect noise, cadence and range rejection separately. |
| Skin temperature | **CONFIRMED by source:** conversion is device-family-specific; concurrent HR provides a wear proxy, and plausibility/count/baseline gates apply. Auxiliary channels remain raw. | Worn/doff transition records and independent thermometer references. Presence of HR is an imperfect contact proxy; do not promote an auxiliary channel from plausibility alone. |
| SpO2 and raw optical data | **CONFIRMED by source:** WHOOP4 red/IR ADC means are kept as raw signals, not calibrated oxygen percentage. WHOOP5 unexplained fields/raw PPG require their own provenance and validation. | Paired reference oximetry over varying values and known channel semantics. No guessed percentage conversion. |
| Sleep stages | **CONFIRMED by source:** V2 normalizes features within each night and substitutes a spread only when SD is exactly zero. Near-constant nonzero features can gain disproportionate weight; this is already in Backlog. | Replay on independent PSG cohorts with held-out subjects/time, per-stage bias, onset/wake minutes, missing-data strata and reference-contamination checks. Do not fit one clinical cohort's base rates. |
| Effort | **CONFIRMED by source:** HR-reserve intensity integrates sample duration, caps long gaps, and maps load to 0–100. Edwards gives zero below its first zone. A quiet day's zero is not by itself a sensor failure. | Identical-input duration/cadence fixtures, independently measured exercise load and accurate HRmax/RHR inputs. Coverage and physiological load are different questions. |
| Baseline composition | **CONFIRMED by source:** a 21-day calendar window and import handoff limit old vendor influence. Firmware/source-era recalibration needs to remain aligned with explanatory UI; open upstream #2583 addresses part of that. | Verify own/import/source-era composition per metric on a backup; preserve upstream changes. |
| Confidence | **CONFIRMED by source:** Charge tiers use HRV baseline trust; Effort uses sample count; Rest has sparse-motion and stage-coverage downgrades. **INFERRED limitation:** a mature baseline or many samples cannot certify this night's signal quality. | Add quality/provenance instrumentation first; validate any new quality tier against actual capture failures. Do not invent numeric confidence from an uncalibrated label. |
| Stress language | **CONFIRMED:** UI calls LF/HF autonomic balance and reads it as sympathetic versus parasympathetic tone. The primary literature does not support that simple interpretation. | Correct the claim and describe a spectral ratio with limitations; keep psychological-stress inference distinct from exertion. [Billman 2013](https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2013.00026/full). |
| Spot HRV source description | **CONFIRMED:** both platforms map WHOOP4 to a `chestStrap` source described as electrical. WHOOP4 uses optical LEDs/photodiodes, so this source description overstates its reference quality. | Correct source vocabulary on both platforms and preserve actual generic ECG/chest sources. [WHOOP hardware description](https://www.whoop.com/gb/en/thelocker/chief-technology-officer-whoop-4-0-accuracy/). |
| Spot capture and Baevsky index | **CONFIRMED by source:** spot capture checks accumulated beat time against capture duration and rejects excessive cleaning loss. Baevsky's optional histogram readout checks cleaning/count/range but its row overload drops timestamps. | Replay malformed, banked and missing-time inputs per consumer; establish signal quality before interpreting an index as psychological stress. No clinical claim or score change from source inspection alone. |
| Experimental HRV readiness | **CONFIRMED by source:** the default-off engine works in log RMSSD, requires 14 valid nights, then computes windows after dropping missing nights. **INFERRED recency risk:** seven valid readings can span more than seven calendar nights. | Test missing-date patterns and the UI's window description; use dated, held-out recordings before promoting the experiment or changing thresholds. |
| Fitness Age / Vitality | **CONFIRMED by source:** these consume demographic/population references and derived activity/vital estimates; their fixed age bands are presentation constants. **INFERRED limitation:** correlated derived inputs and a fixed band are not independent measurements or calibrated uncertainty. | Audit input provenance and freshness, then independent exercise-capacity/outcome evidence. Preserve the wellness-comparison meaning; do not present an estimated age as a biological measurement. |

## Decision and next experiments

The SDNN repair is in green PR #2722 and verified testing build `01b55ac2`; phone installation/normal-strap
observation remain pending. The release IPA checksum and app identity were independently checked; install over
the existing app with AltStore. Next reproduce and repair
uncalibrated-baseline consumption consistently in Charge, explanations and trace. Then handle the spectral estimator
as one concern including absolute units, resolution and clock/cleaning behavior. Packet strictness and inaccurate
source/ratio descriptions can be separate small fixes. Keep each concern independently reviewable.

A fresh NOOP backup is useful for per-channel coverage, clock gaps, clean/rejected counts, source-era boundaries,
missing baselines and replaying the same stored readings through old/new code. It remains private and is never
published at row level. It cannot supply independent sleep-stage or recovery truth.

For physiological improvements, use the project's `docs/VALIDATION_PROTOCOL.md`: record predictions and domains
before measuring, remove machine-derived reference contamination, hold out later recordings, report units and
sample sizes, and use the metric appropriate to the question. Synthetic agreement and matching WHOOP scores are
not substitutes for independent truth. Sleep-accel provides motion/HR with PSG labels; DREAMT supplies multisensor
wearable recordings with PSG but requires the owner's data-access agreement. No download or account step was
performed during this audit. [Sleep-accel](https://www.physionet.org/content/sleep-accel/1.0.0/),
[DREAMT](https://physionet.org/content/dreamt/2.0.0/).
