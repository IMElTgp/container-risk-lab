#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-perfmon}"

echo "[capability] CAP_PERFMON probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" /tmp/perf_event_probe

echo "Observed effect: the container opened a perf event directly."
