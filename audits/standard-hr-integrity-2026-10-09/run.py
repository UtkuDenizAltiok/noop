#!/usr/bin/env python3
"""Compile verbatim old/new production Swift parsers and compare every returned field."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

repo, cache = map(lambda p: Path(p).resolve(), sys.argv[1:3])
here = Path(__file__).resolve().parent
cache.mkdir(parents=True, exist_ok=True)


def git(*args):
    return subprocess.check_output(["git", "-C", str(repo), *args], text=True)


base = git("rev-parse", "eae23433").strip()
streams = git("show", base + ":Packages/WhoopProtocol/Sources/WhoopProtocol/Streams.swift")
start = streams.index("public enum StandardHRContact:")
end = streams.index("{", start) + 1
depth = 1
while depth:
    depth += (streams[end] == "{") - (streams[end] == "}")
    end += 1
contact = streams[start:end]
original = git("show", base + ":Strand/BLE/StandardHeartRate.swift")
candidate = (repo / "Strand/BLE/StandardHeartRate.swift").read_text()
predicate = (repo / "Packages/WhoopProtocol/Sources/WhoopProtocol/StandardHRMeasurement.swift").read_text()
sources = {
    "Contact.swift": contact,
    "Original.swift": original.replace("import WhoopProtocol\n", "").replace(
        "public enum StandardHeartRate", "public enum OriginalStandardHeartRate"),
    "Candidate.swift": candidate.replace("import WhoopProtocol\n", ""),
    "Predicate.swift": predicate,
    "main.swift": (here / "Audit.swift").read_text(),
}
for name, source in sources.items():
    (cache / name).write_text(source)
subprocess.run(["swiftc", "-O", *map(lambda name: str(cache / name), sources), "-o", str(cache / "audit")], check=True)
output = subprocess.check_output([str(cache / "audit")], text=True)
result = json.loads(output)
result.update({"base": base, "head": git("rev-parse", "HEAD").strip(),
               "sourceDigests": {name: hashlib.sha256(value.encode()).hexdigest()
                                 for name, value in [("originalParser", original), ("candidateParser", candidate), ("predicate", predicate)]}})
(cache / "result.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result, indent=2))
