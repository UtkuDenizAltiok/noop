# Optional Charge baseline experiment — 8 Oct 2026

Recorded before the new tests or measurement. Source base: 8e94d559be273ec8d74832fe5db78898be83cc11.
Worktree: /Users/utk/.codex/worktrees/charge-baseline-usability/noop; branch codex/charge-baseline-usability.

Prediction: BaselineState respiration and Effort marked calibrating/stale currently affect Charge when values exist.
Respiration also emits a driver/baseline/term in engine diagnostics, although Apple UI prefilters it.
Threshold/direction: corrected calibrating/stale states must produce EXACTLY the nil-baseline score bits, other
rows and trace. Provisional/trusted and nil inputs must preserve the original raw DriverBaseline math exactly.
Existing BaselineState.usable is the authority; do not change baseline learning, weights, physiological cutoffs or
stale eligibility. Dominant HRV still refuses cold-start. No accuracy or phone-energy improvement prediction.

Domain: optional baseline states nil/calibrating/provisional/trusted/stale; resp values nil/10/14/18/22 br/min;
Effort values nil/0/30/60/100 on its 0-100 scale. All 25 baseline pairs x 25 value pairs = 625 score cases,
with HRV55/RHR58, trusted HRV50 spread8 and RHR60 spread4, rest0.85, skin deviation0.2 and slope-0.5.
Status fixtures use resp16 spread2 / Effort45 spread10, n=0/6/14/14, stale age20. Additional genuine empty and
all-implausible folded states pin the reachable cold-start. Respiratory driver/trace cases cover every status and
value, with other terms present. HRV calibrating/stale cases pin the nil headline/empty rows/cold-start trace.
Raw-bit cross-platform oracle covers all 25 baseline pairs at resp14/Effort60 with unchanged surrounding inputs.

Exclusions: none in this finite synthetic domain. Strata: nil/missing, calibrating, provisional, trusted, stale.
Human subjects/nights: none. No physiological accuracy claim, no fitting, no personal backup needed. Compare old
and new over identical inputs. Independent ground truth and temporal holdout are required for later physiological
improvement claims, not supplied by this software-contract test.

Expected failure: new omission tests fail on original code on both platforms, then pass after the fix. Mutation
of each scorer/driver/trace gate must fail its corresponding test. Full local verify, final-head Android, source
parity/governance, current-head PR roster, combined iOS/Android/Swift and asset/tag/IPA delivery remain required.
