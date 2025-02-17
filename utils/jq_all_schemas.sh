#!/bin/bash

# Applies the provided jq command to all 6 values.schema.json file and update them all in place
# Examples:
# # To set, or create, a field:
# /utils/jq_all_schemas.sh '.properties.extraEnvVars.title = "Environment variables available within your service"'
# # To delete a field (does nothing if field does not exist):
# /utils/jq_all_schemas.sh 'del(.properties.extraEnvVars)'
# # To create a new field in first position (does not set the value if the field already exists but does move it in first position)
# /utils/jq_all_schemas.sh '.properties.extraEnvVars = ({"title": "Environment variables available within your service"} + .properties.extraEnvVars)'

# Ensure correct usage
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 '<jq_query>'"
    exit 1
fi

JQ_QUERY="$1"
TMP_FILE="/tmp/jq_tmp.json"

echo "Applying query '$JQ_QUERY'"
for CHART in vscode-python vscode-pyspark rstudio rstudio-sparkr jupyter-python jupyter-pyspark; do
    SCHEMA_FILE="./charts/$CHART/values.schema.json"
    echo "  Processing $SCHEMA_FILE"
    jq "$JQ_QUERY" "$SCHEMA_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$SCHEMA_FILE"
done
