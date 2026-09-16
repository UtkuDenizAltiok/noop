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

1. **Follow-up** — `lift-log-discard-and-edit` @ `1564578a` on `upstream/main` `c430ca0b`: one Save; discarded
   sets kept as 0 × 0 (hidden from every figure, fillable in Edit sets); add/remove sets in Edit sets; the guard
   reads "no set counts" with a warning before Save; SQL mirrors `reps != 0`; the Kotlin `LiftMetrics` twin in
   step; and `deleteLiftSets` now has its Kotlin twin in `DeviceRegistryDao`, ported ahead of its consumer.
2. **Target max RPE** — `lift-log-target-rpe` @ `858b8678`, stacked on it: a max RPE (1–10) per program line,
   typed in the line editor or imported from the template's `Target max RPE` column, shown grey in the session;
   a set the session keeps and nobody rated saves it (`RULES.md` 34). No schema change.

- **Work branch:** `lift-log-target-rpe`
- **Testing build on Utku's phone:** `4fda4266` — both PRs, max RPE included. Just update, no wipe. Not yet gym-tested.

## Verified

- `8f6c8f3d` (max RPE, pre-rebase): WhoopStore 600 · StrandAnalytics 2021 · StrandImport 322 · StrandTests 1896
  (only the two locale-dependent `TodayCarryOverTests`) · iOS build · doc lint · i18n · Android CI green.
- The RPE-fills-a-blank rule: macOS Lift Log tests 86, incl. `testAMaxRpeFillsAnEmptyRatingLikeEveryOtherGreyNumber`
  and `testADiscardedSetTakesNoMaxRpe`. Importer fail-first seen for the 1–10 range check.
- **Parity, with Python 3.12 (`/opt/homebrew/bin/python3.12`): ledger has no new finding and the ratchet no
  error against the branch's own base, WITHOUT touching `parity_twin_map.json` or `parity_ledger_baseline.json`.**
  The three one-sided declarations the ratchet named were resolved rather than declared as debt: a private helper
  and a constant inlined, and `deleteLiftSets` given its Kotlin twin.
- **`main` itself is red again (16 Sep).** On clean `upstream/main` `6ce9a0d7` the two `RepositoryBaselineTests`
  fail and the ratchet says the base authority cannot be reproduced — upstream's own #2240 drifted the authority
  without refreshing it (#2229's pattern, not ours).
- **The authority refresh is verified to work on our side:** run against our base it made all three green
  (governance 124 tests OK). It is deliberately NOT committed yet — it goes in right after the PR-time rebase
  (`NEXT_PR.md` step 3), because a snapshot against an older base is stale on arrival.
- **Upstream moved to `6ce9a0d7`** (Oura, rescore, coach and i18n fixes; only #2250 touches the shared catalog).
  Both branches still merge cleanly, so the rebase happens at PR time rather than costing another full run.
- **Full `verify.sh` on `39b5f56e`** (the same Swift as the tips): WhoopStore 600 · StrandAnalytics 2021 ·
  StrandImport 322 · StrandTests 1897 (only the two `TodayCarryOverTests`) · iOS build · doc lint · i18n ·
  ledger OK. The only change after it was Android test code, covered by **Android CI, green on both branches**.
- **A DAO method breaks its Kotlin test doubles** (16 Sep): three fakes implement `DeviceRegistryDao`, and the
  fork's testing build assembles Android without compiling its tests, so only Android CI caught it.

## Next

1. When `verify.sh` is green: push both branches, `Android CI` on each, `bash dist/tools/ship-build.sh
   lift-log-target-rpe`, and tell Utku "just update".
2. Utku's gym session on that build (`NEXT_PR.md` lists what to watch, in plain words).
3. With his yes: open the follow-up and reply on #2099; after it merges, rebase the max-RPE branch
   `--onto upstream/main` and open it.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `c430ca0b`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-build`, `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags.
- Retired refs removed 15 Sep are in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle`
  (Utku may delete it any time).
