{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a PVC */}}
{{- define "library-chart.persistentVolumeClaim" -}}
{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ include "library-chart.fullname" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
spec:
  accessModes:
    - {{ .Values.persistence.accessMode | quote }}
  resources:
    requests:
      storage: {{ .Values.persistence.size | quote }}
{{- if .Values.persistence.storageClass }}
{{- if (eq "-" .Values.persistence.storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: "{{ .Values.persistence.storageClass }}"
{{- end }}
{{- end }}
{{- end }}
{{- end }}
