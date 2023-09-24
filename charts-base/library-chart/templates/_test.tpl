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
    - name: curl
      image: curlimages/curl:8.00.1
      command: ['curl']
      args: ['http://{{ include "library-chart.fullname" . }}:{{ .Values.networking.service.port }}', '-L']
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
