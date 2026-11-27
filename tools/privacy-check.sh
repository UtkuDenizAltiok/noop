#!/usr/bin/env bash
# Scan what is published (the handbook branch, and the app's own top-level docs) for the owner's private details
# before a push. Prints each hit as file:line and exits 1 when there is one. See WORKFLOW.md → Privacy.
#   bash dist/tools/privacy-check.sh                (from the app checkout; NOOP_REPO=<app> to point elsewhere)
# The patterns are deliberately general (no personal string is written here): figures from "his"/"the owner's"
# nights, a phone model, phone-usage reports, places, ages, personal e-mail domains, raw strap-log lines.
set -uo pipefail
H="$(cd "$(dirname "$0")/.." && pwd)"
A="${NOOP_REPO:-$(cd "$H/../app" 2>/dev/null && pwd || true)}"
PAT='\bhis (four |five |six |seven |october |november |own |first |last )?(nights?|days?|sleep|logs?|backup|strap log|phone)\b'
PAT+='|\bof his sleep\b|\butku.?s (nights?|days?|backup|logs?|heart|sleep|phone|ipad)\b|\biphone 1[0-9]( plus| pro)?\b'
PAT+='|\bmetrickit (day|report) (showed|said|read)|\bcentral europe\b|\b[0-9]{2} years old\b|\bage [0-9]{2}\b'
PAT+='|[a-z0-9._%+-]+@(gmail|googlemail|icloud|me|outlook|hotmail|yahoo|proton|protonmail)\.[a-z]+'
PAT+='|^[0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]+)? .*(bpm|hr=|wrist)'
hits=0
scan() {  # $1 repo, then paths
  local repo=$1; shift
  while IFS= read -r -d '' f; do
    case "$f" in tools/privacy-check.sh) continue ;; esac
    # Simulator device names ("iPhone 18 Pro") are not the owner's phone: lines about the simulator are skipped.
    if out=$(grep -nIiE "$PAT" -- "$repo/$f" 2>/dev/null | grep -viE "simulator|simctl|xcrun|--demo|iphone 1[78] pro"); then
      while IFS= read -r line; do echo "  ${repo##*/}/$f:$line"; hits=$((hits + 1)); done <<<"$out"
    fi
  done < <(git -C "$repo" ls-files -z -- "$@")
}
echo "== handbook ($H)"
scan "$H" .
if [ -n "$A" ] && [ -d "$A/.git" -o -f "$A/.git" ]; then
  echo "== app top-level docs ($A)"
  scan "$A" AGENTS.md README.md CLAUDE.md GEMINI.md CHANGELOG.md 'docs/releases/v13*.md'
fi
if [ "$hits" -gt 0 ]; then echo "$hits possible private detail(s): fix each, or be sure it is not personal"; exit 1; fi
echo "OK no private details found"
