#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-bpf"
HELPER_SRC="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/bpf_prog_test_run_probe.go"
HELPER_BIN="${BASE_DIR}/bpf_prog_test_run_probe"

mkdir -p "${BASE_DIR}"
go build -tags labhelpers -o "${HELPER_BIN}" "${HELPER_SRC}"

echo "Prepared CAP_BPF helper:"
echo "  base dir: ${BASE_DIR}"
echo "  helper:   ${HELPER_BIN}"
