# Preregistered cancellation investigation — 8 Oct 2026

Source base: `8e94d559`. Record written before running the controlled scheduler/harness.

Hypothesis: a cancelled Apple Stress load can publish a late stored series, timeline or advanced readout after
its replacement has published fresh state. Android can similarly publish an empty fallback after catching
`CancellationException`. The mechanism is reachable at `.task(id: repo.refreshSeq)` and Android's keyed
`LaunchedEffect`/lifecycle loop, not a numerical property of HRV.

## Domain and predictions

- Primary domain: two ordered loads, old starts first, replacement finishes first, old completes last.
  Pause old work at stored-series, HR/core and advanced boundaries; use non-cooperative suspended work on Apple
  and a cancellation throw inside the existing `runCatching` boundary on Android. These are scheduler-controlled
  fixtures, not natural-world prevalence or phone-energy measurements.
- Controls: uncancelled successful read; pre-cancelled caller; cancellation while an underlying read deliberately
  ignores cancellation; an ordinary read failure on Android; original successful result and phase order.
- Prediction before repair: at least one stale write on Apple and one post-cancellation fallback write on Android.
  Repair threshold: zero writes attributable to the cancelled load in every controlled interleaving; no additional
  read or advanced phase starts after a cancelled read returns. Every uncancelled result remains identical.
- No data/fixture exclusions. Report all cases, failed cases and any harness correction. Use deterministic gates
  rather than timing-dependent sleeps. Repeat the same inputs with old/new code.
- Sampling/tuning: no physiological parameter fitted, no personal data, no PSG stage comparison, no ECG-accuracy
  claim. Independent references are the Swift/Kotlin cooperative-cancellation contracts and source semantics.

## Boundary and delivery

One concern: cancellation at the Stress screen's async read/publication boundary. Keep successful two-phase loading
(timeline first, advanced lenses later), priority, formulas, raw samples, source arbitration, score paths and UI
layout. Do not expand into spectral normalization, confidence thresholds or global coroutine cleanup.

Use production helpers/paths in regression tests, deliberately remove cancellation rejection and observe failures,
then restore source hashes. Validate both Apple app targets and Android's actual build/unit steps. Deliver the
verified app change through the existing testing stack/release; hardware/phone observations remain distinct.
