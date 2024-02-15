{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a NetworkPolicy */}}
{{- define "library-chart.networkPolicy" -}}
{{- if .Values.security.networkPolicy.enabled -}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: {{ include "library-chart.fullname" . }}
spec:
  podSelector:
    matchLabels:
      {{- include "library-chart.selectorLabels" . | nindent 6 }}
  ingress:
  - from:
    - podSelector: {}
  policyTypes:
  - Ingress
{{- end }} 
{{- end }}

{{/* Template to generate a NetworkPolicy for an Ingress */}}
{{- define "library-chart.networkPolicyIngress" -}}
{{- if .Values.security.networkPolicy.enabled -}}
{{- if .Values.ingress.enabled -}}
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: {{ include "library-chart.fullname" . }}-2
spec:
  podSelector:
    matchLabels:
      {{- include "library-chart.selectorLabels" . | nindent 6 }}
  ingress:
  {{- with .Values.security.networkPolicy.from }}
  - from: 
  {{- toYaml . | nindent 4 }}
  {{- end }}
  policyTypes:
  - Ingress
{{- end }}
{{- end }} 
{{- end }}
