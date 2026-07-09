{{/* vim: set filetype=mustache: */}}

{{/* HTTPRoute annotations */}}
{{- define "library-chart.httproute.annotations" -}}
{{- with (.Values.httproute).annotations }}
{{- toYaml . }}
{{- end }}
{{- if ((.Values.security).allowlist).enabled }}
gateway.networking.k8s.io/client-ip-masking: "true"
{{- end }}
{{- end }}

{{/* HTTPRoute hostname */}}
{{- define "library-chart.httproute.hostname" -}}
{{- if (.Values.httproute).generate }}
{{- .Values.httproute.userHostname }}
{{- else }}
{{- .Values.httproute.hostname }}
{{- end }}
{{- end }}

{{/* Template to generate a standard HTTPRoute */}}
{{- define "library-chart.httproute" -}}
{{- if (.Values.httproute).enabled -}}
{{- if or (.Values.autoscaling).enabled (not (.Values.global).suspend) }}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.service.port -}}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $fullName }}-ui
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    {{- include "library-chart.httproute.annotations" . | nindent 4 }}
spec:
  parentRefs:
    {{- toYaml .Values.httproute.parentRefs | nindent 4 }}
  hostnames:
    - {{ .Values.httproute.hostname | quote }}
  rules:
    - backendRefs:
        - name: {{ $fullName }}
          port: {{ $svcPort }}
      {{- if .Values.httproute.path }}
      matches:
        - path:
            type: PathPrefix
            value: {{ .Values.httproute.path }}
      {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* Template to generate a custom HTTPRoute */}}
{{- define "library-chart.httprouteUser" -}}
{{- if (.Values.httproute).enabled -}}
{{- if or (.Values.autoscaling).enabled (not (.Values.global).suspend) }}
{{- if ((.Values.networking).user).enabled -}}
{{- $userPorts := list -}}
{{- if or .Values.networking.user.ports .Values.networking.user.port -}}
{{- $userPorts = .Values.networking.user.ports | default (list .Values.networking.user.port) -}}
{{- end -}}
{{- if $userPorts -}}
{{- $fullName := include "library-chart.fullname" . -}}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $fullName }}-user
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    {{- include "library-chart.httproute.annotations" . | nindent 4 }}
spec:
  parentRefs:
    {{- toYaml .Values.httproute.parentRefs | nindent 4 }}
  hostnames:
    {{- range $userPort := $userPorts }}
    {{- if eq (len $userPorts) 1 }}
    - {{ $.Values.httproute.userHostname | quote }}
    {{- else }}
    - {{ regexReplaceAll "([^\\.]+)\\.(.*)" $.Values.httproute.userHostname (printf "${1}-%d.${2}" (int $userPort)) | quote }}
    {{- end }}
    {{- end }}
  rules:
    {{- range $userPort := $userPorts }}
    - backendRefs:
        - name: {{ $fullName }}
          port: {{ $userPort }}
      {{- if $.Values.httproute.userPath }}
      matches:
        - path:
            type: PathPrefix
            value: {{ $.Values.httproute.userPath }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* Template to generate an HTTPRoute for the Spark UI */}}
{{- define "library-chart.httprouteSpark" -}}
{{- if and (.Values.httproute).enabled (.Values.spark).ui -}}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.sparkui.port -}}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $fullName }}-sparkui
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    {{- include "library-chart.httproute.annotations" . | nindent 4 }}
spec:
  parentRefs:
    {{- toYaml .Values.httproute.parentRefs | nindent 4 }}
  hostnames:
    - {{ .Values.spark.hostname | quote }}
  rules:
    - backendRefs:
        - name: {{ $fullName }}
          port: {{ $svcPort }}
      {{- if .Values.spark.path }}
      matches:
        - path:
            type: PathPrefix
            value: {{ .Values.spark.path }}
      {{- end }}
{{- end }}
{{- end }}