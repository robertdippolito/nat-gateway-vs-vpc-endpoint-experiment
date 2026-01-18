#!/usr/bin/env bash
set -euo pipefail

: "${TEST_BUCKET:?TEST_BUCKET not set. Run: source /etc/profile.d/experiment.sh}"
: "${TEST_PREFIX:=experiment}"

SIZE_MB="${SIZE_MB:-256}"
WORKERS="${WORKERS:-2}"
DURATION_SEC="${DURATION_SEC:-60}"
REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region || true)"

RUN_ID="$(date +%Y%m%d-%H%M%S)"
KEY_BASE="${TEST_PREFIX}/${RUN_ID}"
TMP_DIR="/tmp/vpce-demo-${RUN_ID}"
FILE="${TMP_DIR}/payload.bin"

mkdir -p "${TMP_DIR}"

echo "== VPCE Traffic Generator (disk-safe) =="
echo "Bucket:   ${TEST_BUCKET}"
echo "Prefix:   ${KEY_BASE}"
echo "Size:     ${SIZE_MB} MB (logical)"
echo "Workers:  ${WORKERS}"
echo "Duration: ${DURATION_SEC}s"
echo

truncate -s "${SIZE_MB}M" "${FILE}"
ls -lh "${FILE}"
echo

end_at=$(( $(date +%s) + DURATION_SEC ))

worker() {
  local wid="$1"
  local i=0
  while [ "$(date +%s)" -lt "${end_at}" ]; do
    i=$((i+1))
    local key="${KEY_BASE}/w${wid}/iter${i}.bin"

    local t0 t1 t2 put_ms get_ms
    t0=$(date +%s%3N)

    if aws s3 cp "${FILE}" "s3://${TEST_BUCKET}/${key}" ${REGION:+--region "$REGION"} --only-show-errors; then
      t1=$(date +%s%3N)
      if aws s3 cp "s3://${TEST_BUCKET}/${key}" - ${REGION:+--region "$REGION"} --only-show-errors > /dev/null; then
        t2=$(date +%s%3N)
        put_ms=$((t1 - t0))
        get_ms=$((t2 - t1))
        echo "w${wid} iter${i} PUT=${put_ms}ms GET=${get_ms}ms"
      else
        echo "w${wid} iter${i} GET_FAILED" >&2
      fi
    else
      echo "w${wid} iter${i} PUT_FAILED" >&2
    fi
  done
}

pids=()
for w in $(seq 1 "${WORKERS}"); do
  worker "${w}" &
  pids+=("$!")
done

for pid in "${pids[@]}"; do
  wait "${pid}" || true
done

echo "Done. Objects under: s3://${TEST_BUCKET}/${KEY_BASE}/"
EOF

chmod +x /tmp/vpce-traffic.sh
source /etc/profile.d/experiment.sh
WORKERS=2 SIZE_MB=256 DURATION_SEC=600 /tmp/vpce-traffic.sh
