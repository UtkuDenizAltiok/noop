#!/bin/bash
# Measure re-score passes in the simulator on a real store (BACKLOG A; 28 Sep 2026, PR #2574/#2575).
#   1. worktree of the code to measure + `git apply dist/tools/rescore-profile/prof.patch` (AppModel: waits 25 s,
#      then 8 forced passes, a synthetic 600 s "offload" before each warm one, strap-log lines mirrored to NSLog);
#      xcodegen + Release build for simulator 281E44EC into ~/Library/Caches/noop-handbook/builds/<name>.
#   2. BACKUP_DB=<copy of noop-backup.sqlite unzipped from a .noopbak> bash run.sh <name>   → PROF lines (cost per pass)
#   3. CPU profile: launch, then `xcrun xctrace record --device <sim> --template 'Time Profiler' --attach <pid>`;
#      export the `time-profile` table and run prof-agg.py <xml> <t0> <t1> / prof-callers.py <xml> <t0> <t1> <symbol>.
# Alternate A/B builds; afterwards put the simulator's demo data back and reinstall a clean build.
# A backup is personal: work on a COPY, never commit it or its output.
DEV=281E44EC-9163-4B17-95B6-3C5ADB5AD061
APP="$HOME/Library/Caches/noop-handbook/builds/${1:-prof}/Build/Products/Release-iphonesimulator/NOOP Staging.app"
C=$(xcrun simctl get_app_container $DEV com.noopapp.noop data)
W="$C/Library/Application Support/OpenWhoop"
xcrun simctl terminate $DEV com.noopapp.noop 2>/dev/null; sleep 1
rm -f "$W"/whoop.sqlite*; rm -rf "$W/strap-log"
cp "${BACKUP_DB:?set BACKUP_DB to a COPY of a noop-backup.sqlite}" "$W/whoop.sqlite"
xcrun simctl install $DEV "$APP"
START=$(date "+%Y-%m-%d %H:%M:%S")
xcrun simctl launch $DEV com.noopapp.noop >/dev/null
sleep ${WAIT:-75}
xcrun simctl spawn $DEV log show --start "$START" --style compact --predicate 'process == "NOOP Staging" AND eventMessage CONTAINS "PROF"' 2>/dev/null \
  | sed -E 's/^([0-9-]+ [0-9:.]+).*\(Foundation\) /\1 /' \
  | grep -E "PROF: |re-score: (trigger|done|cost)|analyzeRecent (cost|dayCache|postLoop|storeProbes|windows|stepsMotion)|sleep-detect|Dedup" | cut -c1-260
