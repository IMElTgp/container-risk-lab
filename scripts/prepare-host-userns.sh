#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/host-userns"
HOST_DIR="${BASE_DIR}/host-view"

mkdir -p "${HOST_DIR}"
chmod 0777 "${HOST_DIR}"
rm -f "${HOST_DIR}/from-container.txt"

cat > "${HOST_DIR}/README.txt" <<'EOF'
This directory is mounted into the host-userns scenario to observe host-meaning UID/GID semantics.
EOF

echo "Prepared host-userns bind source:"
echo "  host dir: ${HOST_DIR}"
ls -ld "${HOST_DIR}"
ls -l "${HOST_DIR}"
