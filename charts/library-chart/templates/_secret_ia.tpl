{{/* vim: set filetype=mustache: */}}

{{/* Return the IA assistant config, preferring top-level aiAssistant over legacy userPreferences.aiAssistant */}}
{{- define "library-chart.aiAssistant" -}}
{{- $userPreferences := get .Values "userPreferences" | default dict -}}
{{- $legacyAiAssistant := get $userPreferences "aiAssistant" | default dict -}}
{{- $aiAssistant := get .Values "ai" | default dict -}}
{{- $merged := mergeOverwrite (dict) $legacyAiAssistant $aiAssistant -}}
{{/* Build an activeProvider from the legacy flat fields when the new format does not provide one */}}
{{- if and (empty $merged.activeProvider) (or $legacyAiAssistant.provider $legacyAiAssistant.model $legacyAiAssistant.apiBase $legacyAiAssistant.apiKey) -}}
{{- $models := list -}}
{{- if $legacyAiAssistant.model -}}
{{- $models = list $legacyAiAssistant.model -}}
{{- end -}}
{{- $active := dict
      "id" ($legacyAiAssistant.provider | default "")
      "name" ($legacyAiAssistant.provider | default "")
      "provider" ($legacyAiAssistant.provider | default "")
      "apiBase" ($legacyAiAssistant.apiBase | default "")
      "apiKey" ($legacyAiAssistant.apiKey | default "")
      "selectedModel" ($legacyAiAssistant.model | default "")
      "models" $models
-}}
{{- $_ := set $merged "activeProvider" $active -}}
{{- end -}}
{{- $merged | toJson -}}
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

{{/* Template to generate a generic IA secret (uses the active provider) */}}
{{- define "library-chart.secretIa" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
{{- $active := $aiAssistant.activeProvider | default dict -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameIa" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
type: Opaque
stringData:
  OPENAI_API_KEY: {{ $active.apiKey | default "" | quote }}
  OPENAI_BASE_URL: {{ $active.apiBase | default "" | quote }}
{{- end }}
{{- end }}

{{/* Create the name of the secret AI Assistant to use (VSCode / Continue) */}}
{{- define "library-chart.secretNameAssistant" -}}
{{- if (.Values.userPreferences.aiAssistant).enabled }}
{{- $name := printf "%s-secretassistant" (include "library-chart.fullname" .) }}
{{- default $name .Values.userPreferences.aiAssistant.secretName }}
{{- else }}
{{- default "default" .Values.userPreferences.aiAssistant.secretName }}
{{- end }}
{{- end }}
