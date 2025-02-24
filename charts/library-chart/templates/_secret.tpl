{{/* vim: set filetype=mustache: */}}

{{/* Create the name of the secret S3 to use */}}
{{- define "library-chart.secretNameS3" -}}
{{- if .Values.s3.enabled }}
{{- $name := printf "%s-secrets3" (include "library-chart.fullname" .) }}
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
  AWS_ACCESS_KEY_ID: {{ .Values.s3.accessKeyId | quote }}
  AWS_S3_ENDPOINT: {{ .Values.s3.endpoint | quote }}
  S3_ENDPOINT: {{ printf "https://%s/" .Values.s3.endpoint | quote }}
  AWS_DEFAULT_REGION: {{ .Values.s3.defaultRegion | quote }}
  AWS_SECRET_ACCESS_KEY: {{ .Values.s3.secretAccessKey | quote }}
  AWS_SESSION_TOKEN: {{ .Values.s3.sessionToken | quote }}
{{- end }}
{{- end }}

{{/* Create the name of the secret Proxy to use */}}
{{- define "library-chart.secretNameProxy" -}}
{{ if (.Values.proxy).enabled }}
{{- printf "%s-secretproxy" (include "library-chart.fullname" .) }}
{{- end }}
{{- end }}

{{/* Template to generate a secret for proxy */}}
{{- define "library-chart.secretProxy" -}}
{{ if (.Values.proxy).enabled }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameProxy" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  {{- if .Values.proxy.httpProxy }}
    http_proxy: {{ .Values.proxy.httpProxy | quote }}
    HTTP_PROXY: {{ .Values.proxy.httpProxy }}
  {{- end }}
  {{- if .Values.proxy.httpsProxy }}
    https_proxy: {{ .Values.proxy.httpsProxy | quote }}
    HTTPS_PROXY: {{ .Values.proxy.httpsProxy | quote }}
  {{- end }}
  {{- if .Values.proxy.noProxy }}
    no_proxy: {{ .Values.proxy.noProxy | quote }}
    NO_PROXY: {{ .Values.proxy.noProxy | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/* Create the name of the secret Vault to use */}}
{{- define "library-chart.secretNameVault" -}}
{{- if .Values.vault.enabled }}
{{- $name := printf "%s-secretvault" (include "library-chart.fullname" .) }}
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
  VAULT_ADDR: {{ .Values.vault.url | quote }}
  VAULT_TOKEN: {{ .Values.vault.token | quote }}
  VAULT_RELATIVE_PATH: {{ .Values.vault.secret | quote }}
  VAULT_TOP_DIR: {{ .Values.vault.directory | quote }}
  VAULT_MOUNT: {{ .Values.vault.mount | quote }}
{{- end }}
{{- end }}

{{/* Create the name of the secret Git to use */}}
{{- define "library-chart.secretNameGit" -}}
{{- if .Values.git.enabled }}
{{- $name := printf "%s-secretgit" (include "library-chart.fullname" .) }}
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
  GIT_USER_NAME: {{ .Values.git.name | quote }}
  GIT_USER_MAIL: {{ .Values.git.email | quote }}
  GIT_CREDENTIALS_CACHE_DURATION: {{ .Values.git.cache | quote }}
  GIT_PERSONAL_ACCESS_TOKEN: {{ .Values.git.token | quote }}
  GIT_REPOSITORY: {{ .Values.git.repository | quote }}
  GIT_BRANCH: {{ .Values.git.branch | quote }}
{{- end }}
{{- end }}

{{/* Create the name of the secret Token to use */}}
{{- define "library-chart.secretNameToken" -}}
{{- printf "%s-secrettoken" (include "library-chart.fullname" .) }}
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
  PASSWORD: {{ .Values.security.password | quote }}
{{- end }}

{{/*
  Checks if a secret has the "onyxia/discovery" annotation matching a given service name.

  Params:
    - First: The secret object to check
    - Second: Service name to match against (e.g. "postgresql")

  Example:
    {{- include "library-chart.isOnyxiaDiscoverySecret" (list $secret "postgresql") -}}
*/}}
{{- define "library-chart.isOnyxiaDiscoverySecret" -}}
{{- $secret := first . }}
{{- $service := last . -}}
{{- if eq $service (index (($secret.metadata).annotations | default dict) "onyxia/discovery" | default "" | toString) }}
{{- "ok" }}
{{- end -}}
{{- end -}}

{{/*
  List data from all discovery secrets of a given service name in a given namespace.

  Example:
    {{- range $secretData := include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "postgresql") | fromJsonArray -}}
      or, to only retrieve the first secret:
    {{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "postgresql") | fromJsonArray) -}}
*/}}
{{- define "library-chart.getOnyxiaDiscoverySecrets" -}}
{{- $namespace := first . }}
{{- $service := last . }}
{{- $discoverySecrets := list }}
{{- range $secret := (lookup "v1" "Secret" $namespace "").items -}}
{{- if (include "library-chart.isOnyxiaDiscoverySecret" (list $secret $service)) -}}
{{- $discoverySecrets = append $discoverySecrets $secret.data -}}
{{- end -}}
{{- end -}}
{{- toJson $discoverySecrets -}}
{{- end -}}

{{/* Create the name of the secret MLFlow to use */}}
{{- define "library-chart.secretNameMLFlow" -}}
{{- $name := printf "%s-secretmlflow" (include "library-chart.fullname" .) }}
{{- default $name .Values.mlflow.secretName }}
{{- end }}

{{/* Secret for MLFlow */}}
{{- define "library-chart.secretMLFlow" }}
{{- $context := . }}
{{- if .Values.discovery.mlflow }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "mlflow") | fromJsonArray) -}}
{{- $uri                      := $secretData.uri                      | default "" | b64dec }}
{{- $mlflow_tracking_username := $secretData.MLFLOW_TRACKING_USERNAME | default "" | b64dec }}
{{- $mlflow_tracking_password := $secretData.MLFLOW_TRACKING_PASSWORD | default "" | b64dec }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMLFlow" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
stringData:
{{- if $uri }}
  MLFLOW_TRACKING_URI: {{ $uri | quote }}
{{- end }}
{{- if and $mlflow_tracking_username $mlflow_tracking_password }}
  MLFLOW_TRACKING_USERNAME: {{ $mlflow_tracking_username | quote }}
  MLFLOW_TRACKING_PASSWORD: {{ $mlflow_tracking_password | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* Create the name of the secret Coresite to use */}}
{{- define "library-chart.secretNameCoreSite" -}}
{{- if .Values.s3.enabled -}}
{{- $name := printf "%s-secretcoresite" (include "library-chart.fullname" .) }}
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
    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
    <property>
        <name>fs.s3a.connection.ssl.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>fs.s3a.endpoint</name>
        <value>{{ .Values.s3.endpoint }}</value>
    </property>
    <property>
        <name>fs.s3a.path.style.access</name>
        <value>true</value>
    </property>
{{- if .Values.s3.sessionToken }}
    <property>
        <name>fs.s3a.aws.credentials.provider</name>
        <value>org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider</value>
    </property>
    <property>
        <name>trino.s3.credentials-provider</name>
        <value>org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider</value>
    </property>
    <property>
        <name>fs.s3a.session.token</name>
        <value>{{ .Values.s3.sessionToken }}</value>
    </property>
{{- else }}
    <property>
        <name>fs.s3a.aws.credentials.provider</name>
        <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>
    </property>
    <property>
        <name>trino.s3.credentials-provider</name>
        <value>org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider</value>
    </property>
{{- end }}
    <property>
        <name>fs.s3a.access.key</name>
        <value>{{ .Values.s3.accessKeyId }}</value>
    </property>
    <property>
        <name>fs.s3a.secret.key</name>
        <value>{{ .Values.s3.secretAccessKey }}</value>
    </property>
    </configuration>
{{- end }}
{{- end }}

{{/* Create the name of the secret Hive to use */}}
{{- define "library-chart.secretNameHive" -}}
{{- if .Values.discovery.hive }}
{{- $name := printf "%s-secrethive" (include "library-chart.fullname" .) }}
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
    <?xml version="1.0"?>
    <?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
    <configuration>
    {{- range $secretData := include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "hive") | fromJsonArray }}
      <property>
        <name>hive.metastore.uris</name>
        <value>thrift://{{ index $secretData "hive-service" | default "" | b64dec }}:9083</value>
      </property>
    {{- end }}
    </configuration>
{{- end }}
{{- end }}

