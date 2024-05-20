{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper Scylladb image name
*/}}
{{- define "scylladb.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container sysctl image)
*/}}
{{- define "scylladb.sysctl.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.sysctl.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "scylladb.volumePermissions.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "scylladb.imagePullSecrets" -}}
{{ include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.sysctl.image .Values.volumePermissions.image) "global" .Values.global) }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "scylladb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the list of Scylladb seed nodes
*/}}
{{- define "scylladb.seeds" -}}
{{- $seeds := list }}
{{- $fullname := include "common.names.fullname" .  }}
{{- $releaseNamespace := include "common.names.namespace" . }}
{{- $clusterDomain := .Values.clusterDomain }}
{{- $seedCount := .Values.cluster.seedCount | int }}
{{- range $e, $i := until $seedCount }}
{{- if $.Values.service.internal.enabled -}}
{{- $seeds = append $seeds (printf "%s-%d-internal.%s.svc.%s" $fullname $i $releaseNamespace $clusterDomain) }}
{{- else -}}
{{- $seeds = append $seeds (printf "%s-%d.%s-headless.%s.svc.%s" $fullname $i $fullname $releaseNamespace $clusterDomain) }}
{{- end }}
{{- end }}
{{- range .Values.cluster.extraSeeds }}
{{- $seeds = append $seeds . }}
{{- end }}
{{- join "," $seeds }}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "scylladb.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "scylladb.validateValues.seedCount" .) -}}
{{- $messages := append $messages (include "scylladb.validateValues.tls" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate values of Scylladb - Number of seed nodes */}}
{{- define "scylladb.validateValues.seedCount" -}}
{{- $replicaCount := int .Values.replicaCount }}
{{- $seedCount := int .Values.cluster.seedCount }}
{{- if or (lt $seedCount 1) (gt $seedCount $replicaCount) }}
scylladb: cluster.seedCount

    Number of seed nodes must be greater or equal than 1 and less or
    equal to `replicaCount`.
{{- end -}}
{{- end -}}

{{/* Validate values of Scylladb - Tls enabled */}}
{{- define "scylladb.validateValues.tls" -}}
{{- if and (include "scylladb.tlsEncryptionEnabled" .) (not .Values.tls.autoGenerated.enabled) (not .Values.tls.existingSecret) }}
scylladb: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the certificate/keyfile or
    enable auto-generated certificates.
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Return  the proper Commit Storage Class
{{ include "scylladb.commitstorage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "scylladb.commitstorage.class" -}}
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
Return type of internode communication connections should be configured
*/}}
{{- define "scylladb.internode.tlsEncryption" -}}
{{- if (ne .Values.tls.internodeEncryption "none") -}}
    {{- printf "%s" .Values.tls.internodeEncryption -}}
{{- else -}}
    {{- printf "none" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if encryption via TLS should be configured
*/}}
{{- define "scylladb.tlsEncryptionEnabled" -}}
{{- if or .Values.tls.clientEncryption ( ne "none" (include "scylladb.internode.tlsEncryption" . )) -}}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Scylladb TLS credentials secret
*/}}
{{- define "scylladb.tlsSecretName" -}}
{{- if .Values.tls.existingSecret -}}
    {{- print (tpl .Values.tls.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-crt" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Scylladb TLS credentials secret
*/}}
{{- define "scylladb.tlsCASecretName" -}}
{{- if .Values.tls.existingCASecret -}}
    {{- print (tpl .Values.tls.existingCASecret $) -}}
{{- else -}}
    {{- printf "%s-ca-crt" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "scylladb.createTlsSecret" -}}
{{- if and (include "scylladb.tlsEncryptionEnabled" .) .Values.tls.autoGenerated.enabled (not .Values.tls.existingSecret)  }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert file.
*/}}
{{- define "scylladb.tlsCert" -}}
{{- if (include "scylladb.createTlsSecret" . ) -}}
    {{- printf "/bitnami/scylladb/cert/%s" "tls.crt" -}}
{{- else -}}
    {{- required "Certificate filename is required when TLS in enabled" .Values.tls.certFilename | printf "/bitnami/scylladb/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the cert key file.
*/}}
{{- define "scylladb.tlsCertKey" -}}
{{- if (include "scylladb.createTlsSecret" . ) -}}
    {{- printf "/bitnami/scylladb/cert/%s" "tls.key" -}}
{{- else -}}
    {{- required "Certificate Key filename is required when TLS in enabled" .Values.tls.certKeyFilename | printf "/bitnami/scylladb/certs/%s" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path to the CA cert file.
*/}}
{{- define "scylladb.tlsCACert" -}}
{{- if (include "scylladb.createTlsSecret" . ) -}}
    {{- printf "/bitnami/scylladb/ca/%s" "tls.crt" -}}
{{- else if .Values.tls.certCAFilename -}}
    {{- printf "/bitnami/scylladb/ca/%s" .Values.tls.certCAFilename -}}
{{- end -}}
{{- end -}}

