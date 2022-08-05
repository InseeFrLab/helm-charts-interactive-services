{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a Pod which tests connection to the service */}}
{{- define "library-chart.testConnection" -}}
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "library-chart.fullname" . }}-test-connection"
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test-success
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ include "library-chart.fullname" . }}:{{ .Values.networking.service.port }}']
  restartPolicy: Never
{{- end }}
