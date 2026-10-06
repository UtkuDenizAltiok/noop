#!/usr/bin/env bash
# Checkpoints and recovery for the NOOP handbook. No external memory or agent hooks.
#   bash dist/tools/checkpoint.sh status [--net]    journal, Git, jobs; --net adds GitHub evidence
#   bash dist/tools/checkpoint.sh save "note"       save the handbook LOCALLY; does not upload
#   bash dist/tools/checkpoint.sh event "text"      record local evidence in ignored private/events.log
#   bash dist/tools/checkpoint.sh brief             print the recovery brief and local status
# Write long/public/hard-to-undo steps in STATE.md "Now" before acting. backup.sh folds checkpoints on upload.
set -uo pipefail
HB=$(cd "$(dirname "$0")/.." && pwd)
REPO=$(cd "$HB/.." && pwd)
PRIV="$HB/private"; EVENTS="$PRIV/events.log"
FORK=UtkuDenizAltiok/noop UPSTREAM=ryanbr/noop

event() {  # one line in the local event log, trimmed to its newest 1,000 lines past 2,000
  mkdir -p "$PRIV" 2>/dev/null || return 0
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$EVENTS"
  if [ "$(wc -l < "$EVENTS")" -gt 2000 ]; then tail -n 1000 "$EVENTS" > "$EVENTS.tmp" && mv "$EVENTS.tmp" "$EVENTS"; fi
}

on_handbook() { [ "$(git -C "$HB" symbolic-ref --short HEAD 2>/dev/null)" = handbook ]; }

git_busy() {  # a rebase, merge or cherry-pick in progress, or another git holding the index, in worktree $1
  local p
  for p in index.lock rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD; do
    [ -e "$(git -C "$1" rev-parse --git-path "$p")" ] && { echo "$p"; return 0; }
  done
  return 1
}

save() {
  local note=$1 busy
  on_handbook || { echo "$HB is not the handbook worktree: nothing saved"; return 1; }
  if busy=$(git_busy "$HB"); then
    echo "git is busy in the handbook ($busy): nothing saved"; return 1
  fi
  git -C "$HB" add -A || return 1
  if git -C "$HB" diff --cached --quiet; then echo "nothing to save"; return 0; fi
  git -C "$HB" commit -q -m "checkpoint: $note" || { echo "commit failed"; return 1; }
  echo "saved $(git -C "$HB" rev-parse --short HEAD) locally: $(git -C "$HB" diff --name-only HEAD~1 HEAD | tr '\n' ' ')"
}

journal() {  # STATE.md's "Now" section, as written
  awk '/^## Now/{f=1; next} /^## /{f=0} f' "$HB/STATE.md" 2>/dev/null | sed -e '/./,$!d'
}

