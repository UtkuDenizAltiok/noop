#!/usr/bin/env bash
# Checkpoints and recovery: what is true right now, and a local save of this handbook that costs nothing.
#   bash dist/tools/checkpoint.sh status [--net]    the ground truth after any interruption (read-only; --net asks GitHub)
#   bash dist/tools/checkpoint.sh save ["note"]     commit this handbook + Claude Code's memory LOCALLY (no upload)
#   bash dist/tools/checkpoint.sh event "text"      add a line to private/events.log (verify, ship and backup do)
#   bash dist/tools/checkpoint.sh install-hooks     let Claude Code call `hook` by itself (Utku's choice: README)
#   bash dist/tools/checkpoint.sh remove-hooks      undo install-hooks
#   bash dist/tools/checkpoint.sh hook <kind>       what those hooks run; reads Claude Code's JSON on stdin
# The journal is STATE.md's "Now" section, written by hand BEFORE each long, public or hard-to-undo step
# (WORKFLOW.md §2). This tool only shows the evidence to check it against, and saves; it never uploads.
# macOS bash 3.2: no associative arrays, no mapfile.
set -uo pipefail
HB=$(cd "$(dirname "$0")/.." && pwd)
REPO=$(cd "$HB/.." && pwd)
MEM=${CLAUDE_MEMORY_DIR:-$HOME/.claude/projects/$(printf '%s' "$REPO" | tr '/' '-')/memory}
PRIV="$HB/private"; EVENTS="$PRIV/events.log"; MARK="$PRIV/interrupted"
FORK=UtkuDenizAltiok/noop UPSTREAM=ryanbr/noop

event() {  # one line in the local event log, trimmed to its newest 1,000 lines past 2,000
  mkdir -p "$PRIV" 2>/dev/null || return 0
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$EVENTS"
  if [ "$(wc -l < "$EVENTS")" -gt 2000 ]; then tail -n 1000 "$EVENTS" > "$EVENTS.tmp" && mv "$EVENTS.tmp" "$EVENTS"; fi
}

on_handbook() { [ "$(git -C "$HB" symbolic-ref --short HEAD 2>/dev/null)" = lift-log-handbook ]; }

git_busy() {  # a rebase, merge or cherry-pick in progress, or another git holding the index, in worktree $1
  local p
  for p in index.lock rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD; do
    [ -e "$(git -C "$1" rev-parse --git-path "$p")" ] && { echo "$p"; return 0; }
  done
  return 1
}

