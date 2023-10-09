{{/* vim: set filetype=mustache: */}}

{{/* Create the name of the config map repository to use */}}
{{- define "library-chart.repository.enabled" -}}
{{- default "" (or (or (or .Values.repository.pipRepository .Values.repository.condaRepository) .Values.repository.rRepository) .Values.repository.packageManagerUrl) }}
{{- end }}

{{- define "library-chart.configMapNameRepository" -}}
{{- if (include "library-chart.repository.enabled"  .) }}
{{- $name:= (printf "%s-configmaprepository" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.repository.configMapName }}
{{- else }}
{{- default "default" .Values.repository.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for repositories */}}
{{- define "library-chart.configMapRepository" -}}
{{- if (include "library-chart.repository.enabled"  .) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameRepository" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  {{- if .Values.repository.pipRepository }}
  PIP_REPOSITORY: "{{ .Values.repository.pipRepository }}"
  {{- end }}
  {{- if .Values.repository.condaRepository }}
  CONDA_REPOSITORY: "{{ .Values.repository.condaRepository }}"
  {{- end }}
  {{- if .Values.repository.rRepository }}
  R_REPOSITORY: "{{ .Values.repository.rRepository }}"
  {{- end }}
  {{- if .Values.repository.packageManagerUrl }}
  PACKAGE_MANAGER_URL: "{{ .Values.repository.packageManagerUrl }}"
  {{- end }}
{{- end }}
{{- end }}
