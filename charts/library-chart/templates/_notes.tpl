{{/* vim: set filetype=mustache: */}}

{{/* Template to generate notes about service deletion */}}
{{- define "library-chart.notes-deletion" -}}
  {{- if and (.Values.persistence).enabled (not .Values.persistence.existingClaim) -}}
    {{- if eq .Values.userPreferences.language "fr" -}}
**NOTES concernant la suppression :**
Votre répertoire de travail `/home/{{ .Values.environment.user }}/work`
sera **immédiatement effacé** à la suppression de votre service {{ .Chart.Name }}.
Assurez-vous de sauvegarder toutes vos ressources de travail sur des supports persistants :
- Votre code peux être stocké dans une forge logicielle telle que git.
- Vos données et modèles peuvent être stockés dans un système de stockage objet tel que S3.
Il est possible d'associer un script d'initialisation à votre service pour mettre en place un environnement de travail sur mesure
(télécharger vos ressources, installer les bibliothèques et outils dont vous avez besoin, configurer votre service, etc.)
    {{- else -}}
**NOTES about deletion:**
Your work directory `/home/{{ .Values.environment.user }}/work`
will be **immediately deleted** upon the termination of your {{ .Chart.Name }} service.
Make sure to save all your work resources on persistent storage:
- Your code can be stored in a version control system such as git.
- Your data and models can be stored in an object storage system such as S3.
It is possible to associate an initialization script with your service to set up a customized working environment
(download your resources, install the libraries and tools you need, configure your service, etc.).
    {{- end -}}
  {{- end -}}
{{- end -}}
