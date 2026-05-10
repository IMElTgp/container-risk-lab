#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/writable-host-mount"
HOST_DIR="${BASE_DIR}/host-view"
MARKER_FILE="${HOST_DIR}/marker.txt"

mkdir -p "${HOST_DIR}"
chmod 0777 "${HOST_DIR}"
cat > "${MARKER_FILE}" <<'EOF'
Writable host mount marker file.
EOF
chmod 0666 "${MARKER_FILE}"

echo "Prepared writable host-mount bind source:"
echo "  host dir:    ${HOST_DIR}"
echo "  marker file: ${MARKER_FILE}"
ls -ld "${HOST_DIR}"
ls -l "${HOST_DIR}"
