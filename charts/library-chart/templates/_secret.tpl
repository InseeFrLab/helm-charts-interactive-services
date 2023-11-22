{{/* vim: set filetype=mustache: */}}

{{/* Create the name of the secret S3 to use */}}
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

{{/* Create the name of the secret Vault to use */}}
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

{{/* Create the name of the secret Git to use */}}
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

{{/* Create the name of the secret Token to use */}}
{{- define "library-chart.secretNameToken" -}}
{{- $name:= (printf "%s-secrettoken" (include "library-chart.fullname" .) )  }}
{{- default $name (printf "%s-secrettoken" (include "library-chart.fullname" .) )  }}
{{- end }}

{{/* Template to generate a secret for token */}}
{{- define "library-chart.secretToken" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameToken" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  PASSWORD: "{{ .Values.security.password }}"
{{- end }}

{{/* Create the name of the secret MLFlow to use */}}
{{- define "library-chart.secretNameMLFlow" -}}
{{- $name:= (printf "%s-secretmlflow" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.mlflow.secretName }}
{{- end }}

{{/* Secret for MLFlow */}}
{{- define "library-chart.secretMLFlow" -}}
{{- $context:= . -}}
{{- if .Values.discovery.mlflow -}}
{{- range $index, $secret := (lookup "v1" "Secret" .Release.Namespace "").items -}}
{{- if (index $secret "metadata" "annotations") -}}
{{- if and (index $secret "metadata" "annotations" "onyxia/discovery") (eq "mlflow" (index $secret "metadata" "annotations" "onyxia/discovery" | toString)) -}}
{{- $uri:= ( index $secret.data "uri" | default "") | b64dec  -}}
{{- $mlflow_tracking_username:= ( index $secret.data "MLFLOW_TRACKING_USERNAME" | default "") | b64dec  -}}
{{- $mlflow_tracking_password:= ( index $secret.data "MLFLOW_TRACKING_PASSWORD" | default "") | b64dec  -}}

apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMLFlow" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
stringData:
{{-  if $uri }}
  MLFLOW_TRACKING_URI: {{ printf "%s" $uri }}
{{- end }}
{{-  if and  $mlflow_tracking_username $mlflow_tracking_password }}
  MLFLOW_TRACKING_USERNAME: {{ printf "%s" $mlflow_tracking_username }}
  MLFLOW_TRACKING_PASSWORD: {{ printf "%s" $mlflow_tracking_password }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* Secret for CoreSite.xml Metastore */}}
{{- define "library-chart.coreSite" -}}
{{ printf "<?xml version=\"1.0\"?>" }}
{{ printf "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>" }} 
{{ printf "<configuration>"}}     
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.connection.ssl.enabled</name>" | indent 4}}
{{ printf "<value>true</value>" | indent 4}}
{{ printf "</property>"}}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.endpoint</name>" | indent 4}}
{{ printf "<value>%s</value>" .Values.s3.endpoint | indent 4}}
{{ printf "</property>"}}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.path.style.access</name>" | indent 4}}
{{ printf "<value>true</value>" | indent 4}}
{{ printf "</property>"}}
{{- if .Values.s3.sessionToken }}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.aws.credentials.provider</name>" | indent 4}}
{{ printf "<value>org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider</value>" | indent 4}}
{{ printf "</property>"}}
{{ printf "<property>"}}
{{ printf "<name>trino.s3.credentials-provider</name>" | indent 4}}
{{ printf "<value>org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider</value>" | indent 4}}
{{ printf "</property>"}}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.session.token</name>" | indent 4}}
{{ printf "<value>%s</value>" .Values.s3.sessionToken | indent 4}}
{{ printf "</property>"}}
{{- else }}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.aws.credentials.provider</name>" | indent 4}}
{{ printf "<value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>" | indent 4}}
{{ printf "</property>"}}
{{ printf "<property>"}}
{{ printf "<name>trino.s3.credentials-provider</name>" | indent 4}}
{{ printf "<value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>" | indent 4}}
{{ printf "</property>"}}
{{- end }}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.access.key</name>" | indent 4}}
{{ printf "<value>%s</value>" .Values.s3.accessKeyId | indent 4}}
{{ printf "</property>"}}
{{ printf "<property>"}}
{{ printf "<name>fs.s3a.secret.key</name>" | indent 4}}
{{ printf "<value>%s</value>" .Values.s3.secretAccessKey | indent 4}}
{{ printf "</property>"}}
{{ printf "</configuration>"}}
{{- end }}

{{/* Create the name of the secret Coresite to use */}}
{{- define "library-chart.secretNameCoreSite" -}}
{{- if .Values.s3.enabled -}}
{{- $name:= (printf "%s-secretcoresite" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.coresite.secretName }}
{{- else }}
{{- default "default" .Values.coresite.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a Secret for CoreSite */}}
{{- define "library-chart.secretCoreSite" -}}
{{- if .Values.s3.enabled -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameCoreSite" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  core-site.xml: |
    {{- include "library-chart.coreSite" . | nindent 17 }}
{{- end }}
{{- end }}


{{/* Secret for Hive Metastore */}}
{{- define "hiveMetastore.secret" -}}
{{- printf "<?xml version=\"1.0\"?>\n" }}
{{- printf "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>\n" }} 
{{- printf "<configuration>\n"}}     
{{- range $index, $secret := (lookup "v1" "Secret" .Release.Namespace "").items }}
{{- if (index $secret "metadata" "annotations") }}
{{- if and (index $secret "metadata" "annotations" "onyxia/discovery") (eq "hive" (index $secret "metadata" "annotations" "onyxia/discovery" | toString)) }}
{{- $service:= ( index $secret.data "hive-service" | default "") | b64dec  }}
{{- printf "<property>\n"}}
{{- printf "<name>hive.metastore.uris</name>\n"  | indent 4}}
{{- printf "<value>thrift://%s:9083</value>\n" $service | indent 4}}
{{- printf "</property>\n"}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- printf "</configuration>"}}
{{- end }}

{{/* Create the name of the secret Hive to use */}}
{{- define "library-chart.secretNameHive" -}}
{{- if .Values.discovery.hive }}
{{- $name:= (printf "%s-secrethive" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.hive.secretName }}
{{- else }}
{{- default "default" .Values.hive.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a Secret for Hive */}}
{{- define "library-chart.secretHive" -}}
{{- if .Values.discovery.hive -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameHive" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  hive-site.xml: |
    {{- include "hiveMetastore.secret" . | nindent 17 }}
{{- end }}
{{- end }}



{{/* Secret for Ivy Settings (custom maven repository for Spark) */}}
{{- define "library-chart.ivySettings" -}}
{{ printf "<ivysettings>" }}
{{ printf "<settings defaultResolver=\"custom_maven_repository\"/>" | indent 4 }}
{{ printf "<resolvers>" | indent 4 }}
{{ printf "<ibiblio name=\"custom_maven_repository\" m2compatible=\"true\" root=\"%s\"/>"  .Values.repository.mavenRepository | indent 8 }}
{{ printf "</resolvers>" | indent 4 }}
{{ printf "</ivysettings>" }}
{{- end -}}

{{/* Create the name of the secret Ivy Settings to use */}}
{{- define "library-chart.secretNameIvySettings" -}}
{{- if and (.Values.spark.default) (.Values.repository.mavenRepository) }}
{{- $name:= (printf "%s-secretivysettings" (include "library-chart.fullname" .) )  }}
{{- $name }}
{{- end }}
{{- end }}

{{/* Template to generate a Secret for Ivy Settings */}}
{{- define "library-chart.secretIvySettings" -}}
{{- if and (.Values.spark.default) (.Values.repository.mavenRepository) }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameIvySettings" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  ivysettings.xml: |
  {{- include "library-chart.ivySettings" . | nindent 19 }}
{{- end }}
{{- end }}


{{/* Create the name of the secret Metaflow to use */}}
{{- define "library-chart.secretNameMetaflow" -}}
{{- $name:= (printf "%s-secretmetaflow" (include "library-chart.fullname" .)) }}
{{- default $name .Values.metaflow.configMapName }}
{{- end }}

{{/* Secret for config.json for Metaflow */}}
{{- define "library-chart.metaflow" -}}
{{- $namespace:= .Release.Namespace -}}
{{- printf "{" }}
{{- printf "\"METAFLOW_DEFAULT_METADATA\": \"service\"," | indent 2 }}
{{- printf "\"METAFLOW_KUBERNETES_SERVICE_ACCOUNT\": \"default\"," | indent 2 }}
{{- printf "\"METAFLOW_S3_ENDPOINT_URL\": \"https://%s\"," (ternary (printf "s3.%s.amazonaws.com" .Values.s3.defaultRegion ) .Values.s3.endpoint (eq .Values.s3.endpoint "s3.amazonaws.com") ) | indent 2 }}
{{- if .Values.discovery.metaflow -}}
{{- range $index, $secret := (lookup "v1" "Secret" .Release.Namespace "").items -}}
{{- if (index $secret "metadata" "annotations") -}}
{{- if and (index $secret "metadata" "annotations" "onyxia/discovery") (eq "metaflow" (index $secret "metadata" "annotations" "onyxia/discovery" | toString)) -}}
{{- $host:= ( index $secret.data "host" | default "") | b64dec  -}}
{{- $s3Bucket := (index $secret.data "s3Bucket" | default "") | b64dec -}}
{{- $s3Secret := (index $secret.data "s3Secret" | default "") | b64dec -}}
{{- printf "\"METAFLOW_KUBERNETES_NAMESPACE\": \"%s\"," $namespace | indent 2 }}
{{- printf "\"METAFLOW_SERVICE_URL\": \"%s\"," $host | indent 2 }}
{{- printf "\"METAFLOW_KUBERNETES_SECRETS\": \"%s\"," $s3Secret | indent 2 }}
{{- printf "\"METAFLOW_DATASTORE_SYSROOT_S3\": \"%s\"," $s3Bucket | indent 2 }}
{{- printf "\"METAFLOW_DATATOOLS_SYSROOT_S3\": \"%s\"," $s3Bucket | indent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- printf "\"METAFLOW_DEFAULT_DATASTORE\": \"s3\"" | indent 2 }}
{{- printf "}" }}
{{- end }}


{{/* Template to generate a Secret for Metaflow */}}
{{- define "library-chart.secretMetaflow" -}}
{{- $context:= . -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMetaflow" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
stringData:
  config.json: |
  {{- include "library-chart.metaflow" . | nindent 15}}
{{- end }}

{{/* Secret for SparkConf Metastore */}}
{{/*
Aggregate variable to set extraJavaOptions
*/}}
{{- define "library-chart.sparkExtraJavaOptions" -}}

{{/*
Flag to disable certificate checking for Spark
*/}}
{{- if .Values.spark -}}
{{- printf " -Dcom.amazonaws.sdk.disableCertChecking=%v" (default false .Values.spark.disabledCertChecking) }}
{{- end -}}

{{/* Build a spark (or java) oriented non proxy hosts list from the linux based noProxy variable */}}
{{- if .Values.proxy -}}
{{- $nonProxyHosts := regexReplaceAllLiteral "\\|\\." (regexReplaceAllLiteral "^(\\.)" (replace "," "|" (default "localhost" .Values.proxy.noProxy))  "*.") "|*." -}}
{{- printf " -Dhttp.nonProxyHosts=%v" $nonProxyHosts }}
{{- printf " -Dhttps.nonProxyHosts=%v" $nonProxyHosts }}
{{- end -}}

{{- end }}

{{- define "library-chart.sparkConf" -}}
{{- $context:= .}}
{{- range $key, $value := default dict .Values.spark.config }}
{{- printf "%s %s\n" $key  (tpl $value  $context)}}
{{- end }}
{{- range $key, $value := default dict .Values.spark.userConfig }}
{{- printf "%s %s\n" $key  (tpl $value  $context)}}
{{- end }}
{{- end }}

{{/* Create the name of the secret Spark Conf to use */}}
{{- define "library-chart.secretNameSparkConf" -}}
{{- if .Values.spark.default -}}
{{- $name:= (printf "%s-secretsparkconf" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.spark.secretName }}
{{- else }}
{{- default "default" .Values.spark.secretName }}
{{- end }}
{{- end }}


{{/* Template to generate a Secret for SparkConf */}}
{{- define "library-chart.secretSparkConf" -}}
{{- if .Values.spark.default -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameSparkConf" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  spark-defaults.conf: |
    {{- include "library-chart.sparkConf" . | nindent 4 }}
    {{- if .Values.repository -}}
    {{- if .Values.repository.mavenRepository -}}
    {{ printf "spark.jars.ivySettings /opt/spark/conf/ivysettings.xml" }}
    {{- end }}
    {{- end }}
{{- end }}
{{- end }}