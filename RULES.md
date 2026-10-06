# Rules

The rules for making NOOP better. Break one and the change is wrong, not just different. Each was paid for with a
real bug or settled deliberately; numbers are stable (other pages cite them), so a retired rule is marked, never
renumbered. The app repository's own `AGENTS.md` (read by every AI tool) and `docs/CONTRIBUTING.md` hold upstream's
rules for all code — scope, BLE safety, parity, design tokens, migrations — and are not repeated here. Feature rules
live with their feature: `features/lift-log.md` (Lift Log rules 1–48), `features/live-hr-banner.md`.

## The mandate and ownership (Utku, 24 Sep; renewed 6 Oct 2026)

Make NOOP the best WHOOP companion app: correct, reliable, efficient, optimised, clean and sleek, with biometrics as
close to measured truth as the evidence supports. Improve the whole app and its algorithms, storage, connection,
resource use and user experience. Measure results; never label an unvalidated estimate as a true measurement.

On 6 Oct Utku delegated ownership of the project work to ChatGPT/Codex, including backlog order, product and
technical decisions, architecture, implementation, verification, releases and this handbook. Decide routine matters
and finish the work. Utku supplies real-device observations and feedback; his later instructions remain authoritative.
The durable record is the handbook, not a model's memory or a chat. README describes the current working agreement.

## Settled decisions

- **ChatGPT/Codex decides the project work; Utku gets clear steps.** Make product and technical choices with evidence,
  explain what changed and why, and end every final response with one to three simple numbered next steps. If no
  action is needed from him, say so and identify what comes next. Request his phone, strap, direct observation,
  account approval or data access only when needed. Routine engineering and product choices need no separate
  permission question.
  Record the reason whenever new evidence changes a previously settled choice.
- **One concern per PR, behaviour kept** — unless the PR fixes a proven bug, or improves a result with evidence
  (rules 2, 3). Both platforms wherever both have the code (`AGENTS.md` parity contract), or the PR says why not.
- **Standing permission (Utku, 23–24 Sep 2026):** replies on our own PRs, pushes to our own branches, and opening a PR
  for an improvement this journey is about, once it is verified (`WORKFLOW.md` §3). Anything else public in his name —
  a new issue, a comment on someone else's thread — is asked first.
- **Every app change reaches his phone** as a testing build on his releases page, with "just update" or "wipe and reinstall from zero"
  (`WORKFLOW.md` §6). A change nobody has run on a real strap is not finished; BLE behaviour is only proven there.
- **Fresh start, this installation only (Utku, 6 Oct):** delete NOOP Staging first, then install `6de9d6d`'s unsigned
  IPA with AltStore. This overrides the prior update instruction by choice, not a migration requirement. Future
  sessions must state whether the current build needs just update or wipe/reinstall; do not make deletion routine.
- **Upstream moves fast and is good.** The maintainers merge within hours and often fix the same thing: check
  `upstream-check.sh` and the open issues and PRs before starting, and never duplicate or undo their work. Work they
  already did (#2293 re-scoring, widget/Watch/notification dedup, Today's leaf isolation, the Liquid motion gate) is
  left alone unless measured wrong.
- **Background re-scores at most every 30 minutes (Utku, 28 Sep 2026).** His MetricKit day showed 1 h 36 m of CPU,
  ~20 min of it a 7–9 s re-score after nearly every sync (~every 9 min). While NOOP is in the background a re-score
  runs at most every 30 minutes; opening the app runs one at once; the morning's scores come within ~30 minutes of
  the night ending. Sent upstream as its own PR, which the maintainers may decline; the fork keeps it either way.
- **Lower usage by doing the same work cheaper, never by doing less of it (Utku, 28 Sep 2026, afternoon).** "Don't
  reduce usage just by limiting the actual work NOOP does; achieve better things with lower usage." So an
  optimisation keeps every result and its freshness and makes the computation, the reads or the radio cheaper; a
  change that skips or delays work is a last resort, stated as such to him. He then clarified: the 30-minute re-score
  spacing STAYS (and goes upstream as planned); the point is not to improve the app mainly by that kind of change.
  Also his: work on the biometrics and the strap connection —
  "better than the original WHOOP" — each change with evidence (rules 2, 12).
- **Deep-sleep base prior 0.18 → 0.15 (Utku, 28 Sep 2026, evening): propose upstream and ship to his build.** Evidence:
  PhysioNet sleep-accel PSG, n = 31 (upstream's `Tools/SleepPSG`): kappa up for 21/31 subjects, |deep bias| down for
  19/31, wake and REM untouched; on his four nights deep ~30% → ~27% of sleep. The awake half of #348-A is NOT taken
  (it repeats #437). REM (31–40% of his sleep) needs PSG with heartbeats: a second PhysioNet dataset. Explain its source,
  access requirements and size before a substantial download; obtain any required account agreement from Utku.
  He chose DREAMT (free; he registers, signs
  its data use agreement and downloads it himself — never his credentials in our hands). Datasets live in
  `~/datasets`, never in the repo; a restricted one (DREAMT) is used locally and reported only as aggregates.
- **RSA respiration weight 0.6 → 0.3 (Utku, 30 Sep 2026): propose upstream and ship to his build.** Evidence: DREAMT
  (PSG with the E4's R-R, n = 100, `Tools/SleepPSG` section 8): the breathing-regularity feature separates the stages
  the assumed way (AUC deep–REM 0.658) but at 0.6 moved light epochs into deep and REM; 0.3 raises per-subject kappa for
  61 and lowers it for 28, and matches the weight the separation implies (0.29–0.35). Lower weights and "off" score
  within 0.001 on DREAMT but its deep truth is 3.4 % (a clinical cohort), so 0.3 is where it stops. On his six nights
  REM 31.9 → 29.3 % of sleep. DREAMT is restricted: local only, aggregates only, nothing fitted to its base rates.
- **Two new features, Utku's yes (1 Oct 2026):** (a) **a silent swiped-away reminder** — one local notification,
  fixed identifier, rescheduled ~3 h ahead at every completed sync (and app-state change), delivered with no sound and
  no screen wake (`.passive`), with a Settings switch (**default OFF since 6 Oct**, superseding the original ON choice); it fires only if NOOP stopped syncing (swiped
  away, or the strap away 3 h) and says so plainly. iOS only: Android's foreground service survives a swipe. (b) **The
  iOS deleted-sleep list, like Android's (#515)** — deleted nights listed with "bring back" (`allowSleepReDetection` +
  re-score) and hide; on iOS a deleted night could only be undone for a few seconds. Both upstream as separate PRs;
  the fork keeps them either way. Default-OFF reason: a battery-alert permission grant does not opt a user into a new recurring sync reminder; explicit saved ON/OFF choices survive updates.
- **Android is tested on GitHub, not on the Mac; the fork keeps all of upstream's checks (Utku, 28 Sep 2026).** He
  declined installing the Android SDK locally and switching off the fork's copy of Parity Governance CI. So: Android
  CI on the fork for every Kotlin change, and he is told BEFORE any run that is meant to fail (each failure emails
  him); a failure email caused by upstream's own drift is explained, not silenced.
- **A Live HR banner iOS has ended is removed, not left frozen** (3 Oct 2026, #2659): it can only show its last
  number, and rule 49 (`features/live-hr-banner.md`) allows a heart rate only while the strap measures it.
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
