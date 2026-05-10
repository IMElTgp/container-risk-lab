#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-rawio}"
HELPER_PATH="${HELPER_PATH:-/labhelpers/sysrawio_probe}"

echo "[capability] CAP_SYS_RAWIO probe"
echo "  container: ${CONTAINER_NAME}"
echo "  proof mode: grant per-thread port I/O permission only"

docker exec "${CONTAINER_NAME}" "${HELPER_PATH}"

echo "Observed effect: the container granted direct I/O-port access to its own thread without touching host-global kernel state."
