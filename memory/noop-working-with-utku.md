---
name: noop-working-with-utku
description: "Utku is not a programmer: plain words, I decide technical questions, he owns what users see and feel, tests on his WHOOP 5.0 + iPhone; tests are numbered steps ending with the strap log; say what a log can and cannot prove; build requests as narrow as worded."
metadata:
  node_type: memory
  type: feedback
  originSessionId: ed340050-008d-44ae-be66-66b9c198334f
  modified: 2026-10-01T11:00:00.000Z
---

Utku Deniz Altiok owns the product and tests it on his own WHOOP 5.0 and iPhone. He does not read code or use the
terminal; I write all code, run all tools and explain in plain language. His product judgement has corrected mine many
times — treat it as authoritative — and he wants technical questions decided by me, reviewers verified rather than
obeyed.

**Why:** he can check outcomes, not code; every time I explained plainly and showed evidence, he caught real problems
(a banner that closed itself, "91" frozen after the strap came off, a timing I could not have known).

**How to apply:**
- Anything that changes what a user sees or how a feature behaves: explain it plainly first; he can say no. He
  reversed his own request once (the banner: "if it can re-open it, it shouldn't close") after living with it — that
  is normal, record the reversal.
- Build a request exactly as narrow as he words it; a general mandate (24 Sep: optimise all of NOOP) still means one
  concern per PR.
- A test for him is numbered steps with what he should see, ending with More → Test Centre → Strap log → Save…; ask
  him to note the times. A log proves what NOOP did and when; only his eyes prove what iOS drew. Say so plainly.
- Every step in a test must describe behaviour I have seen work (simulator or code path), never a guess about the UI:
  on 24 Sep three of my steps were wrong (no ring-tap vibration on his phone, no pull-to-sync on Today, night stars
  too faint to see) and he had to report that "nothing is wrong, but it is not as you say".
- When his reading of evidence differs from mine, re-read it fully, then show exact lines and a search he can repeat.
  He pushes back hard when a claim looks unproven — answer with what is proven and what is not.
- Never delete his things (his strap logs in ~/Downloads) or touch his comments without asking.
- He cannot keep records of taking the band off or swiping NOOP away (1 Oct: "you decide"): read those gaps from
  the strap log (WRIST_OFF, app runs), never ask him to log them; design for both as normal use.
- When he says "you decide", decide and say what was decided in one line (1 Oct: the handbook history scrub).
- Nothing personal on the public handbook branch, however mild (per-night times or HR, where he sleeps): numbers as
  aggregates only; check a commit before it goes public, and fix a slip at once.

See [[noop-project]].
