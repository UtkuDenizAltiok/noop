# History

One line per event. What a session or review found, and the rule it produced, is what makes the rules
trustworthy — keep it.

## Upstream timeline

- **9 Sep 2026** — #2029 (catalog hygiene) merged: the first upstream contribution.
- **11 Sep** — first review round on #2098 (schema) and #2099 (app): Android delete list fixed; double-tap de-dup
  made a set; estimates labelled; work-vs-rest deleted; the CI template commit kept out of PRs as
  `fork/ships-template`.
- **14 Sep** — #2098 squash-merged; #2099 rebased with `--onto`. ryanbr confirmed and corrected his own
  "migration registered twice" (a grep counting a comment). #2099 cleared the 14 lift-log ledger entries (#2211).
- **15 Sep, early** — first gym session → three changes added to #2099 (program counts asked at finish; grey
  stays grey with one complete/discard question; editing finished sessions).
- **15 Sep 04:04–04:16 UTC** — ryanbr reviewed them, asked whether a face-down session with nothing typed should
  be emptied by a discard (it filed an empty session plus a workout with strain), pushed the guard `fed714cb`
  and merged #2099.
- **15 Sep** — second gym session (before the merge was seen) → one Save, discards kept as zeros, add/remove in
  Edit sets; built on `lift-log-discard-and-edit`.
- **15 Sep** — the maintainers merged #2232 (Kotlin `LiftMetrics` twin). Rebased onto it; the twin and its
  oracle now follow `isPerformed`.
- **15 Sep** — #2229 reported that #2099 left parity governance red on `main` (files added without an authority
  refresh; the check never runs on product PRs); #2233 repaired it. Governance tests added to `verify.sh`.
- **15 Sep** — fork cleaned to its exact layout; notes restructured into this handbook.
- **15 Sep** — Utku asked for a target max RPE per program line, as a safety ceiling shown grey in the session
  and imported from the template; built on `lift-log-target-rpe` (stacked on the follow-up).

## What found what

| what was wrong | found by | rule |
|---|---|---|
| session walked back to a skipped machine | gym | 4 |
| completed sets saved no numbers (19 empty sets) | gym | 5 |
| "SET" header wrapped to "SE / T" | gym | shared 34 pt column |
| hidden HR readout read as a missing feature | gym | 6 |
| 45.5 kg stored as 455; `%.1f` rounding | gym | 11, 12 |
| phantom double-tap advance; de-dup caught only consecutive replays | gym, maintainer review | 22 |
| gym rest labelled with the sleep "Rest" key | code reading | 10 |
| weekly bar full and green at the floor | review | 15 |
| set count computed two ways, guards differed | review | 2, 3 |
| no way to log an unplanned set | Utku asked | 17, 18 |
| typing into a pending set was discarded | gym | 19 |
| no way to delete a session | gym | 13 |
| 51 of 205 strings never reached the catalog | pre-PR audit | 20, 21 |
| estimates read as measurements; work-vs-rest informed nothing | Discord review, Utku | 23, 24 |
| uncalled APIs kept alive | audit, parity ledger | 2, 25 |
| template allowed column inserts (inverted protection flags) | checking a claim | a test pins the lock |
| removing a set kept numbers typed into it | audit | 26 |
| grey numbers written in at "set done" had to be typed over | gym | 5, 28 |
| ⊕/⊖ rewrote the program on every tap | gym | 27 |
| a mistyped or missed number could not be fixed after finishing | gym | 30 |
| a double-tap that did not register left no evidence | gym | 29 |
| a saved session missing from the hub until reopened | simulator | 31 |
| a Save that could not be pressed still looked pressable | simulator | dim disabled buttons |
| Skip and Save session saved the same way | gym | 28 |
| a mistaken discard could not be undone; sets not addable/removable after finishing | gym | 30, 32 |
| a set typed as 0 reps still counted | audit | 32 |
| an all-untyped discard filed an empty session with a workout and strain | maintainer review | 32 |
| a session with nothing performed showed an empty list and a wrong message | simulator | 32 |
| typing into a 0 in Edit sets appended to it ("600") | simulator | 30 |
| SQL counted `reps > 0` where Swift counts `reps != 0` | audit | 32 |
| two same-arity `isPerformed` overloads made the twin claim ambiguous | parity ledger | 25 |
| a Swift figure change without its Kotlin twin, once #2232 landed | upstream moving | 33 |
| a product PR left parity governance red on `main` | maintainers (#2229) | 25 |

**Confirmed on hardware:** Lock Screen activity (HR, reps × weight, ticking seconds), carried values across
sessions, spreadsheet import on device, double-tap with confirm and rest buzzes.

**The pattern worth remembering:** the bugs that mattered were silent wrong data that passed every test and
build — a value that looks right on screen while being wrong underneath. A real session catches that; a suite
does not.
