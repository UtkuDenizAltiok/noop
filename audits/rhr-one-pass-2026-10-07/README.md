# Resting-heart-rate processing: one-pass measurement, 7 Oct 2026

The original floor calculation and its diagnostic filter the whole session again for every five-minute bin.
The replacement accumulates integer sums and sample counts in one row walk. It keeps the current bin in locals
for ordered input, reloads previously occupied bins for unordered input, and sorts only occupied bin keys.
It keeps the same gate, ungated fallback, rounding, closed final endpoint, zero-length span, diagnostic counts
and chronological tie order. It retains no raw rows and allocates in proportion to occupied bins.

This changes processing cost, not the physiological model. Collection, freshness, scoring weights, thresholds,
background spacing, Bluetooth commands and storage schema stay as before.

## Reproduction

Run against any unchanged or candidate app checkout:

```sh
NOOP_REPO=/absolute/path/to/app NOOP_RHR_CACHE=/absolute/cache/path bash run.sh 420
NOOP_REPO=/absolute/path/to/app NOOP_RHR_CACHE=/absolute/cache/path bash run.sh --oracle
```

`run.sh` copies the exact production RHR functions/constants and HRSample model, records their SHA-256 and the
checkout HEAD, and compiles with Swift `-O`. Its shim only hosts those unchanged functions; no reference algorithm
is substituted for the measured implementation. This is an isolated function measurement, not an app profile.
`Benchmark.swift` supplies identical deterministic recordings; each repetition computes the floor and diagnostic.
Time is actual process CPU (`CLOCK_PROCESS_CPUTIME_ID`) and wall time; `/usr/bin/time -lp` supplies peak memory.

Mac: Apple M3, macOS 27.0.1, Apple Swift 6.4 / Xcode 27.0. Baseline: upstream `8e94d559`.
Baseline SleepStager SHA-256: `4b7aef0585521c9e6f5e6d2a4531766e14b9ed11d0413b7ed2e2c73aee2ea9aa`.
Measured candidate SHA-256: `d814c4b6e0afd8d961cfb6e6072b31137b6b26dd810d15f4e4e61f6bbcc7dfa3`.
A subsequent comments-only edit is `d6761fa71b6812a47600ec13e28c2b3d83e60d6960de33fd0039054b8ac5bd1a`.

## Results

Seven trials per version, alternating which version runs first, 420 repetitions per fixture. No other test/build
was running during the timing measurements. [measurements.json](measurements.json) contains every observation and
complete outputs. All outputs were identical across both versions and all trials.

| Synthetic fixture | HR rows | Median CPU, original | Median CPU, replacement | Reduction |
|---|---:|---:|---:|---:|
| Eight-hour dense night | 28,502 | 1.137077 s | 0.030908 s | 97.3% |
| Eight-hour night inside a 54-hour read | 194,102 | 1.179368 s | 0.071953 s | 93.9% |
| Sparse night, 30-second cadence | 952 | 0.054471 s | 0.006299 s | 88.4% |
| Reversed dense night | 28,502 | 1.153725 s | 0.030717 s | 97.3% |

Median peak process footprint: 6,947,272 → 5,734,856 bytes. Median maximum RSS:
10,977,280 → 9,764,864 bytes. These include harness/data allocations, so neither is an app memory prediction.
A dense eight-hour night saves about **2.6 milliseconds** per floor-plus-diagnostic pair in this measurement.
Resting HR is a small part of a full re-score: these percentages do not describe total NOOP CPU or battery use.
No phone energy/thermal/MetricKit comparison is available; Utku deferred installation and the private backup.

## Exact-output contract

[Oracle.swift](Oracle.swift) compiles the original production functions over 12 named fixtures plus a 768-case
sweep covering aligned/unaligned endpoints, reversed/zero spans, negative timestamps, unordered duplicate rows,
outside rows, sparse/implausible bins, custom diagnostic thresholds and overlapping sessions.
[baseline-oracle.txt](baseline-oracle.txt) is its actual stdout. The named output block and FNV-1a digest of all
768 full floor/diagnostic strings (`a9770363`) were pasted verbatim into the Swift and Kotlin tests and read back
against that file. Candidate production stdout is byte-identical. A separate sparse 30-year span test asserts
occupied-bin sums/counts and the closed endpoint without allocating millions of empty bins.

Mutation check: remove final-endpoint clamping locally. All three new Swift tests fail by assertion (five
assertions total, no crash). Restore the exact source SHA-256, then all 101 targeted RHR/sleep tests pass.
This tests output invariants; no unstable wall-clock threshold is added to CI.

Full local `verify.sh` at `035b6ab1` finished `all steps passed`: 632/2138/327 package tests, all source
and parity gates, 127 governance tests, 2267 Mac app tests and iOS build. One import/two Mac skips.
Final `14783994` removes four redundant Kotlin null assertions; its diff against `035b6ab1` contains no Swift,
store, Apple app or tooling changes. Final-head source/parity gates and 127 clean-checkout governance tests pass.
Combined iOS build at `979a2baf` also passes. Final-head fork Android run [37683254213](https://github.com/UtkuDenizAltiok/noop/actions/runs/37683254213)
passes its build and actual full unit-test step, with no warnings in the changed SleepStager file.
PR/release identities are in State/History.
