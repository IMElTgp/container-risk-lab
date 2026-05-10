#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-perfmon"

rm -rf "${BASE_DIR}"

echo "Cleaned CAP_PERFMON lab state from ${BASE_DIR}"
