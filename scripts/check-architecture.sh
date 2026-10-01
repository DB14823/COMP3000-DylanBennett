#!/usr/bin/env bash
# Fails the build if a package declares a dependency the architecture forbids.
# Uses `swift package dump-package` (JSON manifest) + jq, so it checks the real
# resolved manifest rather than grepping source text.
set -euo pipefail
cd "$(dirname "$0")/../Packages"

# package -> space-separated list of packages it must NOT depend on
declare -A FORBIDDEN=(
  [Domain]="PumpPort SafetyKit LoopEngine FoodVision Persistence OrefAdapter SimulationKit"
  [LoopEngine]="PumpPort"
  [FoodVision]="PumpPort SafetyKit LoopEngine"
  [Persistence]="PumpPort SafetyKit LoopEngine"
  [OrefAdapter]="PumpPort SafetyKit LoopEngine"
)

status=0
for pkg in "${!FORBIDDEN[@]}"; do
  if [[ ! -d "$pkg" ]]; then echo "MISSING package: $pkg"; status=1; continue; fi
  deps=$(swift package --package-path "$pkg" dump-package \
         | jq -r '.dependencies[]? | (.fileSystem[0].identity // .sourceControl[0].identity // empty)')
  for bad in ${FORBIDDEN[$pkg]}; do
    if grep -qix "$bad" <<<"$deps"; then
      echo "VIOLATION: $pkg must not depend on $bad"; status=1
    fi
  done
done
[[ $status -eq 0 ]] && echo "Architecture OK"
exit $status
