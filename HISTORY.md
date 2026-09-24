# History

One line per event: what happened, what it found, the rule it produced. The lessons themselves live in `RULES.md` and
`WORKFLOW.md`; the detailed day-by-day record of the first journey is in this branch's git history before 24 Sep 2026
(`git log --before=2026-09-25 -- HISTORY.md` on the `handbook` branch).

## Journey 1 — the Lift Log and the Live HR banner (2–24 Sep 2026), finished

A gym log book built into NOOP for Utku, then the heart-rate Lock Screen banner. Seven gym sessions and nine strap logs
found every bug that mattered; each fix went upstream to `ryanbr/noop`, whose maintainers merged within hours:
- **9 Sep** #2029 catalog hygiene — the first contribution.
- **14–15 Sep** #2098 the Lift Log's storage (migration `v46-lift-log`, Room twin), #2099 the app; the maintainers added
  #2232 (Kotlin `LiftMetrics` twin) and #2233 (a parity repair our merge had needed).
- **22–23 Sep** #2386 strap log kept on disk within 2 MB; #2402 the standard-HR log line summarised; #2403 Lift Log
  rounds 3–6 (finish flow, max RPE, knock guard, restart survival, no work between taps, the Dynamic Island).
- **23 Sep, NOOP itself:** #2415 Live HR banner pushed only on change; #2416 manual workout one sample a second;
  #2417 707 lines of unused private code removed; #2418 the stress check-in takes each R-R packet once.
- **24 Sep** #2422 merged: live heart rate only while the strap measures it; the banner kept until its switch, "–"
  otherwise (Utku's decision after living with both versions); ryanbr's review answered. Utku's tests on the phone
  confirmed every case but one; the strap's WRIST_OFF dash waited ~2 min for iOS — fixed in **#2437** the same hour
  (a sink read another object's state inside a willSet: `RULES.md` 6), confirmed on his phone at 13:48.
- **Open at the close:** #2419 (Live notifications: one switch each), #2420 (MetricKit reports into the strap log),
  #2437.

The pattern worth remembering: the bugs that mattered were silent wrong data that passed every test and build — a
value that looks right on screen while being wrong underneath. A real session catches that; a suite does not
(`RULES.md` 3, 12). What found each Lift Log bug: `features/lift-log.md`.

## Journey 2 — NOOP, perfected (from 24 Sep 2026)

- **24 Sep, ~14:15** — Utku opened it: the whole of NOOP perfect, optimised, low usage on phone and strap, better
  algorithms and biometrics than WHOOP, clean code; me as owner and decider. The handbook was reorganised for it
  (branches `handbook`, `testing-stack`, `testing-build`; `RULES.md`, `WORKFLOW.md`, `BACKLOG.md` rewritten; the two
  finished features moved to `features/`). First survey: a 500 ms R-R filler stored as a real beat on WHOOP 5 (#2371)
  leads the backlog; half of all history syncs are an automatic follow-up that finds nothing.
