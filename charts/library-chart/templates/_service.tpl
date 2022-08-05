{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a Service */}}
{{- define "library-chart.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "library-chart.fullname" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.networking.type }}
  {{- if .Values.networking.clusterIP }}
  clusterIP: {{ .Values.networking.clusterIP }}
  {{- end }}
  ports:
    - port: {{ .Values.networking.service.port }}
      targetPort: http
      protocol: TCP
      name: http
    {{ if .Values.networking.user.enabled }}
    - port: {{ .Values.networking.user.port }}
      targetPort: {{ .Values.networking.user.port }}
      protocol: TCP
      name: user
    {{- end }}
  selector:
    {{- include "library-chart.selectorLabels" . | nindent 4 }}
{{- end }}
