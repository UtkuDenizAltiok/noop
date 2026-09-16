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
- **16 Sep** — he then asked for grey to mean the same for RPE as for weight and reps: a set left unrated saves
  the line's max RPE. Accepted with its cost stated (a stored rating no longer proves he rated that set).
- **16 Sep** — adding a method to the Room DAO interface broke three Kotlin test doubles. The fork's testing
  build stayed green (its Android job assembles the app; it does not compile or run the unit tests), and only
  Android CI caught it — run it on every branch that touches `android/**`.
- **16 Sep** — Python 3.12 installed, so the parity ratchet ran for the first time. It named three new one-sided
  Swift declarations; two were avoidable (a helper and a constant, both inlined) and `deleteLiftSets` got its
  Kotlin twin ported ahead of its consumer. Ratchet errors: 0.
- **16 Sep, later** — upstream's `main` went green again (`8576a2dd`: #2259/#2267 parity-scan fixes, twin maps
  re-derived). On a test merge each branch then failed exactly one way — `twin-map-authority-drift` from its two
  new twin pairs — and the guarded refresh fixed it touching nothing else. So the PR carries that refresh; the
  earlier "leave the JSONs alone" plan only held while `main` itself did not reproduce.
- **16 Sep, 21:20–22:26** — third gym session, on build `4fda4266` (16 sets). Worked: the grey max RPE saved when
  left blank, one Save, discarded sets as 0 / 0 in Edit sets, adding and removing sets there, the orange warning.
  Found: weight → reps still took two taps; one double-tap "skipped two things" and 3–4 did not register; buzzes
  sometimes slightly late; the Lock Screen rest clock counted up past zero. Asked for: the Lock Screen to light on
  a strap step, and the next set instead of "0 of 16 sets". The strap log held only 21:54 onward; in it the strap
  sensed 22 double-taps and all 22 were acted on, two of them knocks 3–4 s after a tap. All six built on
  `lift-log-gym-round-3` the same night, plus typed numbers missing from the bar (found in the simulator).

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
| weight → reps took two taps: the tap-outside gesture took back the focus it had just given | gym | `KeyboardDismiss` |
| a knock 3–4 s after a tap finished a set seconds old | gym, strap console log | 35 |
| the confirming buzz came 1–2.8 s late when the tap's event also kicked a sync | strap log | 36 |
| the Lock Screen rest clock counted up past zero | gym | 38 |
| "0 of 16 sets done" told a lifter nothing to act on | Utku asked | 37 |
| the bar showed the grey plan for a set whose numbers were typed | simulator | 5 |
| an exported strap log had lost the first half hour of the session | log analysis | 29 |

**Confirmed on hardware:** Lock Screen activity (HR, reps × weight, ticking seconds), carried values across
sessions, spreadsheet import on device, double-tap with confirm and rest buzzes; and on 16 Sep the max RPE grey
fill, one Save, discards as 0 / 0 in Edit sets, adding and removing sets there, and the warning before an empty
Save.

**The pattern worth remembering:** the bugs that mattered were silent wrong data that passed every test and
build — a value that looks right on screen while being wrong underneath. A real session catches that; a suite
does not.
