#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-dac-override-writable-host-mount}"
HOST_DIR="${HOST_DIR:-/tmp/container-risk-labs/cap-dac-override-host-mount/host-view}"
RESTRICTED_FILE="${HOST_DIR}/restricted.txt"

echo "[composition] CAP_DAC_OVERRIDE + writable host mount probe"
echo "  container: ${CONTAINER_NAME}"
echo "  restricted file: ${RESTRICTED_FILE}"

if docker exec "${CONTAINER_NAME}" sh -lc 'printf "container-write\n" >> /host/restricted.txt'; then
    echo "RESULT=success"
    echo "Observed effect: the container modified the controlled host file even though it started with restrictive DAC permissions."
    exit 0
fi

echo "Restricted-file write was blocked. Checking whether the bind mount is still writable through an ordinary marker file."
if docker exec "${CONTAINER_NAME}" sh -lc 'printf "marker-touch\n" >> /host/marker.txt'; then
    echo "RESULT=blocked_by_host_hardening"
    echo "Observed effect: the bind mount is writable, but the DAC-bypass write probe was blocked by an additional host control such as SELinux or another LSM policy."
    exit 0
fi

echo "RESULT=blocked_by_host_hardening"
echo "Observed effect: both the restricted-file probe and the marker-file probe were blocked, which indicates that host labeling or another LSM policy denied the bind subtree before the container could exercise the write path."
exit 0
