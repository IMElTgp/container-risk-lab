#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-cap-sys-chroot-mountns}"
STATE_DIR="${STATE_DIR:-/tmp/chroot-dev-state}"
CAP_SYS_CHROOT_MASK=$((1<<18))
CAP_SYS_ADMIN_MASK=$((1<<21))

wait_for_container_file() {
    local path="$1"
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        if docker exec "${CONTAINER_NAME}" sh -lc "test -f '${path}'"; then
            return 0
        fi
        sleep 1
    done
    return 1
}

value_of() {
    local key="$1"
    local content="$2"
    awk -F'=' -v wanted="${key}" '$1 == wanted {print $2}' <<<"${content}"
}

assert_mask_set() {
    local hex_value="$1"
    local mask="$2"
    (( (16#${hex_value}) & mask ))
}

assert_mask_clear() {
    local hex_value="$1"
    local mask="$2"
    (( ((16#${hex_value}) & mask) == 0 ))
}

echo "[composition] CAP_SYS_CHROOT + thread-level mount namespace deviation probe"
echo "  container: ${CONTAINER_NAME}"

wait_for_container_file "${STATE_DIR}/ready.status" || { echo "Timed out waiting for ${STATE_DIR}/ready.status" >&2; exit 1; }
ready_content="$(docker exec "${CONTAINER_NAME}" sh -lc "cat '${STATE_DIR}/ready.status'")"

main_mntns="$(value_of "main_mntns" "${ready_content}")"
worker_mntns="$(value_of "worker_mntns" "${ready_content}")"
main_eff="$(value_of "main_CapEff" "${ready_content}")"
worker_eff="$(value_of "worker_CapEff" "${ready_content}")"

[[ "${main_mntns}" != "${worker_mntns}" ]] || { echo "Main and worker mount namespaces are still identical" >&2; exit 1; }
assert_mask_set "${main_eff}" "${CAP_SYS_CHROOT_MASK}" || { echo "Main thread lacks CAP_SYS_CHROOT" >&2; exit 1; }
assert_mask_set "${worker_eff}" "${CAP_SYS_CHROOT_MASK}" || { echo "Worker thread lacks CAP_SYS_CHROOT" >&2; exit 1; }
assert_mask_clear "${main_eff}" "${CAP_SYS_ADMIN_MASK}" || { echo "Main thread still has CAP_SYS_ADMIN" >&2; exit 1; }
assert_mask_clear "${worker_eff}" "${CAP_SYS_ADMIN_MASK}" || { echo "Worker thread still has CAP_SYS_ADMIN" >&2; exit 1; }

docker kill --signal USR1 "${CONTAINER_NAME}" >/dev/null
wait_for_container_file "${STATE_DIR}/afteraction.status" || { echo "Timed out waiting for ${STATE_DIR}/afteraction.status" >&2; exit 1; }
after_content="$(docker exec "${CONTAINER_NAME}" sh -lc "cat '${STATE_DIR}/afteraction.status'")"

grep -q '^marker=worker-private-root$' <<<"${after_content}" || { echo "Worker did not report chroot into the private marker root" >&2; exit 1; }

echo "Observed effect: a non-main thread in a different mount namespace used CAP_SYS_CHROOT to enter a private root that was not the main thread's filesystem view."
