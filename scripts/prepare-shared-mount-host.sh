#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script as root because mount propagation changes require CAP_SYS_ADMIN on the host."
    exit 1
fi

BASE_DIR="/tmp/container-risk-labs/shared-mount"
SOURCE_DIR="${BASE_DIR}/source"
SHARED_BIND_DIR="${BASE_DIR}/shared-bind"

mkdir -p "${SOURCE_DIR}" "${SHARED_BIND_DIR}"

if mountpoint -q "${SHARED_BIND_DIR}"; then
    echo "Shared bind mount already exists at ${SHARED_BIND_DIR}"
else
    mount --bind "${SOURCE_DIR}" "${SHARED_BIND_DIR}"
fi

mount --make-shared "${SHARED_BIND_DIR}"

cat > "${SOURCE_DIR}/README.txt" <<'EOF'
This directory is prepared on the host as a bind mount with shared propagation.
The shared-mount scenario re-binds this path into the container with propagation=shared.
EOF

echo "Prepared shared host mount:"
echo "  source:      ${SOURCE_DIR}"
echo "  shared bind: ${SHARED_BIND_DIR}"
findmnt "${SHARED_BIND_DIR}"

