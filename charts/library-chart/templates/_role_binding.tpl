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
  name: {{ .Values.kubernetes.role | quote }}
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
  name: {{ printf "%s-scc-%s" (include "library-chart.serviceAccountName" .) .Values.openshiftSCC.scc | quote }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ printf "system:openshift:scc:%s" .Values.openshiftSCC.scc | quote }}
subjects:
- kind: ServiceAccount
  name: {{ include "library-chart.serviceAccountName" . }}
  namespace: {{ .Release.Namespace }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
