#!/bin/bash

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")
CHART_DIR="$SCRIPT_DIR/../charts"

for CHART_NAME in $(ls "$CHART_DIR"); do
    if [[ -n "$(git status | grep /$CHART_NAME/)" ]]; then
        if [[ -z "$(git diff $CHART_DIR/$CHART_NAME/Chart.yaml | grep +version)" ]]; then
            OLD_VERSION=$(grep '^version:' $CHART_DIR/$CHART_NAME/Chart.yaml | awk '{print $2}' | cut -d. -f3)
            NEW_VERSION=$(($OLD_VERSION+1))
            echo "Upgrading $CHART_NAME from version $OLD_VERSION to $NEW_VERSION"
            sed -i -E 's/^(version: [0-9]+\.[0-9]+\.)[0-9]+/\1'$NEW_VERSION'/' $CHART_DIR/$CHART_NAME/Chart.yaml
        fi
    fi
done
