#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-module}"
HELPER_PATH="${HELPER_PATH:-/labhelpers/sysmodule_probe}"

echo "[capability] CAP_SYS_MODULE probe"
echo "  container: ${CONTAINER_NAME}"
echo "  proof mode: non-existent module deletion, no host module state change"

docker exec "${CONTAINER_NAME}" "${HELPER_PATH}"

echo "Observed effect: the container reached the privileged module-management path without loading or unloading a real kernel module."
