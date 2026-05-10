#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-kill-host-pidns}"
PID_FILE="${PID_FILE:-/tmp/container-risk-labs/cap-kill-host-pidns/target.pid}"

if [[ ! -f "${PID_FILE}" ]]; then
    echo "Missing PID file: ${PID_FILE}" >&2
    echo "Run ./scripts/prepare-cap-kill-host-pidns.sh first." >&2
    exit 1
fi

TARGET_PID="$(cat "${PID_FILE}")"
if [[ -z "${TARGET_PID}" ]] || ! kill -0 "${TARGET_PID}" 2>/dev/null; then
    echo "Target PID ${TARGET_PID:-<empty>} is not alive before the probe." >&2
    exit 1
fi

echo "[composition] CAP_KILL + host PID namespace probe"
echo "  container: ${CONTAINER_NAME}"
echo "  target pid: ${TARGET_PID}"

docker exec "${CONTAINER_NAME}" sh -lc "
set -euo pipefail
kill -TERM ${TARGET_PID}
"

for _ in 1 2 3 4 5; do
    if ! kill -0 "${TARGET_PID}" 2>/dev/null; then
        echo "Observed effect: controlled host process ${TARGET_PID} was terminated from inside the container."
        exit 0
    fi
    sleep 1
done

echo "Target process ${TARGET_PID} is still alive after the probe." >&2
exit 1
