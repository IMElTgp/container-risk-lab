#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-perfmon"
HELPER_SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/perf_event_probe.go"
HELPER_BIN="${BASE_DIR}/perf_event_probe"

mkdir -p "${BASE_DIR}"
go build -tags labhelpers -o "${HELPER_BIN}" "${HELPER_SRC}"

echo "Prepared CAP_PERFMON helper:"
echo "  base dir: ${BASE_DIR}"
echo "  helper:   ${HELPER_BIN}"
