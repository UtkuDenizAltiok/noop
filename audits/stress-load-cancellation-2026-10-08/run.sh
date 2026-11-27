#!/usr/bin/env bash
# Compile the actual StressView load methods with scheduler-controlled dependencies.
set -euo pipefail
REPO=${1:?usage: run.sh /absolute/path/to/noop}
HERE=$(cd "$(dirname "$0")" && pwd)
source_digest=$(python3 - "$REPO" <<'PY'
from pathlib import Path
import hashlib, sys
root = Path(sys.argv[1])
names = ['Strand/Screens/StressView.swift', 'Strand/Data/UnescalatedWork.swift', 'Strand/Data/StressLoadCancellation.swift']
digest = hashlib.sha256()
for name in names:
    p = root / name
    if p.exists(): digest.update(p.read_bytes())
print(digest.hexdigest()[:12])
PY
)
OUT="${HOME}/Library/Caches/noop-handbook/stress-load-cancellation-2026-10-08/$(git -C "$REPO" rev-parse --short HEAD)-$source_digest"
mkdir -p "$OUT"
python3 - "$REPO" "$OUT" <<'PY'
from pathlib import Path
import sys, hashlib, json
root, out = map(Path, sys.argv[1:])
path = root / 'Strand/Screens/StressView.swift'
s = path.read_text()
start = s.index('    private func load() async {')
end = s.index('    /// Recompute the cached', start)
methods = s[start:end].replace('private func load()', 'func load()')
prefix = '''import Foundation
@MainActor final class FixtureScreen {
    let repo: Repository
    var storedSeries: [(day: String, value: Double)] = []
    var loaded = false
    var daytime: DaytimeStress.Result?
    var daytimeUsesPersonalBaseline = false
    var stressIndex: StressIndex.Components?
    var freqHRV: HRVFreqDomain.Bands?
    init(repo: Repository) { self.repo = repo }
    func rebuildModelIfNeeded() {}
    var snapshot: String {
        "series=\\(storedSeries.first?.value ?? -1),core=\\(daytime?.identity ?? -1),index=\\(stressIndex?.identity ?? -1),freq=\\(freqHRV?.identity ?? -1),personal=\\(daytimeUsesPersonalBaseline)"
    }
'''
(out / 'Screen.swift').write_text(prefix + methods + '}\n')
names = ['Strand/Screens/StressView.swift', 'Strand/Data/UnescalatedWork.swift', 'Strand/Data/StressLoadCancellation.swift']
inputs = {name: hashlib.sha256((root / name).read_bytes()).hexdigest() for name in names if (root / name).exists()}
(out / 'source-inputs.json').write_text(json.dumps(inputs, indent=2)+'\n')
PY
sources=("$OUT/Screen.swift" "$HERE/Fixture.swift" "$REPO/Strand/Data/UnescalatedWork.swift")
if [ -f "$REPO/Strand/Data/StressLoadCancellation.swift" ]; then
  sources+=("$REPO/Strand/Data/StressLoadCancellation.swift")
fi
swiftc -swift-version 5 -O -parse-as-library "${sources[@]}" -o "$OUT/replay"
"$OUT/replay" | tee "$OUT/output.txt"
