#!/usr/bin/env bash
# Compile the actual pure production helpers and print the 25-case raw-bit oracle.
# bash dist/audits/charge-baseline-usability-2026-10-08/run.sh /path/to/app [--example]
set -euo pipefail
REPO=${1:?usage: run.sh /path/to/app [--example]}
HERE=$(cd "$(dirname "$0")" && pwd)
CACHE="${HOME}/Library/Caches/noop-handbook/charge-baseline-usability"
mkdir -p "$CACHE"
WORK=$(mktemp -d "$CACHE/oracle-XXXXXX")
trap 'rm -rf "$WORK"' EXIT
python3 - "$REPO" "$WORK" <<'PYTHON'
from pathlib import Path
import sys
source=Path(sys.argv[1])/'Packages/StrandAnalytics/Sources/StrandAnalytics'
out=Path(sys.argv[2])
for name in ['Baselines.swift','RecoveryScorer.swift']:
    # RecoveryScorer has an unused protocol import; its math and BaselineState are unchanged.
    (out/name).write_text((source/name).read_text().replace('import WhoopProtocol\n',''))
PYTHON
if [ "${2:-}" = --example ]; then cp "$HERE/EmptyRespiration.swift" "$WORK/main.swift"
else cp "$HERE/Oracle.swift" "$WORK/main.swift"; fi
swiftc -O "$WORK/Baselines.swift" "$WORK/RecoveryScorer.swift" "$WORK/main.swift" -o "$WORK/oracle"
"$WORK/oracle"
