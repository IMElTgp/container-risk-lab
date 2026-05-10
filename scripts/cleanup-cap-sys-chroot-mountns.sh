#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-sys-chroot-mountns"

rm -rf "${BASE_DIR}"

echo "Cleaned CAP_SYS_CHROOT mount-namespace lab state from ${BASE_DIR}"
