#!/usr/bin/env bash
set -e

SCENARIO="${1:-api-500}"
TARGET_ENV="${2:-dev}"
CONFIG_FILE="/mnt/c/inetpub/nexora/${TARGET_ENV}/api/appsettings.json"

echo "=== SIMULATING FAILURE SCENARIO: $SCENARIO on ${TARGET_ENV^^} ==="

case "$SCENARIO" in
  api-500)
    echo "[FAULT INJECTION] Setting SIMULATE_FAILURE to 500..."
    sed -i 's/"SIMULATE_FAILURE": "false"/"SIMULATE_FAILURE": "500"/' "$CONFIG_FILE" || true
    powershell.exe -Command "Restart-WebAppPool -Name 'inventory-api-${TARGET_ENV}-pool'"
    echo "[TEST] Probing health endpoint (expecting 500):"
    curl -I -s "http://localhost:8101/health" | head -n 1
    ;;

  health-timeout)
    echo "[FAULT INJECTION] Suspending Application Pool to force health timeout..."
    powershell.exe -Command "Stop-WebAppPool -Name 'inventory-api-${TARGET_ENV}-pool'"
    echo "[TEST] Probing health endpoint (expecting connection failure):"
    curl -I -m 2 -s "http://localhost:8101/health" || echo "[CONFIRMED] Connection timed out / refused."
    ;;

  bad-config)
    echo "[FAULT INJECTION] Injecting malformed invalid JSON into appsettings.json..."
    echo '{"Logging": { INVALID_JSON_PAYLOAD_HERE }}}' > "$CONFIG_FILE"
    powershell.exe -Command "Restart-WebAppPool -Name 'inventory-api-${TARGET_ENV}-pool'"
    echo "[TEST] Probing health endpoint (expecting startup crash 500.30):"
    curl -I -s "http://localhost:8101/health" | head -n 1
    ;;

  database-unavailable)
    echo "[FAULT INJECTION] Breaking database connection string host..."
    sed -i 's/Host=localhost/Host=invalid_db_host/' "$CONFIG_FILE" || true
    powershell.exe -Command "Restart-WebAppPool -Name 'inventory-api-${TARGET_ENV}-pool'"
    echo "[TEST] Probing health endpoint (expecting 503 Service Unavailable):"
    curl -I -s "http://localhost:8101/health" | head -n 1
    ;;

  restore)
    echo "[RECOVERY] Restoring healthy baseline configuration..."
    devopsctl rollback inventory-api --env "${TARGET_ENV^^}"
    ;;

  *)
    echo "Usage: ./simulate-failure.sh {api-500|health-timeout|bad-config|database-unavailable|restore} [env]"
    exit 1
    ;;
esac
