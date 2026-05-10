#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-setfcap}"

echo "[capability] CAP_SETFCAP probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" sh -lc 'cp /bin/sh /tmp/shcap && setcap cap_net_raw+ep /tmp/shcap && getcap /tmp/shcap'

echo "Observed effect: the container stamped a file capability onto an executable, creating a future privilege-carrying binary."
