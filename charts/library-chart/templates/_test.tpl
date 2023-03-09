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
      image: busybox:1.36.0-uclibc
      command: ['wget']
      args: ['{{ include "library-chart.fullname" . }}:{{ .Values.networking.service.port }}']
      resources:
        limits:
          cpu: 200m
          memory: 256Mi
        requests:
          cpu: 100m
          memory: 128Mi
      securityContext:    
        runAsUser: 1000
        runAsNonRoot: true
  restartPolicy: Never
{{- end }}