{{/* Create the name of the secret Ivy Settings to use */}}
{{- define "library-chart.secretNameIvySettings" -}}
{{- if and (.Values.spark.default) (.Values.repository.mavenRepository) }}
{{- printf "%s-secretivysettings" (include "library-chart.fullname" .) }}
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
    <ivysettings>
        <settings defaultResolver="custom_maven_repository"/>
        <resolvers>
            <ibiblio name="custom_maven_repository" m2compatible="true" root={{ .Values.repository.mavenRepository | quote }}/>
        </resolvers>
    </ivysettings>
{{- end }}
{{- end }}

{{/* Create the name of the secret Metaflow to use */}}
{{- define "library-chart.secretNameMetaflow" -}}
{{- $name := printf "%s-secretmetaflow" (include "library-chart.fullname" .) }}
{{- default $name .Values.metaflow.configMapName }}
{{- end }}

{{/* Template to generate a Secret for Metaflow */}}
{{- define "library-chart.secretMetaflow" -}}
{{- $namespace := .Release.Namespace -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameMetaflow" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
stringData:
  config.json: |
    {
      "METAFLOW_DEFAULT_METADATA": "service",
      "METAFLOW_KUBERNETES_SERVICE_ACCOUNT": "default",
      "METAFLOW_S3_ENDPOINT_URL": "https://{{ eq .Values.s3.endpoint "s3.amazonaws.com" | ternary (printf "s3.%s.amazonaws.com" .Values.s3.defaultRegion) .Values.s3.endpoint }}",
{{- if .Values.discovery.metaflow }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list $namespace "metaflow") | fromJsonArray) }}
{{- $host     := $secretData.host     | default "" | b64dec }}
{{- $s3Bucket := $secretData.s3Bucket | default "" | b64dec }}
{{- $s3Secret := $secretData.s3Secret | default "" | b64dec }}
      "METAFLOW_KUBERNETES_NAMESPACE": {{ $namespace | quote }},
      "METAFLOW_SERVICE_URL": {{ $host | quote }},
      "METAFLOW_KUBERNETES_SECRETS": {{ $s3Secret | quote }},
      "METAFLOW_DATASTORE_SYSROOT_S3": {{ $s3Bucket | quote }},
      "METAFLOW_DATATOOLS_SYSROOT_S3": {{ $s3Bucket | quote }},
{{- end }}
{{- end }}
      "METAFLOW_DEFAULT_DATASTORE": "s3"
    }
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
{{- if (.Values.proxy).enabled -}}
{{- $nonProxyHosts := regexReplaceAllLiteral "\\|\\." (regexReplaceAllLiteral "^(\\.)" (replace "," "|" (default "localhost" .Values.proxy.noProxy))  "*.") "|*." -}}
{{- printf " -Dhttp.nonProxyHosts=%v" $nonProxyHosts }}
{{- printf " -Dhttps.nonProxyHosts=%v" $nonProxyHosts }}
{{- end -}}

