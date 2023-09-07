{{/* vim: set filetype=mustache: */}}

{{/* Create the name of the config map S3 to use */}}
{{- define "library-chart.configMapNameS3" -}}
{{- if .Values.s3.enabled }}
{{- $name:= (printf "%s-configmaps3" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.s3.configMapName }}
{{- else }}
{{- default "default" .Values.s3.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for S3 */}}
{{- define "library-chart.configMapS3" -}}
{{- if .Values.s3.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameS3" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  AWS_ACCESS_KEY_ID: "{{ .Values.s3.accessKeyId }}"
  AWS_S3_ENDPOINT: "{{ .Values.s3.endpoint }}"
  S3_ENDPOINT: "https://{{ .Values.s3.endpoint }}/"
  AWS_DEFAULT_REGION: "{{ .Values.s3.defaultRegion }}"
  AWS_SECRET_ACCESS_KEY: "{{ .Values.s3.secretAccessKey }}"
  AWS_SESSION_TOKEN: "{{ .Values.s3.sessionToken }}"
{{- end }}
{{- end }}

{{/* Create the name of the config map Vault to use */}}
{{- define "library-chart.configMapNameVault" -}}
{{- if .Values.vault.enabled }}
{{- $name:= (printf "%s-configmapvault" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.vault.configMapName }}
{{- else }}
{{- default "default" .Values.vault.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for Vault */}}
{{- define "library-chart.configMapVault" -}}
{{- if .Values.vault.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameVault" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  VAULT_ADDR: "{{ .Values.vault.url }}"
  VAULT_TOKEN: "{{ .Values.vault.token }}"
  VAULT_RELATIVE_PATH: "{{ .Values.vault.secret }}"
  VAULT_TOP_DIR: "{{ .Values.vault.directory }}"
  VAULT_MOUNT: "{{ .Values.vault.mount }}"
{{- end }}
{{- end }}

{{/* Create the name of the config map Git to use */}}
{{- define "library-chart.configMapNameGit" -}}
{{- if .Values.git.enabled }}
{{- $name:= (printf "%s-configmapgit" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.git.configMapName }}
{{- else }}
{{- default "default" .Values.git.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for git */}}
{{- define "library-chart.configMapGit" -}}
{{- if .Values.git.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameGit" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  GIT_USER_NAME: "{{ .Values.git.name }}"
  GIT_USER_MAIL: "{{ .Values.git.email }}"
  GIT_CREDENTIALS_CACHE_DURATION: "{{ .Values.git.cache }}"
  GIT_PERSONAL_ACCESS_TOKEN: "{{ .Values.git.token }}"
  GIT_REPOSITORY: "{{ .Values.git.repository }}"
  GIT_BRANCH: "{{ .Values.git.branch }}"
{{- end }}
{{- end }}


{{/* ConfigMap for Hive Metastore */}}
{{- define "hiveMetastore.configmap" -}}
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

{{/* Create the name of the config map Hive to use */}}
{{- define "library-chart.configMapNameHive" -}}
{{- if .Values.discovery.hive }}
{{- $name:= (printf "%s-configmaphive" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.hive.configMapName }}
{{- else }}
{{- default "default" .Values.hive.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for Hive */}}
{{- define "library-chart.configMapHive" -}}
{{- if .Values.discovery.hive -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameHive" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  hive-site.xml: |
    {{- include "hiveMetastore.configmap" . | nindent 4 }}
{{- end }}
{{- end }}

{{/* ConfigMap for CoreSite.xml Metastore */}}
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

{{/* Create the name of the config map Coresite to use */}}
{{- define "library-chart.configMapNameCoreSite" -}}
{{- if .Values.s3.enabled -}}
{{- $name:= (printf "%s-configmapcoresite" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.coresite.configMapName }}
{{- else }}
{{- default "default" .Values.coresite.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for CoreSite */}}
{{- define "library-chart.configMapCoreSite" -}}
{{- if .Values.s3.enabled -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameCoreSite" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  core-site.xml: |
    {{- include "library-chart.coreSite" . | nindent 4 }}
{{- end }}
{{- end }}

{{/* Create the name of the config map MLFlow to use */}}
{{- define "library-chart.configMapNameMLFlow" -}}
{{- $name:= (printf "%s-configmapmlflow" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.mlflow.configMapName }}
{{- end }}

{{/* ConfigMap for MLFlow */}}
{{- define "library-chart.configMapMLFlow" -}}
{{- $context:= . -}}
{{- if .Values.discovery.mlflow -}}
{{- range $index, $secret := (lookup "v1" "Secret" .Release.Namespace "").items -}}
{{- if (index $secret "metadata" "annotations") -}}
{{- if and (index $secret "metadata" "annotations" "onyxia/discovery") (eq "mlflow" (index $secret "metadata" "annotations" "onyxia/discovery" | toString)) -}}
{{- $uri:= ( index $secret.data "uri" | default "") | b64dec  -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameMLFlow" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
data:
  MLFLOW_TRACKING_URI: {{ printf "%s" $uri }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* ConfigMap for SparkConf Metastore */}}
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

{{/* Create the name of the config map Spark Conf to use */}}
{{- define "library-chart.configMapNameSparkConf" -}}
{{- if .Values.spark.default -}}
{{- $name:= (printf "%s-configmapsparkconf" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.spark.configMapName }}
{{- else }}
{{- default "default" .Values.spark.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for CoreSite */}}
{{- define "library-chart.configMapSparkConf" -}}
{{- if .Values.spark.default -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameSparkConf" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  spark-defaults.conf: |
    {{- include "library-chart.sparkConf" . | nindent 4 }}
    {{- if .Values.repository.mavenRepository -}}
    {{ printf "spark.jars.ivySettings /opt/spark/conf/ivysettings.xml" }}
    {{- end }}
{{- end }}
{{- end }}



{{/* ConfigMap for Ivy Settings (custom maven repository for Spark) */}}
{{- define "library-chart.ivySettings" -}}
{{ printf "<ivysettings>" }}
{{ printf "<settings defaultResolver=\"custom_maven_repository\"/>" | indent 4 }}
{{ printf "<resolvers>" | indent 4 }}
{{ printf "<ibiblio name=\"custom_maven_repository\" m2compatible=\"true\" root=\"%s\"/>"  .Values.repository.mavenRepository | indent 8 }}
{{ printf "</resolvers>" | indent 4 }}
{{ printf "</ivysettings>" }}
{{- end -}}

{{/* Create the name of the config map Ivy Settings to use */}}
{{- define "library-chart.configMapNameIvySettings" -}}
{{- if and (.Values.spark.default) (.Values.repository.mavenRepository) }}
{{- $name:= (printf "%s-configmapivysettings" (include "library-chart.fullname" .) )  }}
{{- $name }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for Ivy Settings */}}
{{- define "library-chart.configMapIvySettings" -}}
{{- if and (.Values.spark.default) (.Values.repository.mavenRepository) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameIvySettings" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  ivysettings.xml: |
    {{- include "library-chart.ivySettings" . | nindent 4 }}
{{- end }}
{{- end }}


{{/* Create the name of the config map repository to use */}}
{{- define "library-chart.repository.enabled" -}}
{{- default "" (or (or (or .Values.repository.pipRepository .Values.repository.condaRepository) .Values.repository.rRepository) .Values.repository.packageManagerUrl) }}
{{- end }}

{{- define "library-chart.configMapNameRepository" -}}
{{- if (include "library-chart.repository.enabled"  .) }}
{{- $name:= (printf "%s-configmaprepository" (include "library-chart.fullname" .) )  }}
{{- default $name .Values.repository.configMapName }}
{{- else }}
{{- default "default" .Values.repository.configMapName }}
{{- end }}
{{- end }}

{{/* Template to generate a ConfigMap for repositories */}}
{{- define "library-chart.configMapRepository" -}}
{{- if (include "library-chart.repository.enabled"  .) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameRepository" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
data:
  {{- if .Values.repository.pipRepository }}
  PIP_REPOSITORY: "{{ .Values.repository.pipRepository }}"
  {{- end }}
  {{- if .Values.repository.condaRepository }}
  CONDA_REPOSITORY: "{{ .Values.repository.condaRepository }}"
  {{- end }}
  {{- if .Values.repository.rRepository }}
  R_REPOSITORY: "{{ .Values.repository.rRepository }}"
  {{- end }}
  {{- if .Values.repository.packageManagerUrl }}
  PACKAGE_MANAGER_URL: "{{ .Values.repository.packageManagerUrl }}"
  {{- end }}
{{- end }}
{{- end }}

{{/* Create the name of the config map Metaflow to use */}}
{{- define "library-chart.configMapNameMetaflow" -}}
{{- $name:= (printf "%s-configmapmetaflow" (include "library-chart.fullname" .)) }}
{{- default $name .Values.metaflow.configMapName }}
{{- end }}

{{/* ConfigMap for config.json for Metaflow */}}
{{- define "library-chart.metaflow" -}}
{{- $namespace:= .Release.Namespace -}}
{{- printf "{" }}
{{- printf "\"METAFLOW_DEFAULT_METADATA\": \"service\"," | indent 2 }}
{{- printf "\"METAFLOW_KUBERNETES_SERVICE_ACCOUNT\": \"default\"," | indent 2 }}
{{- printf "\"METAFLOW_S3_ENDPOINT_URL\": \"https://minio.lab.sspcloud.fr\"," | indent 2 }}
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


{{/* Template to generate a ConfigMap for Metaflow */}}
{{- define "library-chart.configMapMetaflow" -}}
{{- $context:= . -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "library-chart.configMapNameMetaflow" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
data:
  config.json: |
  {{- include "library-chart.metaflow" . | nindent 4}}
{{- end }}
