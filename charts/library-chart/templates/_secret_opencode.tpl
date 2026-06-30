{{/* vim: set filetype=mustache: */}}

{{/* Template to generate the opencode config secret (multi-provider) */}}
{{- define "library-chart.secretOpencode" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
{{- $providers := $aiAssistant.providers | default list -}}
{{- $active := $aiAssistant.activeProvider | default dict -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s-secretopencode" (include "library-chart.fullname" .) }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  opencode.jsonc: |
    {
      "$schema": "https://opencode.ai/config.json",
      "provider": {
{{- range $i, $p := $providers }}
{{- if $i }},{{ end }}
        {{ $p.id | quote }}: {
          "npm": "@ai-sdk/openai-compatible",
          "name": {{ $p.name | quote }},
          "options": {
            "baseURL": {{ $p.apiBase | quote }},
            "apiKey": {{ $p.apiKey | quote }}
          },
          "models": {
{{- range $j, $m := $p.models }}
{{- if $j }},{{ end }}
            {{ $m | quote }}: {}
{{- end }}
          }
        }
{{- end }}
      }{{- if $active.id }},
      "model": {{ printf "%s/%s" $active.id ($active.selectedModel | default "") | quote }}
{{- end }}
    }
{{- end }}
{{- end }}
