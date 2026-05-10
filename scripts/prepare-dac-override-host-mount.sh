#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-dac-override-host-mount"
HOST_DIR="${BASE_DIR}/host-view"
RESTRICTED_FILE="${HOST_DIR}/restricted.txt"
MARKER_FILE="${HOST_DIR}/marker.txt"

mkdir -p "${HOST_DIR}"

cat > "${RESTRICTED_FILE}" <<'EOF'
This file starts with mode 000. The cap-dac-override-writable-host-mount scenario uses it to show that a container with CAP_DAC_OVERRIDE can still modify a controlled host bind mount.
EOF
chmod 000 "${RESTRICTED_FILE}"

cat > "${MARKER_FILE}" <<'EOF'
This file is writable by ordinary DAC checks and acts only as a directory marker.
EOF

echo "Prepared DAC override host bind source:"
echo "  host dir:        ${HOST_DIR}"
echo "  restricted file: ${RESTRICTED_FILE}"
ls -l "${HOST_DIR}"

