{{/* vim: set filetype=mustache: */}}

{{/* Template to generate the continue config secret (multi-provider) */}}
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
    {{- range $p := ($aiAssistant.providers | default list) }}
    {{- range $m := ($p.models | default list) }}
    - name: {{ printf "%s / %s" $p.name $m | quote }}
      model: {{ $m | quote }}
      provider: {{ $p.provider | quote }}
      {{- if $p.apiBase }}
      apiBase: {{ $p.apiBase | quote }}
      {{- end }}
      {{- if $p.apiKey }}
      apiKey: {{ $p.apiKey }}
      {{- end }}
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
