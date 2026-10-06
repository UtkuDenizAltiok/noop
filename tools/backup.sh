#!/usr/bin/env bash
# Upload the public NOOP handbook. Local checkpoints are folded into one milestone commit.
#   bash dist/tools/backup.sh "what changed" ["extra commit paragraph"]
# Only handbook files are staged. Personal data and drafts belong in ignored private/.
set -euo pipefail
HB=$(cd "$(dirname "$0")/.." && pwd)
MSG=${1:?usage: backup.sh "what changed"}
case "$MSG" in -*) echo 'usage: backup.sh "what changed"' >&2; exit 1 ;; esac

cd "$HB"
[ "$(git symbolic-ref --short HEAD 2>/dev/null)" = handbook ] || { echo "$HB is not the handbook worktree"; exit 1; }
# Fold local checkpoint commits into this one, so the public history keeps one commit per backup — only when every
# local commit is a checkpoint and sits on the fork's tip; anything else is uploaded as it is.
git fetch -q origin handbook
local_subjects=$(git log --format=%s origin/handbook..HEAD)
if [ -n "$local_subjects" ] && git merge-base --is-ancestor origin/handbook HEAD \
   && ! grep -qv '^checkpoint: ' <<<"$local_subjects"; then
  git reset -q --soft origin/handbook
fi

git add -A
if git diff --cached --quiet; then echo "nothing changed"; else git commit -q -m "handbook: $MSG" ${2:+-m "$2"}; fi
git push -q origin handbook
git fetch -q origin
[ "$(git rev-parse HEAD)" = "$(git rev-parse origin/handbook)" ] || { echo "push did not land"; exit 1; }
echo "backed up $(git rev-parse --short HEAD): $(git ls-files | wc -l | tr -d ' ') files on the PUBLIC branch"
bash "$HB/tools/checkpoint.sh" event "backup $(git rev-parse --short HEAD) uploaded: $MSG"
git status --short --ignored | sed 's/^/  kept private: /'
