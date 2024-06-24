{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper Cilium Agent fullname
*/}}
{{- define "cilium.agent.fullname" -}}
{{- printf "%s-agent" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Cilium Operator fullname
*/}}
{{- define "cilium.operator.fullname" -}}
{{- printf "%s-operator" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Cilium Envoy fullname
*/}}
{{- define "cilium.envoy.fullname" -}}
{{- printf "%s-envoy" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Cilium Agent fullname (with namespace)
*/}}
{{- define "cilium.agent.fullname.namespace" -}}
{{- printf "%s-agent" (include "common.names.fullname.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Cilium Operator fullname (with namespace)
*/}}
{{- define "cilium.operator.fullname.namespace" -}}
{{- printf "%s-operator" (include "common.names.fullname.namespace" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Cilium key-value store fullname
*/}}
{{- define "cilium.kvstore.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "etcd" "chartValues" .Values.etcd "context" $) -}}
{{- end -}}

{{/*
Return the proper Cilium Agent image name
*/}}
{{- define "cilium.agent.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.agent.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Cilium Operator image name
*/}}
{{- define "cilium.operator.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.operator.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Cilium Operator image name
*/}}
{{- define "cilium.envoy.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.envoy.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "cilium.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.agent.image .Values.operator.image .Values.envoy.image) "context" $) -}}
{{- end -}}

{{/*
Return the Cilium configuration configmap.
*/}}
{{- define "cilium.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- print (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- print (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Cilium configuration configmap.
*/}}
{{- define "cilium.envoy.configmapName" -}}
{{- if .Values.envoy.existingConfigmap -}}
    {{- print (tpl .Values.envoy.existingConfigmap $) -}}
{{- else -}}
    {{- print (include "cilium.envoy.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for Cilium Agent
*/}}
{{- define "cilium.agent.serviceAccountName" -}}
{{- if .Values.agent.serviceAccount.create -}}
    {{ default (include "cilium.agent.fullname" .) .Values.agent.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.agent.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for Cilium Operator
*/}}
{{- define "cilium.operator.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create -}}
    {{ default (include "cilium.operator.fullname" .) .Values.operator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.operator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for Cilium Envoy
*/}}
{{- define "cilium.envoy.serviceAccountName" -}}
{{- if .Values.envoy.serviceAccount.create -}}
    {{ default (include "cilium.envoy.fullname" .) .Values.envoy.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.envoy.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret containing the TLS certificates for Hubble
*/}}
{{- define "cilium.tls.hubble.secretName" -}}
{{- if or .Values.tls.autoGenerated.enabled (and (not (empty .Values.tls.hubble.cert)) (not (empty .Values.tls.hubble.key))) -}}
    {{- printf "%s-hubble-crt" (include "cilium.agent.fullname" .) -}}
{{- else -}}
    {{- required "An existing hubble secret name must be provided if hubble cert and key are not provided!" (tpl .Values.tls.hubble.existingSecret .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the name of the secret containing the TLS certificates for Hubble client(s)
*/}}
{{- define "cilium.tls.client.secretName" -}}
{{- if or .Values.tls.autoGenerated.enabled (and (not (empty .Values.tls.client.cert)) (not (empty .Values.tls.client.key))) -}}
    {{- printf "%s-client-crt" (include "common.names.fullname" .) -}}
{{- else -}}
    {{- required "An existing secret name must be provided with TLS certs for Hubble client(s) if cert and key are not provided!" (tpl .Values.tls.client.existingSecret .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the host's CNI bin directory
*/}}
{{- define "cilium.agent.hostCNIBinDir" -}}
{{- if .Values.agent.cniPlugin.hostCNIBinDir -}}
    {{- print .Values.agent.cniPlugin.hostCNIBinDir -}}
{{- else if .Values.gcp.enabled -}}
    {{- print "/home/kubernetes/bin" -}}
{{- else -}}
    {{- print "/opt/cni/bin" -}}
{{- end -}}
{{- end -}}

{{/*
Return the host's CNI net configuration directory
*/}}
{{- define "cilium.agent.hostCNINetDir" -}}
{{- default "/etc/cni/net.d" .Values.agent.cniPlugin.hostCNINetDir -}}
{{- end -}}

{{/*
Return the default Cilium Operator command
*/}}
{{- define "cilium.operator.command" -}}
{{- if .Values.operator.command -}}
{{- include "common.tplvalues.render" (dict "value" .Values.operator.command "context" .) -}}
{{- else if .Values.azure.enabled -}}
- cilium-operator-azure
{{- else if .Values.aws.enabled -}}
- cilium-operator-aws
{{- else -}}
- cilium-operator-generic
{{- end -}}
{{- end -}}

{{/*
Return the key-value store endpoints
*/}}
{{- define "cilium.kvstore.endpoints" -}}
{{- if .Values.etcd.enabled -}}
    {{- $svcName := include "cilium.kvstore.fullname" . -}}
    {{- $port := int .Values.etcd.service.ports.client -}}
    {{- printf "- http://%s:%d" $svcName $port -}}
{{- else if .Values.externalKvstore.enabled -}}
    {{- range $endpoint := .Values.externalKvstore.endpoints -}}
        {{- printf "- http://%s" $endpoint -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the key-value store port
*/}}
{{- define "cilium.kvstore.port" -}}
{{- if .Values.etcd.enabled -}}
    {{- printf "%d" int .Values.etcd.service.ports.client -}}
{{- else if .Values.externalKvstore.enabled -}}
    {{- print "2379" -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "cilium.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "cilium.validateValues.kvstore" .) -}}
{{- $messages := append $messages (include "cilium.validateValues.provider" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of Cilium - KeyValue Store
*/}}
{{- define "cilium.validateValues.kvstore" -}}
{{- if and .Values.etcd.enabled .Values.externalKvstore.enabled -}}
etcd.enabled and externalKvstore.enabled
    Both etcd and externalKvstore are enabled. Please enable only one key-value store.
{{- end -}}
{{- end -}}

{{/*
Validate values of Cilium - Cloud Provider
*/}}
{{- define "cilium.validateValues.provider" -}}
{{- if and .Values.azure.enabled .Values.aws.enabled .Values.gcp.enabled -}}
azure.enabled, aws.enabled and gcp.enabled
    All cloud providers are enabled. Please enable only one cloud provider.
{{- else if and .Values.azure.enabled .Values.aws.enabled -}}
azure.enabled and aws.enabled
    Both AWS and Azure are enabled. Please enable only one cloud provider.
{{- else if and .Values.azure.enabled .Values.gcp.enabled -}}
azure.enabled amd gcp.enabled
    Both gcp and Azure are enabled. Please enable only one cloud provider.
{{- else if and .Values.aws.enabled .Values.gcp.enabled -}}
aws.enabled and gcp.enabled
    Both gcp and AWS are enabled. Please enable only one cloud provider.
{{- end -}}
{{- end -}}

