#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-dac-read-search}"

echo "[capability] CAP_DAC_READ_SEARCH probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" sh -lc 'cat /lab/restricted.txt && stat -c "%s %a" /lab/restricted.txt'

echo "Observed effect: the container read a controlled file whose DAC mode was 000."
