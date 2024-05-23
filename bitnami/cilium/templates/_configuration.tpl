{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the Cilium common configuration.
ref: https://docs.cilium.io/en/stable/network/kubernetes/configuration/
*/}}
{{- define "cilium.configuration" -}}
{{- if .Values.configuration }}
{{- include "common.tplvalues.render" (dict "value" .Values.configuration .) }}
{{- else }}
debug: {{ ternary "true" "false" (or .Values.agent.image.debug .Values.operator.image.debug .Values.diagnosticMode.enabled) | quote }}
# Name & ID of the cluster
cluster-name: default
cluster-id: "0"
{{- if or .Values.etcd.enabled .Values.externalKvstore.enabled }}
# KeyValue Store configuration
kvstore-opt: '{"etcd.config": "/opt/bitnami/cilium/var/lib/etcd/etcd.config"}'
etcd-config: |-
  ---
  endpoints: {{- include "cilium.kvstore.endpoints" . | nindent 4 }}
{{- end }}
# Remove state from the filesystem on startup
clean-cilium-state: "false"
clean-cilium-bpf-state: "false"
# IP addressing
enable-ipv4: "true"
enable-ipv6: "false"
# IP Address Management (IPAM)
# https://docs.cilium.io/en/stable/network/concepts/ipam
routing-mode: "tunnel"
tunnel-protocol: "vxlan"
tunnel-port: "8472"
# Health checking
enable-endpoint-health-checking: "true"
enable-health-checking: "true"
agent-health-port: {{ printf "%d" (int .Values.agent.containerPorts.health) | quote }}
# Monitor aggregation
monitor-aggregation: medium
monitor-aggregation-interval: "5s"
monitor-aggregation-flags: all
# BPF configuration
preallocate-bpf-maps: "false"
# CNI configuration
cni-exclusive: "true"
custom-cni-conf: "false"
cni-log-file: "/opt/bitnami/cilium/var/run/cni.log"
write-cni-conf-when-ready: {{ printf "/host%s/05-cilium.conflist" .Values.agent.cniPlugin.hostCNINetDir }}
cni-uninstall: {{ ternary "true" "false" .Values.agent.cniPlugin.uninstall | quote }}
# Operator configuration
operator-api-serve-addr: {{ printf ":%d" (int .Values.operator.containerPorts.api) | quote }}
disable-endpoint-crd: "false"
skip-crd-creation: "false"
identity-allocation-mode: crd
# Hubble configuration
enable-hubble: "true"
hubble-socket-path: "/opt/bitnami/cilium/var/run/hubble.sock"
hubble-export-file-max-size-mb: "10"
hubble-export-file-max-backups: "5"
hubble-listen-address: {{ printf ":%d" (int .Values.agent.containerPorts.hubblePeer) | quote }}
hubble-disable-tls: {{ ternary "true" "false" .Values.tls.enabled | quote }}
{{- if .Values.tls.enabled }}
hubble-tls-cert-file: /certs/hubble/tls.crt
hubble-tls-key-file: /certs/hubble/tls.key
hubble-tls-client-ca-files: /certs/ca/tls.crt
{{- end }}
{{- if or .Values.agent.metrics.enabled .Values.operator.metrics.enabled }}
# Prometheus metrics
enable-metrics: "true"
{{- if .Values.agent.metrics.enabled }}
prometheus-serve-addr: {{ printf ":%d" (int .Values.agent.containerPorts.metrics) | quote }}
metrics: ~
controllerGroupMetrics: all
{{- end }}
{{- if .Values.operator.metrics.enabled }}
operator-prometheus-serve-addr: {{ printf ":%d" (int .Values.operator.containerPorts.metrics) | quote }}
{{- end }}
{{- end }}
# Other configuration
enable-k8s-networkpolicy: "true"
synchronize-k8s-nodes: "true"
remove-cilium-node-taints: "true"
set-cilium-node-taints: "true"
set-cilium-is-up-condition: "true"
agent-not-ready-taint-key: "node.cilium.io/agent-not-ready"
{{- end }}
{{- end }}
