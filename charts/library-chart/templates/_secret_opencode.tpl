{{/* vim: set filetype=mustache: */}}

{{/* Build an opencode ProviderConfig (https://opencode.ai/config.json) from an Onyxia provider */}}
{{- define "library-chart.opencodeProviderConfig" -}}
{{- $models := dict -}}
{{- range $m := (.models | default list) }}
{{- $_ := set $models $m (dict) -}}
{{- end }}
{{- dict
      "npm" "@ai-sdk/openai-compatible"
      "name" (.name | default "")
      "options" (dict "baseURL" (.apiBase | default "") "apiKey" (.apiKey | default ""))
      "models" $models
    | toJson -}}
{{- end }}

{{/* Template to generate the opencode config secret (multi-provider) */}}
{{- define "library-chart.secretOpencode" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
{{- $providers := $aiAssistant.providers | default list -}}
{{- $active := $aiAssistant.activeProvider | default dict -}}
{{- $providerMap := dict -}}
{{- range $p := $providers }}
{{- if $p.id }}
{{- $_ := set $providerMap $p.id (include "library-chart.opencodeProviderConfig" $p | fromJson) -}}
{{- end }}
{{- end }}
{{- if $active.id }}
{{- $_ := set $providerMap $active.id (include "library-chart.opencodeProviderConfig" $active | fromJson) -}}
{{- end }}
{{- $config := dict "$schema" "https://opencode.ai/config.json" "provider" $providerMap -}}
{{- if and $active.id $active.selectedModel }}
{{- $_ := set $config "model" (printf "%s/%s" $active.id $active.selectedModel) -}}
{{- end }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s-secretopencode" (include "library-chart.fullname" .) }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  opencode.jsonc: |
{{ $config | toPrettyJson | indent 4 }}
{{- end }}
{{- end }}
