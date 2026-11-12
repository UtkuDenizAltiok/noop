# Rules

The rules for making NOOP better. Break one and the change is wrong, not just different. Each was paid for with a
real bug or settled deliberately; numbers are stable (other pages cite them), so a retired rule is marked, never
renumbered. The app repository's own `AGENTS.md` (read by every AI tool) and `docs/CONTRIBUTING.md` hold upstream's
rules for all code — scope, BLE safety, parity, design tokens, migrations — and are not repeated here. Feature rules
live with their feature: `features/lift-log.md` (Lift Log rules 1–48), `features/live-hr-banner.md`.

## Authority and communication

Utku delegates project ownership to ChatGPT/Codex (6–7 Oct 2026): priorities, product/technical choices,
implementation, verification, cleanup, documentation, releases and the full PR lifecycle. Decide routine matters and
finish the work. Prioritise correctness/data integrity, efficiency with unchanged results, evidence-backed biometrics
and clear design. The handbook is the durable memory; Utku's later instructions prevail.

Explain plainly and end every final response with one to three simple numbered next steps. If no action is needed,
say so and name the next work. Request phone/strap evidence, account approval or data access only when needed.
Record the reason when a settled decision changes. Upstream maintainers decide what they merge.
Utku clarified on 7 Oct: give concrete, simple actions and the exact answer needed when asking him to decide;
keep technical investigation and storage choices with the agent unless his input is actually required.
Utku reiterated on 9 Oct: use normal everyday language. Avoid polished AI phrasing and unexplained technical terms.
Utku clarified on 8 Oct after the Stress update: explain what changed, why it matters and what he should actually
notice. A preventive repair may look the same; say so and give a concrete example of the avoided failure. Phone
instructions must name the exact navigation/actions, expected result and evidence needed. Avoid shorthand such as
"leave and return"; distinguish navigating away from closing the app. Do not repeat a completed observation or
request an export without a defined need. Give enough explanation to understand the change, not just a short result.

## Settled decisions

- **Session roles (Utku, 9 Oct 2026).** Start prepares a new chat from saved evidence, finishes eligible carryover
  and PR follow-up, then waits for his next prompt. It does not select new improvements. Deep improvement authorizes
  independent research, prioritization and complete delivery of one bounded improvement in the prepared chat.
  Deep search researches and saves a recommendation. Finish completes active work and essential existing obligations
  before handover; it does not abandon a feasible task or clear the backlog. Genuine blockers/limits and explicit
  deferrals stay honest. [Sessions](SESSIONS.md) owns the exact prompts and procedures; do not duplicate them elsewhere.
- **English only; language (translation) improvements are lowest priority (Utku, 8 Oct 2026, session close; plain
  English wording is in scope since 5 Nov, see below).** He does not
  care about other languages and does not want tokens spent fixing languages. Do not select translation
  or locale cleanup as the bounded improvement (plain English wording is a priority since 5 Nov), or expand/repeat locale QA. Prioritize correctness, biometrics,
  strap reliability and measured efficiency under the mandate above. Handle mandatory upstream resource/parity
  requirements only as necessary for a prioritized functional change. Preserve the already-saved Stress wording
  branch at lowest priority; its pending state lives in State, not an implied instruction to finish it next.
- **The main focus is a human-friendly NOOP (Utku, 4–5 Nov 2026).** He finds the app chaotic, complex and hard to
  understand ("AI slop"). Make it easy to use and easy to understand, thinking like a physician, a fitness expert
  and a technologist, without losing data or anything important (Simple mode switch: Simple ↔ full app). Three
  equal parts: (1) **simple UI** (show each fact once, in reading order, advanced things one tap away); (2) **plain
  wording**: every label, subtitle, explanation and message in everyday English a first-time wearer understands,
  saying what a number means and what to do, with no internal jargon. Not too short (Utku, 5 Nov): never cut an
  explanation down until the meaning is lost. Optimise and humanise: keep every fact a wearer needs (what it is,
  how it is measured in a sentence, what is good, what to do), in warm, clear sentences; shorten by removing jargon
  and repetition, not understanding; (3) **fix what is wrong** in measurement,
  biometrics, sensor reading, interpretation, maths, methods, battery or efficiency, but only with verification or
  proof (cite the method, test it; Rules 1–3), and send generally useful fixes upstream as their own small PRs.
  "Language is not important" (5 Nov) means TRANSLATIONS: do not spend effort on other locales beyond what the CI
  gate requires. Plain ENGLISH wording is in scope and a priority. Project home:
  [`features/simple-mode.md`](features/simple-mode.md) ("Start here").
