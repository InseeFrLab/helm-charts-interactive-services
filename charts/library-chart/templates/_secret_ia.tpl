{{/* vim: set filetype=mustache: */}}

{{/* Return the IA assistant config, preferring top-level aiAssistant over legacy userPreferences.aiAssistant */}}
{{- define "library-chart.aiAssistant" -}}
{{- $userPreferences := get .Values "userPreferences" | default dict -}}
{{- $legacyAiAssistant := get $userPreferences "aiAssistant" | default dict -}}
{{- $aiAssistant := get .Values "ai" | default dict -}}
{{- $merged := mergeOverwrite (dict) $legacyAiAssistant $aiAssistant -}}
{{/* Normalize providers so both injection formats expose the fields consumed by the secrets. */}}
{{- $providers := $merged.providers | default list -}}
{{- range $provider := $providers -}}
{{- $_ := set $provider "id" ($provider.id | default $provider.name) -}}
{{- $_ := set $provider "provider" ($provider.provider | default $provider.type | default "openai-compatible") -}}
{{- end -}}
{{- $_ := set $merged "providers" $providers -}}

{{/* The current injection supplies a provider/model pair, e.g. "lab-llm/gpt-4o". */}}
{{- $selectedModel := $merged.selectedModel | default "" -}}
{{- $resolvedProvider := dict -}}
{{- if $selectedModel -}}
{{- $selectedParts := splitList "/" $selectedModel -}}
{{- if ge (len $selectedParts) 2 -}}
{{- $selectedProviderName := first $selectedParts -}}
{{- $selectedModelName := join "/" (rest $selectedParts) -}}
{{- range $provider := $providers -}}
{{- if eq ($provider.name | default "") $selectedProviderName -}}
{{- $resolvedProvider = mergeOverwrite (dict) $provider -}}
{{- end -}}
{{- end -}}
{{- if $resolvedProvider -}}
{{- $_ := set $resolvedProvider "selectedModel" $selectedModelName -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Retain the older flat user preference fields while they are still supported. */}}
{{- if and (not $resolvedProvider) (or $legacyAiAssistant.provider $legacyAiAssistant.model $legacyAiAssistant.apiBase $legacyAiAssistant.apiKey) -}}
{{- $models := list -}}
{{- if $legacyAiAssistant.model -}}
{{- $models = list $legacyAiAssistant.model -}}
{{- end -}}
{{- $resolvedProvider = dict
      "id" ($legacyAiAssistant.provider | default "")
      "name" ($legacyAiAssistant.provider | default "")
      "provider" ($legacyAiAssistant.provider | default "")
      "apiBase" ($legacyAiAssistant.apiBase | default "")
      "apiKey" ($legacyAiAssistant.apiKey | default "")
      "selectedModel" ($legacyAiAssistant.model | default "")
      "models" $models
-}}
{{- $_ := set $merged "resolvedProvider" $resolvedProvider -}}
{{/* mergeOverwrite lets the new block's zero values (enabled: false) clobber the legacy flag */}}
{{- $_ := set $merged "enabled" (or $aiAssistant.enabled $legacyAiAssistant.enabled false) -}}
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
{{- $resolvedProvider := $aiAssistant.resolvedProvider | default dict -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameIa" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
type: Opaque
stringData:
  OPENAI_API_KEY: {{ $resolvedProvider.apiKey | default "" | quote }}
  OPENAI_BASE_URL: {{ $resolvedProvider.apiBase | default "" | quote }}
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
