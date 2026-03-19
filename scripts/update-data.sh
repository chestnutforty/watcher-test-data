#!/usr/bin/env bash
# Update a watcher test data file via GitHub API.
#
# Usage:
#   ./scripts/update-data.sh <dataset> <json_path> <new_value>
#   ./scripts/update-data.sh unemployment latest.value 5.1
#   ./scripts/update-data.sh fed-rate latest.value 4.25
#   ./scripts/update-data.sh sp500 latest.close 6000
#
# Or replace the entire file:
#   ./scripts/update-data.sh unemployment --file new-unemployment.json
#
# Requires: gh (GitHub CLI), jq

set -euo pipefail

REPO="danielproj/watcher-test-data"
DATASET="${1:?Usage: $0 <dataset> <json_path> <new_value>}"
FILEPATH="data/${DATASET}.json"

# Get current file content and SHA
echo "→ Fetching current ${FILEPATH}..."
CURRENT=$(gh api "repos/${REPO}/contents/${FILEPATH}" 2>/dev/null) || {
    echo "Error: Could not fetch ${FILEPATH} from ${REPO}"
    exit 1
}

SHA=$(echo "$CURRENT" | jq -r '.sha')
CONTENT=$(echo "$CURRENT" | jq -r '.content' | base64 -d)

if [[ "${2:-}" == "--file" ]]; then
    # Replace entire file
    NEW_FILE="${3:?Usage: $0 <dataset> --file <path>}"
    NEW_CONTENT=$(cat "$NEW_FILE")
    COMMIT_MSG="Replace ${DATASET} data"
else
    JSON_PATH="${2:?Usage: $0 <dataset> <json_path> <new_value>}"
    NEW_VALUE="${3:?Usage: $0 <dataset> <json_path> <new_value>}"

    # Update the specific field using jq
    # Handle numeric vs string values
    if [[ "$NEW_VALUE" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        NEW_CONTENT=$(echo "$CONTENT" | jq ".${JSON_PATH} = ${NEW_VALUE} | .updated_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"")
    else
        NEW_CONTENT=$(echo "$CONTENT" | jq ".${JSON_PATH} = \"${NEW_VALUE}\" | .updated_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"")
    fi
    COMMIT_MSG="Update ${DATASET}: ${JSON_PATH} → ${NEW_VALUE}"
fi

# Show diff
echo ""
echo "── Changes ──"
diff <(echo "$CONTENT" | jq .) <(echo "$NEW_CONTENT" | jq .) || true
echo ""

# Upload via GitHub API
echo "→ Pushing to ${REPO}..."
ENCODED=$(echo "$NEW_CONTENT" | base64)

gh api "repos/${REPO}/contents/${FILEPATH}" \
    --method PUT \
    --field message="${COMMIT_MSG}" \
    --field content="${ENCODED}" \
    --field sha="${SHA}" \
    --jq '.commit.html_url' 2>/dev/null

echo ""
echo "✓ Updated! GitHub Pages will refresh in ~30s."
echo "  View: https://danielproj.github.io/watcher-test-data/data/${DATASET}.json"
