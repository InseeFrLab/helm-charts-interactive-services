{{/* Create the name of the Milvus secret to use */}}
{{- define "library-chart.secretNameMilvus" -}}
{{- if (.Values.discovery).milvus }}
{{- $name := printf "%s-secretmilvus" (include "library-chart.fullname" .) }}
{{- default $name (.Values.milvus).secretName }}
{{- else }}
{{- default "default" (.Values.milvus).secretName }}
{{- end }}
{{- end }}


{{/* Secret for Milvus */}}
{{- define "library-chart.secretMilvus" }}
{{- if (.Values.discovery).milvus }}
{{- $context := . }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "milvus") | fromJsonArray) -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMilvus" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
data:
  MILVUS_GRPC_URI: {{ $secretData.MILVUS_GRPC_URI | quote }}
  MILVUS_REST_URI: {{ $secretData.MILVUS_REST_URI | quote }}
  MILVUS_USERNAME: {{ $secretData.MILVUS_USERNAME | quote }}
  MILVUS_PASSWORD: {{ $secretData.MILVUS_PASSWORD | quote }}
  MILVUS_TOKEN:    {{ $secretData.MILVUS_TOKEN    | quote }}
{{- end }}
{{- end }}
{{- end }}


{{- define "library-chart.milvus-discovery-help" -}}
{{- if (.Values.discovery).milvus }}
{{- if first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "milvus") | fromJsonArray) }}
The connection to your Milvus service is already preconfigured in your service.
{{- if regexMatch "^r|r$" .Chart.Name }}
There is no well-supported Milvus client for R yet.
{{- else }}
Install the `pymilvus` package first:
```bash
pip3 install pymilvus
```

A client can then be created in a Python script or interactive console:
```python
import os
from pymilvus import MilvusClient

client = MilvusClient(
    uri=os.getenv("MILVUS_GRPC_URI"),
    token=os.getenv("MILVUS_TOKEN")
)

client.create_database(db_name="my_database")
```

To learn more about integrating Milvus using `pymilvus`, read [the full documentation](https://github.com/milvus-io/pymilvus).
{{- end }}

You may use the RESTful API:
```bash
curl --request POST \
    --url "${MILVUS_REST_URI}/v2/vectordb/collections/list" \
    --header "Authorization: Bearer ${MILVUS_TOKEN}" \
    -d '{ "dbName": "default" }'
```
{{- end }}
{{- end }}
{{- end -}}
