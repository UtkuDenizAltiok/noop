#!/usr/bin/env bash
# What changed upstream that the Lift Log work has to adapt to. Read-only.
#   bash dist/tools/upstream-check.sh [branch]      (default: the branch checked out in the app repo)
set -euo pipefail
REPO=${NOOP_REPO:-$(cd "$(dirname "$0")/../.." && pwd)}
cd "$REPO"
BRANCH=${1:-$(git rev-parse --abbrev-ref HEAD)}
git fetch -q upstream && git fetch -q origin --prune

base=$(git merge-base "$BRANCH" upstream/main)
echo "upstream/main $(git rev-parse --short upstream/main); $BRANCH sits on $(git rev-parse --short "$base"),"\
     "$(git rev-list --count "$base"..upstream/main) commit(s) behind"
[ "$(git rev-parse origin/main)" = "$(git rev-parse upstream/main)" ] || echo "fork main is not a mirror of upstream/main (WORKFLOW.md §7)"

# Everything the Lift Log owns or leans on, on both platforms, plus the parity tooling that judges it.
paths=(':(glob)**/*Lift*' ':(glob)**/*lift*' 'Strand/Resources/Localizable.xcstrings'
       'Packages/WhoopStore/Sources/WhoopStore/Database.swift' 'android/app/src/main/java/com/noop/data/WhoopDatabase.kt'
       ':(glob)Tools/parity_*' 'Tools/PARITY_GOVERNANCE.md' 'Strand/BLE/FrameRouter.swift' 'Strand/App/AppModel.swift'
       'StrandiOS/App/RootTabView.swift' 'StrandiOSWidgets/NOOPWidgetBundle.swift')
echo "== upstream commits since the base touching Lift Log paths (read each one):"
git log --format='  %h %ad %an: %s' --date=short "$base"..upstream/main -- "${paths[@]}"
echo "== upstream commits since the base that mention lift:"
git log -i --grep='lift' --format='  %h %s' "$base"..upstream/main

if git merge-tree --write-tree "$BRANCH" upstream/main >/dev/null 2>&1; then
  echo "== $BRANCH merges cleanly into upstream/main"
else
  echo "== $BRANCH CONFLICTS with upstream/main in:"
  git merge-tree --write-tree --name-only "$BRANCH" upstream/main | sed -n '2,/^$/p' | sed 's/^/  /'
fi

echo "== open upstream PRs and issues about the Lift Log:"
for q in '"lift log"' LiftMetrics liftSet; do
  gh search prs --repo ryanbr/noop "$q" --state open --json number,title,author \
    --jq '.[] | "  PR #\(.number) \(.author.login): \(.title)"'
  gh search issues --repo ryanbr/noop "$q" --state open --json number,title --jq '.[] | "  #\(.number): \(.title)"'
done | sort -u
echo "== our upstream PRs:"
gh pr list --repo ryanbr/noop --author UtkuDenizAltiok --state all --limit 5
