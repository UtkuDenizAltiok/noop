# State

**Updated 15 Sep 2026.** The only file that changes every session. Replace, don't append — history goes in
`HISTORY.md`.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |

**Unanswered:** ryanbr's 15 Sep 04:07 comment on #2099. The reply is drafted in `NEXT_PR.md`; it goes out right
after the follow-up opens, with Utku's yes.

## Open work — two PRs, in this order

1. **Follow-up** — branch `lift-log-discard-and-edit` @ `0a55bc8c` on `upstream/main` `c430ca0b` (pushed): one
   Save; discarded sets kept as 0 × 0 (hidden from every figure, fillable in Edit sets); add/remove sets in Edit
   sets; the guard reads "no set counts" with a warning before Save; SQL mirrors `reps != 0`; Kotlin twin and
   oracle in step.
2. **Target max RPE** — branch `lift-log-target-rpe` @ `8f6c8f3d`, stacked on the follow-up (pushed): a max RPE
   (1–10) per program line, typed in the line editor or imported from the template's `Target max RPE` column,
   shown grey "≤8" in the session, never saved as a rating (`RULES.md` 34). No schema change.

- **Work branch:** `lift-log-target-rpe`
- **Testing build on Utku's phone:** `f854fa5d` (both PRs). Just update, no wipe. Not yet gym-tested.

## Verified (`8f6c8f3d`, Xcode 27)

WhoopStore 600 · StrandAnalytics 2021 · StrandImport 322 · StrandTests 1896 (only the two locale-dependent
`TodayCarryOverTests` fail) · iOS build · doc lint · i18n · Android CI green · fail-first seen for the max-RPE
range check and the "never saved as a rating" rule. Only the known `onChange(of:perform:)` warnings.

**Not verified: parity.** The default ledger reports checked-in authority drift — `function_pairs` (the new
`isPerformed` twin pair, follow-up) and `constants` (max-RPE branch). Both PRs must carry the guarded refresh
(`python3.12 Tools/parity_ledger.py --refresh-derived --base origin/main`, then ledger and ratchet), or `main`
goes red after merge exactly as in #2229. Ratchet and governance tests need Python 3.12 too.

## Blocked

- **Python 3.12+ is not installed** (only Xcode's 3.9, which lacks tarfile's extraction filter). Needs Utku's yes
  to `brew install python@3.12`.

## Next

1. With Python 3.12: guarded authority refresh on the follow-up (commit it there), then rebase the max-RPE branch
   onto it and refresh again for its own drift; ratchet and governance tests on both; answer the `deleteLiftSets`
   question (a new Swift-only function — prefer not adding the identity, else a Kotlin twin; #2163).
2. Utku's gym session on `f854fa5d` (`NEXT_PR.md` lists what to watch, in plain words).
3. With his yes: open the follow-up and reply on #2099; after it merges, rebase the max-RPE branch
   `--onto upstream/main` and open it.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `c430ca0b`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-build`, `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags.
- Retired refs removed 15 Sep are in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle`
  (Utku may delete it any time).
