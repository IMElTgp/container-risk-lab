#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-setpcap"

rm -rf "${BASE_DIR}"

echo "Cleaned CAP_SETPCAP lab state from ${BASE_DIR}"
