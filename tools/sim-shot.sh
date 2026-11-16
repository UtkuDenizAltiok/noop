#!/usr/bin/env bash
# A half-size screenshot of the booted simulator, small enough to read many of in one chat.
#   bash dist/tools/sim-shot.sh <name> [wait-seconds]        -> prints the PNG's path
# Waits first (default 4 s; the screen can trail a tap or a launch, and a busy Mac needs longer), then saves
# $NOOP_SHOTS/<name>.png at 1340 px tall (616 px wide on an iPhone 18 Pro).
# Tap and swipe coordinates are POINTS: a pixel in this picture x 0.6526 (402 pt / 616 px).
# Device: $NOOP_SIM (default "iPhone 18 Pro"). Folder: $NOOP_SHOTS (default the handbook cache's sim-shots).
# Useful launches (WORKFLOW.md §3 and features/simple-mode.md "How to work"):
#   xcrun simctl launch "<device>" com.noopapp.noop --demo-seed      seeds 120 days once; wait ~45 s, relaunch
#   … -noop.simpleMode NO | -windDown.enabled YES | -noop.onboarded NO -noop.acceptedTermsVersion ""
set -euo pipefail
NAME=${1:?usage: sim-shot.sh <name> [wait-seconds]}
WAIT=${2:-4}
DEVICE=${NOOP_SIM:-iPhone 18 Pro}
DIR=${NOOP_SHOTS:-$HOME/Library/Caches/noop-handbook/sim-shots}
mkdir -p "$DIR"
END=$(( $(date +%s) + WAIT )); until [ "$(date +%s)" -ge "$END" ]; do :; done
xcrun simctl io "$DEVICE" screenshot "$DIR/$NAME-full.png" >/dev/null 2>&1
sips -Z 1340 "$DIR/$NAME-full.png" --out "$DIR/$NAME.png" >/dev/null 2>&1
rm -f "$DIR/$NAME-full.png"
echo "$DIR/$NAME.png"
