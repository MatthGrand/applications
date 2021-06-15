{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Cassandra image name
*/}}
{{- define "cassandra.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper metrics image name
*/}}
{{- define "cassandra.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "cassandra.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container init-certs image)
*/}}
{{- define "cassandra.tls.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.tls.image "global" .Values.global) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "cassandra.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "global" .Values.global) }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "cassandra.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the list of Cassandra seed nodes
*/}}
{{- define "cassandra.seeds" -}}
{{- $seeds := list }}
{{- $fullname := include "common.names.fullname" .  }}
{{- $releaseNamespace := .Release.Namespace }}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $seedCount := .Values.cluster.seedCount | int }}
{{- range $e, $i := until $seedCount }}
{{- $seeds = append $seeds (printf "%s-%d.%s-headless.%s.svc.%s" $fullname $i $fullname $releaseNamespace $clusterDomain) }}
{{- end }}
{{- range .Values.cluster.extraSeeds }}
{{- $seeds = append $seeds . }}
{{- end }}
{{- join "," $seeds }}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "cassandra.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "cassandra.validateValues.seedCount" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Cassandra - Number of seed nodes */}}
{{- define "cassandra.validateValues.seedCount" -}}
{{- $replicaCount := int .Values.replicaCount }}
{{- $seedCount := int .Values.cluster.seedCount }}
{{- if or (lt $seedCount 1) (gt $seedCount $replicaCount) }}
cassandra: cluster.seedCount

    Number of seed nodes must be greater or equal than 1 and less or
    equal to `replicaCount`.
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Return  the proper Commit Storage Class
{{ include "cassandra.commitstorage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "cassandra.commitstorage.class" -}}
{{- $storageClass := .persistence.commitStorageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.commitStorageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return true if encryption via TLS for client connections should be configured
*/}}
{{- define "cassandra.client.tlsEncryption" -}}
{{- if (or .Values.tls.clientEncryption .Values.cluster.clientEncryption) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if encryption via TLS for internode communication connections should be configured
*/}}
{{- define "cassandra.internode.tlsEncryption" -}}
{{- if (ne .Values.tls.internodeEncryption "none") -}}
    {{- printf "%s" .Values.tls.internodeEncryption -}}
{{- else if (ne .Values.cluster.internodeEncryption "none") -}}
    {{- printf "%s" .Values.cluster.internodeEncryption -}}
{{- else -}}
    {{- printf "none" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if encryption via TLS should be configured
*/}}
{{- define "cassandra.tlsEncryption" -}}
{{- if or (include "cassandra.client.tlsEncryption" . ) ( ne "none" (include "cassandra.internode.tlsEncryption" . )) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Cassandra TLS credentials secret
*/}}
{{- define "cassandra.tlsSecretName" -}}
{{- $secretName := coalesce .Values.tls.existingSecret .Values.tlsEncryptionSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "cassandra.createTlsSecret" -}}
{{- if and (include "cassandra.tlsEncryption" .) .Values.tls.autoGenerated (not .Values.tls.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "cassandra.tlsPasswordsSecret" -}}
{{- $secretName := coalesce .Values.tls.passwordsSecret .Values.tlsEncryptionSecretName -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-tls-pass" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