status() {
  local net=${1:-} w b sha sync n a z busy running pat
  [ "$net" = --net ] && { git -C "$REPO" fetch -q origin 2>/dev/null || echo "(fetch failed: offline?)"; }

  echo "== journal: open steps in STATE.md \"Now\""
  journal | grep -E '^- \[ \]' | cut -c1-160 | sed 's/^/  /' || echo "  none"

  echo "== handbook (dist/, branch handbook)"
  if on_handbook; then
    echo "  last upload: $(git -C "$HB" log -1 --format='%h, %cr: %s' origin/handbook 2>/dev/null | cut -c1-120)"
    n=$(git -C "$HB" rev-list --count origin/handbook..HEAD 2>/dev/null || echo '?')
    [ "$n" = 0 ] || echo "  $n local checkpoint(s) not uploaded yet — backup.sh uploads them as one commit"
    n=$(git -C "$HB" status --porcelain | awk '{print $NF}' | tr '\n' ' ')
    [ -z "$n" ] || echo "  unsaved: $n"

  else
    echo "  NOT on handbook — checkpoints and backups are off"
  fi

  echo "== code (worktrees)"
  git -C "$REPO" worktree list --porcelain | awk '/^worktree /{print substr($0, 10)}' | while read -r w; do
    [ "$w" = "$HB" ] && continue
    b=$(git -C "$w" symbolic-ref --short HEAD 2>/dev/null || echo detached)
    sha=$(git -C "$w" rev-parse --short HEAD)
    if git -C "$w" rev-parse -q --verify "origin/$b" >/dev/null; then
      a=$(git -C "$w" rev-list --count "origin/$b..HEAD"); z=$(git -C "$w" rev-list --count "HEAD..origin/$b")
      if [ "$a$z" = 00 ]; then sync="same as the fork"; else sync="$a ahead, $z behind the fork"; fi
    else
      sync="not on the fork"
    fi
    n=$(git -C "$w" status --porcelain | wc -l | tr -d ' ')
    printf '  %s: %s @ %s — %s; ' "$(basename "$w")" "$b" "$sha" "$sync"
    if [ "$n" = 0 ]; then echo "clean"; else
      echo "$n uncommitted: $(git -C "$w" status --porcelain | head -6 | awk '{print $NF}' | tr '\n' ' ')"; fi
    busy=$(git_busy "$w") && echo "    UNFINISHED git operation: $busy"
  done
  n=$( (git -C "$REPO" tag -l 'backup/*'; git -C "$REPO" branch --list 'backup/*' | tr -d ' *+') | tr '\n' ' ')
  [ -z "$n" ] || echo "  local safety refs still present (an unfinished rebase or push?): $n"
  n=$(git -C "$REPO" stash list | wc -l | tr -d ' ')
  [ "$n" = 0 ] || echo "  $n git stash entr(ies) — the stack is shared; read before using"

  echo "== long jobs running now"
  # Each job from the command that matched (a waiter's shell line starts with its setup); the pattern reaches perl
  # through the environment, so no filter in this pipeline lists itself.
  pat='xcodebuild|gradle|ship-build\.sh|verify\.sh|gh run (watch|view)|gh pr checks|swift-(build|test)|simctl'
  running=$(ps -Ao pid=,etime=,command= | grep -E "$pat" | grep -v -e grep -e 'checkpoint\.sh' -e 'log stream' \
            | PAT="$pat" perl -ne 'print "  pid $1, running $2: ", substr($3, 0, 110), "\n" if /^\s*(\d+)\s+(\S+)\s+.*?((?:$ENV{PAT}).*)$/')
  if [ -n "$running" ]; then echo "$running"; else echo "  none"; fi

  echo "== last events (dist/private/events.log)"
  if [ -s "$EVENTS" ]; then tail -n 8 "$EVENTS" | cut -c1-160 | sed 's/^/  /'; else echo "  none yet"; fi

  [ "$net" = --net ] || { echo "(add --net for CI, the releases page and our PRs)"; return 0; }
  echo "== fork CI, newest runs"
  gh run list --repo "$FORK" --limit 6 --json databaseId,workflowName,headBranch,headSha,status,conclusion,createdAt \
    --jq '.[] | "  \(.databaseId) \(.workflowName) · \(.headBranch) @ \(.headSha[0:8]) · \(.status) \(.conclusion) · \(.createdAt)"' \
    2>/dev/null || echo "  (gh failed)"
  echo "== the build on Utku's releases page"
  gh release view testing-latest --repo "$FORK" --json name,targetCommitish,assets \
    --jq '"  \(.name) → \(.targetCommitish[0:8]); files: \([.assets[].name] | join(", "))"' 2>/dev/null || echo "  (gh failed)"
  echo "== our PRs upstream (newest 5, any state)"
  gh pr list --repo "$UPSTREAM" --author UtkuDenizAltiok --state all --limit 5 \
    --json number,state,headRefName,title --jq '.[] | "  #\(.number) \(.state) \(.headRefName): \(.title)"' \
    2>/dev/null || echo "  (gh failed)"
}

brief() {  # what a new or compacted session must read first
  echo "NOOP — recovery brief. From dist/, the durable record: trust it over any summary"
  echo "or recollection of this conversation. An unticked step below may or may not have happened: find its evidence"
  echo "(git, CI, the releases page, gh pr list) before redoing it; never repeat a push, build, PR or comment without it."
  echo "Procedure: dist/README.md \"After an interruption\". Full check: bash dist/tools/checkpoint.sh status --net"
  echo
  echo "STATE.md \"Now\":"
  journal | sed 's/^/  /'
  echo
  status
}

case "${1:-status}" in
  status) status "${2:-}" ;;
  save) save "${2:-by hand}" && event "checkpoint: ${2:-by hand}" ;;
  event) shift; event "$*" ;;
  brief) brief manual ;;
  *) sed -n '2,7p' "$0"; exit 1 ;;
esac
