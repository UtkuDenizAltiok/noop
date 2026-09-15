#!/usr/bin/env bash
# Back up this handbook, with Claude Code's memory for the project, to the public lift-log-handbook branch.
#   bash dist/tools/backup.sh "what changed" ["extra commit paragraph"]
#   bash dist/tools/backup.sh --restore-memory          (new machine: copy memory/ back for Claude Code)
# Memory lives in $CLAUDE_MEMORY_DIR, by default Claude Code's folder for ~/Developer/noop.
set -euo pipefail
HB=$(cd "$(dirname "$0")/.." && pwd)
MEM=${CLAUDE_MEMORY_DIR:-$HOME/.claude/projects/$(cd "$HB/.." && pwd | tr '/' '-')/memory}

if [ "${1:-}" = "--restore-memory" ]; then
  mkdir -p "$MEM" && cp "$HB"/memory/*.md "$MEM"/ && echo "memory restored to $MEM"; exit 0
fi
MSG=${1:?usage: backup.sh "what changed"}

cd "$HB"
[ "$(git symbolic-ref --short HEAD 2>/dev/null)" = lift-log-handbook ] || { echo "$HB is not the lift-log-handbook worktree"; exit 1; }
if [ -d "$MEM" ]; then rm -f memory/*.md && mkdir -p memory && cp "$MEM"/*.md memory/; else echo "no memory at $MEM; skipped"; fi

git add -A
if git diff --cached --quiet; then echo "nothing changed"; else git commit -q -m "handbook: $MSG" ${2:+-m "$2"}; fi
git push -q origin lift-log-handbook
git fetch -q origin
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/lift-log-handbook)" ] || { echo "push did not land"; exit 1; }
echo "backed up $(git rev-parse --short HEAD): $(git ls-files | wc -l | tr -d ' ') files on the PUBLIC branch"
git status --short --ignored | sed 's/^/  kept private: /'
