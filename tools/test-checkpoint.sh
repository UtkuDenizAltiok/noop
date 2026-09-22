#!/usr/bin/env bash
# Self-test for checkpoint.sh and backup.sh's folding, in a throwaway sandbox: a fake app repo, this handbook's
# tools in a worktree of it, a local bare "origin" and a fake memory folder. Touches nothing real, needs no network.
#   bash dist/tools/test-checkpoint.sh
set -uo pipefail
TOOLS=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export CLAUDE_MEMORY_DIR="$T/mem" GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
fails=0
check() {  # check "what" <command…>
  local what=$1; shift
  if "$@" >/dev/null 2>&1; then echo "  ok    $what"; else echo "  FAIL  $what"; fails=$((fails + 1)); fi
}

# The sandbox.
git init -q --bare "$T/origin.git"
git init -q -b main "$T/app" && cd "$T/app"
printf 'dist/\n' > .gitignore && git add .gitignore && git commit -q -m app && git remote add origin "$T/origin.git"
git checkout -q --orphan lift-log-handbook && git rm -rq --cached . && rm .gitignore
mkdir -p tools memory && cp "$TOOLS/checkpoint.sh" "$TOOLS/backup.sh" tools/
printf 'private/\n.DS_Store\n' > .gitignore
printf '# State\n\n## Now — work in flight\n\n- [ ] step one ← in progress\n- [x] step zero\n\n## Upstream\n' > STATE.md
mkdir -p "$T/mem" && echo "note a" > "$T/mem/a.md" && cp "$T/mem/a.md" memory/
git add -A && git commit -q -m "handbook: start" && git push -q origin lift-log-handbook
git checkout -q main && git worktree add -q dist lift-log-handbook
git -C dist branch -q --set-upstream-to=origin/lift-log-handbook
CP="$T/app/dist/tools/checkpoint.sh"; H="$T/app/dist"
subject() { git -C "$H" log -1 --format=%s; }

echo "status"
out=$(bash "$CP" status 2>&1)
check "runs and lists the open journal step" grep -q 'step one' <<<"$out"
check "does not list a ticked step" bash -c '! grep -q "step zero" <<<"$1"' _ "$out"
check "names both worktrees' state" grep -q 'app: main @' <<<"$out"

echo "save"
echo "edit 1" >> "$H/STATE.md"; bash "$CP" save "first" >/dev/null
check "commits locally as a checkpoint" test "$(subject)" = "checkpoint: first"
check "logs the event" grep -q 'checkpoint: first' "$H/private/events.log"
check "keeps private/ out of git" bash -c '! git -C "$1" ls-files | grep -q private' _ "$H"
echo "note a2" > "$T/mem/a.md"; bash "$CP" save "memory" >/dev/null
check "copies changed memory in" grep -q 'note a2' "$H/memory/a.md"
mv "$T/mem" "$T/mem-away"; mkdir "$T/mem"; echo "edit 2" >> "$H/STATE.md"; bash "$CP" save "empty memory" >/dev/null
check "never erases the copy from an empty memory folder" test -f "$H/memory/a.md"
rm -rf "$T/mem"; mv "$T/mem-away" "$T/mem"
touch "$(git -C "$H" rev-parse --git-path index.lock)"; echo "edit 3" >> "$H/STATE.md"
check "stands aside while git is busy" bash -c 'bash "$1" save busy | grep -q busy' _ "$CP"
rm -f "$(git -C "$H" rev-parse --git-path index.lock)"

