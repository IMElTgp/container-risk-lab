#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-shared-mount}"
HOST_SHARED_DIR="${HOST_SHARED_DIR:-/tmp/container-risk-labs/shared-mount/shared-bind}"
HOST_PROPAGATED_MOUNT="${HOST_PROPAGATED_MOUNT:-${HOST_SHARED_DIR}/from-host}"
CONTAINER_PROPAGATED_MOUNT="${CONTAINER_PROPAGATED_MOUNT:-/lab/shared-mount/from-host}"

run_in_host_mountns() {
    local cmd="$1"
    docker run --rm --privileged --pid host -e HOST_MOUNT_NS_CMD="${cmd}" -v /tmp/container-risk-labs:/tmp/container-risk-labs \
        container-risk-labs-toolbox:local \
        sh -lc 'nsenter -t 1 -m sh -lc "$HOST_MOUNT_NS_CMD"'
}

cleanup() {
    run_in_host_mountns "if mountpoint -q '${HOST_PROPAGATED_MOUNT}'; then umount '${HOST_PROPAGATED_MOUNT}'; fi; rmdir '${HOST_PROPAGATED_MOUNT}' 2>/dev/null || true" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[high-risk] shared mount propagation visibility probe"
echo "  container: ${CONTAINER_NAME}"
echo "  host propagated mount: ${HOST_PROPAGATED_MOUNT}"

run_in_host_mountns "mkdir -p '${HOST_PROPAGATED_MOUNT}'; mount -t tmpfs tmpfs '${HOST_PROPAGATED_MOUNT}'; printf 'from-host-shared-propagation\n' > '${HOST_PROPAGATED_MOUNT}/proof.txt'"

docker exec "${CONTAINER_NAME}" sh -lc "test -f '${CONTAINER_PROPAGATED_MOUNT}/proof.txt' && cat '${CONTAINER_PROPAGATED_MOUNT}/proof.txt' && grep ' ${CONTAINER_PROPAGATED_MOUNT} ' /proc/self/mountinfo >/dev/null"

echo "Observed effect: a host-side mount under the controlled shared subtree became visible inside the container."
