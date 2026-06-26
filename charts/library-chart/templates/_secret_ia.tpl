{{/* vim: set filetype=mustache: */}}

{{/* Return the IA assistant config, preferring top-level aiAssistant over legacy userPreferences.aiAssistant */}}
{{- define "library-chart.aiAssistant" -}}
{{- $userPreferences := get .Values "userPreferences" | default dict -}}
{{- $legacyAiAssistant := get $userPreferences "aiAssistant" | default dict -}}
{{- $aiAssistant := get .Values "ai" | default dict -}}
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
  OPENAI_API_KEY: {{ $aiAssistant.apiKey | default "" | quote }}
  OPENAI_BASE_URL: {{ $aiAssistant.apiBase | default "" | quote }}
{{- end }}
{{- end }}

{{/* Template to generate the opencode config secret */}}
{{- define "library-chart.secretOpencode" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
{{- $provider := $aiAssistant.provider | default "openai" -}}
{{- $model := $aiAssistant.model | default "" -}}
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
        {{ $provider | quote }}: {
          "npm": "@ai-sdk/openai-compatible",
          "options": {
            "baseURL": "{env:OPENAI_BASE_URL}",
            "apiKey": "{env:OPENAI_API_KEY}"
          },
          "models": {
            {{ $model | quote }}: {}
          }
        }
      },
      "model": {{ printf "%s/%s" $provider $model | quote }}
    }
{{- end }}
{{- end }}

{{/* Template to generate the continue config secret */}}
{{- define "library-chart.secretContinue" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ printf "%s-secretcontinue" (include "library-chart.fullname" .) }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  config.yaml: |
    name: config
    version: 0.0.2
    models:
    {{- if $aiAssistant.model }}
    - name: {{ $aiAssistant.model | quote }}
      model: {{ $aiAssistant.model | quote }}
      provider: {{ $aiAssistant.provider | quote }}
      {{- if $aiAssistant.apiBase }}
      apiBase: {{ $aiAssistant.apiBase | quote }}
      {{- end }}
      {{- if $aiAssistant.apiKey }}
      apiKey: {{ $aiAssistant.apiKey }}
      {{- end }}
    {{- end }}
    {{- if $aiAssistant.embeddingsModel }}
    embeddingsProvider:
      model: {{ $aiAssistant.embeddingsModel | quote }}
      {{- if $aiAssistant.apiBase }}
      apiBase: {{ $aiAssistant.apiBase | quote }}
      {{- end }}
      {{- if $aiAssistant.apiKey }}
      apiKey: {{ $aiAssistant.apiKey }}
      {{- end }}
    {{- end }}
    context:
      - provider: problems
      - provider: debugger
        params:
          stackDepth: 3
      - provider: tree
      - provider: clipboard
      - provider: url
      - provider: search
      - provider: folder
      - provider: codebase
      - provider: web
        params:
          n: 5
      - provider: open
        params:
          onlyPinned: true
      - provider: docs
      - provider: terminal
      - provider: currentFile
      - provider: diff
      - provider: code
      - provider: file
    mcpServers:
      - name: DuckDB
        command: uvx
        args:
          - mcp-server-motherduck
          - "--allow-switch-databases"
          - "--read-write"
          - "--db-path"
          - ":memory:"
          - "--home-dir"
          - "/home/{{ .Values.environment.user }}"
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

{{/* Template to generate a secret for AI Assistant (Jupyter) */}}
{{- define "library-chart.secretAssistantJupyter" -}}
{{- $aiAssistant := include "library-chart.aiAssistant" . | fromJson -}}
{{- if $aiAssistant.enabled -}}
{{- $modelProvider       := $aiAssistant.modelProvider -}}
{{- $embeddingsProvider  := $aiAssistant.embeddingsProvider -}}
{{- $model               := $aiAssistant.model -}}
{{- $apiBase             := $aiAssistant.apiBase -}}

apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameAssistantJupyter" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  config.json: |
    {
{{- if and $modelProvider $model }}
      "model_provider_id": {{ printf "%s:%s" $modelProvider $model | quote }},
{{- else }}
      "model_provider_id": null,
{{- end }}
{{- if and $embeddingsProvider $model }}
      "embeddings_provider_id": {{ printf "%s:%s" $embeddingsProvider $model | quote }},
{{- else }}
      "embeddings_provider_id": null,
{{- end }}
      "send_with_shift_enter": false,
      "fields": {
{{- if and $modelProvider $apiBase }}
        {{ printf "%s:" $modelProvider | quote }}: {
          "openai_api_base": {{ $apiBase | quote }}
        }{{- if $model }},{{ end }}
{{-   if $model }}
        {{ printf "%s:%s" $modelProvider $model | quote }}: {
          "openai_api_base": {{ $apiBase | quote }}
        }
{{-   end }}
{{- end }}
      },
      "api_keys": {
{{- if $aiAssistant.apiKey }}
        "OPENAI_API_KEY": {{ $aiAssistant.apiKey | quote }}
{{- end }}
      },
      "completions_model_provider_id": null,
      "completions_fields": {},
      "embeddings_fields": {
{{- if and $embeddingsProvider $model }}
        {{ printf "%s:%s" $embeddingsProvider $model | quote }}: {
          "openai_api_base": {{ $apiBase | quote }}
        }
{{- end }}
      }
    }
{{- end }}
{{- end }}
