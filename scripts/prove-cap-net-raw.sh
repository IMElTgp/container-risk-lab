#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-net-raw}"

echo "[capability] CAP_NET_RAW probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" /tmp/raw_socket_probe

echo "Observed effect: the container opened a raw packet socket directly."
