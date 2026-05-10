#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-crl-no-new-privs-delayed-cap}"
STATE_DIR="${STATE_DIR:-/tmp/delayed-cap-state}"
CAP_SETUID_MASK=$((1<<7))

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

extract_hex_value() {
    local key="$1"
    local content="$2"
    awk -F':' -v wanted="${key}" '$1 == wanted {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' <<<"${content}"
}

assert_bit_set() {
    local hex_value="$1"
    local mask="$2"
    (( (16#${hex_value}) & mask ))
}

assert_bit_clear() {
    local hex_value="$1"
    local mask="$2"
    (( ((16#${hex_value}) & mask) == 0 ))
}

echo "[composition] NoNewPrivs disabled + delayed privilege-transition capability probe"
echo "  container: ${CONTAINER_NAME}"

wait_for_container_file "${STATE_DIR}/armed.status" || { echo "Timed out waiting for ${STATE_DIR}/armed.status" >&2; exit 1; }
armed_content="$(docker exec "${CONTAINER_NAME}" sh -lc "cat '${STATE_DIR}/armed.status'")"

armed_eff="$(extract_hex_value "CapEff" "${armed_content}")"
armed_prm="$(extract_hex_value "CapPrm" "${armed_content}")"
armed_amb="$(extract_hex_value "CapAmb" "${armed_content}")"
armed_nnp="$(awk -F':' '$1 == "NoNewPrivs" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' <<<"${armed_content}")"

assert_bit_clear "${armed_eff}" "${CAP_SETUID_MASK}" || { echo "CapEff still contains CAP_SETUID before exec" >&2; exit 1; }
if ! assert_bit_set "${armed_prm}" "${CAP_SETUID_MASK}" && ! assert_bit_set "${armed_amb}" "${CAP_SETUID_MASK}"; then
    echo "Neither CapPrm nor CapAmb carries CAP_SETUID before exec" >&2
    exit 1
fi
[[ "${armed_nnp}" == "0" ]] || { echo "NoNewPrivs is not disabled in armed state" >&2; exit 1; }

docker kill --signal USR1 "${CONTAINER_NAME}" >/dev/null
wait_for_container_file "${STATE_DIR}/afterexec.status" || { echo "Timed out waiting for ${STATE_DIR}/afterexec.status" >&2; exit 1; }
afterexec_content="$(docker exec "${CONTAINER_NAME}" sh -lc "cat '${STATE_DIR}/afterexec.status'")"

after_eff="$(extract_hex_value "CapEff" "${afterexec_content}")"
assert_bit_set "${after_eff}" "${CAP_SETUID_MASK}" || { echo "CapEff did not regain CAP_SETUID after exec" >&2; exit 1; }

echo "Observed effect: the process rested with CAP_SETUID outside CapEff, then regained CAP_SETUID in CapEff after a controlled execve path."
