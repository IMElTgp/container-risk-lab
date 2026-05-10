#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-sys-rawio"
HELPER_SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/sysrawio_probe.go"
HELPER_BIN="${BASE_DIR}/sysrawio_probe"

mkdir -p "${BASE_DIR}"
go build -tags labhelpers -o "${HELPER_BIN}" "${HELPER_SRC}"

echo "Prepared CAP_SYS_RAWIO helper:"
echo "  base dir: ${BASE_DIR}"
echo "  helper:   ${HELPER_BIN}"
