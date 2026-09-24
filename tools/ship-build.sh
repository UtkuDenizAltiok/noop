#!/usr/bin/env bash
# Ship a testing build to Utku's phone and verify what was published.
#   bash dist/tools/ship-build.sh testing-stack      (any pushed branch works; the stack is what his phone runs)
# testing-build = that branch + fork/ships-template (uploads the Lift Log's .xlsx program template; kept out of PRs).
# How the stack is rebuilt: WORKFLOW.md §6.
set -euo pipefail
TOOLS=$(cd "$(dirname "$0")" && pwd)
REPO=${NOOP_REPO:-$(cd "$TOOLS/../.." && pwd)}
cd "$REPO"
FORK=UtkuDenizAltiok/noop BUILD=testing-build WF="Testing build (fork)"
WORK=${1:-testing-stack}
# One line per outcome in the event log, so an interrupted ship can be checked instead of repeated.
trap 'rc=$?; [ $rc = 0 ] || bash "$TOOLS/checkpoint.sh" event "ship $WORK FAILED (exit $rc)${RUN:+ — run $RUN}"' EXIT

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
bash "$TOOLS/checkpoint.sh" event "ship ${SHA:0:7} ($WORK @ $(git rev-parse --short "$WORK")) building — run $RUN"
gh run watch "$RUN" --repo "$FORK" --interval 60 --exit-status >/dev/null \
  || { echo "build FAILED — gh run view $RUN --repo $FORK; on a 5xx or early clone failure: gh run rerun $RUN"; exit 1; }

target=$(gh release view testing-latest --repo "$FORK" --json targetCommitish --jq .targetCommitish)
# The release's OWN asset list, not `gh release view` or /releases/tags/…: on 23 Sep both of those listed 0 files for
# over ten minutes after every attach step had succeeded, while this list held all five and the .ipa downloaded.
rid=$(gh api "repos/$FORK/releases" --jq '.[] | select(.tag_name == "testing-latest") | .id' | head -1)
assets=$(gh api "repos/$FORK/releases/$rid/assets" --jq '.[] | select(.state == "uploaded") | .name')
[ "$target" = "$SHA" ] || { echo "release points at ${target:0:8}, not ${SHA:0:8}"; exit 1; }
grep -q '^NOOP-ios-unsigned-.*\.ipa$' <<<"$assets" || { echo "release has no .ipa"; exit 1; }
grep -q '^lift-log-program-template\.xlsx$' <<<"$assets" || { echo "release has no template"; exit 1; }
ipa=$(grep '^NOOP-ios-unsigned-.*\.ipa$' <<<"$assets" | head -1)
code=$(curl -s -o /dev/null -I -L -w '%{http_code}' "https://github.com/$FORK/releases/download/testing-latest/$ipa")
[ "$code" = 200 ] || { echo "the .ipa does not download (HTTP $code)"; exit 1; }
echo "shipped ${SHA:0:8} with the .ipa and the template: https://github.com/$FORK/releases/tag/testing-latest"
bash "$TOOLS/checkpoint.sh" event "ship ${SHA:0:7} verified on the releases page (.ipa + template) — run $RUN"
