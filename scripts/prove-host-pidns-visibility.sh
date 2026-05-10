#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-host-pidns}"
PID_FILE="${PID_FILE:-/tmp/container-risk-labs/host-pidns-visibility/target.pid}"

if [[ ! -f "${PID_FILE}" ]]; then
    echo "Missing PID file: ${PID_FILE}" >&2
    echo "Run ./scripts/prepare-host-pidns-visibility.sh first." >&2
    exit 1
fi

TARGET_PID="$(cat "${PID_FILE}")"
if [[ -z "${TARGET_PID}" ]] || ! kill -0 "${TARGET_PID}" 2>/dev/null; then
    echo "Target PID ${TARGET_PID:-<empty>} is not alive." >&2
    exit 1
fi

echo "[high-risk] host PID namespace visibility probe"
echo "  container: ${CONTAINER_NAME}"
echo "  target pid: ${TARGET_PID}"

docker exec "${CONTAINER_NAME}" sh -lc "
set -euo pipefail
test -d /proc/${TARGET_PID}
ps -o pid=,comm= -p ${TARGET_PID}
"

echo "Observed effect: container can see a controlled host process through /proc and ps."
