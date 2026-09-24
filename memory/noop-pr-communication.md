---
name: noop-pr-communication
description: "On our upstream PRs: answer a GitHub comment with ONE reply posted after it; put self-found or off-GitHub changes into an edit of the description; simple clear words; standing permission covers replies, pushes and verified PRs for the journey — a new issue or a comment elsewhere is asked first."
metadata:
  node_type: memory
  type: feedback
  originSessionId: ed340050-008d-44ae-be66-66b9c198334f
  modified: 2026-09-24T12:36:18.079Z
---

Utku's rule (13 Sep 2026, after I got it wrong twice): a thread must read in logical order — a question, then its
answer — so the maintainer can follow and accept the PR easily.

**Why:** piling on "update" comments, or moving review answers into the description, made threads hard to follow.

**How to apply — two cases, never mixed:**
1. **Someone comments or reviews on GitHub** → ONE concise reply posted after it, covering only their points, citing
   commits (24 Sep: ryanbr's #2422 review got one reply with the next step for each of his two points).
2. **A change I found myself, or feedback from outside GitHub** (Utku's test, a tool) → EDIT the description (24 Sep:
   #2437's hardware result went into its description). No new comment.

The description describes the PR as it is now, in simple, clear words (Utku, 21 Sep): what changed and why, as a user
would say it, then the technical notes. Standing permission (23–24 Sep): replies on our PRs, pushes to our branches,
and opening a verified PR for this journey's work. A new issue or a comment on someone else's thread needs his yes.
Never touch Utku's own comments.

See [[noop-project]].
