#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-mknod}"

echo "[capability] CAP_MKNOD probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" sh -lc 'rm -f /tmp/test-null && mknod /tmp/test-null c 1 3 && stat -c "%F %t:%T" /tmp/test-null'

echo "Observed effect: the container created a character device node directly."
