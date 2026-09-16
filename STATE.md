# State

**Updated 17 Sep 2026 (just after midnight).** The only file that changes every session. Replace, don't append —
history goes in `HISTORY.md`.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |

**Unanswered:** ryanbr's 15 Sep 04:07 comment on #2099. The reply is drafted in `NEXT_PR.md`; it goes out right
after the follow-up opens, with Utku's yes.

**`upstream/main` is `8576a2dd`** (checked 16 Sep evening) and green on its own: doc lint, i18n, ledger, ratchet
and governance all pass on it. The fork's `main` mirrors it. Nothing open upstream about the Lift Log.

## Open work — three stacked branches, three PRs, in this order

1. **Follow-up** — `lift-log-discard-and-edit` @ `1564578a` on `c430ca0b`: one Save; discards kept as 0 × 0; add /
   remove sets in Edit sets; the guard reads "no set counts"; SQL mirrors `reps != 0`; Kotlin twins of
   `LiftMetrics` and `deleteLiftSets`. **Hardware-confirmed 16 Sep.**
2. **Target max RPE** — `lift-log-target-rpe` @ `858b8678`, stacked on it (`RULES.md` 34). **Hardware-confirmed 16 Sep.**
3. **Gym round 3** — `lift-log-gym-round-3` @ `7b993bd5`, stacked on 2, three commits: one tap moves between
   fields; a strap knock under 8 s is held back and the buzz goes out before the sync (`RULES.md` 35, 36); the
   next set on the bar and Lock Screen, a rest clock that stops at 0:00, typed numbers on the bar, and the Lock
   Screen lights on a strap step (37–39). App-target Swift only — nothing under `Packages/**` or `android/**`.

- **Work branch:** `lift-log-gym-round-3`
- **Testing build on Utku's phone:** `496dbc3b` = round 3 (`7b993bd5`) + the template commit, shipped and verified
  17 Sep (release points at it; `.ipa` and template present). Just update, no wipe (no stored shape changed; the
  Live Activity state is not persisted). Not yet gym-tested.

## Verified

- **Round 3, full `verify.sh` on `7b993bd5`:** WhoopStore 600 · StrandAnalytics 2021 · StrandImport 322 · doc lint ·
  i18n · ledger · ratchet · macOS tests 1906 (only the two `TodayCarryOverTests`) · iOS build. Governance: ONE
  failure, `test_checked_metadata_is_compact_v3_and_expands_losslessly` (functions 4404 → 4408), identical on
  `858b8678` — the known twin-pair drift the PR-time refresh fixes. A second failure seen in place was build
  output under `Packages/*/.build` (this base predates #2259); `verify.sh` now runs governance on a clean checkout.
- **Tests seen to fail without their fix:** the knock guard, the synchronous buzz, the tap-before-sync order, the
  two next-set engine tests, typed numbers on the bar.
- **Simulator, before/after builds:** typing — the old build lost the digit after one tap on REPS, the new one
  takes it (also in Edit sets); a button tap with the keyboard open dismisses and acts. Lock Screen — after the
  rest ended and the "Ready" push re-rendered it, the old clock read "2:--" and climbing, the new one 0:00. The
  "Next: Set 2 · Bench press" line on the bar and the Lock Screen. **Not verifiable in the simulator:** the
  Lock Screen lighting, whether the phone vibrates with it, and buzz latency on a real strap.
- **The 16 Sep strap log** (21:54–22:26 only; the first half hour had rolled out): 22 double-taps sensed by the
  strap, 22 acted on; knocks at +3 s and +4 s; the four 1.0–2.8 s buzzes were the taps whose event kicked a sync.
- **PRs 1 and 2 on `8576a2dd`** (test merge, parity refresh applied): full `verify.sh` green; the refresh changes
  only what their two twin pairs add (`NEXT_PR.md` step 3). Android CI green on `1564578a` / `858b8678`.

## Nothing is blocked

The round-3 branch waits only on a gym session. PRs 1 and 2 wait only on Utku's yes to open.

## Next

1. **Utku's next gym session on the round-3 build.** The checklist is at the top of `NEXT_PR.md` (typing, knocks,
   buzz speed, 0:00, the next-set line, the Lock Screen lighting — and whether it vibrates or sounds). Ask him
   to export the strap log straight after.
2. **Fix whatever it finds**, verify, ship (`bash dist/tools/ship-build.sh lift-log-gym-round-3`), say "just
   update" or "wipe".
3. **Only with his yes, in order:** rebase PR 1 onto the latest `upstream/main`, commit the parity refresh, run
   everything and Android CI, open it, post the reply on #2099. Then PR 2, then PR 3 (`NEXT_PR.md`).
4. **Ask Utku** whether to raise upstream's once-a-second heart-rate log line, which fills the strap log in
   ~50 minutes (`BACKLOG.md` 7). Public, so his yes first.
5. Keep this file true and run `bash dist/tools/backup.sh "what changed"` before the session ends.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `8576a2dd`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-gym-round-3`, `lift-log-build`, `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags.
- Retired refs removed 15 Sep sit in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle`, LOCAL ONLY:
  it disappears with a machine format, and nothing in it is needed — that content is either merged upstream
  (#2098/#2099 pre-squash history) or the maintainers' own old prototypes.
