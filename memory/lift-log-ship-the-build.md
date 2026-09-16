---
name: lift-log-ship-the-build
description: "After any Lift Log change, ship a testing build myself with dist/tools/ship-build.sh (branch lift-log-build), trust only the verified assets, and tell Utku \"just update\" or \"wipe\" — he installs from the web and never uses the terminal."
metadata:
  node_type: memory
  type: feedback
  originSessionId: 227b34a2-29a0-48aa-85c4-bae7f11cc8ad
  modified: 2026-09-15T13:37:35.019Z
---

Finishing a Lift Log change means **shipping a build**, not offering one. Utku installs the `.ipa` from
`https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest` with AltStore. He asked (10 Sep 2026)
that every build comes with a one-line **"just update" or "wipe"**, and never a broken build.

**Why:** pushing code rebuilds nothing; and the workflow recreates `testing-latest` before building, so a failed
run once left him an empty release that looked new.

**How to apply:** verify first (`bash dist/tools/verify.sh`), push the work branch, then
`bash dist/tools/ship-build.sh`: it rebuilds `lift-log-build` (work branch + `fork/ships-template`), runs the
workflow and checks the release's target commit, `.ipa` and template. Just update for logic/UI/analytics or an
optional snapshot field; wipe only for an edited migration or a changed stored shape (see `dist/WORKFLOW.md` §6).

**Every update must be on his GitHub releases page** (Utku, 17 Sep 2026) — it is where he downloads. The
testing release is `testing-latest`, marked Pre-release, titled "NOOP Staging — base … · <date> · <7-char id>".
After shipping, give him the link and the id to look for in the title, so he can tell the new build from the last.

See [[noop-lift-log-project]], [[lift-log-verify-before-claiming]].
