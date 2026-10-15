#!/usr/bin/env bash
# Fails the build if a package declares a dependency the architecture forbids.
# Uses `swift package dump-package` (JSON manifest) + jq, so it checks the real
# resolved manifest rather than grepping source text.
# AI-assisted tooling. Compatible with macOS's Bash 3.2.
set -euo pipefail
cd "$(dirname "$0")/../Packages"

status=0
# Each row names a package followed by dependencies it must not declare.
# Read rows instead of using associative arrays, which require Bash 4 or later.
while read -r pkg forbidden; do
  if [[ ! -d "$pkg" ]]; then echo "MISSING package: $pkg"; status=1; continue; fi
  deps=$(swift package --package-path "$pkg" dump-package \
         | jq -r '.dependencies[]? | (.fileSystem[0].identity // .sourceControl[0].identity // empty)')
  for bad in $forbidden; do
    if grep -qix "$bad" <<<"$deps"; then
      echo "VIOLATION: $pkg must not depend on $bad"; status=1
    fi
  done
done <<'RULES'
Domain PumpPort SafetyKit LoopEngine FoodVision Persistence OrefAdapter SimulationKit
LoopEngine PumpPort
FoodVision PumpPort SafetyKit LoopEngine
Persistence PumpPort SafetyKit LoopEngine
OrefAdapter PumpPort SafetyKit LoopEngine
RULES
[[ $status -eq 0 ]] && echo "Architecture OK"
exit $status
