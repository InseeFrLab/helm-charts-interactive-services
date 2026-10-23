{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a Service */}}
{{- define "library-chart.service" -}}
{{- if or .Values.autoscaling.enabled (not (.Values.global).suspend) }}
{{- $userPorts := list -}}
{{- if and .Values.networking.user .Values.networking.user.enabled (or .Values.networking.user.ports .Values.networking.user.port) -}}
{{- $userPorts = .Values.networking.user.ports | default (list .Values.networking.user.port) -}}
{{- end -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "library-chart.fullname" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.networking.type | quote }}
  {{- if .Values.networking.clusterIP }}
  clusterIP: {{ .Values.networking.clusterIP | quote }}
  {{- end }}
  ports:
    - port: {{ .Values.networking.service.port | int }}
      targetPort: {{ default .Values.networking.service.port .Values.networking.service.targetPort | int }}
      protocol: TCP
      name: main
    {{- range $userPort := $userPorts }}
    - port: {{ $userPort | int }}
      targetPort: {{ $userPort | int }}
      protocol: TCP
      name: {{ printf "user-%d" (int $userPort) | quote }}
    {{- end }}
    {{ if .Values.spark }}
    {{ if .Values.spark.ui }}
    {{ if .Values.networking.sparkui }}
    - port: {{ .Values.networking.sparkui.port | int }}
      targetPort: {{ .Values.networking.sparkui.port | int }}
      protocol: TCP
      name: sparkui
    {{- end }}
    {{- end }}
    {{- end }}
  selector:
    {{- include "library-chart.selectorLabels" . | nindent 4 }}
{{- end -}}
{{- end }}
