---
name: noop-ship-the-build
description: "After any app change, rebuild testing-stack (upstream/main + our open PRs), build it for iOS locally, then dist/tools/ship-build.sh testing-stack; trust only the verified release assets; tell Utku \"just update\" or \"wipe\" with the 7-char id."
metadata:
  node_type: memory
  type: feedback
  originSessionId: ed340050-008d-44ae-be66-66b9c198334f
  modified: 2026-09-24T12:36:22.886Z
---

Finishing a change means **shipping a build**, not offering one. Utku installs the `.ipa` from
`https://github.com/UtkuDenizAltiok/noop/releases/tag/testing-latest` with AltStore, and every build comes with a
one-line **"just update" or "wipe"** and the 7-character id that ends the release title (10 and 17 Sep 2026).

**Why:** pushing code rebuilds nothing; and the workflow recreates `testing-latest` before building, so a failed run
once left him an empty release that looked new.

**How to apply:** `testing-stack` = every open PR of ours on `upstream/main` (a PR that conflicts commit by commit goes
in as its net diff), rebuilt in a scratch worktree after any merge or change; check `git diff --stat upstream/main`
lists only our files; build it for iOS locally; force-push with a pinned lease; then
`bash dist/tools/ship-build.sh testing-stack` (it makes `testing-build` = the stack + `fork/ships-template`, runs the
workflow, verifies the target commit, the `.ipa`, the template and the download). Just update for logic/UI/analytics or
an optional stored field; wipe only for an edited migration or a changed stored shape (`dist/WORKFLOW.md` §6).

See [[noop-project]], [[noop-verify-before-claiming]].
