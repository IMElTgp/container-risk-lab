#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/ro-parent-rw-child"

rm -rf "${BASE_DIR}"

echo "Cleaned ro-parent-rw-child lab state from ${BASE_DIR}"

