#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-bpf}"
HELPER_PATH="${HELPER_PATH:-/labhelpers/bpf_prog_test_run_probe}"

echo "[capability] CAP_BPF probe"
echo "  container: ${CONTAINER_NAME}"
echo "  proof mode: load and test-run only; no attach, no pin, no host hook"

docker exec "${CONTAINER_NAME}" "${HELPER_PATH}"

echo "Observed effect: the container loaded and executed a minimal eBPF program without attaching it to a host-global hook."
