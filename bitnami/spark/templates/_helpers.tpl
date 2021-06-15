{{- /* vim: set filetype=mustache: */}}

{{/*
Return the proper Spark image name
*/}}
{{- define "spark.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Spark TLS image name
*/}}
{{- define "spark.certs.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.security.ssl.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "spark.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image) "global" .Values.global) -}}
{{- end -}}

{{- /*
As we use a headless service we need to append -master-svc to
the service name.
*/ -}}
{{- define "spark.master.service.name" -}}
{{ include "common.names.fullname" . }}-master-svc
{{- end -}}

{{/* Get the secret for passwords */}}
{{- define "spark.passwordsSecretName" -}}
{{- if .Values.security.passwordsSecretName -}}
  {{- printf "%s" .Values.security.passwordsSecretName -}}
{{- else }}
  {{- printf "%s-secret" (include "common.names.fullname" .) -}}
{{- end }}
{{- end -}}

{{/*
Return the secret containing Spark TLS certificates
*/}}
{{- define "spark.tlsSecretName" -}}
{{- $secretName := coalesce .Values.security.ssl.existingSecret .Values.security.certificatesSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "spark.createTlsSecret" -}}
{{- if and .Values.security.ssl.autoGenerated .Values.security.ssl.enabled (not .Values.security.ssl.existingSecret) (not .Values.security.certificatesSecretName) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/* Check if there are rolling tags in the images */}}
{{- define "spark.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image -}}
{{- end -}}

{{/* Validate values of Spark - Incorrect extra volume settings */}}
{{- define "spark.validateValues.extraVolumes" -}}
{{- if and (.Values.worker.extraVolumes) (not .Values.worker.extraVolumeMounts) -}}
spark: missing-worker-extra-volume-mounts
    You specified worker extra volumes but no mount points for them. Please set
    the extraVolumeMounts value
{{- end -}}
{{- end -}}

{/* Validate values of Spark - number of workers must be greater than 0 */}}
{{- define "spark.validateValues.workerCount" -}}
{{- $replicaCount := int .Values.worker.replicaCount }}
{{- if lt $replicaCount 1 -}}
spark: workerCount
    Worker replicas must be greater than 0!!
    Please set a valid worker count size (--set worker.replicaCount=X)
{{- end -}}
{{- end -}}

{{/* Validate values of Spark - Security SSL enabled */}}
{{- define "spark.validateValues.security.ssl" -}}
{{- if and .Values.security.ssl.enabled (not .Values.security.ssl.autoGenerated) (not .Values.security.ssl.existingSecret) (not .Values.security.certificatesSecretName) }}
spark: security.ssl.enabled
    In order to enable Security SSL, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "spark.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "spark.validateValues.extraVolumes" .) -}}
{{- $messages := append $messages (include "spark.validateValues.workerCount" .) -}}
{{- $messages := append $messages (include "spark.validateValues.security.tls" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}
