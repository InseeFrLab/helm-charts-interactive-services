#!/bin/bash
# Auto-suspend EOStat sessions older than threshold

set -euo pipefail

MAX_AGE_HOURS=${MAX_AGE_HOURS:-8}
NAMESPACE=${NAMESPACE:-$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)}
LABEL_SELECTOR=${LABEL_SELECTOR:-"app.kubernetes.io/name=eostat"}

echo "[$(date -Iseconds)] Checking for EOStat sessions older than ${MAX_AGE_HOURS}h in namespace ${NAMESPACE}"

# Calculate cutoff time (seconds since epoch)
CUTOFF_TIME=$(($(date +%s) - (MAX_AGE_HOURS * 3600)))

# Find all pods matching label selector
PODS=$(kubectl get pods -n "${NAMESPACE}" \
  -l "${LABEL_SELECTOR}" \
  -o jsonpath='{range .items[*]}{.metadata.name}|{.metadata.creationTimestamp}{"\n"}{end}')

if [ -z "$PODS" ]; then
  echo "No EOStat pods found"
  exit 0
fi

# Check each pod's age
echo "$PODS" | while IFS='|' read -r POD_NAME CREATION_TIME; do
  if [ -z "$POD_NAME" ]; then
    continue
  fi

  # Convert creation time to epoch seconds
  CREATION_EPOCH=$(date -d "$CREATION_TIME" +%s 2>/dev/null || echo "0")

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

    # Suspend via helm upgrade
    echo "  Running: helm upgrade ${RELEASE_NAME} --reuse-values --set global.suspend=true"

    helm upgrade "${RELEASE_NAME}" \
      --reuse-values \
      --set global.suspend=true \
      --namespace="${NAMESPACE}" \
      2>&1 || echo "  ⚠️ Warning: helm upgrade failed"

    echo "  ✓ Suspended release: ${RELEASE_NAME}"
  else
    echo "  ✓ OK: Pod is only ${POD_AGE_HOURS}h old"
  fi
done

echo "[$(date -Iseconds)] Auto-suspend check complete"
