#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/ro-parent-rw-child"
PARENT_DIR="${BASE_DIR}/parent"
CHILD_DIR="${PARENT_DIR}/writable-child"

mkdir -p "${CHILD_DIR}"

cat > "${PARENT_DIR}/parent-only.txt" <<'EOF'
The parent directory is mounted read-only into the container.
EOF

cat > "${CHILD_DIR}/child-rw.txt" <<'EOF'
The child directory is mounted again as read-write on top of the read-only parent subtree.
EOF

echo "Prepared nested bind sources:"
echo "  parent: ${PARENT_DIR}"
echo "  child:  ${CHILD_DIR}"