{{- end }}

{{- define "library-chart.sparkConf" -}}
{{- $context := . }}
{{- range $key, $value := (.Values.spark).config | default dict }}
{{- printf "%s %s\n" $key (tpl $value $context) }}
{{- end }}
{{- range $key, $value := (.Values.spark).userConfig | default dict }}
{{- printf "%s %s\n" $key (tpl $value $context) }}
{{- end }}
{{- end }}

{{/* Create the name of the secret Spark Conf to use */}}
{{- define "library-chart.secretNameSparkConf" -}}
{{- if .Values.spark.default -}}
{{- $name := printf "%s-secretsparkconf" (include "library-chart.fullname" .) }}
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
    {{- if .Values.repository }}
    {{- if .Values.repository.mavenRepository }}
    spark.jars.ivySettings /opt/spark/conf/ivysettings.xml
    {{- end }}
    {{- end }}
{{- end }}
{{- end }}


{{/* Name of the CA certificates secret */}}
{{- define "library-chart.secretNameCacerts" -}}
{{- if .Values.certificates }}
{{- $name := printf "%s-secretcacerts" (include "library-chart.fullname" .) }}
{{- default $name .Values.certificates.secretName }}
{{- else }}
{{- default "default" .Values.certificates.secretName }}
{{- end }}
{{- end }}

{{/* Template to generate a secret for CA certificates */}}
{{- define "library-chart.secretCacerts" -}}
{{- if and .Values.certificates .Values.certificates.cacerts }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameCacerts" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- if regexMatch "^https?://" .Values.certificates.cacerts }}
  ca-certs.url: {{ .Values.certificates.cacerts }}
  {{- else }}
  ca.pem: |
    {{- .Values.certificates.cacerts | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}



{{/* Name of the extraEnv secret */}}
{{- define "library-chart.secretNameExtraEnv" -}}
{{- printf "%s-secretextraenv" (include "library-chart.fullname" .) }}
{{- end }}

{{/* Template to generate a secret for extra environment variables */}}
{{- define "library-chart.secretExtraEnv" -}}
{{- if .Values.extraEnvVars }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNameExtraEnv" . }}
  labels:
    {{- include "library-chart.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- range .Values.extraEnvVars }}
  {{ .name | trim }}: {{ tpl .value $.Values | quote }}
  {{- end }}
{{- end }}
{{- end }}
