#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-net-admin}"
TEST_ADDR="${TEST_ADDR:-198.51.100.10/32}"
HOST_DEV="${HOST_DEV:-lo}"

echo "[capability] CAP_NET_ADMIN probe"
echo "  container: ${CONTAINER_NAME}"
echo "  test addr: ${TEST_ADDR}"

network_mode="$(docker inspect -f '{{.HostConfig.NetworkMode}}' "${CONTAINER_NAME}")"
container_netns="$(docker exec "${CONTAINER_NAME}" readlink /proc/self/ns/net)"

echo "  docker network mode: ${network_mode}"
echo "  container netns: ${container_netns}"

if [[ "${network_mode}" == "host" ]]; then
    echo "Container uses host network mode; refusing to run CAP_NET_ADMIN proof." >&2
    exit 1
fi

docker exec "${CONTAINER_NAME}" sh -lc "ip addr add ${TEST_ADDR} dev ${HOST_DEV} && ip -o addr show dev ${HOST_DEV}"

if ip -o addr show dev "${HOST_DEV}" | grep -q "${TEST_ADDR%/*}"; then
    echo "Host interface ${HOST_DEV} unexpectedly gained ${TEST_ADDR%/*}" >&2
    exit 1
fi

echo "Observed effect: the container changed its own network namespace state without changing the host interface."
