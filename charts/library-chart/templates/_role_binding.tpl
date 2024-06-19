{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a RoleBinding */}}
{{- define "library-chart.roleBinding" -}}
{{- if .Values.serviceAccount.create -}}
{{- if .Values.kubernetes.enabled -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ include "library-chart.serviceAccountName" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ .Values.kubernetes.role}}
subjects:
- kind: ServiceAccount
  name: {{ include "library-chart.serviceAccountName" . }}
  namespace: {{ .Release.Namespace }}
{{- end }}
{{- end }}
{{- end }}


{{/* Template to generate a RoleBinding to SCC */}}
{{- define "library-chart.roleBindingSCC" -}}
{{- if .Values.serviceAccount.create -}}
{{- if .Values.openshiftSCC -}}
{{- if .Values.openshiftSCC.enabled -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: '{{ include "library-chart.serviceAccountName" . }}-scc-{{ .Values.openshiftSCC.scc }}'
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:{{ .Values.openshiftSCC.scc }}
subjects:
- kind: ServiceAccount
  name: {{ include "library-chart.serviceAccountName" . }}
  namespace: {{ .Release.Namespace }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
