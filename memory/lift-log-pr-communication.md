---
name: lift-log-pr-communication
description: "On the Lift Log PRs, answer a GitHub comment with a reply posted after it; put self-found or off-GitHub changes into an edit of the description; keep everything short and never touch or delete others' comments."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-15T10:59:23.738Z
---

Utku's rule for ryanbr/noop #2098/#2099, stated 13 Sep 2026 after I got it wrong twice in one day (first
piling on update comments, then moving review answers into a "Changes since review" section of the
description).

**Why:** a thread must read in logical order — a question, then its answer — so the maintainer can follow
and accept the PR easily.

**How to apply — two cases, never mixed:**
1. **Someone comments or asks on GitHub** → answer in ONE concise reply posted after that comment,
   covering only their points, citing commits. Never answer by editing the description or an old post.
2. **A change I found myself, or feedback from outside GitHub** (Discord, Utku in chat, a tool finding)
   → EDIT the description (or my own earlier post it concerns). No new comment.

The same rule holds for the follow-up PR: ryanbr's 15 Sep 04:07 comment on merged #2099 gets one reply
(drafted in `dist/NEXT_PR.md`), posted with Utku's yes right after the follow-up opens.

The description describes the PR as it is now, not a changelog. **Write it in simple, clear words** (Utku,
21 Sep): what changed since the last merge and why, plainly — no sophisticated or AI-sounding phrasing. Never touch Utku's own comments. Deleting
my own self-initiated comments needed his go-ahead (given 13 Sep 2026); otherwise ask first, and confirm
the content survives where it belongs before removing anything. Public posts outside the PR (issues,
Discord) need his explicit yes.

See [[lift-log-upstream-prs]], [[noop-lift-log-project]].
