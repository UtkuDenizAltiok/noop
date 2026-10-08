# Stress freshness and deeper system assessment — 8 Oct 2026

An older Stress screen load can overwrite a newer refresh after cancellation. The original Apple load methods
reproduced the defect at all seven suspension boundaries. The repair keeps fresh state in the same seven cases,
while retaining normal results and the existing timeline-before-advanced ordering. Android needs the same
boundary protection: `runCatching` swallowed cancellation and could publish its failed-read fallback.

This extends the [7 Oct pipeline audit](../biometric-pipeline-2026-10-07/README.md) and
[8 Oct whole-app assessment](../charge-baseline-usability-2026-10-08/README.md). It does not repeat their completed
SDNN, RHR or Charge investigations. Source base: `8e94d559be273ec8d74832fe5db78898be83cc11`. Delivery and the
latest verification state belong in [State](../../STATE.md).

## Assessment and choice

The review followed raw WHOOP frames through clocks, storage, source selection, cleaning, biometrics, scores and
screens. The existing evidence was checked against current source, with deeper inspection of spectral callers,
R-R timestamp provenance and Stress lifecycle/loading. No personal sample-level backup or independent reference
recordings are available on this Mac; prior phone logs establish collection, not physiological accuracy.

| Area and candidate | Evidence and remaining uncertainty | Decision |
|---|---|---|
| Spectral HRV units, resolution and time | Prior synthetic defects persist in current Swift/Kotlin. Newly traced `HistoricalStreams` emits every interval in a record with the same timestamp; `HRVFreqDomain` discards row timestamps and cumulatively sums cleaned intervals. Coarse stored timestamps cannot simply become precise beat times. | Keep normalization, grid and timing together. Validate the reconstruction/continuity contract before an estimator repair. |
| Sensor interpretation and packet completeness | Existing truncated standard-HR examples remain relevant. Bluetooth HRS permits zero R-R subfields; rejecting all empty R-R packets would lose valid data. WHOOP 5 raw-word and filler policies already exist. | A separate parser task needs matched edge fixtures and a real-strap log. No BLE change here. |
| RMSSD, respiration, sleep, confidence and source arbitration | Prior audit distinguishes interval cleaning, banked timing, signal coverage, proxy measurements and reference contamination. WHOOP 5 whole-read source selection can withhold live-only coverage; near-constant sleep features and confidence labels remain validation candidates. | Require representative raw/reference recordings and held-out evaluation before changing physiological outputs. Keep phone export deferred. |
| Recovery and baselines | Completed Charge eligibility repair is already in #2729; calibrated numerical math and cold-start HRV gates are pinned there. | Preserve the verified change; no weights or new baseline parameters. |
| Storage and backup integrity | Reproduced deleted-sleep suppression loss is already reported in #2720; maintainers' storage direction is pending. | Preserve the parked task, without a duplicate report or speculative migration. |
| CPU, memory, disk and radio | Previous measurements identify fingerprint, relaunch/config and write costs. The RHR repair saves a small measured calculation cost; current data do not identify a new dominant phone-energy cause. | No unsupported battery claim or reduced sampling/freshness. |
| Responsiveness and data freshness | Fresh source review found unchecked returns from Apple's detached Stress work and four Android `runCatching` boundaries. Cancellation can still produce observable state writes. | Choose this bounded, independently testable correctness repair. |
| Design, localization, privacy and maintenance | Existing #2717/#2737 retain useful guides and accurate network disclosure. Stress layout/tokens/strings need no change for the race. The personal-lens wiring test must recognize a wrapped resolver without losing its preference/scorer assertions. | Preserve visual quality and all languages; adjust only that existing wiring guard. |

The freshness race has immediate user value: a current chart/readout must not revert to an older refresh or an
empty cancelled-read fallback. Unlike a physiological calibration, its correctness can be established with an
explicit ordering contract, production paths and deterministic interleavings. Its natural frequency on Utku's
phone has not been measured.

## Independent references and scientific boundary

