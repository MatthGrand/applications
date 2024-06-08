{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Returns an init-container that copies some dirs to an empty dir volume to make them writable
*/}}
{{- define "cilium.agent.initContainers.prepareWriteDirs" -}}
- name: prepare-write-dirs
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.prepareWriteDirs.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.prepareWriteDirs.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.prepareWriteDirs.resources }}
  resources: {{- toYaml .Values.agent.initContainers.prepareWriteDirs.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.prepareWriteDirs.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.prepareWriteDirs.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - /bin/bash
  args:
    - -ec
    - |
      . /opt/bitnami/scripts/liblog.sh

      info "Copying writable dirs to empty dir"
      # In order to not break the application functionality we need to make some
      # directories writable, so we need to copy it to an empty dir volume
      cp -r --preserve=mode /opt/bitnami/cilium/var/lib/bpf /emptydir/bpf-lib-dir
      info "Copy operation completed"
  volumeMounts:
    - name: empty-dir
      mountPath: /emptydir
{{- end -}}

{{/*
Returns an init-container that generate the Cilium configuration
*/}}
{{- define "cilium.agent.initContainers.buildConfig" -}}
- name: build-config
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.buildConfig.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.buildConfig.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.buildConfig.resources }}
  resources: {{- toYaml .Values.agent.initContainers.buildConfig.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.buildConfig.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.buildConfig.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - cilium-dbg
  args:
    - build-config
    - --dest
    - /config
    - --source
    - {{ printf "config-map:%s/%s" (include "common.names.namespace" .) (include "cilium.configmapName" .) }}
  env:
    - name: K8S_NODE_NAME
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: spec.nodeName
    - name: CILIUM_K8S_NAMESPACE
      valueFrom:
        fieldRef:
          apiVersion: v1
          fieldPath: metadata.namespace
  volumeMounts:
    - name: empty-dir
      mountPath: /config
      subPath: config-dir
{{- end -}}

{{/*
Returns an init-container that installs Cilium CNI plugin in the host
*/}}
{{- define "cilium.agent.initContainers.installCniPlugin" -}}
- name: install-cni-plugin
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.installCniPlugin.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.installCniPlugin.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.installCniPlugin.resources }}
  resources: {{- toYaml .Values.agent.initContainers.installCniPlugin.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.installCniPlugin.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.installCniPlugin.resourcesPreset) | nindent 4 }}
  {{- end }}
  args:
    - /opt/bitnami/scripts/cilium/install-cni-plugin.sh
    - /host
  env:
    - name: HOST_CNI_BIN_DIR
      value: {{ .Values.agent.cniPlugin.hostCNIBinDir }}
  volumeMounts:
    - name: host-cni-bin
      mountPath: {{ printf "/host%s" .Values.agent.cniPlugin.hostCNIBinDir }}
{{- end -}}

{{/*
Returns an init-container that mount bpf fs in the host
*/}}
{{- define "cilium.agent.initContainers.mountBpf" -}}
- name: host-mount-bpf
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.mountBpf.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.mountBpf.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.mountBpf.resources }}
  resources: {{- toYaml .Values.agent.initContainers.mountBpf.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.mountBpf.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.mountBpf.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      mount | grep "{{ .Values.agent.bpf.hostRoot }} type bpf" || mount -t bpf bpf {{ .Values.agent.bpf.hostRoot }}
  volumeMounts:
    - name: bpf-maps
      mountPath: {{ .Values.agent.bpf.hostRoot }}
      mountPropagation: Bidirectional
{{- end -}}

{{/*
Returns an init-container that mount cgroup2 filesystem in the host
*/}}
{{- define "cilium.agent.initContainers.mountCgroup2" -}}
- name: host-mount-cgroup2
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.mountCgroup2.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.mountCgroup2.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.mountCgroup2.resources }}
  resources: {{- toYaml .Values.agent.initContainers.mountCgroup2.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.mountCgroup2.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.mountCgroup2.resourcesPreset) | nindent 4 }}
  {{- end }}
  args:
    - /opt/bitnami/scripts/cilium/mount-cgroup2.sh
    - /host
    - {{ .Values.agent.cgroup2.hostRoot }}
  env:
    - name: HOST_CNI_BIN_DIR
      value: {{ .Values.agent.cniPlugin.hostCNIBinDir }}
  volumeMounts:
    - name: host-cni-bin
      mountPath: {{ printf "/host%s" .Values.agent.cniPlugin.hostCNIBinDir }}
    - name: host-proc
      mountPath: /host/proc
{{- end -}}

{{/*
Returns an init-container that cleans up the Cilium state
*/}}
{{- define "cilium.agent.initContainers.cleanState" -}}
- name: clean-state
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.cleanState.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.cleanState.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.cleanState.resources }}
  resources: {{- toYaml .Values.agent.initContainers.cleanState.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.cleanState.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.cleanState.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      if [[ "$CLEAN_CILIUM_BPF_STATE" = "true" ]]; then
          cilium-dbg post-uninstall-cleanup -f --bpf-state
      fi
      if [[ "$CLEAN_CILIUM_STATE" = "true" ]]; then
          cilium-dbg post-uninstall-cleanup -f --all-state
      fi
  env:
    - name: CLEAN_CILIUM_STATE
      valueFrom:
        configMapKeyRef:
          name: {{ template "cilium.configmapName" . }}
          key: clean-cilium-state
          optional: true
    - name: CLEAN_CILIUM_BPF_STATE
      valueFrom:
        configMapKeyRef:
          name: {{ template "cilium.configmapName" . }}
          key: clean-cilium-bpf-state
          optional: true
    - name: WRITE_CNI_CONF_WHEN_READY
      valueFrom:
        configMapKeyRef:
          name: {{ template "cilium.configmapName" . }}
          key: write-cni-conf-when-ready
          optional: true
  volumeMounts:
    {{- if .Values.agent.bpf.autoMount }}
    - name: bpf-maps
      mountPath: {{ .Values.agent.bpf.hostRoot }}
    {{- end }}
    - name: cilium-run
      mountPath: /opt/bitnami/cilium/var/run
    - name: host-cgroup-root
      mountPath: {{ .Values.agent.cgroup2.hostRoot }}
      mountPropagation: HostToContainer
{{- end -}}

{{/*
Returns an init-container that waits for kube-proxy to be ready
*/}}
{{- define "cilium.agent.initContainers.waitForKubeProxy" -}}
- name: wait-for-kube-proxy
  image: {{ include "cilium.agent.image" . }}
  imagePullPolicy: {{ .Values.agent.image.pullPolicy }}
  {{- if .Values.agent.initContainers.waitForKubeProxy.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.agent.initContainers.waitForKubeProxy.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.agent.initContainers.waitForKubeProxy.resources }}
  resources: {{- toYaml .Values.agent.initContainers.waitForKubeProxy.resources | nindent 4 }}
  {{- else if ne .Values.agent.initContainers.waitForKubeProxy.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.agent.initContainers.waitForKubeProxy.resourcesPreset) | nindent 4 }}
  {{- end }}
  args:
    - /opt/bitnami/scripts/cilium/wait-for-kube-proxy.sh
{{- end -}}
