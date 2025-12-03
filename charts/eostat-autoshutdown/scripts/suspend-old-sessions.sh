#!/bin/bash
# Optimized Auto-suspend EOStat sessions
# IMPROVEMENTS:
# 1. Single API call to fetch all candidates (vs one per namespace/app combo).
# 2. Uses jq for date math (milliseconds) vs spawning Python (seconds).
# 3. Only runs Helm logic on confirmed targets.

set -euo pipefail

# Configuration
MAX_AGE_HOURS=${MAX_AGE_HOURS:-8}
NAMESPACE_PREFIXES=${NAMESPACE_PREFIXES:-"user- project-"}
APP_NAMES=${APP_NAMES:-"eostat-jupyter eostat-rstudio"}
HELM_REPO=${HELM_REPO:-"unglobalplatform"}
DRY_RUN=${DRY_RUN:-"false"} # Set to "true" to test without suspending

echo "[$(date -Iseconds)] Starting optimized auto-suspend check (Threshold: ${MAX_AGE_HOURS}h)"

# 1. Setup Helm (Check availability first to save time)
if ! helm repo list | grep -q "${HELM_REPO}"; then
    echo "Adding helm repo..."
    helm repo add "${HELM_REPO}" https://unglobalplatform.github.io/helm-charts-interactive-services 2>/dev/null
fi
# Only update repo if we actually plan to suspend (optimization deferred),
# or run it asynchronously if you want freshest charts.
# For speed, we usually skip update in automated loops unless failures occur.
helm repo update >/dev/null 2>&1 || true

# 2. Prepare Selectors
# Convert "eostat-jupyter eostat-rstudio" to "eostat-jupyter,eostat-rstudio" for the label selector
COMMA_APPS=$(echo "$APP_NAMES" | tr ' ' ',')

# Convert "user- project-" to regex "^(user-|project-)" for jq filtering
# This allows us to filter namespaces locally instead of multiple kubectl calls
REGEX_PREFIXES=$(echo "$NAMESPACE_PREFIXES" | sed 's/ /|/g')
NS_REGEX="^(${REGEX_PREFIXES})"

# Calculate Cutoff in Epoch Seconds
NOW=$(date +%s)
CUTOFF_TIME=$(($NOW - ($MAX_AGE_HOURS * 3600)))

echo "• Fetching all pods matching apps: [${COMMA_APPS}]..."

# 3. The "God Query"
# Fetches ALL pods across ALL namespaces matching the app labels in ONE network call.
# Pipes JSON to jq to perform: Namespace filtering, Age calculation, and Formatting.
TARGETS=$(kubectl get pods -A \
  -l "app.kubernetes.io/name in (${COMMA_APPS})" \
  -o json | jq -r --arg regex "$NS_REGEX" --argjson cutoff "$CUTOFF_TIME" --argjson now "$NOW" '
  .items[] |
  # Filter 1: Check if namespace matches our prefix regex
  select(.metadata.namespace | test($regex)) |
  # Filter 2: Calculate Age
  (.metadata.creationTimestamp | fromdateiso8601) as $created |
  select($created < $cutoff) |
  # Calculate hours old for display
  (($now - $created) / 3600 | floor) as $age_hours |
  # Output: Namespace | PodName | AppName | AgeHours
  "\(.metadata.namespace)|\(.metadata.name)|\(.metadata.labels["app.kubernetes.io/name"])|\($age_hours)"
')

if [ -z "$TARGETS" ]; then
    echo "✓ No expired sessions found."
    echo "[$(date -Iseconds)] Check complete."
    exit 0
fi

# 4. Processing Loop (Only runs for actual expired pods)
# We read the pre-calculated list line by line
while IFS='|' read -r NAMESPACE POD_NAME APP_NAME AGE_HOURS; do
    echo "---------------------------------------------------"
    echo "⏰ SUSPENDING: ${NAMESPACE}/${POD_NAME}"
    echo "   Details: ${APP_NAME}, ${AGE_HOURS} hours old."

    # Extract release name (strip ordinal suffix like -0)
    RELEASE_NAME=${POD_NAME%-*}

    CMD="helm upgrade ${RELEASE_NAME} ${HELM_REPO}/${APP_NAME} --reuse-values --set global.suspend=true --namespace=${NAMESPACE}"

    if [ "$DRY_RUN" == "true" ]; then
        echo "   [DRY RUN] Would execute: $CMD"
    else
        # Run upgrade. Capture output to handle errors gracefully.
        if OUT=$($CMD 2>&1); then
             echo "   ✓ Suspended release: ${RELEASE_NAME}"
        else
             echo "   ⚠️ Failed to suspend: $OUT"
        fi
    fi

done <<< "$TARGETS"

echo ""
echo "[$(date -Iseconds)] Check complete."
