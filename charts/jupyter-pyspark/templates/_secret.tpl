{{/* vim: set filetype=mustache: */}}

{{/* Create the name of the config map S3 to use */}}
{{- define "library-chart.secretNameS3" -}}
{{- if .Values.s3.enabled }}
{{- $name:= (printf "%s-secrets3" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.s3.secretName }}
{{- else }}
{{- default "default" .Values.s3.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a secret for S3 */}}
{{- define "library-chart.secretS3" -}}
{{- if .Values.s3.enabled -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameS3" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: "{{ .Values.s3.accessKeyId }}"
  AWS_S3_ENDPOINT: "{{ .Values.s3.endpoint }}"
  S3_ENDPOINT: "https://{{ .Values.s3.endpoint }}/"
  AWS_DEFAULT_REGION: "{{ .Values.s3.defaultRegion }}"
  AWS_SECRET_ACCESS_KEY: "{{ .Values.s3.secretAccessKey }}"
  AWS_SESSION_TOKEN: "{{ .Values.s3.sessionToken }}"
{{- end }}
{{- end }}


{{/* Create the name of the config map Vault to use */}}
{{- define "library-chart.secretNameVault" -}}
{{- if .Values.vault.enabled }}
{{- $name:= (printf "%s-secretvault" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.vault.secretName }}
{{- else }}
{{- default "default" .Values.vault.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a secret for Vault */}}
{{- define "library-chart.secretVault" -}}
{{- if .Values.vault.enabled -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameVault" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  VAULT_ADDR: "{{ .Values.vault.url }}"
  VAULT_TOKEN: "{{ .Values.vault.token }}"
  VAULT_RELATIVE_PATH: "{{ .Values.vault.secret }}"
  VAULT_TOP_DIR: "{{ .Values.vault.directory }}"
  VAULT_MOUNT: "{{ .Values.vault.mount }}"
{{- end }}
{{- end }}


{{/* Create the name of the config map Git to use */}}
{{- define "library-chart.secretNameGit" -}}
{{- if .Values.git.enabled }}
{{- $name:= (printf "%s-secretgit" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.git.secretName }}
{{- else }}
{{- default "default" .Values.git.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a secret for git */}}
{{- define "library-chart.secretGit" -}}
{{- if .Values.git.enabled -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameGit" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  GIT_USER_NAME: "{{ .Values.git.name }}"
  GIT_USER_MAIL: "{{ .Values.git.email }}"
  GIT_CREDENTIALS_CACHE_DURATION: "{{ .Values.git.cache }}"
  GIT_PERSONAL_ACCESS_TOKEN: "{{ .Values.git.token }}"
  GIT_REPOSITORY: "{{ .Values.git.repository }}"
  GIT_BRANCH: "{{ .Values.git.branch }}"
{{- end }}
{{- end }}

