#!/usr/bin/env bash
# Back up this handbook, with Claude Code's memory for the project, to the public lift-log-handbook branch.
#   bash dist/tools/backup.sh "what changed" ["extra commit paragraph"]
#   bash dist/tools/backup.sh --restore-memory          (new machine: copy memory/ back for Claude Code)
# Memory lives in $CLAUDE_MEMORY_DIR, by default Claude Code's folder for ~/Developer/noop.
# Local checkpoints (checkpoint.sh save, or its hooks) go up folded into this one commit.
set -euo pipefail
HB=$(cd "$(dirname "$0")/.." && pwd)
MEM=${CLAUDE_MEMORY_DIR:-$HOME/.claude/projects/$(cd "$HB/.." && pwd | tr '/' '-')/memory}

if [ "${1:-}" = "--restore-memory" ]; then
  mkdir -p "$MEM" && cp "$HB"/memory/*.md "$MEM"/ && echo "memory restored to $MEM"; exit 0
fi
MSG=${1:?usage: backup.sh "what changed"}

cd "$HB"
[ "$(git symbolic-ref --short HEAD 2>/dev/null)" = lift-log-handbook ] || { echo "$HB is not the lift-log-handbook worktree"; exit 1; }
# Never copy from an empty folder: that would erase the backed-up notes.
if ls "$MEM"/*.md >/dev/null 2>&1; then rm -f memory/*.md && mkdir -p memory && cp "$MEM"/*.md memory/
else echo "no memory notes at $MEM; memory/ left as it is"; fi

# Fold local checkpoint commits into this one, so the public history keeps one commit per backup — only when every
# local commit is a checkpoint and sits on the fork's tip; anything else is uploaded as it is.
git fetch -q origin lift-log-handbook
local_subjects=$(git log --format=%s origin/lift-log-handbook..HEAD)
if [ -n "$local_subjects" ] && git merge-base --is-ancestor origin/lift-log-handbook HEAD \
   && ! grep -qv '^checkpoint: ' <<<"$local_subjects"; then
  git reset -q --soft origin/lift-log-handbook
fi

git add -A
if git diff --cached --quiet; then echo "nothing changed"; else git commit -q -m "handbook: $MSG" ${2:+-m "$2"}; fi
git push -q origin lift-log-handbook
git fetch -q origin
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/lift-log-handbook)" ] || { echo "push did not land"; exit 1; }
echo "backed up $(git rev-parse --short HEAD): $(git ls-files | wc -l | tr -d ' ') files on the PUBLIC branch"
bash "$HB/tools/checkpoint.sh" event "backup $(git rev-parse --short HEAD) uploaded: $MSG"
git status --short --ignored | sed 's/^/  kept private: /'
