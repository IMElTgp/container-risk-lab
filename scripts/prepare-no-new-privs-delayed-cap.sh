#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/no-new-privs-delayed-cap"
HELPER_SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/delayed_cap_helper.go"
HELPER_BIN="${BASE_DIR}/delayed_cap_helper"

mkdir -p "${BASE_DIR}"
go build -tags labhelpers -o "${HELPER_BIN}" "${HELPER_SRC}"

echo "Prepared delayed capability helper:"
echo "  base dir: ${BASE_DIR}"
echo "  helper:   ${HELPER_BIN}"
