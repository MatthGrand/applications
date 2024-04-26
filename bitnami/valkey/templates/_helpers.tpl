{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Valkey image name
*/}}
{{- define "valkey.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Valkey Sentinel image name
*/}}
{{- define "valkey.sentinel.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sentinel.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the metrics image)
*/}}
{{- define "valkey.metrics.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "valkey.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return kubectl image
*/}}
{{- define "valkey.kubectl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.kubectl.image "global" .Values.global) }}
{{- end -}}

{{/*
Return sysctl image
*/}}
{{- define "valkey.sysctl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sysctl.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "valkey.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.image .Values.sentinel.image .Values.metrics.image .Values.volumePermissions.image .Values.sysctl.image) "context" $) -}}
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
Return the appropriate apiGroup for PodSecurityPolicy.
*/}}
{{- define "podSecurityPolicy.apiGroup" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy" -}}
{{- else -}}
{{- print "extensions" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "valkey.createTlsSecret" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated (and (not .Values.tls.existingSecret) (not .Values.tls.certificatesSecret)) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing Valkey TLS certificates
*/}}
{{- define "valkey.tlsSecretName" -}}
{{- $secretName := coalesce .Values.tls.existingSecret .Values.tls.certificatesSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert file.
*/}}
{{- define "valkey.tlsCert" -}}
{{- if (include "valkey.createTlsSecret" . ) -}}
    {{- printf "/opt/bitnami/valkey/certs/%s" "tls.crt" -}}
{{- else -}}
    {{- required "Certificate filename is required when TLS in enabled" .Values.tls.certFilename | printf "/opt/bitnami/valkey/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert key file.
*/}}
{{- define "valkey.tlsCertKey" -}}
{{- if (include "valkey.createTlsSecret" . ) -}}
    {{- printf "/opt/bitnami/valkey/certs/%s" "tls.key" -}}
{{- else -}}
    {{- required "Certificate Key filename is required when TLS in enabled" .Values.tls.certKeyFilename | printf "/opt/bitnami/valkey/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "valkey.tlsCACert" -}}
{{- if (include "valkey.createTlsSecret" . ) -}}
    {{- printf "/opt/bitnami/valkey/certs/%s" "ca.crt" -}}
{{- else -}}
    {{- required "Certificate CA filename is required when TLS in enabled" .Values.tls.certCAFilename | printf "/opt/bitnami/valkey/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the DH params file.
*/}}
{{- define "valkey.tlsDHParams" -}}
{{- if .Values.tls.dhParamsFilename -}}
{{- printf "/opt/bitnami/valkey/certs/%s" .Values.tls.dhParamsFilename -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the shared service account to use
*/}}
{{- define "valkey.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the master service account to use
*/}}
{{- define "valkey.masterServiceAccountName" -}}
{{- if .Values.master.serviceAccount.create -}}
    {{ default (printf "%s-master" (include "common.names.fullname" .)) .Values.master.serviceAccount.name }}
{{- else -}}
    {{- if .Values.serviceAccount.create -}}
        {{ template "valkey.serviceAccountName" . }}
    {{- else -}}
        {{ default "default" .Values.master.serviceAccount.name }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the replicas service account to use
*/}}
{{- define "valkey.replicaServiceAccountName" -}}
{{- if .Values.replica.serviceAccount.create -}}
    {{ default (printf "%s-replica" (include "common.names.fullname" .)) .Values.replica.serviceAccount.name }}
{{- else -}}
    {{- if .Values.serviceAccount.create -}}
        {{ template "valkey.serviceAccountName" . }}
    {{- else -}}
        {{ default "default" .Values.replica.serviceAccount.name }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the configuration configmap name
*/}}
{{- define "valkey.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-configuration" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created
*/}}
{{- define "valkey.createConfigmap" -}}
{{- if empty .Values.existingConfigmap }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "valkey.secretName" -}}
{{- if .Values.auth.existingSecret -}}
{{- printf "%s" (tpl .Values.auth.existingSecret $) -}}
{{- else -}}
{{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the password key to be retrieved from Valkey&reg; secret.
*/}}
{{- define "valkey.secretPasswordKey" -}}
{{- if and .Values.auth.existingSecret .Values.auth.existingSecretPasswordKey -}}
{{- printf "%s" (tpl .Values.auth.existingSecretPasswordKey $) -}}
{{- else -}}
{{- printf "valkey-password" -}}
{{- end -}}
{{- end -}}


{{/*
Returns the available value for certain key in an existing secret (if it exists),
otherwise it generates a random value.
*/}}
{{- define "getValueFromSecret" }}
    {{- $len := (default 16 .Length) | int -}}
    {{- $obj := (lookup "v1" "Secret" .Namespace .Name).data -}}
    {{- if $obj }}
        {{- index $obj .Key | b64dec -}}
    {{- else -}}
        {{- randAlphaNum $len -}}
    {{- end -}}
{{- end }}

{{/*
Return Valkey&reg; password
*/}}
{{- define "valkey.password" -}}
{{- if or .Values.auth.enabled .Values.global.valkey.password }}
    {{- if not (empty .Values.global.valkey.password) }}
        {{- .Values.global.valkey.password -}}
    {{- else if not (empty .Values.auth.password) -}}
        {{- .Values.auth.password -}}
    {{- else -}}
        {{- include "getValueFromSecret" (dict "Namespace" (include "common.names.namespace" .) "Name" (include "valkey.secretName" .) "Length" 10 "Key" (include "valkey.secretPasswordKey" .))  -}}
    {{- end -}}
{{- end -}}
{{- end }}

{{/* Check if there are rolling tags in the images */}}
{{- define "valkey.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image }}
{{- include "common.warnings.rollingTag" .Values.sentinel.image }}
{{- include "common.warnings.rollingTag" .Values.metrics.image }}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "valkey.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "valkey.validateValues.topologySpreadConstraints" .) -}}
{{- $messages := append $messages (include "valkey.validateValues.architecture" .) -}}
{{- $messages := append $messages (include "valkey.validateValues.podSecurityPolicy.create" .) -}}
{{- $messages := append $messages (include "valkey.validateValues.tls" .) -}}
{{- $messages := append $messages (include "valkey.validateValues.createMaster" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Valkey&reg; - spreadConstrainsts K8s version */}}
{{- define "valkey.validateValues.topologySpreadConstraints" -}}
{{- if and (semverCompare "<1.16-0" .Capabilities.KubeVersion.GitVersion) .Values.replica.topologySpreadConstraints -}}
valkey: topologySpreadConstraints
    Pod Topology Spread Constraints are only available on K8s  >= 1.16
    Find more information at https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
{{- end -}}
{{- end -}}

{{/* Validate values of Valkey&reg; - must provide a valid architecture */}}
{{- define "valkey.validateValues.architecture" -}}
{{- if and (ne .Values.architecture "standalone") (ne .Values.architecture "replication") -}}
valkey: architecture
    Invalid architecture selected. Valid values are "standalone" and
    "replication". Please set a valid architecture (--set architecture="xxxx")
{{- end -}}
{{- if and .Values.sentinel.enabled (not (eq .Values.architecture "replication")) }}
valkey: architecture
    Using valkey sentinel on standalone mode is not supported.
    To deploy valkey sentinel, please select the "replication" mode
    (--set "architecture=replication,sentinel.enabled=true")
{{- end -}}
{{- end -}}

{{/* Validate values of Valkey&reg; - PodSecurityPolicy create */}}
{{- define "valkey.validateValues.podSecurityPolicy.create" -}}
{{- if and .Values.podSecurityPolicy.create (not .Values.podSecurityPolicy.enabled) }}
valkey: podSecurityPolicy.create
    In order to create PodSecurityPolicy, you also need to enable
    podSecurityPolicy.enabled field
{{- end -}}
{{- end -}}

{{/* Validate values of Valkey&reg; - TLS enabled */}}
{{- define "valkey.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.existingSecret) (not .Values.tls.certificatesSecret) }}
valkey: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the TLS certificates or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}

{{/* Validate values of Valkey&reg; - master service enabled */}}
{{- define "valkey.validateValues.createMaster" -}}
{{- if and .Values.sentinel.service.createMaster (or (not .Values.rbac.create) (not .Values.replica.automountServiceAccountToken) (not .Values.serviceAccount.create)) }}
valkey: sentinel.service.createMaster
    In order to redirect requests only to the master pod via the service, you also need to
    create rbac and serviceAccount. In addition, you need to enable
    replica.automountServiceAccountToken.
{{- end -}}
{{- end -}}

{{/* Define the suffix utilized for external-dns */}}
{{- define "valkey.externalDNS.suffix" -}}
{{ printf "%s.%s" (include "common.names.fullname" .) .Values.useExternalDNS.suffix }}
{{- end -}}

{{/* Compile all annotations utilized for external-dns */}}
{{- define "valkey.externalDNS.annotations" -}}
{{- if and .Values.useExternalDNS.enabled .Values.useExternalDNS.annotationKey }}
{{ .Values.useExternalDNS.annotationKey }}hostname: {{ include "valkey.externalDNS.suffix" . }}
{{- range $key, $val := .Values.useExternalDNS.additionalAnnotations }}
{{ $.Values.useExternalDNS.annotationKey }}{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}
{{- end }}
