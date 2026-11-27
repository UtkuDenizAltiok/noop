#!/usr/bin/env python3
"""Compile verbatim Swift cleaning bodies; compare a buffer-only candidate and measure CPU."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys

repo, out, audit = map(Path, sys.argv[1:4])
out.mkdir(parents=True, exist_ok=True)
path = 'Packages/StrandAnalytics/Sources/StrandAnalytics/HRVAnalyzer.swift'
source = (repo / path).read_text()

def declaration(text, prefix):
    start = text.index(prefix)
    opened = text.index('{', start)
    depth = 1
    end = opened + 1
    while depth:
        depth += (text[end] == '{') - (text[end] == '}')
        end += 1
    return text[start:end]

def shell(text, name):
    constants = '\n'.join(line.strip() for line in text.splitlines()
                          if any(f'let {key}:' in line for key in
                                 ['rrMinMs', 'rrMaxMs', 'ectopicThreshold', 'ectopicWindowRadius']))
    bodies = '\n'.join(declaration(text, prefix) for prefix in [
        'public static func rangeFilter(', 'public static func rejectEctopic(',
        'public static func cleanRR(', 'public struct CleanSeries:',
        'public static func cleanRRGapAware(', 'static func median('])
    return f'enum {name} {{\n{constants}\n{bodies}\n}}\n'

def reuse(text):
    text = text.replace('kept.reserveCapacity(nn.count)\n        for',
        'kept.reserveCapacity(nn.count)\n        var neighbours: [Double] = []\n'
        '        neighbours.reserveCapacity(2 * ectopicWindowRadius)\n        for', 1)
    text = text.replace('var neighbours: [Double] = []\n            neighbours.reserveCapacity(hi - lo)',
                        'neighbours.removeAll(keepingCapacity: true)', 1)
    text = text.replace('} else {\n            for i in 0..<rangedVal.count {',
        '} else {\n            var neighbours: [Double] = []\n'
        '            neighbours.reserveCapacity(2 * ectopicWindowRadius)\n'
        '            for i in 0..<rangedVal.count {', 1)
    text = text.replace('var neighbours: [Double] = []; neighbours.reserveCapacity(hi - lo)',
                        'neighbours.removeAll(keepingCapacity: true)', 1)
    assert text != source
    return text

original = subprocess.check_output(['git', '-C', str(repo), 'show', f'8e94d559:{path}'], text=True)
candidate = reuse(source) if '--pilot' in sys.argv else source
code = 'import Foundation\nimport Darwin\n' + shell(original, 'OriginalCleaner') + shell(candidate, 'CandidateCleaner')
code += (audit / 'Measure.swift').read_text()
(out / 'main.swift').write_text(code)
subprocess.run(['swiftc', '-O', str(out / 'main.swift'), '-o', str(out / 'measure')], check=True)
metadata = {'head': subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD'], text=True).strip(),
            'originalSHA256': hashlib.sha256(original.encode()).hexdigest(),
            'candidateSHA256': hashlib.sha256(candidate.encode()).hexdigest(),
            'compiledSHA256': hashlib.sha256(code.encode()).hexdigest(),
            'swiftVersion': subprocess.check_output(['swiftc', '--version'], text=True).strip()}
(out / 'source.json').write_text(json.dumps(metadata, indent=2) + '\n')
with (out / 'results.txt').open('w') as log:
    subprocess.run([str(out / 'measure')], stdout=log, check=True)
print((out / 'results.txt').read_text())
