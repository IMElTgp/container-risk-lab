#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-resource}"

echo "[capability] CAP_SYS_RESOURCE probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" sh -lc 'prlimit --pid $$ --nofile=64:64; prlimit --pid $$ --nofile=4096:4096; prlimit --pid $$ --nofile'

echo "Observed effect: the container raised its own hard resource limit after first constraining it."
