# State

**Updated 17 Sep 2026.** The only file that changes every session. Replace, don't append — history goes in
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

**`upstream/main` was `8576a2dd`** when last checked (16 Sep evening), green on its own; the fork's `main` mirrors
it. Nothing open upstream about the Lift Log. Run `bash dist/tools/upstream-check.sh` first — it moves daily.

## Open work — three stacked branches, three PRs, in this order

1. **Follow-up** — `lift-log-discard-and-edit` @ `1564578a` on `c430ca0b`: one Save; discards kept as 0 × 0; add /
   remove sets in Edit sets; the guard reads "no set counts"; SQL mirrors `reps != 0`; Kotlin twins of
   `LiftMetrics` and `deleteLiftSets`. **Hardware-confirmed 16 Sep.** Ready to open with Utku's yes.
2. **Target max RPE** — `lift-log-target-rpe` @ `858b8678`, stacked on 1 (`RULES.md` 34). **Hardware-confirmed 16 Sep.**
3. **Gym round 3** — `lift-log-gym-round-3` @ `65c5a68e`, stacked on 2, five commits (`NEXT_PR.md` PR 3): one tap
   moves between fields; a strap knock under 8 s is held back and the buzz goes out before the sync (`RULES.md`
   35, 36); the next set on the bar and Lock Screen, a rest clock that stops at 0:00, typed numbers on the bar,
   a locked Lock Screen lights on a strap step (37–39); cleanup. App-target Swift only — nothing under
   `Packages/**` or `android/**`. **Not yet gym-tested.**

- **Work branch:** `lift-log-gym-round-3`
- **Testing build on Utku's phone:** `954a53a8` = `65c5a68e` + the template commit. Releases page: "NOOP Staging —
  base 11.7.0 · 2026-09-16 · 954a53a" (Pre-release; the title date is UTC), `.ipa` uploaded 01:53 on 17 Sep,
  verified. Just update, no wipe.

## Verified

- **Round 3, full `verify.sh` on `65c5a68e`:** WhoopStore 600 · StrandAnalytics 2021 · StrandImport 322 · doc lint ·
  i18n · ledger · ratchet · macOS tests 1907 (only the two `TodayCarryOverTests`) · iOS build. Governance, on a
  clean checkout: one failure, `test_checked_metadata_is_compact_v3_and_expands_losslessly` (functions 4404 →
  4408), identical on `858b8678` — the twin-pair drift PR 1's refresh fixes.
- **Tests seen to fail without their fix:** the knock guard, the synchronous buzz, the tap-before-sync order, the
  two next-set engine tests, typed numbers on the bar, the one light-up signal per strap step.
- **Simulator, before/after builds:** typing — the old build lost the digit after one tap on REPS, the new one
  takes it, also in Edit sets and the program editor; a button tap with the keyboard open dismisses and acts.
  Lock Screen — after a rest ended and the "Ready" push re-rendered it, the old clock read "2:--" and climbing,
  the new one 0:00; "Next: Set 2 · Bench press" on the bar and the Lock Screen. **Not verifiable in the
  simulator:** the Lock Screen lighting, whether the phone vibrates with it, buzz latency on a real strap.
- **The 16 Sep strap log** (`python3 dist/tools/strap-log.py <log>`): 22 double-taps sensed by the strap, 22
  acted on; knocks at +2.9 s and +4.1 s; the four 1.0–2.8 s buzzes were the taps that kicked a sync. The log has
  nothing from 21:15:05 to 21:54:01: the app run started at 21:14:45 stopped logging at 21:15:05, a new run
  started at 21:20:24, and its first half hour was trimmed from its 5,000-entry log by the 22:44 export (58% of
  its entries upstream's once-a-second heart-rate line; 44 the Lift Log's). Not a Lift Log fault; nothing about
  logging is to change (Utku).
- **PRs 1 and 2 on `8576a2dd`** (test merge, parity refresh applied): full `verify.sh` green; the refresh changes
  only what their two twin pairs add (`NEXT_PR.md` step 3). Android CI green on `1564578a` / `858b8678`.

## The 21:15 restart

Answered 17 Sep: no NOOP crash report on his phone for 16 Sep. He may have closed NOOP or left it in the
background for Spotify around 21:15, so the run that started at 21:14:45 was most likely closed by him or by iOS,
not a crash. His workout itself was saved (the log header: "Latest: 2026-09-16 · Strength Training (manual)");
only the diagnostic text of its first half hour was trimmed.

## Nothing is blocked

Round 3 waits only on a gym session. PRs 1 and 2 wait only on Utku's yes to open.

## Next

1. **Utku's next gym session on the round-3 build.** The checklist is at the top of `NEXT_PR.md`. Read the log
   he sends with `dist/tools/strap-log.py` (`WORKFLOW.md` §3).
2. **Fix whatever it finds**, verify, ship (`bash dist/tools/ship-build.sh lift-log-gym-round-3`), give him the
   release link and the build id, and say "just update" or "wipe".
3. **Only with his yes, in order:** rebase PR 1 onto the latest `upstream/main`, commit the parity refresh, run
   everything and Android CI, open it, post the reply on #2099. Then PR 2, then PR 3 (`NEXT_PR.md`).
4. Keep this file true and run `bash dist/tools/backup.sh "what changed"` before the session ends.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `8576a2dd`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-gym-round-3`, `lift-log-build`, `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- Retired refs removed 15 Sep sit in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle` on Utku's Mac,
  LOCAL ONLY — nothing in it is needed (its content is merged upstream or the maintainers' old prototypes).
