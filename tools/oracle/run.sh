#!/usr/bin/env bash
# Print the Swift oracle for LiftMetricsParityOracleTest: the real StrandAnalytics + WhoopStore packages run on
# the test's fixture. Paste the output as the test's expected block; keep main.swift's fixture and format in
# step with the test's render(). Sections a change cannot affect must come back byte-identical.
#   bash dist/tools/oracle/run.sh
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=${NOOP_REPO:-$(cd "$HERE/../../.." && pwd)}
W="${TMPDIR:-/tmp}/lift-oracle"
mkdir -p "$W/Sources/LiftOracle"
cp "$HERE/Package.swift" "$W/Package.swift"
cp "$HERE/main.swift" "$W/Sources/LiftOracle/main.swift"
NOOP_REPO="$REPO" swift build -c release --package-path "$W" >"$W/build.log" 2>&1 \
  || { echo "oracle build failed: $W/build.log"; exit 1; }
"$W/.build/release/LiftOracle"
