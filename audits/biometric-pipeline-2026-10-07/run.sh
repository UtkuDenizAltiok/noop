#!/usr/bin/env bash
# Reproduce arithmetic/data-contract observations using an unchanged app checkout.
set -euo pipefail
AUDIT_DIR=$(cd "$(dirname "$0")" && pwd)
AUDIT_REPO=${NOOP_REPO:-$(cd "$AUDIT_DIR/../../.." && pwd)}
AUDIT_CACHE=${NOOP_AUDIT_CACHE:-"$HOME/Library/Caches/noop-handbook/biometric-audit"}
python3 - "$AUDIT_REPO" "$AUDIT_CACHE" "$AUDIT_DIR" <<'PY'
from pathlib import Path
import hashlib, json, shutil, subprocess, sys
repo, cache, audit = map(Path, sys.argv[1:])
src = cache / 'Sources' / 'Audit'
src.mkdir(parents=True, exist_ok=True)
paths = ['Packages/StrandAnalytics/Sources/StrandAnalytics/HRVFreqDomain.swift',
         'Strand/BLE/StandardHeartRate.swift']
hashes = {}
for rel in paths:
    data = (repo / rel).read_bytes()
    hashes[rel] = hashlib.sha256(data).hexdigest()
    prefix = b'import StrandAnalytics\n' if rel.endswith('HRVFreqDomain.swift') else b''
    (src / Path(rel).name).write_bytes(prefix + data)
shutil.copyfile(audit / 'Audit.swift', src / 'Audit.swift')
analytics = json.dumps(str(repo / 'Packages' / 'StrandAnalytics'))
protocol = json.dumps(str(repo / 'Packages' / 'WhoopProtocol'))
(cache / 'Package.swift').write_text(f'''// swift-tools-version:5.9
import PackageDescription
let package = Package(name:"Audit",platforms:[.macOS(.v13)],dependencies:[.package(path:{analytics}),.package(path:{protocol})],targets:[.executableTarget(name:"Audit",dependencies:["StrandAnalytics","WhoopProtocol"])])
''')
head = subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD'], text=True).strip()
(cache / 'source-hashes.json').write_text(json.dumps({'head': head, 'copiedSources': hashes}, indent=2) + '\n')
print('source=' + head)
PY
swift run --package-path "$AUDIT_CACHE" Audit
