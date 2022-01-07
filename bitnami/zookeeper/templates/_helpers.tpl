{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Zookeeper image name
*/}}
{{- define "zookeeper.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "zookeeper.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "zookeeper.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Check if there are rolling tags in the images
*/}}
{{- define "zookeeper.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image }}
{{- include "common.warnings.rollingTag" .Values.volumePermissions.image }}
{{- end -}}

{{/*
 Create the name of the service account to use
 */}}
{{- define "zookeeper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return ZooKeeper Client Password
*/}}
{{- define "zookeeper.clientPassword" -}}
{{- if .Values.auth.clientPassword -}}
    {{- .Values.auth.clientPassword -}}
{{- else -}}
    {{- randAlphaNum 10 -}}
{{- end -}}
{{- end -}}

{{/*
Return ZooKeeper Servers Passwords
*/}}
{{- define "zookeeper.serverPasswords" -}}
{{- if .Values.auth.serverPasswords -}}
    {{- .Values.auth.serverPasswords -}}
{{- else -}}
    {{- randAlphaNum 10 -}}
{{- end -}}
{{- end -}}

{{/*
Return ZooKeeper Namespace to use
*/}}
{{- define "zookeeper.namespace" -}}
    {{- if .Values.namespaceOverride }}
        {{- .Values.namespaceOverride -}}
    {{- else }}
        {{- .Release.Namespace -}}
    {{- end }}
{{- end -}}

{{/*
Return the secret containing Zookeeper quorum TLS certificates
*/}}
{{- define "zookeeper.quorum.tlsSecretName" -}}
{{- $secretName := .Values.tls.quorum.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-quorum-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "zookeeper.quorum.createTlsSecret" -}}
{{- if and .Values.tls.quorum.enabled .Values.tls.quorum.autoGenerated (not .Values.tls.quorum.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret containing the Keystore and truststore password
*/}}
{{- define "zookeeper.quorum.tlsPasswordsSecret" -}}
{{- $secretName := .Values.tls.quorum.passwordsSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-quorum-tls-pass" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing Zookeper client TLS certificates
*/}}
{{- define "zookeeper.client.tlsSecretName" -}}
{{- $secretName := .Values.tls.client.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-client-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "zookeeper.client.createTlsSecret" -}}
{{- if and .Values.tls.client.enabled .Values.tls.client.autoGenerated (not .Values.tls.client.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret containing the Keystore and truststore password
*/}}
{{- define "zookeeper.client.tlsPasswordsSecret" -}}
{{- $secretName := .Values.tls.client.passwordsSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-client-tls-pass" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "zookeeper.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "zookeeper.validateValues.client.tls" .) -}}
{{- $messages := append $messages (include "zookeeper.validateValues.quorum.tls" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Zookeeper - Client TLS enabled */}}
{{- define "zookeeper.validateValues.client.tls" -}}
{{- if and .Values.tls.client.enabled (not .Values.tls.client.autoGenerated) (not .Values.tls.client.existingSecret) }}
zookeeper: tls.client.enabled
    In order to enable Client TLS encryption, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}

{{/* Validate values of Zookeeper - Quorum TLS enabled */}}
{{- define "zookeeper.validateValues.quorum.tls" -}}
{{- if and .Values.tls.quorum.enabled (not .Values.tls.quorum.autoGenerated) (not .Values.tls.quorum.existingSecret) }}
zookeeper: tls.quorum.enabled
    In order to enable Quorum TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}
