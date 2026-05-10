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
SOURCE_DIR="${BASE_DIR}/source"
SHARED_BIND_DIR="${BASE_DIR}/shared-bind"

mkdir -p "${SOURCE_DIR}" "${SHARED_BIND_DIR}"

run_in_host_mountns "mkdir -p '${SOURCE_DIR}' '${SHARED_BIND_DIR}'; if mountpoint -q '${SHARED_BIND_DIR}'; then echo 'Shared bind mount already exists at ${SHARED_BIND_DIR}'; else mount --bind '${SOURCE_DIR}' '${SHARED_BIND_DIR}'; fi; mount --make-shared '${SHARED_BIND_DIR}'; chmod 0777 '${SOURCE_DIR}' '${SHARED_BIND_DIR}'"

cat > "${SOURCE_DIR}/README.txt" <<'EOF'
This directory is prepared on the host as a bind mount with shared propagation.
The shared-mount scenario re-binds this path into the container with propagation=shared.
EOF

echo "Prepared shared host mount:"
echo "  source:      ${SOURCE_DIR}"
echo "  shared bind: ${SHARED_BIND_DIR}"
run_in_host_mountns "findmnt '${SHARED_BIND_DIR}'"
