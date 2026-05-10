#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/host-pidns-visibility"
PID_FILE="${BASE_DIR}/target.pid"

if [[ -f "${PID_FILE}" ]]; then
    target_pid="$(cat "${PID_FILE}")"
    if [[ -n "${target_pid}" ]] && kill -0 "${target_pid}" 2>/dev/null; then
        kill "${target_pid}" 2>/dev/null || true
        wait "${target_pid}" 2>/dev/null || true
    fi
fi

rm -rf "${BASE_DIR}"

echo "Cleaned host PID namespace visibility lab state from ${BASE_DIR}"
