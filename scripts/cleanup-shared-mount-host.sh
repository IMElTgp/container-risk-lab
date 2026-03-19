#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root because unmounting the shared bind requires host privileges."
    exit 1
fi

BASE_DIR="/tmp/container-risk-labs/shared-mount"
SHARED_BIND_DIR="${BASE_DIR}/shared-bind"

if mountpoint -q "${SHARED_BIND_DIR}"; then
    umount "${SHARED_BIND_DIR}"
fi

rm -rf "${BASE_DIR}"

echo "Cleaned shared mount lab state from ${BASE_DIR}"

