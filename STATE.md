# State

**Updated 21 Sep 2026.** The only file that changes every session. Replace, don't append — history goes in
`HISTORY.md`.

## Upstream (`ryanbr/noop`)

| PR | what | state |
|---|---|---|
| [#2098](https://github.com/ryanbr/noop/pull/2098) | `v46-lift-log` schema, Room twin, Android delete/re-key | merged 14 Sep, squash `8818477d` |
| [#2099](https://github.com/ryanbr/noop/pull/2099) | the app | merged 15 Sep, squash `4453a089` (our `45caa744` + ryanbr's empty-session guard `fed714cb`) |
| [#2232](https://github.com/ryanbr/noop/pull/2232) | Kotlin `LiftMetrics` twin + oracle tests (by the maintainers) | merged 15 Sep, `eb34f3c8` |
| [#2233](https://github.com/ryanbr/noop/pull/2233) | parity-governance repair; `main` green again after #2099 left it red (#2229) | merged 15 Sep, `36b49dbe` |

- **`upstream/main` is `a56840bb`** (21 Sep). 11.8.0 shipped the Lift Log (Apple only). The fork's `main` mirrors it.
- **Open upstream:** ryanbr's #2327 — the Lift Log has no Android UI (`BACKLOG.md` 4). Not ours to answer unasked.
- **Unanswered (optional):** ryanbr's last comment on merged #2099 (15 Sep 04:07) asks whether we would rather
  keep performed sets with their timing — round 4 did exactly that. A 3-sentence reply is drafted in `NEXT_PR.md`,
  to post right after the new PR opens, only with Utku's yes.

## Open work — one stack, ONE PR

Three stacked branches, rebased on `a56840bb` 21 Sep (every commit range-diff identical), to be opened as ONE PR
from a new branch `lift-log-follow-ups` at the tip (`NEXT_PR.md`; the reason is at its top):

1. `lift-log-discard-and-edit` @ `631f411f` — one Save; discards as 0 × 0 fillable in Edit sets; add / remove
   sets in Edit sets; SQL mirrors `reps != 0`; Kotlin twins of `LiftMetrics` and `deleteLiftSets`; and the
   parity refresh commit (`631f411f`: functions +4, function_pairs +2, file_pairs +1, unpaired_files −2).
2. `lift-log-target-rpe` @ `0c9c72e9` — max RPE per program line (`RULES.md` 34).
3. `lift-log-gym-round-3` @ `7bafa857` — rounds 3 and 4: one-tap field focus; knock guard (now 5 s) and buzz
   before the sync; next-set line, 0:00 rest clock, typed numbers on the bar; done sets complete without asking;
   the program takes each line's heaviest set; the Lock Screen lights whenever NOOP is off screen and logs each
   step; no sync banner during a session; banner layout (`RULES.md` 5, 27, 28, 35–40).

- **Work branch:** `lift-log-gym-round-3`
- **Testing build on Utku's phone:** `592e17bf` = `7bafa857` + the template commit, now on NOOP 11.8.0. Releases
  page: "NOOP Staging — base 11.8.0 · 2026-09-21 · 592e17b" (Pre-release), `.ipa` uploaded 10:21 on 21 Sep,
  verified. Just update, no wipe. Not yet gym-tested.

## Verified

- **The tip `7bafa857`, full `verify.sh`, every step passed:** WhoopStore 609 · StrandAnalytics 2030 ·
  StrandImport 327 · doc lint · i18n · ledger · ratchet · governance 124 (clean checkout, no failure) · macOS
  tests 2066 (only the two `TodayCarryOverTests`) · iOS build. `--quick` also passed on `631f411f` and `0c9c72e9`
  alone. The light-up commit `51078475` was built on its own (its file was split by hand).
- **Android CI:** green on the rebased tip `7bafa857` (run 35576172501).
- **Tests seen to fail without their fix (round 4):** knock window pinned at 5 s; done sets complete without
  asking; only never-started sets unfinished or zeroed; a discarded set takes no max RPE; the heaviest-set rule
  and its exclusions. Earlier rounds: listed in `NEXT_PR.md`'s PR body.
- **Simulator:** the new banner with a working set's count-up, a rest's countdown and a finished rest's 0:00, all
  right-aligned under the heart rate, the status line whole ("Resting after set 4 — 9 x 60 kg"). A first layout
  let the running timer spread across the banner; caught here, not on the phone. **Not verifiable in the
  simulator:** whether the Lock Screen lights, and whether the phone vibrates with it.
- **The 17 Sep strap log** (`python3 dist/tools/strap-log.py <log>`): 28 double-taps sensed, 28 reached the app,
  2 held back as knocks (at +3.5 s and +6.0 s after an acted-on tap, under the old 8 s). The log could not show
  which steps lit the screen — each step now logs it. NOOP restarted at 21:37:30 and 21:38:37; the log does not
  say why.

## Confirmed at the gym

Everything up to round 3, including one-tap typing and the 0:00 rest clock (Utku, 21 Sep, about 17 Sep). Round 4
(5 s knock window, done = complete, heaviest set to the program, light-up without the "locked" gate, banner layout,
no sync banner) waits on the next session. Ask him then: for any step that buzzed but stayed dark, was the phone
face down or a Focus on? The log now says whether the app asked iOS to light it.

## Nothing is blocked

The PR is written (`NEXT_PR.md`, plain words as Utku asked) and waits on one gym session on build `592e17b` and his
yes.

## Next

1. **Utku's next gym session on this build.** The checklist is at the top of `NEXT_PR.md`. Read his log with
   `dist/tools/strap-log.py`.
2. **Fix whatever it finds**, verify, ship (`bash dist/tools/ship-build.sh lift-log-gym-round-3`), give him the
   release link and the build id, and say "just update" or "wipe".
3. **Only with his yes:** `NEXT_PR.md` "Before opening" — rebase if `main` moved, refresh parity, verify, create
   `lift-log-follow-ups`, Android CI, open the ONE PR, post the reply on #2099; then, with his yes, delete the
   three stacked branches from the fork.
4. Keep this file true and run `bash dist/tools/backup.sh "what changed"` before the session ends.

## The fork, exactly

- Branches: `main` (mirror of `upstream/main`, `a56840bb`), `lift-log-discard-and-edit`, `lift-log-target-rpe`,
  `lift-log-gym-round-3`, `lift-log-build`, `lift-log-handbook`.
- Tags: `fork/ships-template`, `testing-latest`, plus upstream's version tags. No `backup/*` tags remain.
- Releases: one, `testing-latest` (Pre-release), replaced by every `ship-build.sh`; Utku installs from it.
- Retired refs removed 15 Sep sit in `~/Developer/noop-retired/noop-retired-refs-2026-09-15.bundle` on Utku's Mac,
  LOCAL ONLY — nothing in it is needed (its content is merged upstream or the maintainers' old prototypes).