{{/*
Convert memory to M
Usage:
{{ include "scylladb.memory.convertToM" (dict "value" "3Gi") }}
*/}}
{{- define "scylladb.memory.convertToM" -}}
{{- $res := 0 -}}
{{- if regexMatch "G" .value -}}
{{- /* Multiply by 1000 if it is Gigabytes */ -}}
{{- $res = regexFind "[0-9.]+" .value | float64 | mulf 1000 | int -}}
{{- else -}}
{{- /* Assume M for the rest, so simply extract the number and convert to int */ -}}
{{- $res = regexFind "[0-9]+" .value | int -}}
{{- end -}}
{{- $res -}}
{{- end -}}

{{/*
Return memory limit if resources or resourcesPreset has been set (in M)
*/}}
{{- define "scylladb.memory.getLimitInM" -}}
{{- $res := "" -}}
{{- if .Values.resources -}}
    {{- /* We need to go step by step to avoid nil pointer exceptions */ -}}
    {{- if .Values.resources.limits -}}
        {{- if .Values.resources.limits.memory -}}
            {{- $res = .Values.resources.limits.memory -}}
        {{- end -}}
    {{- end }}
{{- else if (ne .Values.resourcesPreset "none") -}}
    {{- $preset := include "common.resources.preset" (dict "type" .Values.resourcesPreset) | fromYaml -}}
    {{- $res = $preset.limits.memory -}}
{{- end -}}
{{- if $res -}}
    {{- /* Convert to M */ -}}
    {{- include "scylladb.memory.convertToM" (dict "value" $res) -}}
{{- end -}}
{{- end -}}

{{/*
Calculate Max Heap Size based on the given values
*/}}
{{- define "scylladb.memory.calculateMaxHeapSize" -}}
{{- if .Values.jvm.maxHeapSize -}}
{{- /* Honor value explicitly set */ -}}
{{- print .Values.jvm.maxHeapSize -}}
{{- else -}}
{{- /* Calculate based on resources set */ -}}
{{- /* Reference: https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gc-ergonomics.html */ -}}
{{- $res := include "scylladb.memory.getLimitInM" . -}}
{{- $res = div $res 4 | min 1000 -}}
{{- printf "%vM" $res -}}
{{- end -}}
{{- end -}}

{{/*
Calculate New Heap Size based on the given values
*/}}
{{- define "scylladb.memory.calculateNewHeapSize" -}}
{{- if .Values.jvm.newHeapSize -}}
{{- /* Honor value explicitly set */ -}}
{{- print .Values.jvm.newHeapSize -}}
{{- else -}}
{{- /* Calculate based on resources set */ -}}
{{- /* Reference: https://docs.oracle.com/javase/8/docs/technotes/guides/vm/gc-ergonomics.html */ -}}
{{- $res := include "scylladb.memory.getLimitInM" . -}}
{{- $res = div $res 64 | max 256 -}}
{{- printf "%vM" $res -}}
{{- end -}}
{{- end -}}

{{/*
Print warning if jvm memory not set
*/}}
{{- define "scylladb.warnings.jvm" -}}
{{- if not .Values.jvm.maxHeapSize }}
WARNING: JVM Max Heap Size not set in value jvm.maxHeapSize. When not set, the chart will calculate the following size:
     MIN(Memory Limit (if set) / 4, 1024M)
{{- end }}
{{- if not .Values.jvm.maxHeapSize }}
WARNING: JVM New Heap Size not set in value jvm.newHeapSize. When not set, the chart will calculate the following size:
     MAX(Memory Limit (if set) / 64, 256M)
{{- end }}
{{- end -}}
