# HRV neighbour-buffer reuse — 8 Oct 2026

Source base: `8e94d559be273ec8d74832fe5db78898be83cc11`. Recorded before measurements or app edits.

Hypothesis: allocating the local-neighbour array once per cleaning call, clearing it with capacity retained
before each beat, reduces CPU cost while preserving every result. Keep the original local windows, input order,
median sorting, threshold, range filter, output order, and removed-beat adjacency. No changed scientific method.
Scope: Swift `HRVAnalyzer.rejectEctopic` / `cleanRRGapAware` and Kotlin twins only, plus matched preservation tests.

Pilot: compile the verbatim production cleaning bodies with `swiftc -O`; make the buffer-reuse-only candidate
in a cache, before choosing implementation. Seven alternating original/candidate CPU trials, identical inputs:
300-beat short windows, 36,000-beat eight-hour-sized captures, and 108,000-beat day-sized captures; clean and
mixed artefact series. Prebuilt inputs, warm-up, retained checksum, getrusage CPU and monotonic wall clock.
Use the median per workload, report every trial. Continue only if outputs match and measured CPU improves
without a material regression. A microbenchmark cannot establish phone battery savings or whole-pass speed.

Correctness domain: exhaustive sequences of length 0...6 over [299, 300, 800, 960, 1200, 2000, 2001],
plus deterministic fractional, threshold, NaN/infinity, short/end-window and long mixed fixtures. Compare exact
Double bits and every adjacency flag with original production output. Compile original Swift to generate
cross-platform expected literals; both implementations must match them. Mutate the buffer clear separately
in each path so its preservation test must fail, then restore the exact source digest. Android negative CI
must be announced before dispatch. Full local verification, final fork Android, upstream exact-head required
roster, combined iOS/Swift/Android and testing IPA identity/download checks are required for delivery.

No exclusions, no personal data, subjects or reference recordings. Existing spectral defects remain queued;
no improved physiological accuracy, BLE reliability or clinical interpretation is claimed.
