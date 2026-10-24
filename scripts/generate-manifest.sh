#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-1.4.2}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="${BASE_DIR}/artifacts/release-manifest-${VERSION}.json"

mkdir -p "${BASE_DIR}/artifacts"

check_and_hash() {
    local file_path="$1"
    local app_name="$2"
    if [[ ! -f "${file_path}" ]]; then
        echo "ERROR: Required artifact ${file_path} does not exist!" >&2
        exit 1
    fi
    sha256sum "${file_path}" | awk '{print $1}'
}

API_ZIP="${BASE_DIR}/artifacts/inventory-api/inventory-api-${VERSION}.zip"
WEB_ZIP="${BASE_DIR}/artifacts/inventory-web/inventory-web-${VERSION}.zip"
REPORTING_JAR="${BASE_DIR}/artifacts/reporting-service/reporting-service-${VERSION}.jar"

API_HASH=$(check_and_hash "${API_ZIP}" "inventory-api")
WEB_HASH=$(check_and_hash "${WEB_ZIP}" "inventory-web")
REPORTING_HASH=$(check_and_hash "${REPORTING_JAR}" "reporting-service")

cat << MANIFEST > "${OUTPUT_FILE}"
{
  "manifestVersion": "1.0",
  "releaseVersion": "${VERSION}",
  "generatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "artifacts": [
    {
      "application": "inventory-api",
      "version": "${VERSION}",
      "file": "inventory-api-${VERSION}.zip",
      "sha256": "${API_HASH}",
      "verified": true
    },
    {
      "application": "inventory-web",
      "version": "${VERSION}",
      "file": "inventory-web-${VERSION}.zip",
      "sha256": "${WEB_HASH}",
      "verified": true
    },
    {
      "application": "reporting-service",
      "version": "${VERSION}",
      "file": "reporting-service-${VERSION}.jar",
      "sha256": "${REPORTING_HASH}",
      "verified": true
    }
  ]
}
MANIFEST
echo "SUCCESS: Manifest generated at ${OUTPUT_FILE}"
