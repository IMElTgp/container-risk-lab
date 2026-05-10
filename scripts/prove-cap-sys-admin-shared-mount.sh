#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-admin-shared-mount}"
HOST_MOUNT="${HOST_MOUNT:-/tmp/container-risk-labs/shared-mount/shared-bind/from-container}"
CONTAINER_MOUNT="${CONTAINER_MOUNT:-/lab/shared-mount/from-container}"

cleanup() {
    docker exec "${CONTAINER_NAME}" sh -lc "if mountpoint -q '${CONTAINER_MOUNT}'; then umount '${CONTAINER_MOUNT}'; fi; rmdir '${CONTAINER_MOUNT}' 2>/dev/null || true" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[composition] CAP_SYS_ADMIN + shared mount propagation probe"
echo "  container: ${CONTAINER_NAME}"
echo "  host mount: ${HOST_MOUNT}"

docker exec "${CONTAINER_NAME}" sh -lc "mkdir -p '${CONTAINER_MOUNT}' && mount -t tmpfs tmpfs '${CONTAINER_MOUNT}' && grep \" ${CONTAINER_MOUNT} \" /proc/self/mountinfo >/dev/null"
findmnt "${HOST_MOUNT}" >/dev/null

echo "Observed effect: a tmpfs mounted inside the container propagated onto the controlled host bind subtree."
