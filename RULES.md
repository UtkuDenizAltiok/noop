# Rules

The rules for making NOOP better. Break one and the change is wrong, not just different. Each was paid for with a
real bug or settled deliberately; numbers are stable (other pages cite them), so a retired rule is marked, never
renumbered. The app repository's own `AGENTS.md` (read by every AI tool) and `docs/CONTRIBUTING.md` hold upstream's
rules for all code — scope, BLE safety, parity, design tokens, migrations — and are not repeated here. Feature rules
live with their feature: `features/lift-log.md` (Lift Log rules 1–48), `features/live-hr-banner.md`.

## The mandate (Utku, 24 Sep 2026)

"Improve and optimise the whole NOOP app itself. It must be perfect, optimized, clean, sleek, efficient, fast and low
usage — low memory, RAM, CPU, GPU, battery — for both the WHOOP band and the iPhone. The code should be efficient, not
bloated, and clean. If you can improve any algorithms, biometrics mathematics, calculations or features or logic of
any feature, go for it. More robust and reliable than WHOOP itself: the best app for WHOOP bands." He made me the
owner and decider of this journey.

## Settled decisions

- **I decide the technical questions; Utku owns what he sees and feels.** He is not a programmer, tests on his own
  WHOOP 5.0 and iPhone, and his product judgement has corrected the engineering many times. Anything that changes what
  a user sees, or how a feature behaves, is explained to him in plain words first, and he can say no.
- **One concern per PR, behaviour kept** — unless the PR fixes a proven bug, or improves a result with evidence
  (rules 2, 3). Both platforms wherever both have the code (`AGENTS.md` parity contract), or the PR says why not.
- **Standing permission (Utku, 23–24 Sep 2026):** replies on our own PRs, pushes to our own branches, and opening a PR
  for an improvement this journey is about, once it is verified (`WORKFLOW.md` §3). Anything else public in his name —
  a new issue, a comment on someone else's thread — is asked first.
- **Every change reaches his phone** as a testing build on his releases page, with "just update" or "wipe"
  (`WORKFLOW.md` §6). A change nobody has run on a real strap is not finished; BLE behaviour is only proven there.
- **Upstream moves fast and is good.** The maintainers merge within hours and often fix the same thing: check
  `upstream-check.sh` and the open issues and PRs before starting, and never duplicate or undo their work. Work they
  already did (#2293 re-scoring, widget/Watch/notification dedup, Today's leaf isolation, the Liquid motion gate) is
  left alone unless measured wrong.
- **The Lift Log and the Live HR banner are finished** (24 Sep 2026). Their pages list what they rely on; an
  optimisation touching their code keeps every rule there.

## Engineering rules

1. **Measure before and after; a usage claim without a number is not made.** CPU seconds a minute (simulator `ps`),
   memory footprint, pushes and wakes counted from the strap log, iOS's own MetricKit day report on his phone (#2420),
   Bluetooth traffic counted from the log. The before-and-after goes into the PR. `WORKFLOW.md` §11 says how.
2. **A physiological number changes only with evidence that it gets closer to the truth.** Recovery, strain, HRV,
   sleep, resting HR, SpO2, respiration: cite the method, test it against recordings where the true value MOVES (more
   than one night, more than one person — `AGENTS.md`: a single "matched WHOOP" night is not validation), and land it
   first as instrumentation or a default-off Experimental switch when the evidence is thin. Swift and Kotlin stay
   byte-identical, proven by an oracle run (`WORKFLOW.md` §4), never by reading.
3. **Silent wrong data is the worst bug NOOP can have.** It passes every test and build and looks right on screen:
   45.5 kg stored as 455, a set saved with no numbers, a banner showing a number the strap never measured, a 500 ms
   filler stored as a heartbeat (#2371). Test the edges, and a figure computed in two places must agree, pinned by a
   test.
4. **Nothing runs for nothing.** No timer that ticks when nothing changes, no `@Published` that changes on a timer, no
   screen that watches more than it draws (Lift Log rule 43: iOS killed NOOP for background CPU when one did). Every
   wake of the phone and every radio exchange with the strap costs battery on both: batch, coalesce, or skip it.
   **A paused animation is not a still view:** a `TimelineView(.animation(paused: true))` kept the render server busier
   than the animation itself (the sky 22 → 46 CPU-s/min; the header sync ring 15–51 → 0.07 drawn still; #2444). Draw
   the resting frame with no timeline, and pick the view rather than pausing the clock; a census now enforces it.
5. **What must work in the background is wired at process start, never from a screen.** iOS restarts NOOP in the
   background and may build no view at all (Lift Log rule 41; the Live HR banner, #2422).
6. **Never read another object's derived state inside a `@Published` sink.** It runs in willSet, and sinks on one
   publisher run in no promised order: the Live HR banner read AppModel's old median and missed the strap's WRIST_OFF
   (#2437). Pass the value being written, or read once the change has landed.
7. **iOS suspends NOOP between Bluetooth events.** A suspended app's timers fire only at its next wake; only a
   notification, a connect or a disconnect wakes it. Design for that, and prove background behaviour from the strap
   log, not from the simulator.
8. **A diagnostic asserts only what it can attribute; rare events stay always-on** (`AGENTS.md`). Per-connection
   readouts go behind the Test Centre; a state change or a mismatch leaves a line. Removing a line that once
   identified a bug needs a replacement.
9. **Dead code goes only with proof**: no reference on either platform, no framework callback (Bluetooth, scene,
   App Intents, HealthKit), no entry point that was simply never built. The first cleanup (#2417, 707 lines) was
   welcomed.
10. **Stored data is a contract.** A schema change is a new migration with its Room twin and a test, never an edit;
    the `.noopbak` whitelist is byte-identical on both platforms (`AGENTS.md`).
11. **Name test helpers unlike any production function** — the parity ledger pairs calls by name and arity, and a
    test's `run(at:)` once failed governance in a package the branch never touched.
12. **Real use finds what matters.** Strap logs and Utku's days found every bug that mattered in the last journey;
    a list written from reading code predicted almost none. Ask what happened before trusting any list.

## Sources

- Resistance-training dose–response meta-regression (Sports Medicine, 2025) and the hypertrophy umbrella review
  (Frontiers, 2022) — behind the Lift Log's counting (`features/lift-log.md`).
- Research for new physiology is cited in the PR that uses it, and added here once merged.
