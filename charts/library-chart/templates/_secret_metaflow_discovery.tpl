{{/* Create the name of the secret Metaflow to use */}}
{{- define "library-chart.secretNameMetaflow" -}}
{{- if (.Values.discovery).metaflow }}
{{- $name := printf "%s-secretmetaflow" (include "library-chart.fullname" .) }}
{{- default $name (.Values.metaflow).secretName }}
{{- else }}
{{- default "default" (.Values.metaflow).secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a Secret for Metaflow */}}
{{- define "library-chart.secretMetaflow" -}}
{{- $namespace := .Release.Namespace -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMetaflow" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  config.json: |
    {
      "METAFLOW_DEFAULT_METADATA": "service",
      "METAFLOW_KUBERNETES_SERVICE_ACCOUNT": "default",
      "METAFLOW_S3_ENDPOINT_URL": "https://{{ eq .Values.s3.endpoint "s3.amazonaws.com" | ternary (printf "s3.%s.amazonaws.com" .Values.s3.defaultRegion) .Values.s3.endpoint }}",
{{- if (.Values.discovery).metaflow }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list $namespace "metaflow") | fromJsonArray) }}
{{- $host     := $secretData.host     | default "" | b64dec }}
{{- $s3Bucket := $secretData.s3Bucket | default "" | b64dec }}
{{- $s3Secret := $secretData.s3Secret | default "" | b64dec }}
      "METAFLOW_KUBERNETES_NAMESPACE": {{ $namespace | quote }},
      "METAFLOW_SERVICE_URL": {{ $host | quote }},
      "METAFLOW_KUBERNETES_SECRETS": {{ $s3Secret | quote }},
      "METAFLOW_DATASTORE_SYSROOT_S3": {{ $s3Bucket | quote }},
      "METAFLOW_DATATOOLS_SYSROOT_S3": {{ $s3Bucket | quote }},
{{- end }}
{{- end }}
      "METAFLOW_DEFAULT_DATASTORE": "s3"
    }
{{- end }}


{{- define "library-chart.metaflow-discovery-help" }}
{{- if (.Values.discovery).metaflow }}
{{- if first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "metaflow") | fromJsonArray) }}
The connection to your [MetaFlow](https://metaflow.org/) service is already preconfigured in your service.
All MetaFlow objects (flows, runs, tasks, projects, etc.) created using this interactive service
are tracked and can directly be browsed from your MetaFlow user interface.
{{- if hasKey .Values.service "customPythonEnv" }}

For instance, using Python, start by installing MetaFlow with `pip install metaflow`.
Then the following script can be executed with `python helloflow.py run`:

```python
# helloflow.py
from metaflow import FlowSpec, step

class HelloFlow(FlowSpec):
    @step
    def start(self):
        print("HelloFlow is starting.")
        self.next(self.end)
    @step
    def end(self):
        print("HelloFlow is all done.")

if __name__ == "__main__":
    HelloFlow()
```

To learn more about integrating MetaFlow to your data ingestion pipelines, read [the full documentation](https://docs.metaflow.org/).
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
