#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/tmp/container-risk-labs/no-new-privs-delayed-cap"

rm -rf "${BASE_DIR}"

echo "Cleaned delayed capability lab state from ${BASE_DIR}"
