#!/usr/bin/env bash
# check-xcsset.sh — XCSSET malware guard
# Scans the .xcodeproj for known malware injection patterns.
# Run before every commit. CI also runs this.

set -euo pipefail

PROJ="${1:-$(find . -name '*.xcodeproj' | head -1)}"
PBX="$PROJ/project.pbxproj"

if [[ ! -f "$PBX" ]]; then
    echo "❌  project.pbxproj not found at $PBX"
    exit 1
fi

echo "🔍  Scanning $PBX for XCSSET indicators..."

PATTERNS=(
    "xxd -p -r"
    "base64.*|.*sh"
    "curl.*|.*sh"
    "Build Target Libraries"
    "Compile Code Assets"
    "Provision Library Executable"
    "Link Libraries Executable"
    "Copy Target Symbols"
)

FOUND=0
for pattern in "${PATTERNS[@]}"; do
    if grep -qE "$pattern" "$PBX"; then
        echo "🚨  Suspicious pattern found: $pattern"
        FOUND=1
    fi
done

# Check for unexpected shell script build phases (not CocoaPods)
PHASE_COUNT=$(grep -c "PBXShellScriptBuildPhase" "$PBX" || true)
if [[ "$PHASE_COUNT" -gt 2 ]]; then
    echo "⚠️   Unexpected number of PBXShellScriptBuildPhases: $PHASE_COUNT (expected ≤2)"
fi

if [[ "$FOUND" -eq 1 ]]; then
    echo ""
    echo "❌  XCSSET check FAILED. Review project.pbxproj before committing."
    exit 1
fi

echo "✅  XCSSET check passed."
