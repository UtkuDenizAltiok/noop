#!/usr/bin/env bash
# CPU and memory of NOOP running in the iOS Simulator, measured the same way every time (RULES.md 1, WORKFLOW.md §11).
#   bash dist/tools/usage.sh <label> [seconds] [settle]   e.g.  usage.sh "main 141cbd93 · Today · demo" 60 15
# A simulator app is a Mac process, so its CPU time is read with `ps` at the start and at the end of the window
# (default 60 s, after `settle` seconds, default 0, for a screen just opened to finish loading) →
# CPU-seconds a minute (1.0 = 1.7% of one core). The simulator's render server (backboardd) is read
# over the same window: animation and redraw cost lands there, not in NOOP's own process. Then NOOP's physical
# footprint (`footprint`, the number iOS's memory limit is judged on). Keep the screen still during the window and
# compare only like with like: same simulator, same build configuration, same data, same screen.
# Each result is appended to dist/private/usage.log (local, not public).
set -uo pipefail
label=${1:?usage: usage.sh <label> [seconds] [settle]}; secs=${2:-60}; settle=${3:-0}
TOOLS=$(cd "$(dirname "$0")" && pwd)

app_pid() { pgrep -f "CoreSimulator/Devices/.*/NOOP Staging.app/NOOP Staging" | head -1; }
render_pid() { pgrep -f "CoreSimulator/Volumes/.*/backboardd" | head -1; }
cpu_s() {  # ps time is [[dd-]hh:]mm:ss.ss → seconds
  ps -o time= -p "$1" 2>/dev/null | awk '{ n = split($1, p, ":"); s = 0; for (i = 1; i <= n; i++) s = s * 60 + p[i]; print s }'
}

sleep "$settle"
pid=$(app_pid); [ -n "$pid" ] || { echo "NOOP is not running in a booted simulator" >&2; exit 1; }
rpid=$(render_pid)
a0=$(cpu_s "$pid"); r0=${rpid:+$(cpu_s "$rpid")}
sleep "$secs"
[ "$(app_pid)" = "$pid" ] || { echo "NOOP restarted during the window — measure again" >&2; exit 1; }
a1=$(cpu_s "$pid"); r1=${rpid:+$(cpu_s "$rpid")}
app=$(awk -v a="$a0" -v b="$a1" -v s="$secs" 'BEGIN { printf "%.2f", (b - a) * 60 / s }')
render=$( [ -n "$rpid" ] && awk -v a="$r0" -v b="$r1" -v s="$secs" 'BEGIN { printf "%.2f", (b - a) * 60 / s }' || echo "?")
mem=$(footprint -p "$pid" 2>/dev/null | sed -n 's/.*Footprint: \([0-9.]* [KMG]*B\).*/\1/p' | head -1)
line=$(printf '%s · %s · NOOP %s CPU-s/min · render %s CPU-s/min · footprint %s · %ss' \
  "$(date '+%Y-%m-%d %H:%M')" "$label" "$app" "$render" "${mem:-?}" "$secs")
echo "$line"
mkdir -p "$TOOLS/../private" && echo "$line" >> "$TOOLS/../private/usage.log"
