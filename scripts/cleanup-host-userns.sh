#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/host-userns"

rm -rf "${BASE_DIR}"

echo "Cleaned host-userns lab state from ${BASE_DIR}"
