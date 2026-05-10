#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-admin}"
PROBE_DIR="${PROBE_DIR:-/tmp/runtia-cap-sys-admin-probe}"

echo "[fatal] CAP_SYS_ADMIN mount probe"
echo "  container: ${CONTAINER_NAME}"

docker exec "${CONTAINER_NAME}" sh -lc "
set -euo pipefail
rm -rf '${PROBE_DIR}'
mkdir -p '${PROBE_DIR}'
mount -t tmpfs tmpfs '${PROBE_DIR}'
printf 'mounted-by-cap-sys-admin\n' > '${PROBE_DIR}/proof.txt'
grep ' ${PROBE_DIR} ' /proc/self/mountinfo >/dev/null
cat '${PROBE_DIR}/proof.txt'
umount '${PROBE_DIR}'
rmdir '${PROBE_DIR}'
"

echo "Observed effect: container successfully mounted tmpfs in a controlled directory and wrote a proof file."
