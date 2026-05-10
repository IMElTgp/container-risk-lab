#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/cap-dac-override-host-mount"

rm -rf "${BASE_DIR}"

echo "Cleaned DAC override host-mount lab state from ${BASE_DIR}"

