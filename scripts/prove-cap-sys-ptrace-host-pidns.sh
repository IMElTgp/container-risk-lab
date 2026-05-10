#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-ptrace-host-pidns}"
PID_FILE="${PID_FILE:-/tmp/container-risk-labs/cap-sys-ptrace-host-pidns/target.pid}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROBE_SRC="${SCRIPT_DIR}/ptrace_attach_probe.go"
TMP_PROBE="$(mktemp /tmp/runtia-ptrace-attach-probe.XXXXXX)"

cleanup() {
    rm -f "${TMP_PROBE}"
}
trap cleanup EXIT

if [[ ! -f "${PID_FILE}" ]]; then
    echo "Missing PID file: ${PID_FILE}" >&2
    echo "Run ./scripts/prepare-cap-sys-ptrace-host-pidns.sh first." >&2
    exit 1
fi

TARGET_PID="$(cat "${PID_FILE}")"
if [[ -z "${TARGET_PID}" ]] || ! kill -0 "${TARGET_PID}" 2>/dev/null; then
    echo "Target PID ${TARGET_PID:-<empty>} is not alive before the probe." >&2
    exit 1
fi

go build -tags labhelpers -o "${TMP_PROBE}" "${PROBE_SRC}"
docker cp "${TMP_PROBE}" "${CONTAINER_NAME}:/tmp/ptrace_attach_probe" >/dev/null

echo "[composition] CAP_SYS_PTRACE + host PID namespace probe"
echo "  container: ${CONTAINER_NAME}"
echo "  target pid: ${TARGET_PID}"

docker exec "${CONTAINER_NAME}" sh -lc "/tmp/ptrace_attach_probe ${TARGET_PID}"

echo "Observed effect: container successfully attached to a controlled host process and detached again."
