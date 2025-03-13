{{/*
  Generate a general message as a NOTES header.
*/}}
{{- define "library-chart.general-message" -}}
{{- if and (eq .Values.userPreferences.language "fr" (.Values.message).fr) -}}
{{- (.Values.message).fr }}
{{ else -}}
{{- (.Values.message).en }}
{{ end -}}
{{- end -}}


{{- define "library-chart.notes-access-title" -}}
{{- if eq .Values.userPreferences.language "fr" }}
### Accès au service
{{ else }}
### Service access
{{ end -}}
{{- end -}}


{{/*
  Generate NOTES about connection to the service.

  Usage:
    {{ include "library-chart.notes-connection" (dict "serviceName" "Visual Studio Code" "context" $) }}

  Params:
    - serviceName - String - Optional. The human readable name of the service.
    - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "library-chart.notes-connection" -}}
{{- $serviceName := .serviceName | default .context.Chart.Name -}}
{{- with .context -}}
{{- if eq .Values.userPreferences.language "fr" -}}
{{- if or (.Values.ingress).enabled (.Values.route).enabled }}
- Vous pouvez vous connecter à {{ $serviceName }} depuis votre navigateur en utilisant [ce lien]({{ include "library-chart.service-url" . }}).
{{ else }}
- Votre service {{ $serviceName }} n'est pas directement exposé sur internet.
Vous pouvez tout de même y accéder en executant la commande suivante depuis un terminal :
`kubectl port-forward service/{{ include "library-chart.fullname" . }} <port-local>:{{ .Values.networking.service.port }}`
puis en vous connectant depuis votre navigateur à l'URL suivante : `http://localhost:<port-local>`
{{ end -}}
{{- with (.Values.environment).user -}}
- Votre nom d'utilisateur: {{ . }}
{{ end -}}
- Votre password: {{ .Values.security.password }}
{{ else -}}
{{- if or (.Values.ingress).enabled (.Values.route).enabled }}
- You can connect to {{ $serviceName }} with your browser using [this link]({{ include "library-chart.service-url" . }}).
{{ else }}
- Your service {{ $serviceName }} is not exposed on the internet.
You can still access it by running the following command from a terminal:
`kubectl port-forward service/{{ include "library-chart.fullname" . }} <local-port>:{{ .Values.networking.service.port }}`
and then use the following URL with your browser: `http://localhost:<local-port>`
{{ end -}}
{{- with (.Values.environment).user -}}
- Your user name: {{ . }}
{{ end -}}
- Your password: {{ .Values.security.password }}
{{ end -}}
{{- end -}}
{{- end -}}


{{/*
  Generate NOTES about connection to the Spark UI (if enabled).
*/}}
{{- define "library-chart.notes-sparkui" -}}
{{- if (.Values.spark).sparkui -}}
{{- if eq .Values.userPreferences.language "fr" -}}
{{- if or (.Values.ingress).enabled (.Values.route).enabled -}}
- Lorsque le driver Spark est en cours d'exécution, vous pouvez vous connecter à l'interface Spark depuis votre navigateur en utilisant [ce lien]({{ include "library-chart.sparkui-url" . }}).
{{ else }}
- Votre interface Spark n'est pas directement exposée sur internet.
Vous pouvez tout de même y accéder en executant la commande suivante depuis un terminal :
`kubectl port-forward service/{{ include "library-chart.fullname" . }} <port-local>:{{ .Values.networking.sparkui.port }}`
puis en vous connectant depuis votre navigateur à l'URL suivante : `http://localhost:<port-local>`
{{ end -}}
- Votre nom d'utilisateur : **`{{ .Values.environment.user }}`**
- Votre mot de passe : **`{{ .Values.security.password }}`**
{{ else -}}
{{- if or (.Values.ingress).enabled (.Values.route).enabled -}}
- When the Spark driver is running, you can connect to the Spark UI with your browser using [this link]({{ include "library-chart.sparkui-url" . }}).
{{ else }}
- Your Spark interface is not exposed on the internet.
You can still access it by running the following command from a terminal:
`kubectl port-forward service/{{ include "library-chart.fullname" . }} <local-port>:{{ .Values.networking.sparkui.port }}`
and then use the following URL with your browser: `http://localhost:<local-port>`
{{ end -}}
- Your login: **`{{ .Values.environment.user }}`**
- Your password: **`{{ .Values.security.password }}`**
{{ end -}}
{{- end -}}
{{- end -}}


