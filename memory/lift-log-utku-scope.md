---
name: lift-log-utku-scope
description: "Utku: the Lift Log is an addition built from NOOP's own features (strap log, buzz, double-tap), no Lift-Log-only copies; no changes to upstream fundamentals such as logging; requests built as narrow as he words them."
metadata:
  type: feedback
---

Stated 17 Sep 2026 after a gym session.

- **The Lift Log is an addition to NOOP.** Use NOOP's own features — its one strap log, buzz, double-tap, workouts,
  design tokens — never a Lift-Log-only copy of something NOOP already has, unless strictly necessary (and then
  say why). He worried a "strap log thing" I built was a separate log; it was only a handbook script reading
  NOOP's normal export, and the Lift Log's lines already go into NOOP's log — explain such things plainly up front.
- **Keep the Lift Log's own Lock Screen banner as it is.** He likes how it looks and works (17 Sep); don't merge it
  into NOOP's heart-rate banner. Explain design trade-offs in plain words — he did not follow "Live Activity" talk.

- **No changes to upstream fundamentals.** "No change in the log code we are not going to change other
  fundamentals" — the strap log's content, rate and buffer are upstream's. Don't propose changing them, and don't
  propose upstream issues about them.
- **Build a request as narrow as he words it.** The Lock Screen light-up is "just light up" a dark locked screen,
  then dark again on the phone's timer: no vibration, no extra updates, no delay, no extra logic.
- **When his reading of evidence differs from mine**, re-read it fully first, then show him the exact line
  numbers and a search he can do himself; he reads the files and pushes back hard when a claim looks wrong.
  (17 Sep: he read the strap log as 13:08–22:44 complete; the file jumps from line 1654 at 21:15:05 to line 1656
  at 21:54:01. The cause, traced in `LiveState`: an app restart at 21:20:24 plus the running app's 5,000-entry
  cap — `dist/tools/strap-log.py` shows it. He then asked for every finding to live in the handbook so anyone,
  on any machine or AI tool, can continue.)

**Why:** he owns the product, tests on the phone, and wants the fork to stay close to upstream so the PRs merge.

**How to apply:** before changing anything outside the Lift Log's own files, ask whether it changes upstream
behaviour; do it only when it answers something he reported, and say so (the one such change so far: `FrameRouter`
hands a double-tap on before its sync kick, for his late buzzes — `dist/RULES.md` 36).

See [[noop-lift-log-project]], [[lift-log-verify-before-claiming]].
