#!/usr/bin/env bash
# Check the testing-latest release against an expected testing-build commit, the way ship-build.sh does, and look
# for an expected English string in the .ipa's German strings (proof the new build's strings shipped).
#   bash release-check.sh <expected-sha> "<english key>"
set -uo pipefail
FORK=UtkuDenizAltiok/noop SHA=$1 KEY=$2
target=$(gh release view testing-latest --repo "$FORK" --json targetCommitish --jq .targetCommitish)
rid=$(gh api "repos/$FORK/releases" --jq '.[] | select(.tag_name == "testing-latest") | .id' | head -1)
gh api "repos/$FORK/releases/$rid/assets" --jq '.[] | select(.state == "uploaded") | "\(.name) \(.size) \(.updated_at)"'
echo "target ${target:0:8} (expected ${SHA:0:8})"; [ "$target" = "$SHA" ] || { echo "WRONG TARGET"; exit 1; }
ipa=$(gh api "repos/$FORK/releases/$rid/assets" --jq '.[] | select(.name | test("^NOOP-ios-unsigned-.*\\.ipa$")) | .name' | head -1)
code=$(curl -s -o /dev/null -I -L -w '%{http_code}' "https://github.com/$FORK/releases/download/testing-latest/$ipa")
echo "ipa $ipa HTTP $code"; [ "$code" = 200 ] || exit 1
D=$(mktemp -d "${TMPDIR:-/tmp}/ipa.XXXXXX"); curl -s -L -o "$D/app.ipa" "https://github.com/$FORK/releases/download/testing-latest/$ipa"
shasum -a 256 "$D/app.ipa" | cut -c1-16
unzip -q -o "$D/app.ipa" 'Payload/*/de.lproj/Localizable.strings' -d "$D" 2>/dev/null
F=$(find "$D/Payload" -path '*de.lproj/Localizable.strings' | head -1)
if [ -n "$F" ] && plutil -convert json -o - "$F" | /opt/homebrew/bin/python3.12 -c "import json,sys; d=json.load(sys.stdin); k=sys.argv[1]; print('de string:', d.get(k, 'MISSING'))" "$KEY"; then :; else echo "no de.lproj strings found"; fi
rm -rf "$D"
