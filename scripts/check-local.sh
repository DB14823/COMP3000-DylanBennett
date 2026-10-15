#!/usr/bin/env bash
# AI-assisted tooling: run the same package checks locally and in CI.
set -euo pipefail
cd "$(dirname "$0")/.."

case "${1:-packages}" in
  packages)
    scripts/check-architecture.sh
    for package in Packages/*/; do
      echo "Testing $package"
      # Keep CLI builds separate from Xcode output and caches from old locations.
      swift test --package-path "$package" --scratch-path "$package/.build/cli"
    done
    ;;
  app)
    xcodebuild -workspace Omnimonitor.xcworkspace -scheme Omnimonitor \
      -destination 'generic/platform=iOS Simulator' build
    ;;
  *)
    echo "Usage: scripts/check-local.sh [packages|app]" >&2
    exit 2
    ;;
esac
