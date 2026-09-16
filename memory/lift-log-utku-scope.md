---
name: lift-log-utku-scope
description: "Utku keeps Lift Log changes minimal and inside the feature: no changes to upstream fundamentals such as logging, and features built exactly as narrow as he describes (e.g. the Lock Screen light-up)."
metadata:
  type: feedback
---

Stated 17 Sep 2026 after a gym session.

- **No changes to upstream fundamentals.** "No change in the log code we are not going to change other
  fundamentals" — the strap log's content, rate and buffer are upstream's. Don't propose changing them, and don't
  propose upstream issues about them.
- **Build a request as narrow as he words it.** The Lock Screen light-up is "just light up" a dark locked screen,
  then dark again on the phone's timer: no vibration, no extra updates, no delay, no extra logic.
- **When his reading of evidence differs from mine**, re-read it fully first, then show him the exact line
  numbers and a search he can do himself; he reads the files and pushes back hard when a claim looks wrong.
  (17 Sep: he read the strap log as 13:08–22:44 complete; the file jumps from line 1654 at 21:15:05 to line 1656
  at 21:54:01.)

**Why:** he owns the product, tests on the phone, and wants the fork to stay close to upstream so the PRs merge.

**How to apply:** before adding anything outside `Lift*` files, ask whether it changes upstream behaviour; if it
does, only do it when he asked for exactly that.

See [[noop-lift-log-project]], [[lift-log-verify-before-claiming]].
