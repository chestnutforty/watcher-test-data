#!/usr/bin/env bash
# Register all test data endpoints as watcher watches for a forecast.
#
# Usage:
#   ./scripts/register-watches.sh <forecast_id> [api_base_url] [poll_minutes]
#
# Examples:
#   ./scripts/register-watches.sh abc-123
#   ./scripts/register-watches.sh abc-123 http://localhost:6080 2

set -euo pipefail

FORECAST_ID="${1:?Usage: $0 <forecast_id> [api_base_url] [poll_minutes]}"
API_BASE="${2:-http://localhost:6080}"
POLL_MINUTES="${3:-1}"

PAGES_BASE="https://chestnutforty.github.io/watcher-test-data"

declare -A ENDPOINTS=(
    ["test:unemployment"]="data/unemployment.json"
    ["test:gdp"]="data/gdp.json"
    ["test:fed-rate"]="data/fed-rate.json"
    ["test:cpi"]="data/cpi.json"
    ["test:sp500"]="data/sp500.json"
)

echo "Registering ${#ENDPOINTS[@]} watch endpoints for forecast ${FORECAST_ID}"
echo "  API: ${API_BASE}"
echo "  Pages: ${PAGES_BASE}"
echo "  Poll: every ${POLL_MINUTES} min"
echo ""

for key in "${!ENDPOINTS[@]}"; do
    path="${ENDPOINTS[$key]}"
    url="${PAGES_BASE}/${path}"
    echo "→ ${key}: ${url}"

    curl -s -X POST "${API_BASE}/v1/forecast/${FORECAST_ID}/watch" \
        -H "Content-Type: application/json" \
        -d "{
            \"endpoint_key\": \"${key}\",
            \"service\": \"github-pages\",
            \"method\": \"GET\",
            \"url\": \"${url}\",
            \"poll_frequency_minutes\": ${POLL_MINUTES},
            \"notify_strategy\": \"on_change\"
        }" | jq -r '"  Status: \(.status // .detail // "error")"' 2>/dev/null || echo "  Status: request failed"
    echo ""
done

echo "✓ Done! Watch status:"
curl -s "${API_BASE}/v1/forecast/${FORECAST_ID}/watches" | jq '.[] | {endpoint_key, status, next_poll_at}' 2>/dev/null || echo "(could not fetch watch list)"
