#!/usr/bin/env bash
# Run on the Azure VM after the acc-healthcheck container is healthy.
# Produces real, timestamped observations; it does not fabricate recovery metrics.
set -euo pipefail

CONTAINER="${CONTAINER:-acc-healthcheck}"
URL="${URL:-http://127.0.0.1/health}"
RUNS="${RUNS:-3}"
OUT="${OUT:-recovery-results.csv}"

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
  echo "Container '$CONTAINER' was not found." >&2
  exit 1
fi

printf 'run,stop_timestamp_utc,restart_timestamp_utc,recovery_timestamp_utc,recovery_seconds,http_status\n' > "$OUT"

for run in $(seq 1 "$RUNS"); do
  stop_time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  docker stop "$CONTAINER" >/dev/null

  # Confirm the failure state before restarting. A stopped container should not answer.
  if curl --silent --max-time 2 --fail "$URL" >/dev/null; then
    echo "Unexpectedly received HTTP success while container was stopped; aborting." >&2
    docker start "$CONTAINER" >/dev/null || true
    exit 1
  fi

  restart_epoch="$(date +%s.%N)"
  restart_time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  docker start "$CONTAINER" >/dev/null

  recovery_epoch=""
  status=""
  for attempt in $(seq 1 60); do
    if status="$(curl --silent --output /dev/null --write-out '%{http_code}' --max-time 2 "$URL")" && [ "$status" = "200" ]; then
      recovery_epoch="$(date +%s.%N)"
      break
    fi
    sleep 1
  done

  if [ -z "$recovery_epoch" ]; then
    echo "Run $run did not recover within 60 seconds; inspect docker logs $CONTAINER." >&2
    exit 1
  fi

  recovery_seconds="$(awk -v a="$restart_epoch" -v b="$recovery_epoch" 'BEGIN {printf "%.3f", b-a}')"
  recovery_time="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '%s,%s,%s,%s,%s,%s\n' "$run" "$stop_time" "$restart_time" "$recovery_time" "$recovery_seconds" "$status" | tee -a "$OUT"
  sleep 2
done

echo "Saved actual observations to $OUT"
