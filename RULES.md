# Rules

The rules for changing NOOP. Break one and the change is wrong, not just different. Each was paid for with a real
bug or decided deliberately by the owner, Utku. Engineering rules keep their numbers (other pages cite them). The
app's own `AGENTS.md` and `docs/CONTRIBUTING.md` hold the code rules (scope, BLE safety, parity, design tokens,
migrations) and are not repeated here. Feature rules live with their feature in `features/`.

## Working with the owner

- **The agent owns the work.** Utku gives full authority over priorities, product and technical choices,
  implementation, verification, documentation and releases ("you are the full owner", 5–6 Nov 2026). Decide routine
  matters and finish the work; do not put routine choices to him as questions.
- **He is not a programmer** (12 Nov). Never give him building, Git or GitHub choices and never report in those
  terms. Ask him only for what he can see or feel on the phone or the strap, or for one plain click only his account
  can do ("open this page and tell me what it says"). Tell him plainly when a build is ready before he tests it.
- **Plain everyday language** (7–9 Oct). Explain what changed, why it matters and what he will actually notice; a
  preventive repair that looks the same says so with a concrete example. Phone instructions name the exact taps,
  the expected result and the evidence needed. End every final answer with one to three simple numbered next steps;
  if none is needed, say so and name the next work.
- **Files only when he offers them** (27 Nov). Do not ask for a developer file, backup or strap log until he offers
  one. When he reports something from the phone, that is fixed first (Engineering rule 12).
- **From 27 Nov 2026 he wears the strap for about two weeks without prompting**, after a fresh start with NOOP
  13.0.0 (delete the app, install the final build, no backup restored). Later builds are "just update" (Workflow).
- **The agent may be anyone.** The next session may be Claude, ChatGPT/Codex, Gemini or a person: everything needed
  to continue is in this handbook and the app's `AGENTS.md`, never in one tool's private memory.
- **Hand over before the session is full** (16 Nov): finish the change in hand completely (verified, shipped),
  do not start another late in a long session, and leave State so the next session continues without guessing.
- **Keep building; do not wait for his test** (16 Nov). Steps follow one another; what he reports comes first.

## Settled decisions

- **NOOP 13 is its own project (Utku, 27 Nov 2026).** His words: the original repository "is not active anymore...
  I don't want to be connected to the main one. I want to have this as an own project, but don't remove anything."
  So: version 13.0.0 on both platforms (NOOP 12.0.0 was the last original release); `main` is the product; the
  original repository is not synced, and nothing new is sent there; its license (PolyForm Noncommercial 1.0.0) and
  every credit stay. Our 17 pull requests on the original repository are left as they are (not closed, not
  updated). Work that used to wait for the original maintainers (the F-fixes for the full view, the Android twin
  of Simple mode) is now ordinary NOOP work (Backlog).
- **A human-friendly NOOP is the main focus (4–5 Nov).** Three equal parts: (1) a simple UI: each fact once, in
  reading order, advanced things one tap away; (2) plain English wording a first-time wearer understands, never
  cut until the meaning is lost; (3) fix what is wrong in measurement, biometrics, maths, battery or efficiency,
  only with verification (Engineering rules 1–3).
- **Simple mode is the most user-friendly NOOP, not a shorter one (14 Nov).** The measure is understanding: a
  first-time wearer knows what a screen says, whether it is good for them and what to do. Removing is not the
  method: information stays, ordered by need, compared with the wearer's own normal, explained one tap away.
  Four viewpoints decide every screen: fitness coach (what to do today and this week), exercise physiologist (what
  a signal measures and how much it varies), doctor (what is a warning, what is normal variation; never alarm or
  reassure beyond the evidence), software developer (one name per thing, consistent, fast, nothing lost).
- **Hidden is not removed only when it is one tap away (12 Nov).** A Simple-mode screen may hide a card or a tool
  only if the same screen offers "Show everything on this screen".
- **The Lift Log stays fully available in Simple mode (6 Nov).** Never hide, shorten or restyle any part of it.
- **Unscientific or half-thought things are fixed too (15 Nov)**, still under Engineering rules 2–3.
- **Measurement correctness for a WHOOP 5.0 is a standing priority (26 Nov).** The developer loop (the morning
  check-in and the developer file, `features/lab.md`) is the developer's instrument: read his file when he offers
  it and let it drive fixes, data health first.
- **Sleep must be scientific and realistic; never invent (27 Nov).** Every sleep time or figure follows a cited
  method measured against data whose truth moves (PSG: `Tools/SleepPSG`); a limit the wrist cannot overcome (quiet
  wakefulness reads as sleep) is said plainly; where only the wearer can know, NOOP asks (the check-in's
  correction, the nap question). Brief wakes stay inside the night; the final awakening is the night's end.
- **Steps: the iPhone is not always carried (27 Nov).** The phone may calibrate the strap's count but is never the
  source of daily steps; days without the phone change nothing.
- **High heart rate warning (12 Nov):** a switch, default off; the wearer sets a heart rate and a duration; while
  the average over that time is above the limit the strap buzzes twice every 5 s (`features/high-hr-warning.md`).
