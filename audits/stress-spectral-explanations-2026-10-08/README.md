# Stress spectral explanations — 8 Oct 2026

## Extended assessment and bounded choice

This extends the [pipeline audit](../biometric-pipeline-2026-10-07/README.md) and
[whole-system freshness assessment](../stress-load-cancellation-2026-10-08/README.md), rather than repeating
the completed SDNN, Charge, resting-HR or cancellation repairs. Source base `8e94d559` is still current;
all nine owned PRs are open/mergeable with their full expected green rosters. External Stress PRs #2725/#2732
cover Android retry/cache behavior, not this wording. No open issue/PR addressing spectral interpretation was found.

| Area | Current evidence and decision |
|---|---|
| Strap transport, timing and storage | The new private phone log has recent completed history sync/live saves, plus earlier timeouts, a reconnection pause and Bluetooth-off period. Do not infer a new transport defect, uninterrupted connection or raw signal accuracy from it. Deletion-marker backup direction remains parked in #2720. |
| HR/HRV, respiration and sleep | Completed contract fixes are already delivered. `cleanRRGapAware` retains removed-beat adjacency for time-domain metrics, whereas the spectral caller still reconstructs time from cleaned intervals and discards coarse row timestamps. No new physiology change is justified from this log. |
| Spectral estimator | Existing synthetic units/grid failures remain; packed/coarse timestamps complicate a repair. Units, grid and missing-time reconstruction need joint independent validation. Preserve that queued task and avoid an isolated normalization patch. |
| CPU, phone/strap energy and freshness | No comparable before/after phone energy measurement is available. Preserve collection, score scheduling and completed cancellation protection. A copy change carries no resource-saving claim. |
| User decisions, design and accessibility | Stress currently calls LF/HF autonomic balance and says higher is stress-ward; HF is described as a rest band. Apple's shared StatTile clips captions to one line. A qualification there would be hidden. Use brief neutral captions and the existing full-width wrapping footer. |
| Localization, privacy and maintainability | Android spectral captions are hardcoded English. Localize new text in every existing locale. Keep private data local and retain the same components, chart/numeric formatting and optional feature. |

Choose the spectral explanation because it is a directly reachable unsupported claim with a feasible,
independent verification path. A number that looks convincing must not tell a user more than the evidence
supports. This repair changes interpretation and makes its limitation visible; it does not establish estimator
accuracy or hide/remove readouts. API power-unit comments and the estimator defects remain a separate task.

## Primary research

The 2024 Society for Psychophysiological Research committee report rejects LF/HF as an index of bipolar
sympathovagal balance (§4.3.1) and recommends against using LF/HF or LF as selective sympathetic measures
(§4.3.2). Its respiration discussion and reporting checklist also show why a fixed HF band cannot independently
identify breathing-related cardiac control without considering respiration/recording conditions.
[Quigley et al., 2024](https://doi.org/10.1111/psyp.14604).

Billman's physiological review likewise explains that autonomic branches need not change reciprocally,
LF is a mixture of influences, and respiration/heart rate confound a simple LF/HF balance reading.
[Billman, 2013](https://www.frontiersin.org/journals/physiology/articles/10.3389/fphys.2013.00026/full).

The product inference is to label the actual ratio/estimate and avoid direct stress, rest, recovery or
nervous-system balance claims. These sources do not validate NOOP's spectral estimator or its Stress score.

## Acceptance recorded before edits

1. Both current spectral branches retain their original values, rounding, availability gates, colors and load
   phases. Only labels/captions/footer and their resource wiring change; analytics/storage/BLE trees are identical.
2. LF/HF is labeled as a ratio; HF as an estimate. Neither caption implies sympathetic dominance or a direct
   rest measurement. The full-width footer names breathing/recording limitations and states the interpretation
   limit without claiming clinical accuracy or changing the score.
3. Every existing Apple/Android locale contains the new text and its production resource call is compiled.
   Apple iOS/macOS compiled strings are checked, including the title and whole footer. No English fallback is
   accepted for a changed explanatory string in a locale previously supported by the app.
4. Build/run original and fixed Apple apps against the same synthetic input. Inspect ratio and HF-only branches,
   full explanation, phone-width layout and accessibility-size wrapping. Any fixture forcing a branch is explicitly
   synthetic and temporary; restore production source and simulator state byte-for-byte afterward.
5. Finish full local verification, actual Android build/unit steps, exact-head upstream roster, PR and combined
   testing delivery. Preserve IDs/logs before long/public actions. No phone repeat test or export is required.

No new literal-matching unit tests for this reversible copy change. Existing tests, compiled localization,
unchanged-source comparison and rendered UI provide the meaningful checks. Runtime results belong in State
until verification is finished.
