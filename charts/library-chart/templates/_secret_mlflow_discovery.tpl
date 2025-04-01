{{/* Create the name of the secret MLFlow to use */}}
{{- define "library-chart.secretNameMLFlow" -}}
{{- if (.Values.discovery).mlflow }}
{{- $name := printf "%s-secretmlflow" (include "library-chart.fullname" .) }}
{{- default $name (.Values.mlflow).secretName }}
{{- else }}
{{- default "default" (.Values.mlflow).secretName }}
{{- end }}
{{- end }}


{{/* Secret for MLFlow */}}
{{- define "library-chart.secretMLFlow" }}
{{- $context := . }}
{{- if (.Values.discovery).mlflow }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "mlflow") | fromJsonArray) -}}
{{- $uri                      := $secretData.uri                      | default "" | b64dec }}
{{- $mlflow_tracking_username := $secretData.MLFLOW_TRACKING_USERNAME | default "" | b64dec }}
{{- $mlflow_tracking_password := $secretData.MLFLOW_TRACKING_PASSWORD | default "" | b64dec }}
{{- $mlflow_s3_endpoint_url := $secretData.MLFLOW_S3_ENDPOINT_URL | default "" | b64dec }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMLFlow" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
stringData:
{{- if $uri }}
  MLFLOW_TRACKING_URI: {{ $uri | quote }}
{{- end }}
{{- if and $mlflow_tracking_username $mlflow_tracking_password }}
  MLFLOW_TRACKING_USERNAME: {{ $mlflow_tracking_username | quote }}
  MLFLOW_TRACKING_PASSWORD: {{ $mlflow_tracking_password | quote }}
{{- end }}
  MLFLOW_S3_ENDPOINT_URL: {{ $mlflow_s3_endpoint_url | quote }}
{{- end }}
{{- end }}
{{- end }}


{{- define "library-chart.mlflow-discovery-help" -}}
{{- if (.Values.discovery).mlflow }}
{{- if first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "mlflow") | fromJsonArray) }}
The connection to your MLflow service is already preconfigured in your service.
{{- if hasKey .Values.service "customPythonEnv" }}
A client can be created in a Python script or interactive console:
```python
import mlflow
client = mlflow.tracking.MlflowClient()

# Create a new experiment
experiment_id = client.create_experiment("TestExperiment")
with mlflow.start_run(experiment_id=experiment_id) as run:
    ...

# Register model name in the model registry
client.create_registered_model("TestModel")

# Create a new version of the model under the registered model name
client.create_model_version("TestModel", ...)
```
To learn more about integrating MLflow, read [the full documentation](https://mlflow.org/docs/latest/api_reference/python_api/index.html).
{{- end }}
{{- else }}
There is no well-supported MLflow client for R yet.
{{- end }}
{{- end }}
{{- end -}}
