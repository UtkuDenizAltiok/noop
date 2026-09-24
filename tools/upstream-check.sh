#!/usr/bin/env bash
# What moved upstream, and what it means for our branches. Read-only.
#   bash dist/tools/upstream-check.sh             main: what upstream has that the fork's mirror lacks; every open PR branch
#   bash dist/tools/upstream-check.sh <branch>    one branch: upstream commits touching its files; does it still merge
# The maintainers merge within hours, push to our branches and fix things themselves: run it at every session start.
set -euo pipefail
REPO=${NOOP_REPO:-$(cd "$(dirname "$0")/../.." && pwd)}
cd "$REPO"
git fetch -q upstream && git fetch -q origin --prune

echo "upstream/main $(git rev-parse --short upstream/main)"
[ "$(git rev-parse origin/main)" = "$(git rev-parse upstream/main)" ] \
  || echo "fork main $(git rev-parse --short origin/main) is not a mirror: git push origin upstream/main:refs/heads/main (WORKFLOW.md §7)"

check_branch() {  # check_branch <branch>: upstream commits touching the files it changes; clean merge or not
  local b=$1 base files
  base=$(git merge-base "origin/$b" upstream/main)
  echo "== $b sits on $(git rev-parse --short "$base"), $(git rev-list --count "$base"..upstream/main) commit(s) behind"
  files=$(git diff --name-only "$base" "origin/$b")
  if [ -n "$files" ]; then
    # shellcheck disable=SC2086
    git log --format='  %h %ad %an: %s' --date=short "$base"..upstream/main -- $files
  fi
  if git merge-tree --write-tree "origin/$b" upstream/main >/dev/null 2>&1; then
    echo "  merges cleanly into upstream/main"
  else
    echo "  CONFLICTS with upstream/main in:"
    git merge-tree --write-tree --name-only "origin/$b" upstream/main | sed -n '2,/^$/p' | sed 's/^/    /'
  fi
}

if [ -n "${1:-}" ]; then
  check_branch "$1"
else
  echo "== upstream commits the fork's main does not have yet:"
  git log --format='  %h %ad %an: %s' --date=short origin/main..upstream/main | head -30
  # Every branch of ours that is an open upstream PR.
  for b in $(gh pr list --repo ryanbr/noop --author UtkuDenizAltiok --state open --json headRefName --jq '.[].headRefName'); do
    git rev-parse -q --verify "origin/$b" >/dev/null && check_branch "$b"
  done
fi

echo "== our upstream PRs (newest 8, any state):"
gh pr list --repo ryanbr/noop --author UtkuDenizAltiok --state all --limit 8 \
  --json number,title,state,updatedAt --jq '.[] | "  #\(.number) \(.state) \(.updatedAt[0:10]): \(.title[0:90])"'
echo "== comments or reviews on our open PRs in the last 3 days (answer each once, WORKFLOW.md §5):"
since=$(date -u -v-3d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '3 days ago' +%Y-%m-%dT%H:%M:%SZ)
for n in $(gh pr list --repo ryanbr/noop --author UtkuDenizAltiok --state open --json number --jq '.[].number'); do
  gh api "repos/ryanbr/noop/issues/$n/comments?since=$since" --jq ".[] | select(.user.login != \"UtkuDenizAltiok\") | \"  #$n \(.user.login) \(.created_at[0:16]): \(.body[0:100] | gsub(\"\\n\"; \" \"))\""
  gh api "repos/ryanbr/noop/pulls/$n/reviews" --jq ".[] | select(.submitted_at > \"$since\") | \"  #$n review \(.user.login) \(.state) \(.submitted_at[0:16])\""
  gh api "repos/ryanbr/noop/pulls/$n/comments?since=$since" --jq ".[] | \"  #$n inline \(.user.login) \(.created_at[0:16]): \(.body[0:80] | gsub(\"\\n\"; \" \"))\""
done
