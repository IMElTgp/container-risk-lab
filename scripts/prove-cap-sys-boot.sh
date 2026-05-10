#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-boot}"
HELPER_PATH="${HELPER_PATH:-/labhelpers/sysboot_probe}"

echo "[capability] CAP_SYS_BOOT probe"
echo "  container: ${CONTAINER_NAME}"
echo "  proof mode: private pid namespace + invalid reboot command"

pid_mode="$(docker inspect -f '{{.HostConfig.PidMode}}' "${CONTAINER_NAME}")"
if [[ -n "${pid_mode}" && "${pid_mode}" == "host" ]]; then
    echo "Container uses host PID namespace; refusing to run CAP_SYS_BOOT proof." >&2
    exit 1
fi

docker exec "${CONTAINER_NAME}" "${HELPER_PATH}"

echo "Observed effect: the container passed the reboot capability gate in its own PID namespace without issuing a real reboot command."
