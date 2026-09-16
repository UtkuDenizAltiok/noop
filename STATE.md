# State

**Updated 16 Sep 2026 (evening).** The only file that changes every session. Replace, don't append — history goes
in `HISTORY.md`.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |

**Unanswered:** ryanbr's 15 Sep 04:07 comment on #2099. The reply is drafted in `NEXT_PR.md`; it goes out right
after the follow-up opens, with Utku's yes.

**`upstream/main` is `8576a2dd`** and green on its own again: doc lint, i18n, ledger, ratchet and governance all
pass on it (#2259/#2267 fixed the parity scan; the twin maps were re-derived). The fork's `main` mirrors it.
Nothing open upstream about the Lift Log. Upstream touched `FrameRouter` (#1985: every frame now passes one
integrity gate, the double-tap replay path included), `RootTabView`/`AppModel` (coach switch, rescore) and the
catalog — none of it conflicts with ours.

## Open work — two PRs, in this order

1. **Follow-up** — `lift-log-discard-and-edit` @ `1564578a` on `c430ca0b`: one Save; discarded sets kept as
   0 × 0 (hidden from every figure, fillable in Edit sets); add/remove sets in Edit sets; the guard reads "no set
   counts" with a warning before Save; SQL mirrors `reps != 0`; the Kotlin `LiftMetrics` twin in step; and
   `deleteLiftSets` has its Kotlin twin in `DeviceRegistryDao`.
2. **Target max RPE** — `lift-log-target-rpe` @ `858b8678`, stacked on it: a max RPE (1–10) per program line,
   typed in the line editor or imported from the template's `Target max RPE` column, shown grey in the session;
   a set the session keeps and nobody rated saves it (`RULES.md` 34). No schema change.

- **Work branch:** `lift-log-target-rpe` (not rebased — rebase happens at PR time, `NEXT_PR.md`)
- **Testing build on Utku's phone:** `4fda4266` — both PRs, max RPE included. Just update, no wipe. Not yet gym-tested.

## Verified

- **On a test merge of `lift-log-target-rpe` into `8576a2dd`, with the parity refresh applied** (16 Sep, full
  `verify.sh`): WhoopStore 609 · StrandAnalytics 2024 · StrandImport 322 · doc lint · i18n (now also gating format
  specifiers in every locale) · ledger · ratchet · governance 124 · macOS tests 1956 (only the two
  `TodayCarryOverTests`; every Lift Log suite passed) · iOS build. So the PR-time rebase should cost only its own
  re-run.
- **The parity refresh is now REQUIRED in the follow-up PR.** Without it, each branch merged onto `8576a2dd` fails
  the ledger (`twin-map-authority-drift|function_pairs`) and two `RepositoryBaselineTests` — the #2229 pattern.
  `--refresh-derived --base upstream/main` fixes it and changes only what our two twin pairs add (functions +4,
  function_pairs +2, file_pairs +1, unpaired_files −2); `parity_ledger_baseline.json` is untouched. The refresh
  is identical for both branches, so the max-RPE branch adds no pair of its own and PR 2 should need none.
  (The earlier "leave the JSONs alone" plan held only while `main`'s own authority did not reproduce.)
- **Not run on the merge: Android.** No Android file is touched by both sides, and upstream added no new
  `DeviceRegistryDao` fake (still the three that already implement `deleteLiftSets`). Android CI runs at PR time.
- **Branch tips as they stand** (on `c430ca0b`): full `verify.sh` on `39b5f56e`, the same Swift as both tips, green
  apart from the two `TodayCarryOverTests`; Android CI green on `1564578a` and `858b8678`. The RPE-fills-a-blank rule is pinned by
  `testAMaxRpeFillsAnEmptyRatingLikeEveryOtherGreyNumber` and `testADiscardedSetTakesNoMaxRpe`; the importer's
  1–10 range check was seen to fail first.

## Nothing is blocked

Python 3.12 is at `/opt/homebrew/bin/python3.12`, Xcode 27's licence is accepted, both branches are pushed and
green. Two "Android CI failed" emails from 16 Sep name superseded commits (`cc34a27c`, `39b5f56e`), already fixed.

## Next

1. **Utku's gym session on build `4fda4266`.** What to watch is listed in plain words at the top of
   `NEXT_PR.md`; the max-RPE items are new this round.
2. **Fix whatever the session finds**, verify (`bash dist/tools/verify.sh`), ship
   (`bash dist/tools/ship-build.sh lift-log-target-rpe`), and tell him "just update" or "wipe".
3. **Only with his yes, and in this order:** rebase the follow-up onto the latest `upstream/main`, commit the
   parity refresh and run all checks (`NEXT_PR.md` step 3), run Android CI, open the follow-up PR, then post the
   one reply to ryanbr's 15 Sep 04:07 comment on #2099. After it merges, rebase the max-RPE branch
   `--onto upstream/main`, re-run the checks (a refresh should not be needed), and open the second PR.
4. Keep this file true and run `bash dist/tools/backup.sh "what changed"` before the session ends.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `8576a2dd`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-build`, `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags.
- Retired refs removed 15 Sep sit in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle`, LOCAL ONLY:
  it disappears with a machine format, and nothing in it is needed — that content is either merged upstream
  (#2098/#2099 pre-squash history) or the maintainers' own old prototypes.