Swift cancellation is cooperative and callers must inspect cancellation; detached work remains the caller's
responsibility. Android likewise requires cooperative checks and propagation of `CancellationException`.
These contracts support rejecting a cancelled load's return before writing screen state.
[Swift language guide](https://github.com/swiftlang/swift-book/blob/main/TSPL.docc/LanguageGuide/Concurrency.md#task-cancellation),
[Android coroutine guidance](https://developer.android.com/kotlin/coroutines/coroutines-best-practices#watch-out-for-exceptions),
[Kotlin cancellation guide](https://github.com/Kotlin/kotlinx.coroutines/blob/master/docs/topics/coroutines-cancellation.md).

The spectral investigation remains a real scientific task. SciPy distinguishes unnormalized harmonic power
from variance-normalized power; Astropy shows that peak width depends on observation duration and a coarse grid
can miss it. These support the existing units/grid findings, not a clinically validated replacement.
[SciPy](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.lombscargle.html),
[Astropy](https://docs.astropy.org/en/stable/timeseries/lombscargle.html).
Beat replacement/resampling also affects HRV spectral estimates in controlled research; timing provenance must
be part of validation rather than an implementation afterthought.
[Clifford and Tarassenko, 2005](https://ora.ox.ac.uk/objects/uuid%3A2094c0f4-c392-4f68-99c8-cf15d15d2c61).
The September 2026 HRV reproducibility guideline was discovered during this review; its indexed abstract is
available, but full-text retrieval was not established, so no detailed recommendation is attributed to it.
[Guideline record](https://pubmed.ncbi.nlm.nih.gov/42495990/).

No new formula, diagnostic threshold, clinical interpretation, physiological-accuracy or battery-saving claim
is made. This task preserves the actual measured/calculated values on an uncancelled path.

## Prediction, experiment and result

[Predictions and domain](preregistered.md) were saved before running experiments. The four primary Apple pause
points were stored series, HR, timeline/core and advanced work; RR, gravity and selected-mode pauses extended
the source coverage before the first execution and are reported as exploratory cases. All seven are retained.

The [runner](run.sh) extracts the actual `StressView.load`/`loadDaytime` bodies verbatim into a callable shell,
and compiles the original `UnescalatedWork` plus the new helper when present. [Fixture dependencies](Fixture.swift)
control completion order and return identity markers, not simulated physiological truths or database behavior.
For each case: hold old work, cancel its task, complete the replacement, then release old work. The advanced case
uses an empty fresh HR read to test whether cleared lenses reappear. No sleeps, exclusions or guessed timing.

| Observable | Original source | Repaired source |
|---|---:|---:|
| Fresh snapshot preserved after late completion, primary cases | 0/4 | 4/4 |
| Fresh snapshot preserved, exploratory cases | 0/3 | 3/3 |
| Normal result identity and phase order | Original control | Same control |
| Cancelled core starts additional advanced work | Yes in regression mutation | No |

Exact [original output](original-output.txt) and [repaired output](repaired-output.txt) retain series, timeline,
index, spectrum and personal-mode markers. At the original core pause, the late timeline could also disagree
with the displayed mode; the mode now publishes with its guarded timeline. The existing empty-HR clearing
behavior is retained.

Reproduce against isolated original/repaired checkouts:

```bash
bash /path/to/handbook/audits/stress-load-cancellation-2026-10-08/run.sh /absolute/path/to/noop
```

The first runner used only Git HEAD as its output key, so uncommitted original/fixed source shared a directory.
It was corrected to include the combined source digest; both runs were repeated, preserving separate outputs.
No fixture domain or prediction changed. The runner now retains hashes for all compiled production inputs.

## Repair and verification

Apple checks before and after each of seven reads/work phases; a cancelled result returns before publication
or the next phase. Android checks its coroutine on both sides of four reads and rethrows cancellation while
keeping ordinary read failures as absent-value fallbacks. Existing work priorities, read limits, stored/raw
data, selected lens, mathematics, two-phase rendering and layout are preserved. Already-running non-cooperative
CPU work can still finish; cancellation is not advertised as immediate CPU interruption.

Six Apple and eight Android tests cover valid values, absent values, phase order, pre-cancelled callers, reads
that deliberately ignore cancellation, late replacement and late advanced results. Android also covers ordinary
failure and cancellation propagation. All new tests are checked with deliberately broken implementations.

Apple: removal of both checks failed four cancellation tests with six assertions; refusing all valid work failed
the two normal controls. Restoring the identical source hash passed all six new tests and four existing priority
tests. Both negative runs exited 65, restored run exited 0; they failed assertions without crashing.

Android negative run [37783143070](https://github.com/UtkuDenizAltiok/noop/actions/runs/37783143070) built the app
successfully, then ran 6,645 tests with six skips and six failures: five intended cancellation failures and one
existing wiring assertion that depended on the exact unwrapped Swift assignment text. The latter is adjusted
to check the actual preference and selected-mode scoring instead. The separate [control mutation](https://github.com/UtkuDenizAltiok/noop/actions/runs/37784315713) also built successfully,
then ran six selected tests with exactly four expected failures: the three valid-work controls and disconnected
personal preference. The remaining two wiring controls passed; no new-test crash occurred. Thus every new
Android test was observed failing in the appropriate mutation. The first full local run at `82d8d0ae` passed packages, parity/governance and the iOS build; its Mac suite
(2,273 tests, two existing skips) had exactly the equivalent Apple source-text assertion failure. The matched
Apple guard was corrected and deliberately disconnected: two selected tests, one expected assertion failure,
then the exact production source digest restored. These were test compatibility defects, not extra failed race
cases. Final verification and delivery remain pending in State until actual results are captured.

Large logs and compiled replays: `~/Library/Caches/noop-handbook/stress-load-cancellation-2026-10-08/`.
Private scripts/action drafts: handbook `private/stress-load-cancellation-2026-10-08/`. Public output contains no
personal readings. Source-compiled scheduler results, unit tests, simulator appearance and real-phone observation
are separate evidence; none is substituted for another.
