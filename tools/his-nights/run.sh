#!/usr/bin/env bash
# Stage Utku's recorded nights (a COPY of his backup's SQLite) with SleepStagerV2 and with variants of its RSA
# respiration term, via Tools/SleepPSG's knob-for-knob port (`RecipePort.swift`, copied in at build time so no
# upstream code lives on this public branch). Local only: the database is personal and is never committed.
#   bash dist/tools/his-nights/run.sh <noop-backup.sqlite> [<Tools/SleepPSG/Sources/sleeppsg dir>]
# Prints, per night and for each variant, deep / REM / light as % of sleep and wake as % of the window, plus
# the shipped stager itself (StrandAnalytics) as a check that the port reproduces it on these nights.
set -euo pipefail
DB="${1:?usage: run.sh <noop-backup.sqlite> [sleeppsg source dir]}"
SRC="${2:-$HOME/Developer/noop-dreamt/Tools/SleepPSG/Sources/sleeppsg}"
REPO="$(cd "$(dirname "$0")/../../.." && pwd)"
W="$HOME/Library/Caches/noop-handbook/his-nights"
mkdir -p "$W/Sources/hisnights"
cp "$(dirname "$0")/main.swift" "$W/Sources/hisnights/main.swift"
cp "$SRC/RecipePort.swift" "$W/Sources/hisnights/RecipePort.swift"
cat > "$W/Package.swift" <<PKG
// swift-tools-version:5.9
import PackageDescription
let package = Package(name: "hisnights", platforms: [.macOS(.v13)],
    dependencies: [.package(path: "$REPO/Packages/StrandAnalytics"), .package(path: "$REPO/Packages/WhoopProtocol")],
    targets: [.executableTarget(name: "hisnights", dependencies: ["StrandAnalytics", "WhoopProtocol"],
                                linkerSettings: [.linkedLibrary("sqlite3")])])
PKG
(cd "$W" && swift build -c release 2>&1 | grep -E 'error|Build complete' >&2)
"$W/.build/release/hisnights" "$DB"
