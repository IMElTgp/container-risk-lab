#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-sys-ptrace-host-pidns"
PID_FILE="${BASE_DIR}/target.pid"

mkdir -p "${BASE_DIR}"

if [[ -f "${PID_FILE}" ]]; then
    existing_pid="$(cat "${PID_FILE}")"
    if [[ -n "${existing_pid}" ]] && kill -0 "${existing_pid}" 2>/dev/null; then
        echo "Host test process already running with PID ${existing_pid}"
        exit 0
    fi
fi

sleep 600 &
target_pid=$!
printf '%s\n' "${target_pid}" > "${PID_FILE}"

echo "Prepared host PID namespace CAP_SYS_PTRACE target:"
echo "  pid file: ${PID_FILE}"
echo "  target PID: ${target_pid}"
echo "  owner uid: $(id -u)"