echo "hooks"
out=$(echo '{"source":"compact"}' | bash "$CP" hook session-start)
check "session start prints the brief and the journal" bash -c 'grep -q "recovery brief" <<<"$1" && grep -q "step one" <<<"$1"' _ "$out"
check "session start is logged with its source" grep -q 'session start (compact)' "$H/private/events.log"
echo '{"error_type":"rate_limit","error_message":"Rate limit exceeded"}' | bash "$CP" hook api-error
check "an API error checkpoints the unsaved edit" test "$(subject)" = "checkpoint: turn ended by an API error"
check "an API error leaves a mark for the next prompt" grep -q rate_limit "$H/private/interrupted"
out=$(echo '{}' | bash "$CP" hook prompt)
check "the next prompt is told, with the status" bash -c 'grep -q "cut off by an API error (.*rate_limit" <<<"$1" && grep -q "== code" <<<"$1"' _ "$out"
check "only once" test -z "$(echo '{}' | bash "$CP" hook prompt)"
before=$(git -C "$H" rev-parse HEAD); echo '{}' | bash "$CP" hook stop
check "stop with nothing changed makes no commit" test "$(git -C "$H" rev-parse HEAD)" = "$before"
echo "edit 4" >> "$H/STATE.md"; echo '{}' | bash "$CP" hook stop
check "stop saves a change" test "$(subject)" = "checkpoint: after a reply"
echo "edit 5" >> "$H/STATE.md"; echo '{"trigger":"auto"}' | bash "$CP" hook pre-compact
check "pre-compact saves and logs" bash -c '[ "$(git -C "$1" log -1 --format=%s)" = "checkpoint: before compaction" ] && grep -q "compaction (auto)" "$1/private/events.log"' _ "$H"
check "bad input and unknown kinds never fail" bash -c 'echo "not json" | bash "$1" hook session-start && bash "$1" hook nonsense </dev/null' _ "$CP"

echo "backup folds checkpoints"
tip=$(git -C "$H" rev-parse origin/lift-log-handbook); tree=$(git -C "$H" rev-parse HEAD^{tree})
bash "$H/tools/backup.sh" "folded" >/dev/null 2>&1
check "uploads exactly one commit" test "$(git -C "$H" rev-list --count "$tip"..origin/lift-log-handbook)" = 1
check "with the backup's message" test "$(git -C "$H" log -1 --format=%s origin/lift-log-handbook)" = "handbook: folded"
check "and every checkpointed change" test "$(git -C "$H" rev-parse origin/lift-log-handbook^{tree})" = "$tree"
check "logs the upload" grep -q 'backup .* uploaded: folded' "$H/private/events.log"
echo "edit 6" >> "$H/STATE.md"; git -C "$H" commit -qam "a hand-made commit"
echo "edit 7" >> "$H/STATE.md"; bash "$CP" save "after it" >/dev/null
tip=$(git -C "$H" rev-parse origin/lift-log-handbook)
bash "$H/tools/backup.sh" "kept" >/dev/null 2>&1
check "keeps a non-checkpoint commit as it is" bash -c '[ "$(git -C "$1" log --format=%s "$2"..origin/lift-log-handbook)" = \
  "$(printf "checkpoint: after it\na hand-made commit")" ]' _ "$H" "$tip"

echo "install-hooks / remove-hooks (the sandbox's own settings file)"
S="$T/app/.claude/settings.local.json"; mkdir -p "$T/app/.claude"
printf '{"permissions":{"allow":["Bash(ls)"]},"hooks":{"PostToolUse":[{"matcher":"Bash","hooks":[{"type":"command","command":"echo hook-probe"}]}]}}' > "$S"
bash "$CP" install-hooks >/dev/null; bash "$CP" install-hooks >/dev/null
check "keeps other settings" grep -q 'Bash(ls)' "$S"
check "drops the probe" bash -c '! grep -q hook-probe "$1"' _ "$S"
check "adds the five hooks once, pointing at this tool" python3 -c '
import json, sys; h = json.load(open(sys.argv[1]))["hooks"]
assert sorted(h) == ["PreCompact", "SessionStart", "Stop", "StopFailure", "UserPromptSubmit"], h
assert all(len(v) == 1 and sys.argv[2] in v[0]["hooks"][0]["command"] for v in h.values())' "$S" "$CP"
check "git ignores the file" git -C "$T/app" check-ignore -q .claude/settings.local.json
bash "$CP" remove-hooks >/dev/null
check "remove keeps other settings, drops hooks" python3 -c '
import json, sys; s = json.load(open(sys.argv[1])); assert "hooks" not in s and s["permissions"]' "$S"
printf '{"hooks":{}}' > "$S"; bash "$CP" install-hooks >/dev/null; bash "$CP" remove-hooks >/dev/null
check "a file holding only our hooks is removed" test ! -e "$S"

[ $fails = 0 ] && echo "all checks passed" || echo "$fails check(s) FAILED"
exit $fails
