{{/* Create the name of the secret Hive to use */}}
{{- define "library-chart.secretNameHive" -}}
{{- if (.Values.discovery).hive }}
{{- $name := printf "%s-secrethive" (include "library-chart.fullname" .) }}
{{- default $name (.Values.hive).secretName }}
{{- else }}
{{- default "default" (.Values.hive).secretName }}
{{- end }}
{{- end -}}

{{/* Template to generate a Secret for Hive */}}
{{- define "library-chart.secretHive" -}}
{{- if (.Values.discovery).hive -}}
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
    {{- range include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "hive") | fromJsonArray }}
      <property>
        <name>hive.metastore.uris</name>
        <value>thrift://{{ index . "hive-service" | default "" | b64dec }}:9083</value>
      </property>
    {{- end }}
    </configuration>
{{- end }}
{{- end -}}


{{- define "library-chart.hive-discovery-help" }}
{{- if (.Values.discovery).hive }}
{{- with first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "hive") | fromJsonArray) }}
{{- if hasKey (($.Values).service | default dict) "customPythonEnv" -}}
{{- if hasKey $.Values "spark" }}
The connection to your Hive Metastore is already preconfigured in your service.
A Spark session can be configured to use Hive:
```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.enableHiveSupport().getOrCreate()
```
{{- else }}
You may install the `hive-metastore-client`
and configure the connection to the Hive Metastore using environment variables.
```sh
pip install hive-metastore-client
export HIVE_URI={{ index . "hive-service" | default "" | b64dec }}
export HIVE_PORT=9083
```
and then use it
```python
import os
from hive_metastore_client.builders import DatabaseBuilder
from hive_metastore_client import HiveMetastoreClient

database = DatabaseBuilder(name='new_db').build()
with HiveMetastoreClient(os.getenv('HIVE_URI'), os.getenv('HIVE_PORT')) as hive_metastore_client:
    hive_metastore_client.create_database(database)
```
{{- end }}
{{- else }}
There is no well-supported Hive Metastore client for R yet.
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