- **Background re-scores at most every 30 minutes (28 Sep).** Opening the app runs one at once.
- **Lower usage by doing the same work cheaper, never by doing less of it (28 Sep).** An optimisation keeps every
  result and its freshness; skipping work that produces nothing shown is fine (Rule 4), cutting results is not.
- **Evidence decisions on sleep staging:** deep-sleep base prior 0.15 (PhysioNet sleep-accel, 28 Sep); RSA
  respiration weight 0.3 (DREAMT, 30 Sep); persistent onset and wake rescoring (27 Nov); details in History and
  the code's doc comments. DREAMT is restricted: the owner registers and downloads it himself (never his
  credentials in an agent's hands); it is used locally and reported only as aggregates.
- **Android is tested on GitHub, not on the Mac (28 Sep).** Android CI on the repository for every Kotlin change;
  a run meant to fail is announced to Utku first (each failure emails him).
- **Keep the whole project simple without reducing quality (8 Oct).** One authoritative home per subject; remove
  proven-obsolete material after checking references, keep practical guides.
- **English first; translations at the lowest priority (8 Oct).** New strings still get all nine locales because
  the gates require them; no other locale work.
- **Smaller standing decisions:** a silent "NOOP stopped syncing" reminder exists, default off (1 Oct); the iOS
  deleted-sleep list with "bring back" (1 Oct); a Live HR banner iOS has ended is removed, not left frozen (3 Oct);
  the Lift Log and the Live HR banner are finished features (24 Sep): an optimisation keeps every rule on their pages.

Superseded and kept only in the private history: the architect/worker chat split (12 Nov), "no new upstream pull
requests while upstream is quiet" (12 Nov), "upstream moves fast" (Sep–Oct), the October session roles and their
prompts, the 6 Oct one-off fresh start, the September permissions for replying on upstream pull requests.

## Engineering rules

1. **Measure before and after; a usage claim without a number is not made.** CPU seconds a minute (simulator
   `ps`), memory footprint, pushes and wakes counted from the strap log, iOS's own MetricKit day report (#2420),
   Bluetooth traffic counted from the log. Workflow → Measuring says how.
2. **A physiological number changes only with evidence that it gets closer to the truth.** Recovery, strain, HRV,
   sleep, resting HR, SpO2, respiration: cite the method, test it against recordings where the true value MOVES
   (more than one night, more than one person; a single "matched WHOOP" night is not validation), and land it first
   as instrumentation or a default-off Experimental switch when the evidence is thin. Swift and Kotlin stay
   byte-identical, proven by an oracle run (Workflow → Parity), never by reading.
3. **Silent wrong data is the worst bug NOOP can have.** It passes every test and looks right on screen: 45.5 kg
   stored as 455, a set saved with no numbers, a banner showing a number the strap never measured, a 500 ms filler
   stored as a heartbeat (#2371). Test the edges; a figure computed in two places must agree, pinned by a test.
4. **Nothing runs for nothing.** No timer that ticks when nothing changes, no `@Published` that changes on a timer,
   no screen that watches more than it draws. Every wake of the phone and every radio exchange costs battery on both
   devices: batch, coalesce or skip it. A paused animation is not a still view (#2444): draw the resting frame with
   no timeline.
5. **What must work in the background is wired at process start, never from a screen.** iOS restarts NOOP in the
   background and may build no view at all.
6. **Never read another object's derived state inside a `@Published` sink.** It runs in willSet and sinks run in no
   promised order (#2437). Pass the value being written, or read once the change has landed.
7. **iOS suspends NOOP between Bluetooth events.** A suspended app's timers fire only at its next wake; prove
   background behaviour from the strap log, not from the simulator.
8. **A diagnostic asserts only what it can attribute; rare events stay always-on.** Per-connection readouts go
   behind the Test Centre; a state change or a mismatch leaves a line. Removing a line that once identified a bug
   needs a replacement.
9. **Dead code goes only with proof:** no reference on either platform, no framework callback, no entry point that
   was simply never built.
10. **Stored data is a contract.** A schema change is a new migration with its Room twin and a test, never an edit;
    the `.noopbak` whitelist is byte-identical on both platforms.
11. **Name test helpers unlike any production function:** the parity ledger pairs calls by name and arity.
12. **Real use finds what matters.** Strap logs and real days found every bug that mattered; a list written from
    reading code predicted almost none. Ask what happened before trusting any list.

## Sources

Behind the sleep need: Hirshkowitz et al., National Sleep Foundation, Sleep Health 2015; Watson et al., AASM and
SRS consensus, 2015; Kitamura et al., Sci Rep 2016. Steps: Paluch et al., Lancet Public Health 2022. Activity: WHO
2020 guidelines (Bull et al.). Intensity from heart rate: ACSM's Guidelines, 10th ed., 2018. Sleep regularity:
Phillips et al., Sci Rep 2017; Windred et al., Sleep 2024; Fischer et al., Sleep 2021. Wake rescoring: Webster et
al., Sleep 1982 (parameters as restated by Fisher, arXiv 2104.14291). Sleep norms: Ohayon et al., Sleep 2004.
Wrist actigraphy limits: Marino et al., Sleep 2013. Lift Log counting: `features/lift-log.md`. New physiology is
cited in the commit that uses it and added here.
