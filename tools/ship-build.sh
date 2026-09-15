#!/usr/bin/env bash
# Ship a testing build of the work branch to Utku's phone and verify what was published.
#   bash dist/tools/ship-build.sh [work-branch]      (default: the branch checked out in the app repo)
# lift-log-build = work branch + fork/ships-template (uploads the .xlsx template; kept out of upstream PRs).
set -euo pipefail
REPO=${NOOP_REPO:-$(cd "$(dirname "$0")/../.." && pwd)}
cd "$REPO"
FORK=UtkuDenizAltiok/noop BUILD=lift-log-build WF="Testing build (fork)"
WORK=${1:-$(git rev-parse --abbrev-ref HEAD)}

git fetch -q origin
[ "$(git rev-parse "$WORK")" = "$(git rev-parse "origin/$WORK" 2>/dev/null || echo missing)" ] \
  || { echo "push $WORK first (WORKFLOW.md §7): the build must match what is on the fork"; exit 1; }

OLD=$(git rev-parse "origin/$BUILD")
W="$(mktemp -d)/build"
git worktree add -q -B "$BUILD" "$W" "$WORK"
git -C "$W" cherry-pick fork/ships-template >/dev/null
SHA=$(git -C "$W" rev-parse HEAD)
git push -q --force-with-lease="$BUILD:$OLD" origin "$BUILD"
git worktree remove "$W"
git branch -q --set-upstream-to="origin/$BUILD" "$BUILD"

gh workflow run "$WF" --repo "$FORK" --ref "$BUILD"
for _ in $(seq 30); do
  RUN=$(gh run list --repo "$FORK" --workflow "$WF" --limit 5 --json databaseId,headSha \
        --jq ".[] | select(.headSha == \"$SHA\") | .databaseId" | head -1)
  [ -n "$RUN" ] && break; sleep 10
done
[ -n "${RUN:-}" ] || { echo "the run for ${SHA:0:8} did not start"; exit 1; }
echo "building ${SHA:0:8}: https://github.com/$FORK/actions/runs/$RUN (about 15 minutes)"
gh run watch "$RUN" --repo "$FORK" --interval 60 --exit-status >/dev/null \
  || { echo "build FAILED — gh run view $RUN --repo $FORK; on a 5xx or early clone failure: gh run rerun $RUN"; exit 1; }

target=$(gh release view testing-latest --repo "$FORK" --json targetCommitish --jq .targetCommitish)
assets=$(gh release view testing-latest --repo "$FORK" --json assets --jq '.assets[].name')
[ "$target" = "$SHA" ] || { echo "release points at ${target:0:8}, not ${SHA:0:8}"; exit 1; }
grep -q '^NOOP-ios-unsigned-.*\.ipa$' <<<"$assets" || { echo "release has no .ipa"; exit 1; }
grep -q '^lift-log-program-template\.xlsx$' <<<"$assets" || { echo "release has no template"; exit 1; }
echo "shipped ${SHA:0:8} with the .ipa and the template: https://github.com/$FORK/releases/tag/testing-latest"
