{{/* vim: set filetype=mustache: */}}

{{/* Create the name of the secret AI Assistant to use (Jupyter) */}}
{{- define "library-chart.secretNameAssistantJupyter" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled }}
{{- $name := printf "%s-secretassistant" (include "library-chart.fullname" .) }}
{{- default $name $aiAssistant.secretName }}
{{- else }}
{{- default "default" $aiAssistant.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate the jupyter-ai config secret (uses the active provider) */}}
{{- define "library-chart.secretAssistantJupyter" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
{{- $active := $aiAssistant.activeProvider | default dict -}}
{{/* Fall back to the legacy flat structure (userPreferences.aiAssistant) */}}
{{- $model := $active.selectedModel | default $aiAssistant.model | default "" -}}
{{- $apiBase := $active.apiBase | default $aiAssistant.apiBase | default "" -}}
{{- $modelProvider := $aiAssistant.modelProvider | default "openai-chat" -}}
{{- $embeddingsProvider := $aiAssistant.embeddingsProvider | default "" -}}
{{- $fields := dict -}}
{{- $embeddingsFields := dict -}}
{{- if $apiBase }}
{{- $_ := set $fields (printf "%s:" $modelProvider) (dict "openai_api_base" $apiBase) -}}
{{- if $model }}
{{- $_ := set $fields (printf "%s:%s" $modelProvider $model) (dict "openai_api_base" $apiBase) -}}
{{- end }}
{{- if and $embeddingsProvider $model }}
{{- $_ := set $embeddingsFields (printf "%s:%s" $embeddingsProvider $model) (dict "openai_api_base" $apiBase) -}}
{{- end }}
{{- end }}
{{/* No api_keys here: jupyter-ai falls back to the OPENAI_API_KEY env var injected by the statefulset */}}
{{- $config := dict
      "model_provider_id" (empty $model | ternary nil (printf "%s:%s" $modelProvider $model))
      "embeddings_provider_id" (or (empty $embeddingsProvider) (empty $model) | ternary nil (printf "%s:%s" $embeddingsProvider $model))
      "send_with_shift_enter" false
      "fields" $fields
      "api_keys" (dict)
      "completions_model_provider_id" nil
      "completions_fields" (dict)
      "embeddings_fields" $embeddingsFields
-}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameAssistantJupyter" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  config.json: |
{{ $config | toPrettyJson | indent 4 }}
{{- end }}
{{- end }}
