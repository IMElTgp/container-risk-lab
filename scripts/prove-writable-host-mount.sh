#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-writable-host-mount}"
HOST_DIR="${HOST_DIR:-/tmp/container-risk-labs/writable-host-mount/host-view}"
MARKER_FILE="${HOST_DIR}/marker.txt"

echo "[mount] writable host mount probe"
echo "  container: ${CONTAINER_NAME}"
echo "  marker file: ${MARKER_FILE}"

docker exec "${CONTAINER_NAME}" sh -lc 'printf "container-write\n" >> /host/marker.txt'

if ! grep -q 'container-write' "${MARKER_FILE}"; then
    echo "Host marker file did not record container write" >&2
    exit 1
fi

echo "Observed effect: an ordinary write from inside the container modified the controlled host bind mount."