- **Full authority, do not ask (Utku, 5 Nov 2026).** "You are the god of this project": decide, implement, test,
  push, open upstream PRs and deliver phone builds without asking for permission. If a tool or safety check blocks
  an action, use a safe alternative or tell him exactly which setting to change on his Mac. Test hardware he can
  use on request: WHOOP 5.0 and an iPhone 16 Plus (AltStore, "just update").
  Reiterated 6 Nov: "You should have full access and authorization so don't ask me permission! You are the full
  owner." Do not put routine choices to him as questions. Claude Code's own safety check is separate: on 6 Nov it
  refused `gh pr create`, `gh pr close`/`reopen` on our PRs and the Auto-fix switch until he said yes in chat.
  When it blocks, explain the block once in plain words and name the permission rule that would allow it;
  never try to work around it.
- **Utku is not a coder (his words, 12 Nov 2026).** "I am not a coder and not a frequent GitHub user… it's your
  job and decision to do what is needed." So: never give him a building, Git or GitHub choice, and never report
  in those terms. Decide and do it. Ask him only for what he can see or feel (the phone, the strap, a strap
  log) or for one plain click when only his account can do it ("open this page and tell me what it says"). He
  starts testing only after being told plainly that the build is ready. The architect also reviews, stacks,
  verifies and ships the phone build itself (he answered "Yes, build it"); only app code goes to workers.
- **Architect and workers (Utku, 12 Nov 2026).** The most capable model in the chat (Claude Fable 5.2 on
  12 Nov) is the architect: it researches, checks earlier work, decides the roadmap, writes the design and the
  worker briefs, and reviews what comes back. It does not write app code. **Opus 5.5 worker chats implement**,
  one brief each, on the branch the brief names, and hand back a pushed, verified branch with an honest list of
  what could not be verified and where they left the brief. Nothing reaches the testing stack or the phone
  before the diff has been read against its brief. Briefs live in the handbook next to their design
  ([Simple mode](features/simple-mode.md), [High heart rate warning](features/high-hr-warning.md)); the
  prompts are in [Sessions](SESSIONS.md). "Codex/ChatGPT" in older entries means whichever agent runs the chat.
- **High heart rate warning (Utku, 12 Nov 2026).** The wearer sets a heart rate and a duration (his example:
  110 bpm for 90 s); while the average over that time is above the limit the strap buzzes twice every 5 s. An
  average, so a wrong reading neither starts nor stops it. A switch the wearer turns on and off, default off.
  Design, decisions and the phone checks: [`features/high-hr-warning.md`](features/high-hr-warning.md).
- **No new upstream PRs while upstream is quiet (architect, 12 Nov 2026).** Upstream's last merge was 25 Oct
  and none of our 17 open PRs has a maintainer reply. More PRs, or more close-and-reopen CI retries, would only
  add notifications. Work goes to the fork and the phone; ready upstream fixes wait in the Simple mode diary.
  Lift this the first time a maintainer answers. "Upstream moves fast" below describes September–October.
- **Hidden is not removed only when it is one tap away (architect, 12 Nov 2026).** A Simple-mode screen may hide
  a card or a tool only if the same screen offers "Show everything on this screen". Sending the wearer to the
  app-wide Simple mode switch to reach a working tool (PDF export, filters, merge, sleep marks) counts as
  removing it (finding F15).
- **The Lift Log stays fully available in Simple mode (Utku, 6 Nov 2026, night).** It is his own feature (gym
  sessions with records and taps, which he built and got merged upstream). Simple mode must never hide, shorten or
  restyle any part of it: the More → Training entry, the whole `LiftLogView`, the active-session bar, its Lock
  Screen session switch and the lifting-friendly Effort switch stay as they are in both modes. Checked 6 Nov; a
  guard test is queued ([Simple mode → Start here](features/simple-mode.md#start-here-next-chat)).
- **Keep the whole project simple without reducing quality (Utku, 8 Oct 2026).** This applies to code, files,
  documentation, workflows and instructions. One authoritative home per subject; link to it rather than ask Utku
  to save another copy. Preserve practical usage, setup and contribution guides. Consolidate duplication and remove
  proven obsolete or unrelated material after checking references, current implementation and retained rationale;
  file count or age alone is not evidence that a document is unnecessary.
- **One concern per PR, behaviour kept** — unless the PR fixes a proven bug, or improves a result with evidence
  (rules 2, 3). Both platforms wherever both have the code (`AGENTS.md` parity contract), or the PR says why not.
- **Standing permission (Utku, 23–24 Sep 2026):** replies on our own PRs, pushes to our own branches, and opening relevant verified PRs
  and their complete review/fix cycle (explicitly renewed 7 Oct) (`WORKFLOW.md` §3). Anything else public in his name —
  a new issue, a comment on someone else's thread — is asked first.
  **7 Oct specific approval:** publish the verified deleted-sleep backup report and decide/handle its follow-up.
  Do not repeat approval requests for that report or its agreed repair.
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
