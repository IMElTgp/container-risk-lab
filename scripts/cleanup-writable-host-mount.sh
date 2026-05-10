#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/writable-host-mount"

rm -rf "${BASE_DIR}"

echo "Cleaned writable host-mount lab state from ${BASE_DIR}"
