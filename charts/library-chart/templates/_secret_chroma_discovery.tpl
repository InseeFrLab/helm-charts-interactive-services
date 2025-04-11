{{/* Name of the ChromaDB secret used in services */}}
{{- define "library-chart.secretNameChromaDB" -}}
{{- if (.Values.discovery).chromadb }}
{{- $name := printf "%s-secretchromadb" (include "library-chart.fullname" .) }}
{{- default $name (.Values.chromadb).secretName }}
{{- else }}
{{- default "default" (.Values.chromadb).secretName }}
{{- end }}
{{- end -}}


{{/* Secret for ChromaDB */}}
{{- define "library-chart.secretChromaDB" }}
{{- if (.Values.discovery).chromadb }}
{{- $context := . }}
{{- $namespace := .Release.Namespace }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list $namespace "chromadb") | fromJsonArray) -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameChromaDB" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
stringData:
  CHROMA_SERVER_HOST: {{ $secretData.CHROMA_SERVER_HOST | default "" | b64dec | quote }}
  CHROMA_SERVER_SSL_ENABLED: {{ $secretData.CHROMA_SERVER_SSL_ENABLED | default "" | b64dec | quote }}
  CHROMA_SERVER_HTTP_PORT: {{ $secretData.CHROMA_SERVER_HTTP_PORT | default "" | b64dec | quote }}
  {{- with $secretData.CHROMA_CLIENT_AUTH_PROVIDER }}
  CHROMA_CLIENT_AUTH_PROVIDER: {{ b64dec . | quote }}
  {{- end }}
  {{- with $secretData.CHROMA_AUTH_SECRET }}
  CHROMA_AUTH_SECRET: {{ b64dec . | quote }}
  {{- with lookup "v1" "Secret" $namespace (b64dec .) }}
  {{- with .data }}
  {{- if .header }}
  CHROMA_AUTH_TOKEN_TRANSPORT_HEADER: {{ b64dec .header | quote }}
  {{- end }}
  {{- if .token }}
  CHROMA_CLIENT_AUTH_CREDENTIALS: {{ b64dec .token | quote }}
  {{- else if and .username .password }}
  CHROMA_CLIENT_AUTH_USERNAME: {{ b64dec .username | quote }}
  CHROMA_CLIENT_AUTH_PASSWORD: {{ b64dec .password | quote }}
  CHROMA_CLIENT_AUTH_CREDENTIALS: {{ printf "%s:%s" (b64dec .username) (b64dec .password) | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}


{{- define "library-chart.chroma-discovery-help" -}}
{{- if (.Values.discovery).chroma }}
{{- if first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "chromadb") | fromJsonArray) }}
The connection to your ChromaDB service is already preconfigured in your service.
{{- if regexMatch "^r|r$" .Chart.Name }}
There is no well-supported ChromaDB client for R yet.
{{- else }}
Install the ChromaDB client library first:
```bash
uv pip install chromadb-client==0.6.3
```

Environment variables are then automatically used for authentication:
```python
import os
import chromadb
from chromadb.config import Settings

# Setup client using environment variables
client = chromadb.HttpClient(
    host=os.getenv("CHROMA_SERVER_HOST"),
    port=int(os.getenv("CHROMA_SERVER_HTTP_PORT")),
    settings=Settings()
)

# Create a dummy collection
client.get_or_create_collection("test", metadata={"key": "value"})

# Print out all existing collections
print("This should print ['test']:", client.list_collections())
```
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