{{/*
  Generate NOTES about custom user-defined port exposition.
*/}}
{{- define "library-chart.notes-custom-ports" -}}
{{- if and
      ((.Values.networking).user).enabled
      (or .Values.networking.user.ports .Values.networking.user.port)
      (or (.Values.ingress).enabled (.Values.route).enabled)
-}}
{{- $userPorts := .Values.networking.user.ports | default (list .Values.networking.user.port) -}}
{{- $URL := include "library-chart.user-url" . -}}
{{- if eq .Values.userPreferences.language "fr" -}}
{{- if eq (len $userPorts) 1 }}
Vous pouvez vous connecter à votre port personnalisé ({{ first $userPorts }}) en utilisant [ce lien]({{ $URL }}).
{{- else }}
Vous pouvez vous connecter à vos ports personnalisés en utilisant les liens suivant :
{{- range $i, $userPort := $userPorts -}}
{{- gt $i 0 | ternary "," "" }} [port {{ $userPort }}]({{ regexReplaceAll "([^\\.]+)\\.(.*)" $URL (printf "${1}-%d.${2}" (int $userPort)) }})
{{- end -}}.
{{- end }}
Si vous accédez à ces URL sans démarrer vos services personnalisés, vous obtiendrez une erreur 502 Bad Gateway.
{{ else -}}
{{- if eq (len $userPorts) 1 }}
You can connect to your custom port ({{ first $userPorts }}) using [this link]({{ $URL }}).
{{- else }}
You can connect to your custom ports using the following links:
{{- range $i, $userPort := $userPorts -}}
{{- gt $i 0 | ternary "," "" }} [Port {{ $userPort }}]({{ regexReplaceAll "([^\\.]+)\\.(.*)" $URL (printf "${1}-%d.${2}" (int $userPort)) }})
{{- end -}}.
{{- end }}
If you access these URL without starting the corresponding services you will get a 502 bad gateway error.
{{ end -}}
{{- end -}}
{{- end -}}


{{/*
  Generate NOTES about service deletion.

  Usage:
    {{ include "library-chart.notes-deletion" (dict "serviceName" "Visual Studio Code" "context" $) }}

  Params:
    - serviceName - String - Optional. The human readable name of the service.
    - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "library-chart.notes-deletion" -}}
{{- $serviceName := .serviceName | default .context.Chart.Name -}}
{{- with .context -}}
{{- if not (and (.Values.persistence).enabled .Values.persistence.existingClaim) -}}
{{- if eq .Values.userPreferences.language "fr" }}
### Sauvegarde

Votre répertoire de travail `/home/{{ .Values.environment.user }}/work`
sera **immédiatement effacé** à la suppression de votre service {{ $serviceName }}.
Assurez-vous de sauvegarder toutes vos ressources de travail sur des supports persistants :
- Votre code peut être archivé dans une forge logicielle telle que Github ou Gitlab.
- Vos données et modèles peuvent être stockés dans un système de stockage objet tel que S3.

Il est possible d'associer un script d'initialisation à votre service pour mettre en place un environnement de travail sur mesure
(télécharger vos ressources, installer les bibliothèques et outils dont vous avez besoin, configurer votre service, etc.)
{{ else }}
### Save

Your work directory `/home/{{ .Values.environment.user }}/work`
will be **immediately deleted** upon the termination of your {{ $serviceName }} service.
Make sure to save all your work resources on persistent storage:
- Your code can be versioned with Git and pushed to Github or Gitlab servers for persistence.
- Your data and models can be stored in an object storage system such as S3.

It is possible to associate an initialization script with your service to set up a customized working environment
(download your resources, install the libraries and tools you need, configure your service, etc.).
{{ end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  Generate NOTES about service deletion.

  Usage:
    {{ include "library-chart.notes-deletion" (dict "serviceName" "Visual Studio Code" "context" $) }}

  Params:
    - serviceName - String - Optional. The human readable name of the service.
    - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "library-chart.notes-discovery" -}}
{{- if eq .Values.userPreferences.language "fr" }}
### Connexion à des services tiers
{{ else }}
### Connection to third-party services
{{ end -}}

{{- with (include "library-chart.mlflow-discovery-help" .) }}
<details>
  <summary>Mlflow</summary>
{{ . }}
</details>
{{ end -}}

{{- with (include "library-chart.metaflow-discovery-help" .) }}
<details>
  <summary>Metaflow</summary>
{{ . }}
</details>
{{ end -}}

{{- with (include "library-chart.hive-discovery-help" .) }}
<details>
  <summary>Hive Metastore</summary>
{{ . }}
</details>
{{ end -}}
{{ end -}}


{{/*
  Prints out all NOTES.

  Usage:
    {{- template "library-chart.notes" (dict "serviceName" "Visual Studio Code" "context" $) -}}

  Params:
    - serviceName - String - Optional. The human readable name of the service.
    - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "library-chart.notes" -}}
{{- template "library-chart.general-message" .context -}}

{{- template "library-chart.notes-access-title" .context -}}
{{- template "library-chart.notes-connection" . -}}
{{- template "library-chart.notes-sparkui" .context -}}
{{- template "library-chart.notes-custom-ports" .context -}}

{{- template "library-chart.notes-deletion" . -}}

{{- template "library-chart.notes-discovery" .context -}}
{{- end -}}
