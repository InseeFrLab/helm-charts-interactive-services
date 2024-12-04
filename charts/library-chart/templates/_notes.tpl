{{/* vim: set filetype=mustache: */}}

{{/* Template to generate a general message as a note header */}}
{{- define "library-chart.general-message" -}}
{{- if and (eq .Values.userPreferences.language "fr" (.Values.message).fr) -}}
{{- (.Values.message).fr }}
{{ else -}}
{{- (.Values.message).en }}
{{ end -}}
{{- end -}}


{{/* Template to generate notes about custom user-defined port exposition */}}
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
Vous pouvez vous connecter à vos ports personnalisés en utilisant les liens ci-dessous :
{{ range $userPort := $userPorts -}}
- [Port {{ $userPort }}]({{ regexReplaceAll "([^\\.]+)\\.(.*)" $URL (printf "${1}-%d.${2}" (int $userPort)) }})
{{ end -}}
{{- end -}}
Si vous accédez ces URL sans démarrer vos services personnalisés, vous obtiendrez une erreur 502 Bad Gateway.
{{ else -}}
{{- if eq (len $userPorts) 1 }}
You can connect to your custom port ({{ first $userPorts }}) using [this link]({{ $URL }}).
{{- else }}
You can connect to your custom ports using the following links:
{{ range $userPort := $userPorts -}}
- [Port {{ $userPort }}]({{ regexReplaceAll "([^\\.]+)\\.(.*)" $URL (printf "${1}-%d.${2}" (int $userPort)) }})
{{ end -}}
{{- end -}}
If you access these URL without starting the corresponding services you will get a 502 bad gateway error.
{{ end -}}
{{- end -}}
{{- end -}}


{{/* Template to generate notes about service deletion */}}
{{- define "library-chart.notes-deletion" -}}
{{- if and (.Values.persistence).enabled (not .Values.persistence.existingClaim) -}}
{{- if eq .Values.userPreferences.language "fr" }}
**NOTES concernant la suppression :**
Votre répertoire de travail `/home/{{ .Values.environment.user }}/work`
sera **immédiatement effacé** à la suppression de votre service {{ .Chart.Name }}.
Assurez-vous de sauvegarder toutes vos ressources de travail sur des supports persistants :
- Votre code peux être stocké dans une forge logicielle telle que git.
- Vos données et modèles peuvent être stockés dans un système de stockage objet tel que S3.
Il est possible d'associer un script d'initialisation à votre service pour mettre en place un environnement de travail sur mesure
(télécharger vos ressources, installer les bibliothèques et outils dont vous avez besoin, configurer votre service, etc.)
{{ else }}
**NOTES about deletion:**
Your work directory `/home/{{ .Values.environment.user }}/work`
will be **immediately deleted** upon the termination of your {{ .Chart.Name }} service.
Make sure to save all your work resources on persistent storage:
- Your code can be stored in a version control system such as git.
- Your data and models can be stored in an object storage system such as S3.
It is possible to associate an initialization script with your service to set up a customized working environment
(download your resources, install the libraries and tools you need, configure your service, etc.).
{{ end -}}
{{- end -}}
{{- end -}}
