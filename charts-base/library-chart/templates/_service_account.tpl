{{/* vim: set filetype=mustache: */}}

{{/*
Create the name of the service account to use
*/}}
{{- define "library-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "library-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Template to generate a ServiceAccount */}}
{{- define "library-chart.serviceAccount" -}}
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "library-chart.serviceAccountName" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  {{- with .Values.serviceAccount.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
