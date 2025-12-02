#!/bin/bash
# Auto-suspend EOStat sessions older than threshold
# Monitors multiple namespaces by prefix
# Supports both eostat-jupyter and eostat-rstudio variants

set -euo pipefail

MAX_AGE_HOURS=${MAX_AGE_HOURS:-8}
# NAMESPACE_PREFIXES comes as space-separated from Helm array (e.g., "user- project-")
NAMESPACE_PREFIXES=${NAMESPACE_PREFIXES:-"user- project-"}
# APP_NAMES comes as space-separated (e.g., "eostat-jupyter eostat-rstudio")
APP_NAMES=${APP_NAMES:-"eostat-jupyter eostat-rstudio"}
HELM_REPO=${HELM_REPO:-"unglobalplatform"}

echo "[$(date -Iseconds)] Checking for EOStat sessions older than ${MAX_AGE_HOURS}h"
echo "Namespace prefixes: ${NAMESPACE_PREFIXES}"
echo "App names to monitor: ${APP_NAMES}"

# Add Helm repository if not already added
helm repo add "${HELM_REPO}" https://unglobalplatform.github.io/helm-charts-interactive-services 2>/dev/null || true
helm repo update >/dev/null 2>&1 || true

# Calculate cutoff time (seconds since epoch)
CUTOFF_TIME=$(($(date +%s) - (MAX_AGE_HOURS * 3600)))

# Get all namespaces matching prefixes
read -ra PREFIX_ARRAY <<< "$NAMESPACE_PREFIXES"
NAMESPACES=""

# Get all namespace names
ALL_NAMESPACES=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Filter by prefixes
for NS in $ALL_NAMESPACES; do
  for PREFIX in "${PREFIX_ARRAY[@]}"; do
    PREFIX=$(echo "$PREFIX" | xargs)  # Trim whitespace
    if [[ "$NS" == ${PREFIX}* ]]; then
      NAMESPACES="$NAMESPACES $NS"
      break
    fi
  done
done

if [ -z "$NAMESPACES" ]; then
  echo "No namespaces found matching prefixes: ${NAMESPACE_PREFIXES}"
  exit 0
fi

echo "Monitoring namespaces: $NAMESPACES"

# Parse APP_NAMES into array
read -ra APP_NAMES_ARRAY <<< "$APP_NAMES"

# Check each namespace for EOStat pods
for NAMESPACE in $NAMESPACES; do
  echo ""
  echo "Namespace: $NAMESPACE"

  # Check each app name variant (eostat-jupyter, eostat-rstudio)
  for APP_NAME in "${APP_NAMES_ARRAY[@]}"; do
    APP_NAME=$(echo "$APP_NAME" | xargs)  # Trim whitespace
    LABEL_SELECTOR="app.kubernetes.io/name=${APP_NAME}"

    # Find all pods matching label selector in this namespace
    PODS=$(kubectl get pods -n "${NAMESPACE}" \
      -l "${LABEL_SELECTOR}" \
      -o jsonpath='{range .items[*]}{.metadata.name}|{.metadata.creationTimestamp}|{.metadata.labels.app\.kubernetes\.io/name}{"\n"}{end}' 2>/dev/null || true)

    if [ -z "$PODS" ]; then
      continue
    fi

    echo "  Found ${APP_NAME} pods:"

    # Check each pod's age
    echo "$PODS" | while IFS='|' read -r POD_NAME CREATION_TIME POD_APP_NAME; do
      if [ -z "$POD_NAME" ]; then
        continue
      fi

      # Convert ISO8601 creation time to epoch seconds
      if command -v python3 >/dev/null 2>&1; then
        CREATION_EPOCH=$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('${CREATION_TIME}'.replace('Z', '+00:00')).timestamp()))" 2>/dev/null || echo "0")
      else
        echo "Warning: python3 not available, using conservative age estimate for $POD_NAME"
        CREATION_EPOCH=$(($(date +%s) - 60))
      fi

      if [ "$CREATION_EPOCH" -eq "0" ]; then
        echo "Warning: Could not parse creation time for $POD_NAME"
        continue
      fi

      POD_AGE=$(($(date +%s) - CREATION_EPOCH))
      POD_AGE_HOURS=$((POD_AGE / 3600))

      echo "    Pod: $POD_NAME | Age: ${POD_AGE_HOURS}h | Chart: ${APP_NAME}"

      if [ $CREATION_EPOCH -lt $CUTOFF_TIME ]; then
        echo "      ⏰ SUSPENDING: Pod is ${POD_AGE_HOURS}h old (threshold: ${MAX_AGE_HOURS}h)"

        # Extract release name from pod name (strip ordinal suffix -0)
        RELEASE_NAME=$(echo "$POD_NAME" | sed 's/-[0-9]*$//')

        # Suspend via helm upgrade with the correct chart name
        echo "      Running: helm upgrade ${RELEASE_NAME} ${HELM_REPO}/${APP_NAME} --reuse-values --set global.suspend=true"

        helm upgrade "${RELEASE_NAME}" "${HELM_REPO}/${APP_NAME}" \
          --reuse-values \
          --set global.suspend=true \
          --namespace="${NAMESPACE}" \
          2>&1 || echo "      ⚠️ Warning: helm upgrade failed"

        echo "      ✓ Suspended release: ${RELEASE_NAME}"
      else
        echo "      ✓ OK: Pod is only ${POD_AGE_HOURS}h old"
      fi
    done
  done
done

echo ""
echo "[$(date -Iseconds)] Auto-suspend check complete"
