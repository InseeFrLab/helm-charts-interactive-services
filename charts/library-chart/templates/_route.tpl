{{/* vim: set filetype=mustache: */}}

{{/* Route annotations */}}
{{- define "library-chart.route.annotations" -}}
{{- with .Values.route.annotations }}
    {{- toYaml . }}
{{- end }}
{{- if .Values.security.allowlist.enabled }}
haproxy.router.openshift.io/ip_whitelist: {{ .Values.security.allowlist.ip | quote }}
{{- end }}
{{- end }}

{{/* Route hostname */}}
{{- define "library-chart.route.hostname" -}}
{{- if .Values.route.generate }}
{{- printf "%s" .Values.route.userHostname }}
{{- else }}
{{- printf "%s" .Values.route.hostname }}
{{- end }}
{{- end }}

{{/* Template to generate a standard Route */}}
{{- define "library-chart.route" -}}
{{- if .Values.route.enabled -}}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.service.port -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ $fullName }}-ui
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    {{- include "library-chart.route.annotations" . | nindent 4 }}
spec:
  host: {{ .Values.route.hostname | quote }}
  {{- if ne .Values.route.tls.termination "passthrough" }}
  path: {{ .Values.route.path | default "/" | quote }}
  {{- end }}
  to:
    kind: Service
    name: {{ $fullName }}
  port:
    targetPort: {{ $svcPort | int }}
  tls:
    termination: {{ .Values.route.tls.termination | quote }}
    {{- if .Values.route.tls.key }}
    key: {{ .Values.route.tls.key | quote }}
    {{- end }}
    {{- if .Values.route.tls.certificate }}
    certificate: {{ .Values.route.tls.certificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.caCertificate }}
    caCertificate: {{ .Values.route.tls.caCertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.destinationCACertificate }}
    destinationCACertificate: {{ .Values.route.tls.destinationCACertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.insecureEdgeTerminationPolicy }}
    insecureEdgeTerminationPolicy: {{ .Values.route.tls.insecureEdgeTerminationPolicy | quote }}
    {{- end }}
  wildcardPolicy: {{ .Values.route.wildcardPolicy | quote }}
{{- end }}
{{- end }}

{{/* Template to generate a custom Route */}}
{{- define "library-chart.routeUser" -}}
{{- if .Values.route.enabled -}}
{{- if and .Values.networking.user .Values.networking.user.enabled (or .Values.networking.user.ports .Values.networking.user.port) -}}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $userPorts := .Values.networking.user.ports | default (list .Values.networking.user.port) -}}
{{- range $userPort := $userPorts -}}
{{- with $ -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ $fullName }}-user-{{ $userPort }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    {{- include "library-chart.route.annotations" . | nindent 4 }}
spec:
{{- if eq (len $userPorts) 1 }}
  host: {{ .Values.route.userHostname | quote }}
{{- else }}
  host: {{ regexReplaceAll "([^\\.]+)\\.(.*)" .Values.route.userHostname (printf "${1}-%d.${2}" (int $userPort)) | quote }}
{{- end }}
  {{- if ne .Values.route.tls.termination "passthrough" }}
  path: {{ .Values.route.userPath | default "/" | quote }}
  {{- end }}
  to:
    kind: Service
    name: {{ $fullName }}
  port:
    targetPort: {{ $userPort | int }}
  tls:
    termination: {{ .Values.route.tls.termination | quote }}
    {{- if .Values.route.tls.key }}
    key: {{ .Values.route.tls.key | quote }}
    {{- end }}
    {{- if .Values.route.tls.certificate }}
    certificate: {{ .Values.route.tls.certificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.caCertificate }}
    caCertificate: {{ .Values.route.tls.caCertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.destinationCACertificate }}
    destinationCACertificate: {{ .Values.route.tls.destinationCACertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.insecureEdgeTerminationPolicy }}
    insecureEdgeTerminationPolicy: {{ .Values.route.tls.insecureEdgeTerminationPolicy | quote }}
    {{- end }}
  wildcardPolicy: {{ .Values.route.wildcardPolicy | quote }}
---
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* Template to generate a Route for the Spark UI */}}
{{- define "library-chart.routeSpark" -}}
{{- if .Values.route.enabled -}}
{{- if .Values.spark.ui -}}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.sparkui.port -}}
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: {{ $fullName }}-sparkui
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
  annotations:
    {{- include "library-chart.route.annotations" . | nindent 4 }}
spec:
  host: {{ .Values.spark.hostname | quote }}
  {{- if ne .Values.route.tls.termination "passthrough" }}
  path: {{ .Values.spark.path | default "/" | quote }}
  {{- end }}
  to:
    kind: Service
    name: {{ $fullName }}
  port:
    targetPort: {{ $svcPort | int }}
  tls:
    termination: {{ .Values.route.tls.termination | quote }}
    {{- if .Values.route.tls.key }}
    key: {{ .Values.route.tls.key | quote }}
    {{- end }}
    {{- if .Values.route.tls.certificate }}
    certificate: {{ .Values.route.tls.certificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.caCertificate }}
    caCertificate: {{ .Values.route.tls.caCertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.destinationCACertificate }}
    destinationCACertificate: {{ .Values.route.tls.destinationCACertificate | quote }}
    {{- end }}
    {{- if .Values.route.tls.insecureEdgeTerminationPolicy }}
    insecureEdgeTerminationPolicy: {{ .Values.route.tls.insecureEdgeTerminationPolicy | quote }}
    {{- end }}
  wildcardPolicy: {{ .Values.route.wildcardPolicy | quote }}
{{- end }}
{{- end }}
{{- end }}