sync_memory() {  # Claude Code's memory into memory/ — never from an empty folder, which would erase the copy
  ls "$MEM"/*.md >/dev/null 2>&1 || return 0
  mkdir -p "$HB/memory" && rm -f "$HB"/memory/*.md && cp "$MEM"/*.md "$HB/memory/"
}

save() {  # save <note> [quiet] — a local commit of whatever changed; backup.sh later uploads them as one
  local note=$1 quiet=${2:-} busy
  say() { [ -n "$quiet" ] || echo "$@"; }
  on_handbook || { say "$HB is not the lift-log-handbook worktree: nothing saved"; return 0; }
  busy=$(git_busy "$HB") && { say "git is busy in the handbook ($busy): nothing saved"; return 0; }
  sync_memory
  git -C "$HB" add -A >/dev/null 2>&1
  if git -C "$HB" diff --cached --quiet; then say "nothing to save"; return 0; fi
  git -C "$HB" commit -q --no-verify -m "checkpoint: $note" >/dev/null 2>&1 || { say "commit failed"; return 0; }
  say "saved $(git -C "$HB" rev-parse --short HEAD) locally: $(git -C "$HB" diff --name-only HEAD~1 HEAD | tr '\n' ' ')"
}

journal() {  # STATE.md's "Now" section, as written
  awk '/^## Now/{f=1; next} /^## /{f=0} f' "$HB/STATE.md" 2>/dev/null | sed -e '/./,$!d'
}

status() {
  local net=${1:-} w b sha sync n a z busy running pat
  [ "$net" = --net ] && { git -C "$REPO" fetch -q origin 2>/dev/null || echo "(fetch failed: offline?)"; }

  echo "== journal: open steps in STATE.md \"Now\""
  journal | grep -E '^- \[ \]' | cut -c1-160 | sed 's/^/  /' || echo "  none"

  echo "== handbook (dist/, branch lift-log-handbook)"
  if on_handbook; then
    echo "  last upload: $(git -C "$HB" log -1 --format='%h, %cr: %s' origin/lift-log-handbook 2>/dev/null | cut -c1-120)"
    n=$(git -C "$HB" rev-list --count origin/lift-log-handbook..HEAD 2>/dev/null || echo '?')
    [ "$n" = 0 ] || echo "  $n local checkpoint(s) not uploaded yet — backup.sh uploads them as one commit"
    n=$(git -C "$HB" status --porcelain | awk '{print $NF}' | tr '\n' ' ')
    [ -z "$n" ] || echo "  unsaved: $n"
    n=0
    for w in "$MEM"/*.md; do [ -e "$w" ] && ! cmp -s "$w" "$HB/memory/$(basename "$w")" && n=$((n + 1)); done
    [ "$n" = 0 ] || echo "  memory: $n note(s) changed since the last save"
  else
    echo "  NOT on lift-log-handbook — checkpoints and backups are off"
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

field() {  # a field of the hook's JSON input, flattened to one line
  printf '%s' "$INPUT" | python3 -c 'import json, sys
try: print(" ".join(str(json.load(sys.stdin).get(sys.argv[1], "")).split())[:300])
except Exception: print("")' "$1" 2>/dev/null
}

brief() {  # what a new or compacted session must read first
  echo "LIFT LOG — recovery brief (automatic, session $1). From dist/, the durable record: trust it over any summary"
  echo "or recollection of this conversation. An unticked step below may or may not have happened: find its evidence"
  echo "(git, CI, the releases page, gh pr list) before redoing it; never repeat a push, build, PR or comment without it."
  echo "Procedure: dist/README.md \"After an interruption\". Full check: bash dist/tools/checkpoint.sh status --net"
  echo
  echo "STATE.md \"Now\":"
  journal | sed 's/^/  /'
  echo
  status
}

hook() {  # hook <kind> — never blocks and never fails: an error here must not stop Claude Code
  if [ -t 0 ]; then INPUT=""; else INPUT=$(cat); fi
  case "$1" in
    session-start)  # startup, resume, clear or compact: put the journal and the ground truth into context
      local source; source=$(field source); event "session start (${source:-unknown})"
      brief "${source:-start}" ;;
    pre-compact)
      event "compaction ($(field trigger)): checkpoint"; save "before compaction" quiet ;;
    api-error)  # StopFailure: a usage limit or server error ended the turn mid-work
      local what; what="$(field error_type): $(field error_message)"
      event "turn ended by an API error — $what"; save "turn ended by an API error" quiet
      printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$what" > "$MARK" ;;
    prompt)  # UserPromptSubmit: only speaks after an API error ended the last turn
      [ -f "$MARK" ] || return 0
      echo "NOTE (automatic): the previous turn was cut off by an API error ($(cat "$MARK"))."
      echo "Before continuing, check what really happened — STATE.md \"Now\" against the status below — and do not"
      echo "repeat a step that already completed."
      echo
      status
      rm -f "$MARK" ;;
    stop) save "after a reply" quiet ;;
    *) echo "unknown hook kind: $1" >&2 ;;
  esac
  return 0
}

hooks_file() {  # hooks_file install|remove — merge ours into the app repo's .claude/settings.local.json
  local file="$REPO/.claude/settings.local.json" exclude
  exclude="$(git -C "$REPO" rev-parse --git-common-dir)/info/exclude"
  grep -qxF '.claude/settings.local.json' "$exclude" 2>/dev/null \
    || printf '%s\n' '# Claude Code local settings (Lift Log checkpoint hooks) — never committed' \
                     '.claude/settings.local.json' >> "$exclude"
  mkdir -p "$REPO/.claude"
  python3 - "$file" "$1" "$HB/tools/checkpoint.sh" <<'PY'
import json, os, sys
path, mode, tool = sys.argv[1:4]
# Ours: the checkpoint hooks, and the one-off probe left in this file while these were set up (22 Sep).
ours = lambda h: "checkpoint.sh" in h.get("command", "") or "hook-probe" in h.get("command", "")
settings = json.load(open(path)) if os.path.exists(path) and os.path.getsize(path) else {}
hooks = settings.get("hooks", {})
for event in list(hooks):
    groups = [dict(g, hooks=[h for h in g.get("hooks", []) if not ours(h)]) for g in hooks[event]]
    hooks[event] = [g for g in groups if g["hooks"]]
    if not hooks[event]:
        del hooks[event]
if mode == "install":
    for event, kind, timeout in [("SessionStart", "session-start", 30), ("UserPromptSubmit", "prompt", 15),
                                 ("Stop", "stop", 30), ("PreCompact", "pre-compact", 60),
                                 ("StopFailure", "api-error", 30)]:
        command = 'bash "%s" hook %s' % (tool, kind)
        hooks.setdefault(event, []).append({"hooks": [{"type": "command", "command": command, "timeout": timeout}]})
settings.pop("hooks", None)
if hooks:
    settings["hooks"] = hooks
if settings:
    with open(path + ".tmp", "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    os.replace(path + ".tmp", path)
elif os.path.exists(path):
    os.remove(path)
print("%s: %s" % ("installed" if mode == "install" else "removed", path))
print("hooks now: " + (", ".join(sorted(hooks)) or "none"))
PY
}

case "${1:-status}" in
  status) status "${2:-}" ;;
  save) save "${2:-by hand}"; event "checkpoint: ${2:-by hand}" ;;
  event) shift; event "$*" ;;
  hook) hook "${2:-}" ;;
  install-hooks) hooks_file install && event "hooks installed" ;;
  remove-hooks) hooks_file remove && event "hooks removed" ;;
  *) sed -n '2,10p' "$0"; exit 1 ;;
esac
