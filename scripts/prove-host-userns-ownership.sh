#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-host-userns}"
HOST_DIR="${HOST_DIR:-/tmp/container-risk-labs/host-userns/host-view}"
HOST_FILE="${HOST_DIR}/from-container.txt"

echo "[namespace] host user namespace ownership-semantics probe"
echo "  container: ${CONTAINER_NAME}"
echo "  host file: ${HOST_FILE}"

docker exec "${CONTAINER_NAME}" sh -lc 'id -u && cat /proc/self/uid_map && printf "host-userns-proof\n" > /lab-host/from-container.txt' >/tmp/host-userns-proof.txt

host_owner="$(stat -c '%u:%g' "${HOST_FILE}")"
container_uid_map="$(cat /tmp/host-userns-proof.txt)"
rm -f /tmp/host-userns-proof.txt

if [[ "${host_owner}" != "0:0" ]]; then
    echo "Expected host-owned file from container root, got ${host_owner}" >&2
    exit 1
fi

echo "Observed effect: container root created a file on the host bind mount with host ownership ${host_owner}."
echo "Container-side evidence:"
printf '%s\n' "${container_uid_map}"
