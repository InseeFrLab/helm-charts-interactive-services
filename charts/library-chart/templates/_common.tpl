{{/* vim: set filetype=mustache: */}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "library-chart.capabilities.kubeVersion" -}}
{{- if .Values.global }}
    {{- if .Values.global.kubeVersion }}
    {{- .Values.global.kubeVersion -}}
    {{- else }}
    {{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
    {{- end -}}
{{- else }}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- end -}}
{{- end -}}

{{/*
Return the URL at which the service can be accessed
*/}}
{{- define "library-chart.service-url" -}}
  {{- if .Values.ingress.enabled -}}
    {{- printf "%s://%s" (.Values.ingress.tls | ternary "https" "http") .Values.ingress.hostname -}}
  {{- else if .Values.route.enabled -}}
    {{- printf "https://%s" .Values.route.hostname -}}
  {{- end -}}
{{- end -}}

{{/*
Return the URL at which the service can be accessed
*/}}
{{- define "library-chart.spark-url" -}}
  {{- if (.Values.spark).sparkui -}}
    {{- if .Values.ingress.enabled -}}
      {{- printf "%s://%s" (.Values.ingress.tls | ternary "https" "http") .Values.ingress.sparkHostname -}}
    {{- else if .Values.route.enabled -}}
      {{- printf "https://%s" .Values.route.sparkHostname -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return the URL at which the user-defined custom port(s) can be accessed
*/}}
{{- define "library-chart.user-url" -}}
  {{- if .Values.ingress.enabled -}}
    {{- printf "%s://%s" (.Values.ingress.tls | ternary "https" "http") .Values.ingress.userHostname -}}
  {{- else if .Values.route.enabled -}}
    {{- printf "https://%s" .Values.route.userHostname -}}
  {{- end -}}
{{- end -}}
