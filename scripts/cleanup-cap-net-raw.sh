#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-net-raw"

rm -rf "${BASE_DIR}"

echo "Cleaned CAP_NET_RAW lab state from ${BASE_DIR}"
