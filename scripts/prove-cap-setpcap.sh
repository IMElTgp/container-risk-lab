#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-setpcap}"

echo "[capability] CAP_SETPCAP probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" /tmp/setpcap_probe

echo "Observed effect: the container changed its own capability state and turned a non-effective capability into an immediately usable one."
