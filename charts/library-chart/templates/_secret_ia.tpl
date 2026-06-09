{{/* vim: set filetype=mustache: */}}

{{/* Return the IA assistant config, preferring top-level aiAssistant over legacy userPreferences.aiAssistant */}}
{{- define "library-chart.aiAssistant" -}}
{{- $userPreferences := get .Values "userPreferences" | default dict -}}
{{- $legacyAiAssistant := get $userPreferences "aiAssistant" | default dict -}}
{{- $aiAssistant := get .Values "aiAssistant" | default dict -}}
{{- mergeOverwrite (dict) $legacyAiAssistant $aiAssistant | toJson -}}
{{- end }}

{{/* Create the name of the generic IA secret to use */}}
{{- define "library-chart.secretNameIa" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled }}
{{- $name := printf "%s-secretia" (include "library-chart.fullname" .) }}
{{- default $name $aiAssistant.secretName }}
{{- else }}
{{- default "default" $aiAssistant.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a generic IA secret */}}
{{- define "library-chart.secretIa" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameIa" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
type: Opaque
stringData:
  AI_ASSISTANT_MODEL: {{ $aiAssistant.model | default "" | quote }}
  AI_ASSISTANT_PROVIDER: {{ $aiAssistant.provider | default "" | quote }}
  AI_ASSISTANT_MODEL_PROVIDER: {{ $aiAssistant.modelProvider | default "" | quote }}
  AI_ASSISTANT_EMBEDDINGS_PROVIDER: {{ $aiAssistant.embeddingsProvider | default "" | quote }}
  AI_ASSISTANT_API_BASE: {{ $aiAssistant.apiBase | default "" | quote }}
  AI_ASSISTANT_API_KEY: {{ $aiAssistant.apiKey | default "" | quote }}
  AI_ASSISTANT_USE_LEGACY_COMPLETIONS_ENDPOINT: {{ $aiAssistant.useLegacyCompletionsEndpoint | default false | quote }}
{{- end }}
{{- end }}
