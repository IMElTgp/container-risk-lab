#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-dac-override-single}"

echo "[capability] CAP_DAC_OVERRIDE probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" sh -lc 'printf "x" >> /lab/restricted.txt && cat /lab/restricted.txt && stat -c "%s %a" /lab/restricted.txt'

echo "Observed effect: the container modified a controlled file whose DAC mode was 000."
