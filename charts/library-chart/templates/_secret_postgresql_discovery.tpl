{{/* Create the name of the secret PostgreSQL to use */}}
{{- define "library-chart.secretNamePostgreSQL" -}}
{{- if (.Values.discovery).postgresql }}
{{- $name := printf "%s-secretpostgresql" (include "library-chart.fullname" .) }}
{{- default $name (.Values.postgresql).secretName }}
{{- else }}
{{- default "default" (.Values.postgresql).secretName }}
{{- end }}
{{- end }}


{{/* Secret for PostgreSQL */}}
{{- define "library-chart.secretPostgreSQL" }}
{{- $context := . }}
{{- if (.Values.discovery).postgresql }}
{{- with $secretData := first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "postgres") | fromJsonArray) -}}
{{- $pg_service  := index $secretData "postgres-service"  | default "" | b64dec }}
{{- $pg_port     := index $secretData "postgres-port"     | default ""          }}
{{- $pg_database := index $secretData "postgres-database" | default "" | b64dec }}
{{- $pg_username := index $secretData "postgres-username" | default "" | b64dec }}
{{- $pg_password := index $secretData "password"          | default "" | b64dec }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "library-chart.secretNamePostgreSQL" $context }}
  labels:
    {{- include "library-chart.labels" $context | nindent 4 }}
stringData:
  PGHOST: "http://{{ $pg_service }}.{{ $.Release.Namespace }}"
  PGPORT: {{ $pg_port | quote }}
  PGDATABASE: {{ $pg_database | quote }}
  PGUSER: {{ $pg_username | quote }}
  PGPASSWORD: {{ $pg_password | quote }}
{{- end }}
{{- end }}
{{- end }}


{{- define "library-chart.postgresql-discovery-help" -}}
{{- if (.Values.discovery).postgresql }}
{{- if first (include "library-chart.getOnyxiaDiscoverySecrets" (list .Release.Namespace "postgres") | fromJsonArray) }}
The connection to your PostgreSQL service is already preconfigured in your service.
{{- if regexMatch "^r|r$" .Chart.Name }}
```r
library(DBI)
conn <- dbConnect(RPostgres::Postgres())
print(dbGetQuery(conn, "SELECT version();"))
dbDisconnect(conn)
```
{{- else }}
A client can be created in a Python script or interactive console:
```python
import psycopg
conn = psycopg.connect()
with conn.cursor() as cur:
    print(cur.execute("SELECT version();").fetchone())
conn.close()
```
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
