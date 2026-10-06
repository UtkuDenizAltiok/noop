#!/usr/bin/env bash
# Test checkpoints, backup folding and the local Codex installer in disposable Git repositories.
# Uses a local bare origin; no GitHub, agent settings or personal data are touched.
#   bash dist/tools/test-checkpoint.sh
set -euo pipefail
TOOLS=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
fails=0
check() {
  local what=$1; shift
  if "$@" >/dev/null 2>&1; then echo "  ok    $what"; else echo "  FAIL  $what"; fails=$((fails + 1)); fi
}

git init -q --bare "$T/origin.git"
git init -q -b main "$T/app"
cd "$T/app"
printf 'dist/\n' > .gitignore
printf '# Upstream rules\n' > AGENTS.md
git add .gitignore AGENTS.md && git commit -q -m app
git remote add origin "$T/origin.git"
git checkout -q --orphan handbook && git rm -rq --cached . && rm .gitignore AGENTS.md
mkdir -p tools
cp "$TOOLS/checkpoint.sh" "$TOOLS/backup.sh" "$TOOLS/codex-setup.sh" tools/
printf 'private/\n.DS_Store\n' > .gitignore
printf '# Handbook instructions\n' > AGENTS.md
printf '# State\n\n## Now — work in flight\n\n- [ ] step one\n- [x] step zero\n\n## Upstream\n' > STATE.md
git add -A && git commit -q -m 'handbook: start' && git push -q origin handbook
git checkout -q main && git worktree add -q dist handbook
git -C dist branch -q --set-upstream-to=origin/handbook
H="$T/app/dist"; CP="$H/tools/checkpoint.sh"; INSTALL="$H/tools/codex-setup.sh"
subject() { git -C "$H" log -1 --format=%s; }

echo status
out=$(bash "$CP" status)
check 'reports an unfinished journal step' grep -q 'step one' <<<"$out"
check 'does not report a completed journal step' bash -c '! grep -q "step zero" <<<"$1"' _ "$out"
check 'reports the code checkout' grep -q 'app: main @' <<<"$out"
out=$(bash "$CP" brief)
check 'recovery brief includes the current journal' bash -c 'grep -q "recovery brief" <<<"$1" && grep -q "step one" <<<"$1"' _ "$out"

echo save
mkdir -p "$H/private"; printf 'private data\n' > "$H/private/personal.txt"
echo 'edit 1' >> "$H/STATE.md"; bash "$CP" save first >/dev/null
check 'saves a local checkpoint' test "$(subject)" = 'checkpoint: first'
check 'records its event' grep -q 'checkpoint: first' "$H/private/events.log"
check 'excludes private files from the commit' bash -c '[ -z "$(git -C "$1" ls-files private)" ]' _ "$H"
before=$(git -C "$H" rev-parse HEAD); bash "$CP" save unchanged >/dev/null
check 'an unchanged save creates no commit' test "$(git -C "$H" rev-parse HEAD)" = "$before"
lock=$(git -C "$H" rev-parse --git-path index.lock)
touch "$lock"; echo 'edit 2' >> "$H/STATE.md"
check 'a busy index returns failure' bash -c '! bash "$1" save busy' _ "$CP"
check 'a failed save records no success event' bash -c '! grep -q "checkpoint: busy" "$1"' _ "$H/private/events.log"
rm "$lock"; bash "$CP" save second >/dev/null
git -C "$H" checkout -q --detach HEAD
check 'saving outside handbook returns failure' bash -c '! bash "$1" save detached' _ "$CP"
git -C "$H" checkout -q handbook
check 'unknown commands return failure' bash -c '! bash "$1" obsolete' _ "$CP"
check 'removed hook commands do not run' bash -c '! bash "$1" hook stop' _ "$CP"
check 'removed restore interface does not publish' bash -c '! bash "$1" --restore-memory' _ "$H/tools/backup.sh"

echo 'backup folding'
tip=$(git -C "$H" rev-parse origin/handbook); tree=$(git -C "$H" rev-parse 'HEAD^{tree}')
bash "$H/tools/backup.sh" folded >/dev/null 2>&1
check 'uploads checkpoints as exactly one milestone' test "$(git -C "$H" rev-list --count "$tip"..origin/handbook)" = 1
check 'uses the milestone subject' test "$(subject)" = 'handbook: folded'
check 'retains every saved change' test "$(git -C "$H" rev-parse 'origin/handbook^{tree}')" = "$tree"
check 'records the verified upload' grep -q 'backup .* uploaded: folded' "$H/private/events.log"
echo 'edit 3' >> "$H/STATE.md"; git -C "$H" commit -qam 'a hand-made commit'
echo 'edit 4' >> "$H/STATE.md"; bash "$CP" save 'after it' >/dev/null
tip=$(git -C "$H" rev-parse origin/handbook)
bash "$H/tools/backup.sh" kept >/dev/null 2>&1
check 'preserves non-checkpoint commit history' bash -c '[ "$(git -C "$1" log --format=%s "$2"..origin/handbook)" = "$(printf "checkpoint: after it\na hand-made commit")" ]' _ "$H" "$tip"
check 'handbook is clean and uploaded' bash -c '[ -z "$(git -C "$1" status --porcelain)" ] && [ "$(git -C "$1" rev-parse HEAD)" = "$(git -C "$1" rev-parse origin/handbook)" ]' _ "$H"

echo 'Codex entry files'
git -C "$T/app" worktree add -q -b example "$T/app-pr" main
bash "$INSTALL" >/dev/null
check 'configures main and PR worktrees' bash -c '[ -f "$1/AGENTS.override.md" ] && [ -f "$2/AGENTS.override.md" ]' _ "$T/app" "$T/app-pr"
check 'points to the canonical handbook and upstream rules' bash -c 'grep -qF "$2/AGENTS.md" "$1" && grep -q "upstream" "$1"' _ "$T/app/AGENTS.override.md" "$H"
check 'the handbook uses its own tracked AGENTS' test ! -e "$H/AGENTS.override.md"
check 'entry files do not dirty app checkouts' bash -c '[ -z "$(git -C "$1" status --porcelain)" ] && [ -z "$(git -C "$2" status --porcelain)" ]' _ "$T/app" "$T/app-pr"
before=$(shasum -a 256 "$T/app/AGENTS.override.md"); bash "$INSTALL" >/dev/null
check 'reinstallation is idempotent' test "$(shasum -a 256 "$T/app/AGENTS.override.md")" = "$before"
check 'the shared ignore rule is installed once' test "$(grep -c '^/AGENTS.override.md$' "$T/app/.git/info/exclude")" = 1
printf 'Custom local instructions\n' > "$T/app-pr/AGENTS.override.md"
check 'refuses unrelated local instructions' bash -c '! bash "$1"' _ "$INSTALL"
check 'preserves unrelated instructions byte for byte' test "$(cat "$T/app-pr/AGENTS.override.md")" = 'Custom local instructions'

if [ "$fails" = 0 ]; then echo 'all checks passed'; else echo "$fails check(s) FAILED"; fi
exit "$fails"
