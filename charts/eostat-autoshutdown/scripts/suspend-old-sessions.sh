#!/bin/bash
# Auto-suspend EOStat sessions older than threshold
# Monitors multiple namespaces by prefix

set -euo pipefail

MAX_AGE_HOURS=${MAX_AGE_HOURS:-8}
NAMESPACE_PREFIXES=${NAMESPACE_PREFIXES:-"user-,project-"}
LABEL_SELECTOR=${LABEL_SELECTOR:-"app.kubernetes.io/name=eostat"}
HELM_REPO=${HELM_REPO:-"unglobalplatform"}
CHART_NAME=${CHART_NAME:-"eostat"}

echo "[$(date -Iseconds)] Checking for EOStat sessions older than ${MAX_AGE_HOURS}h"
echo "Namespace prefixes: ${NAMESPACE_PREFIXES}"

# Add Helm repository if not already added
helm repo add "${HELM_REPO}" https://unglobalplatform.github.io/helm-charts-interactive-services 2>/dev/null || true
helm repo update >/dev/null 2>&1 || true

# Calculate cutoff time (seconds since epoch)
CUTOFF_TIME=$(($(date +%s) - (MAX_AGE_HOURS * 3600)))

# Get all namespaces matching prefixes
IFS=',' read -ra PREFIX_ARRAY <<< "$NAMESPACE_PREFIXES"
NAMESPACES=""

for PREFIX in "${PREFIX_ARRAY[@]}"; do
  PREFIX=$(echo "$PREFIX" | xargs)  # Trim whitespace
  NS_LIST=$(kubectl get namespaces -o jsonpath="{.items[?(@.metadata.name matches '^${PREFIX}')].metadata.name}" 2>/dev/null || true)
  if [ -n "$NS_LIST" ]; then
    NAMESPACES="$NAMESPACES $NS_LIST"
  fi
done

if [ -z "$NAMESPACES" ]; then
  echo "No namespaces found matching prefixes: ${NAMESPACE_PREFIXES}"
  exit 0
fi

echo "Monitoring namespaces: $NAMESPACES"

# Check each namespace for EOStat pods
for NAMESPACE in $NAMESPACES; do
  echo ""
  echo "Namespace: $NAMESPACE"

  # Find all pods matching label selector in this namespace
  PODS=$(kubectl get pods -n "${NAMESPACE}" \
    -l "${LABEL_SELECTOR}" \
    -o jsonpath='{range .items[*]}{.metadata.name}|{.metadata.creationTimestamp}{"\n"}{end}' 2>/dev/null || true)

  if [ -z "$PODS" ]; then
    echo "  No EOStat pods in this namespace"
    continue
  fi

  # Check each pod's age
  echo "$PODS" | while IFS='|' read -r POD_NAME CREATION_TIME; do
  if [ -z "$POD_NAME" ]; then
    continue
  fi

  # Convert ISO8601 creation time to epoch seconds
  # Alpine busybox date doesn't support -d, so we parse manually
  # Format: 2025-12-01T23:35:40Z -> seconds since epoch
  if command -v python3 >/dev/null 2>&1; then
    CREATION_EPOCH=$(python3 -c "from datetime import datetime; print(int(datetime.fromisoformat('${CREATION_TIME}'.replace('Z', '+00:00')).timestamp()))" 2>/dev/null || echo "0")
  else
    # Fallback: use current time minus a small offset (conservative)
    echo "Warning: python3 not available, using conservative age estimate for $POD_NAME"
    CREATION_EPOCH=$(($(date +%s) - 60))
  fi

  if [ "$CREATION_EPOCH" -eq "0" ]; then
    echo "Warning: Could not parse creation time for $POD_NAME"
    continue
  fi

  POD_AGE=$(($(date +%s) - CREATION_EPOCH))
  POD_AGE_HOURS=$((POD_AGE / 3600))

  echo "Pod: $POD_NAME | Age: ${POD_AGE_HOURS}h"

  if [ $CREATION_EPOCH -lt $CUTOFF_TIME ]; then
    echo "  ⏰ SUSPENDING: Pod is ${POD_AGE_HOURS}h old (threshold: ${MAX_AGE_HOURS}h)"

    # Extract release name from pod name (strip ordinal suffix -0)
    RELEASE_NAME=$(echo "$POD_NAME" | sed 's/-[0-9]*$//')

    # Suspend via helm upgrade with chart reference
    echo "  Running: helm upgrade ${RELEASE_NAME} ${HELM_REPO}/${CHART_NAME} --reuse-values --set global.suspend=true"

    helm upgrade "${RELEASE_NAME}" "${HELM_REPO}/${CHART_NAME}" \
      --reuse-values \
      --set global.suspend=true \
      --namespace="${NAMESPACE}" \
      2>&1 || echo "  ⚠️ Warning: helm upgrade failed"

    echo "  ✓ Suspended release: ${RELEASE_NAME}"
  else
    echo "    ✓ OK: Pod is only ${POD_AGE_HOURS}h old"
  fi
  done
done

echo ""
echo "[$(date -Iseconds)] Auto-suspend check complete"
