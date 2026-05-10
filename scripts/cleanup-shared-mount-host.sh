#!/usr/bin/env bash
set -euo pipefail

run_in_host_mountns() {
    local cmd="$1"
    if [[ "${EUID}" -eq 0 ]]; then
        sh -lc "${cmd}"
        return
    fi

    docker run --rm --privileged --pid host -e HOST_MOUNT_NS_CMD="${cmd}" -v /tmp/container-risk-labs:/tmp/container-risk-labs \
        container-risk-labs-toolbox:local \
        sh -lc 'nsenter -t 1 -m sh -lc "$HOST_MOUNT_NS_CMD"'
}

BASE_DIR="/tmp/container-risk-labs/shared-mount"
SHARED_BIND_DIR="${BASE_DIR}/shared-bind"

run_in_host_mountns "if mountpoint -q '${SHARED_BIND_DIR}/from-container'; then umount '${SHARED_BIND_DIR}/from-container'; fi; if mountpoint -q '${SHARED_BIND_DIR}'; then umount '${SHARED_BIND_DIR}'; fi; rm -rf '${BASE_DIR}'"

echo "Cleaned shared mount lab state from ${BASE_DIR}"
