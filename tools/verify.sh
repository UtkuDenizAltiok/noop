#!/usr/bin/env bash
# The full verification loop for the checked-out branch, cheapest first. Each step's log is kept.
#   bash dist/tools/verify.sh            everything
#   bash dist/tools/verify.sh --quick    skip the Xcode app targets (macOS tests, iOS build)
# Android is not local: gh workflow run "Android CI" --repo UtkuDenizAltiok/noop --ref <branch>
set -uo pipefail
REPO=${NOOP_REPO:-$(cd "$(dirname "$0")/../.." && pwd)}
cd "$REPO"
OUT="${TMPDIR:-/tmp}/lift-verify/$(git rev-parse --short HEAD)"; DD="${TMPDIR:-/tmp}/lift-verify/derived"
mkdir -p "$OUT"
failed=0

step() {  # step <name> <command…>
  local name=$1; shift
  printf '  %-20s' "$name"
  if "$@" >"$OUT/$name.log" 2>&1; then echo "ok"; else echo "FAILED — $OUT/$name.log"; failed=1; fi
  grep -h -E "Executed [0-9]+ tests|^Ran [0-9]+ test|\*\* BUILD (SUCCEEDED|FAILED)" "$OUT/$name.log" | tail -1 | sed 's/^[[:space:]]*/      /'
}

macos_tests() {  # ok when the only failures are the two known locale-dependent TodayCarryOverTests
  local args=(test -project Strand.xcodeproj -scheme Strand -destination platform=macOS
              -derivedDataPath "$DD/mac" CODE_SIGNING_ALLOWED=NO)
  xcodebuild "${args[@]}"
  grep -q -E "Executed [0-9]+ tests" "$OUT/macos-tests.log" || return 1
  ! grep -E "error: -\[StrandTests\." "$OUT/macos-tests.log" | grep -v -q "TodayCarryOverTests"
}

ios_build() {
  local args=(build -project Strand.xcodeproj -scheme NOOPiOS -destination "generic/platform=iOS Simulator"
              -derivedDataPath "$DD/ios" CODE_SIGNING_ALLOWED=NO)
  xcodebuild "${args[@]}"
}

governance() (   # a subshell, so the cd cannot leak into the steps that follow
  cd Tools && "$PY" -m unittest tests.test_parity_ledger tests.test_parity_governance_acceptance \
    tests.test_rr_legacy_preservation_contract tests.test_parity_disposition_kinds
)

# The parity tools need Python 3.12+ (CI's version; 3.9 lacks tarfile's extraction filter).
PY=python3
for v in python3.13 python3.12; do command -v "$v" >/dev/null && { PY=$v; break; }; done
modern_python() { "$PY" -c 'import sys; sys.exit(sys.version_info < (3, 12))'; }

git fetch -q upstream
echo "verifying $(git rev-parse --abbrev-ref HEAD) @ $(git rev-parse --short HEAD) on upstream/main $(git rev-parse --short upstream/main)"
for p in WhoopStore StrandAnalytics StrandImport; do step "swift-$p" swift test --package-path "Packages/$p"; done
step doc-lint          "$PY" Tools/doc_comment_lint.py
step i18n              "$PY" Tools/i18n_audit.py --ci upstream/main
step parity-ledger     "$PY" Tools/parity_ledger.py
if modern_python; then
  step parity-ratchet    "$PY" Tools/parity_ratchet.py --base upstream/main --offline
  step parity-governance governance
else
  echo "  parity-ratchet      SKIPPED — needs Python 3.12+ ($("$PY" --version 2>&1)); not verified"
  echo "  parity-governance   SKIPPED — needs Python 3.12+; not verified"
  failed=1
fi
if [ "${1:-}" != "--quick" ]; then
  step xcodegen        xcodegen generate
  step macos-tests     macos_tests
  step ios-build       ios_build
fi
echo "logs: $OUT"
[ $failed = 0 ] && echo "all steps passed" || echo "some steps FAILED — read their logs; compare with upstream/main before blaming the branch"
exit $failed
