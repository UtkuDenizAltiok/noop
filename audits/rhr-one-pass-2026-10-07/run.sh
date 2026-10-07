#!/usr/bin/env bash
# Measure the exact resting-HR production functions, copied unchanged with their constants/model.
# No personal data; repetitions are per fixture. Swift -O, actual process CPU and peak RSS.
set -euo pipefail
RHR_AUDIT_DIR=$(cd "$(dirname "$0")" && pwd)
RHR_REPO=${NOOP_REPO:-$(cd "$RHR_AUDIT_DIR/../../.." && pwd)}
RHR_CACHE=${NOOP_RHR_CACHE:-"$HOME/Library/Caches/noop-handbook/rhr-one-pass"}
RHR_HARNESS=Benchmark.swift
if [ "${1:-}" = --oracle ]; then RHR_HARNESS=Oracle.swift; fi
mkdir -p "$RHR_CACHE"
python3 - "$RHR_REPO" "$RHR_CACHE" "$RHR_AUDIT_DIR" "$RHR_HARNESS" <<'PY'
from pathlib import Path
import hashlib, json, re, shutil, subprocess, sys
repo, cache, audit = map(Path, sys.argv[1:4])
harness = sys.argv[4]
path = repo / 'Packages/StrandAnalytics/Sources/StrandAnalytics/SleepStager.swift'
s = path.read_text()
body = s[s.index('    public static func rhrBinGateLogLine('):s.index('    /// One 5-min HRV window:')]
# The shared accumulator, once introduced, is immediately after sessionRestingHR in this region.
constants = '\n'.join(re.findall(r'    public static let rhrMin(?:BinSamples|PlausibleBpm):[^\n]+', s))
streams = (repo / 'Packages/WhoopProtocol/Sources/WhoopProtocol/Streams.swift').read_text()
model = streams[streams.index('public struct HRSample:'):streams.index('/// Sensor-contact state')]
(cache / 'Production.swift').write_text('import Foundation\n' + model + '\npublic enum SleepStager {\n' + constants + '\n' + body + '\n}\n')
shutil.copyfile(audit / harness, cache / 'main.swift')
head = subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD'], text=True).strip()
meta = {'head': head, 'sourceSHA256': hashlib.sha256(path.read_bytes()).hexdigest(),
        'modelSHA256': hashlib.sha256(model.encode()).hexdigest(),
        'harness': harness, 'harnessSHA256': hashlib.sha256((audit / harness).read_bytes()).hexdigest()}
(cache / 'source-hashes.json').write_text(json.dumps(meta, indent=2) + '\n')
print(json.dumps(meta))
PY
swiftc -O "$RHR_CACHE/Production.swift" "$RHR_CACHE/main.swift" -o "$RHR_CACHE/measure"
if [ "$RHR_HARNESS" = Oracle.swift ]; then
    "$RHR_CACHE/measure"
else
    /usr/bin/time -lp "$RHR_CACHE/measure" "${1:-21}"
fi
