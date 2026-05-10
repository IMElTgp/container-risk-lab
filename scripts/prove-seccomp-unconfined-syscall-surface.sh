#!/usr/bin/env bash
set -euo pipefail

BASELINE_CONTAINER="${BASELINE_CONTAINER:-crl-baseline}"
UNCONFINED_CONTAINER="${UNCONFINED_CONTAINER:-crl-seccomp-unconfined}"

echo "[high-risk] seccomp unconfined syscall-surface probe"
echo "  baseline container: ${BASELINE_CONTAINER}"
echo "  unconfined container: ${UNCONFINED_CONTAINER}"

baseline_out="$(docker exec "${BASELINE_CONTAINER}" sh -lc 'unshare -Ur true' 2>&1 || true)"
unconfined_out="$(docker exec "${UNCONFINED_CONTAINER}" sh -lc 'unshare -Ur true' 2>&1 || true)"

printf 'baseline: %s\n' "${baseline_out}"
printf 'unconfined: %s\n' "${unconfined_out}"

if [[ "${baseline_out}" == *"Operation not permitted"* ]] && [[ "${unconfined_out}" == *"uid_map"* ]]; then
    echo "Observed effect: the default-seccomp container was blocked earlier, while the unconfined container reached a later kernel permission check."
    exit 0
fi

echo "The local probe did not show the expected baseline/unconfined split." >&2
exit 1
