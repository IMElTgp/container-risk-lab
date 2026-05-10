#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-net-raw"
HELPER_SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/raw_socket_probe.go"
HELPER_BIN="${BASE_DIR}/raw_socket_probe"

mkdir -p "${BASE_DIR}"
go build -tags labhelpers -o "${HELPER_BIN}" "${HELPER_SRC}"

echo "Prepared CAP_NET_RAW helper:"
echo "  base dir: ${BASE_DIR}"
echo "  helper:   ${HELPER_BIN}"
