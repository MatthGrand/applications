{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper image name
*/}}
{{- define "dremio.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.dremio.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name
*/}}
{{- define "dremio.init-containers.default-image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.defaultInitContainers.defaultImage "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the sidecar JMX exporter image)
*/}}
{{- define "dremio.metrics.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.metrics.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Dremio Master Coordinator fullname
*/}}
{{- define "dremio.master-coordinator.fullname" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) "master-coordinator" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Dremio Coordinator fullname
*/}}
{{- define "dremio.coordinator.fullname" -}}
{{- printf "%s-%s" (include "common.names.fullname" .) "coordinator" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Dremio Executor fullname
*/}}
{{- define "dremio.executor.fullname" -}}
{{- printf "%s-%s-%s" (include "common.names.fullname" .context) "executor" .engine | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "dremio.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.dremio.image .Values.defaultInitContainers.defaultImage) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dremio.master-coordinator.dremio-conf.useSecret" -}}
{{- if or .Values.masterCoordinator.dremioConf.existingSecret .Values.dremio.dremioConf.secretConfigOverrides .Values.masterCoordinator.dremioConf.secretConfigOverrides -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dremio.coordinator.dremio-conf.useSecret" -}}
{{- if or .Values.coordinator.dremioConf.existingSecret .Values.dremio.dremioConf.secretConfigOverrides .Values.coordinator.dremioConf.secretConfigOverrides -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dremio.executor.dremio-conf.useSecret" -}}
{{- if or .executorValues.dremioConf.existingSecret .context.Values.dremio.dremioConf.secretConfigOverrides .executorValues.dremioConf.secretConfigOverrides -}}
{{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Dremio metrics configuration configmap
*/}}
{{- define "dremio.metrics.configmapName" -}}
{{- if .Values.metrics.existingConfigmap -}}
{{- include "common.tplvalues.render" (dict "value" .Values.metrics.existingConfigmap "context" $) -}}
{{- else -}}
{{ printf "%s-metrics-configuration" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dremio.master-coordinator.serviceAccountName" -}}
{{- if .Values.masterCoordinator.serviceAccount.create -}}
    {{ default (include "dremio.master-coordinator.fullname" .) .Values.masterCoordinator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.masterCoordinator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dremio.coordinator.serviceAccountName" -}}
{{- if .Values.coordinator.serviceAccount.create -}}
    {{ default (include "dremio.coordinator.fullname" .) .Values.coordinator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.coordinator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dremio.executor.serviceAccountName" -}}
{{- if .executorValues.serviceAccount.create -}}
    {{ default (include "dremio.executor.fullname" (dict "engine" .engine "context" .context)) .executorValues.serviceAccount.name }}
{{- else -}}
    {{ default "default" .executorValues.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
dremio.conf ConfigMap (master-coordinator)
*/}}
{{- define "dremio.master-coordinator.dremio-conf.configmapName" -}}
{{- if .Values.masterCoordinator.dremioConf.existingConfigmap -}}
    {{- tpl .Values.masterCoordinator.dremioConf.existingConfigmap $ -}}
{{- else -}}
    {{- printf "%s-dremio-conf" (include "dremio.master-coordinator.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
dremio.conf ConfigMap (coordinator)
*/}}
{{- define "dremio.coordinator.dremio-conf.configmapName" -}}
{{- if .Values.coordinator.dremioConf.existingConfigmap -}}
    {{- tpl .Values.coordinator.dremioConf.existingConfigmap $ -}}
{{- else -}}
    {{- printf "%s-dremio-conf" (include "dremio.coordinator.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
dremio.conf ConfigMap (executor)
*/}}
{{- define "dremio.executor.dremio-conf.configmapName" -}}
{{- if .executorValues.dremioConf.existingConfigmap -}}
    {{- tpl .executorValues.dremioConf.existingConfigmap .context -}}
{{- else -}}
    {{- printf "%s-dremio-conf" (include "dremio.executor.fullname" (dict "context" .context "engine" .engine)) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
dremio.conf ConfigMap (master-coordinator)
*/}}
{{- define "dremio.master-coordinator.dremio-conf.secretName" -}}
{{- if .Values.masterCoordinator.dremioConf.existingSecret -}}
    {{- tpl .Values.masterCoordinator.dremioConf.existingSecret $ -}}
{{- else -}}
    {{- printf "%s-dremio-conf" (include "dremio.master-coordinator.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
dremio.conf ConfigMap (coordinator)
*/}}
{{- define "dremio.coordinator.dremio-conf.secretName" -}}
{{- if .Values.coordinator.dremioConf.existingSecret -}}
    {{- tpl .Values.coordinator.dremioConf.existingSecret $ -}}
{{- else -}}
    {{- printf "%s-dremio-conf" (include "dremio.coordinator.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
dremio.conf ConfigMap (executor)
*/}}
{{- define "dremio.executor.dremio-conf.secretName" -}}
{{- if .executorValues.dremioConf.existingSecret -}}
    {{- tpl .executorValues.dremioConf.existingSecret $ -}}
{{- else -}}
    {{- printf "%s-dremio-conf" (include "dremio.executor.fullname" (dict "context" .context "engine" .engine)) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
core-site.xml Secret
*/}}
{{- define "dremio.core-site.secretName" -}}
{{- if .Values.dremio.coreSite.existingSecret -}}
    {{- tpl .Values.dremio.coreSite.existingSecret $ -}}
{{- else -}}
    {{- printf "%s-core-site" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS credentials secret object should be created
*/}}
{{- define "dremio.tls.createSecret" -}}
{{- if and .Values.dremio.tls.enabled .Values.dremio.tls.autoGenerated.enabled (not .Values.dremio.tls.existingSecret)  }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the Jenkins JKS password secret name
*/}}
{{- define "dremio.tls.passwordSecretName" -}}
{{- $secretName := .Values.dremio.tls.passwordSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-tls-pass" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Scylladb TLS credentials secret
*/}}
{{- define "dremio.tls.secretName" -}}
{{- if .Values.dremio.tls.existingSecret -}}
    {{- print (tpl .Values.dremio.tls.existingSecret $) -}}
{{- else -}}
    {{- printf "%s-crt" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Dremio auth credentials secret
*/}}
{{- define "dremio.auth.secretName" -}}
{{- if .Values.dremio.auth.existingSecret -}}
    {{- print (tpl .Values.dremio.auth.existingSecret $) -}}
{{- else -}}
    {{- include "common.names.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Return true if the init job should be created
*/}}
{{- define "dremio.bootstrap-user-job.create" -}}
{{- if and .Values.bootstrapUserJob.enabled .Values.dremio.auth.enabled (or .Release.IsInstall .Values.initJob.forceRun) -}}
    {{- true -}}
{{- else -}}
    {{/* Do not return anything */}}
{{- end -}}
{{- end -}}

{{/*
Return the Dremio auth credentials secret
*/}}
{{- define "dremio.auth.passwordKey" -}}
{{- if .Values.dremio.auth.existingSecretKey -}}
    {{- print (tpl .Values.dremio.auth.existingSecretKey $) -}}
{{- else -}}
    {{- print "dremio-password" -}}
{{- end -}}
{{- end -}}

{{/* Return common dremio.conf configuration */}}
{{- define "dremio.dremio-conf.common.default" -}}
paths.local: {{ .Values.masterCoordinator.persistence.mountPath | quote }}
{{- if or (eq .Values.dremio.distStorageType "minio") (eq .Values.dremio.distStorageType "aws") }}
paths.dist: {{ printf "dremioS3://%s%s" (include "dremio.s3.bucket" .) (include "dremio.s3.path" .) | quote }}
{{- end }}
zookeeper: {{ include "dremio.zookeeper.hosts-with-port" . | quote }}
{{- /* Container ports */}}
services.coordinator.web.port: {{ .Values.dremio.containerPorts.web }}
services.coordinator.client-endpoint.port: {{ .Values.dremio.containerPorts.client }}
services.flight.port: {{ .Values.dremio.containerPorts.flight }}
services.fabric.port: {{ .Values.dremio.containerPorts.fabric }}
services.conduit.port: {{ .Values.dremio.containerPorts.conduit }}
services.web-admin.port: {{ .Values.dremio.containerPorts.liveness }}
services.web-admin.host: {{ print "{{ POD_IP }}" | quote }}
{{- if .Values.dremio.tls.enabled }}
services.coordinator.web.ssl.enabled: true
{{- /* We skip Dremio cert auto-generation and rely on the chart instead */}}
services.coordinator.web.ssl.auto-certificate.enabled: false
services.coordinator.web.ssl.keyStore: "/opt/bitnami/dremio/certs/dremio.jks"
services.coordinator.web.ssl.keyStoreType: "jks"
{{- end }}
{{- end }}

{{/* Return common dremio.conf configuration (sensitive) */}}
{{- define "dremio.dremio-conf.common.defaultSecret" -}}
{{- if .Values.dremio.tls.enabled }}
{{- /* Set the value dependant on env vars so we can use external secrets */ -}}
services.coordinator.web.ssl.keyStorePassword: {{ print "{{ DREMIO_KEYSTORE_PASSWORD }}" | quote }}
{{- end }}
{{- end }}

{{- define "dremio.dremio-conf.flattenYAML" -}}
{{- /* Moving parameters to vars before entering the range */ -}}
{{- $prefix := .prefix -}}
{{- /* Loop through the values of the map */ -}}
{{- range $key, $val := .config -}}
{{- $varName := ternary $key (list $prefix $key | join ".") (eq $prefix "") -}}
{{- if kindOf $val | eq "map" -}}
{{- /* If the variable is a map, we call the helper recursively, adding the semi-computed variable name as the prefix */ -}}
{{ include "dremio.dremio-conf.flattenYAML" (dict "config" $val "prefix" $varName) }}
{{- else }}
{{- /* Base case: We reached to a value that is not a map (sting, integer, boolean, array), so we can build the variable */ -}}
{{- if kindOf $val | eq "slice" -}}
{{- /* If it is an array we use the join function to create an array with commas */}}
{{ $varName }}: [{{ join "," $val  }}]
{{- else if kindOf $val | eq "string" -}}
{{- /* String, quote */}}
{{ $varName }}: {{ $val | quote }}
{{- else -}}
{{- /* Integer or boolean */}}
{{ $varName }}: {{ $val }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Init container definition for generating the configuration
*/}}
{{- define "dremio.init-containers.generate-conf" -}}
# This init container renders and merges the Dremio configuration files.
# We need to use a volume because we're working with ReadOnlyRootFilesystem
- name: generate-conf
  image: {{ include "dremio.init-containers.default-image" .context }}
  imagePullPolicy: {{ .context.Values.defaultInitContainers.defaultImage.pullPolicy }}
  {{- if .context.Values.defaultInitContainers.generateConf.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .context.Values.defaultInitContainers.generateConf.containerSecurityContext "context" .context) | nindent 4 }}
  {{- end }}
  {{- if .context.Values.defaultInitContainers.generateConf.resources }}
  resources: {{- toYaml .context.Values.defaultInitContainers.generateConf.resources | nindent 4 }}
  {{- else if ne .context.Values.defaultInitContainers.generateConf.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .context.Values.defaultInitContainers.generateConf.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      set -e
      {{- if .context.Values.usePasswordFile }}
      # We need to load all the secret env vars to the system
      for file in $(find /bitnami/dremio/secrets -type f); do
          env_var_name="$(basename $file)"
          echo "Exporting $env_var_name"
          export $env_var_name="$(< $file)"
      done
      {{- end }}

      # dremio.conf -> We concatenate the configuration from configmap + secret and then
      # perform render-template to substitute all the environment variable references

      echo "Expanding env vars from dremio.conf"
      find /bitnami/dremio/input-dremio -type f -name dremio.conf -print0 | sort -z | xargs -0 cat > /bitnami/dremio/rendered-conf/pre-render-dremio.conf
      render-template /bitnami/dremio/rendered-conf/pre-render-dremio.conf > /bitnami/dremio/rendered-conf/dremio.conf
      rm /bitnami/dremio/rendered-conf/pre-render-dremio.conf

      # Files different from dremio.conf -> Here we only apply render-template to expand the env vars
      for file in $(find /bitnami/dremio/input-dremio -type f -not -name dremio.conf); do
        filename="$(basename $file)"
        echo "Expanding env vars from $filename"
        render-template "$file" > /bitnami/dremio/rendered-conf/$filename
      done
      echo "Configuration generated"
  env:
    - name: BITNAMI_DEBUG
      value: {{ ternary "true" "false" (or .context.Values.dremio.image.debug .context.Values.diagnosticMode.enabled) | quote }}
    {{- if not .context.Values.usePasswordFile }}
    {{- if or .context.Values.dremio.tls.passwordSecret .context.Values.dremio.tls.password .context.Values.dremio.tls.autoGenerated.enabled .context.Values.dremio.tls.usePemCerts }}
    - name: DREMIO_KEYSTORE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "dremio.tls.passwordSecretName" .context }}
          key: keystore-password
    {{- end }}
    {{- if or (eq .context.Values.dremio.distStorageType "minio") (eq .context.Values.dremio.distStorageType "aws") }}
    - name: DREMIO_AWS_ACCESS_KEY_ID
      valueFrom:
        secretKeyRef:
          name: {{ include "dremio.s3.secretName" .context }}
          key: {{ include "dremio.s3.accessKeyIDKey" .context | quote }}
    - name: DREMIO_AWS_SECRET_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: {{ include "dremio.s3.secretName" .context }}
          key: {{ include "dremio.s3.secretAccessKeyKey" .context | quote }}
    {{- end }}
    {{- end }}
    - name: POD_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    {{- if .context.Values.defaultInitContainers.generateConf.extraEnvVars }}
    {{- include "common.tplvalues.render" (dict "value" .context.Values.defaultInitContainers.generateConf.extraEnvVars "context" $) | nindent 4 }}
    {{- end }}
  envFrom:
    {{- if .context.Values.defaultInitContainers.generateConf.extraEnvVarsCM }}
    - configMapRef:
        name: {{ include "common.tplvalues.render" (dict "value" .context.Values.defaultInitContainers.generateConf.extraEnvVarsCM "context" .context) }}
    {{- end }}
    {{- if .context.Values.defaultInitContainers.generateConf.extraEnvVarsSecret }}
    - secretRef:
        name: {{ include "common.tplvalues.render" (dict "value" .context.Values.defaultInitContainers.generateConf.extraEnvVarsSecret "context" .context) }}
    {{- end }}
  volumeMounts:
    - name: input-dremio-conf-cm
      mountPath: /bitnami/dremio/input-dremio/dremio-conf/configmap
    {{- if .mountDremioConfSecret }}
    - name: input-dremio-conf-secret
      mountPath: /bitnami/dremio/input-dremio/dremio-conf/secret
    {{- end }}
    - name: input-core-site
      mountPath: /bitnami/dremio/input-dremio/core-site
    - name: empty-dir
      mountPath: /tmp
      subPath: tmp-dir
    - name: empty-dir
      mountPath: /bitnami/dremio/rendered-conf
      subPath: app-conf-dir
    {{- if .context.Values.usePasswordFile }}
    {{- if or .context.Values.dremio.tls.passwordSecret .context.Values.dremio.tls.password .context.Values.dremio.tls.autoGenerated.enabled .context.Values.dremio.tls.usePemCerts }}
    - name: keystore-password
      mountPath: /bitnami/dremio/secrets/keystore-password
    {{- end }}
    {{- if or (eq .context.Values.dremio.distStorageType "minio") (eq .context.Values.dremio.distStorageType "aws") }}
    - name: s3-credentials
      mountPath: /bitnami/dremio/secrets/s3-credentials
    {{- end }}
    {{- end }}
    {{- if .context.Values.defaultInitContainers.generateConf.extraVolumeMounts }}
    {{- include "common.tplvalues.render" (dict "value" .context.Values.defaultInitContainers.generateConf.extraVolumeMounts "context" .context) | nindent 4 }}
    {{- end }}
{{- end -}}

{{- define "dremio.init-containers.volume-permissions" -}}
{{- /* As most Bitnami charts have volumePermissions in the root, we add this overwrite to maintain a similar UX */}}
{{- $volumePermissionsValues := mustMergeOverwrite .context.Values.defaultInitContainers.volumePermissions .context.Values.volumePermissions }}
- name: volume-permissions
  image: {{ include "dremio.init-containers.default-image" . }}
  imagePullPolicy: {{ .context.Values.defaultInitContainers.defaultImage.pullPolicy | quote }}
  command:
    - /bin/bash
    - -ec
    - |
      {{- if eq ( toString ( $volumePermissionsValues.containerSecurityContext.runAsUser )) "auto" }}
      chown -R `id -u`:`id -G | cut -d " " -f2` {{ .componentValues.persistence.mountPath }}
      {{- else }}
      chown -R {{ .componentValues.containerSecurityContext.runAsUser }}:{{ .componentValues.podSecurityContext.fsGroup }} {{ .componentValues.persistence.mountPath }}
      {{- end }}
  {{- if $volumePermissionsValues.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" $volumePermissionsValues.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if $volumePermissionsValues.resources }}
  resources: {{- toYaml $volumePermissionsValues.resources | nindent 4 }}
  {{- else if ne $volumePermissionsValues.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" $volumePermissionsValues.resourcesPreset) | nindent 4 }}
  {{- end }}
  volumeMounts:
    - name: data
      mountPath: {{ .componentValues.persistence.mountPath }}
      {{- if .componentValues.persistence.subPath }}
      subPath: {{ .componentValues.persistence.subPath }}
      {{- end }}
{{- end -}}

{{/*
Init container definition for waiting for the database to be ready
*/}}
{{- define "dremio.init-containers.wait-for-zookeeper" -}}
- name: wait-for-zookeeper
  image: {{ include "dremio.init-containers.default-image" . }}
  imagePullPolicy: {{ .Values.defaultInitContainers.defaultImage.pullPolicy }}
  {{- if .Values.defaultInitContainers.wait.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.wait.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.wait.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.wait.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.wait.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.wait.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      retry_while() {
        local -r cmd="${1:?cmd is missing}"
        local -r retries="${2:-12}"
        local -r sleep_time="${3:-5}"
        local return_value=1

        read -r -a command <<< "$cmd"
        for ((i = 1 ; i <= retries ; i+=1 )); do
            "${command[@]}" && return_value=0 && break
            sleep "$sleep_time"
        done
        return $return_value
      }

      zookeeper_hosts=(
      {{- if .Values.zookeeper.enabled  }}
        {{ include "dremio.zookeeper.fullname" . | quote }}
      {{- else }}
      {{- range $node :=.Values.externalZookeeper.servers }}
        {{ print $node | quote }}
      {{- end }}
      {{- end }}
      )

      check_zookeeper() {
          local -r zookeeper_host="${1:-?missing zookeeper}"
          if wait-for-port --timeout=5 --host=${zookeeper_host} --state=inuse {{ include "dremio.zookeeper.port" . }}; then
             return 0
          else
             return 1
          fi
      }

      for host in "${zookeeper_hosts[@]}"; do
          echo "Checking connection to $host"
          if retry_while "check_zookeeper $host"; then
              echo "Connected to $host"
          else
              echo "Error connecting to $host"
              exit 1
          fi
      done

      echo "Connection success"
      exit 0
{{- end -}}

{{/*
Init container definition for waiting for the database to be ready
*/}}
{{- define "dremio.init-containers.init-certs" -}}
- name: init-certs
  image: {{ include "dremio.image" . }}
  imagePullPolicy: {{ .Values.dremio.image.pullPolicy }}
  {{- if .Values.defaultInitContainers.initCerts.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.initCerts.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.initCerts.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.initCerts.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.initCerts.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.initCerts.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      set -e
      {{- if .context.Values.usePasswordFile }}
      # We need to load all the secret env vars to the system
      for file in $(find /bitnami/dremio/secrets -type f); do
          env_var_name="$(basename $file)"
          echo "Exporting $env_var_name"
          export $env_var_name="$(< $file)"
      done
      {{- end }}
      {{- if .Values.dremio.tls.usePemCerts }}
      if [[ -f "/certs/tls.key" ]] && [[ -f "/certs/tls.crt" ]]; then
        openssl pkcs12 -export -in "/certs/tls.crt" \
            -passout pass:"${DREMIO_KEYSTORE_PASSWORD}" \
            -inkey "/certs/tls.key" \
            -out "/tmp/keystore.p12"
        keytool -importkeystore -srckeystore "/tmp/keystore.p12" \
            -srcstoretype PKCS12 \
            -srcstorepass "${DREMIO_KEYSTORE_PASSWORD}" \
            -deststorepass "${DREMIO_KEYSTORE_PASSWORD}" \
            -destkeystore "/opt/bitnami/dremio/certs/dremio.jks"
        rm "/tmp/keystore.p12"
      else
          echo "Couldn't find the expected PEM certificates! They are mandatory when encryption via TLS is enabled."
          exit 1
      fi
      {{- else }}
      if [[ -f "/certs/dremio.jks" ]]; then
          cp "/certs/dremio.jks" "/opt/bitnami/dremio/certs/dremio.jks"
      else
          echo "Couldn't find the expected Java Key Stores (JKS) files! They are mandatory when encryption via TLS is enabled."
          exit 1
      fi
      {{- end }}
  env:
    {{- if not .Values.usePasswordFile }}
    {{- if or .Values.dremio.tls.passwordSecret .Values.dremio.tls.password .Values.dremio.tls.autoGenerated.enabled .Values.dremio.tls.usePemCerts }}
    - name: DREMIO_KEYSTORE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ include "dremio.tls.passwordSecretName" . }}
          key: keystore-password
    {{- end }}
    {{- end }}
  volumeMounts:
    - name: input-tls-certs
      mountPath: /certs
    - name: empty-dir
      mountPath: /opt/bitnami/dremio/certs
      subPath: app-processed-certs-dir
    - name: empty-dir
      mountPath: /tmp
      subPath: tmp-dir
    {{- if .Values.usePasswordFile }}
    {{- if or .Values.dremio.tls.passwordSecret .Values.dremio.tls.password .Values.dremio.tls.autoGenerated.enabled .Values.dremio.tls.usePemCerts }}
    - name: keystore-password
      mountPath: /bitnami/dremio/secrets/keystore-password
    {{- end }}
    {{- end }}
{{- end -}}

{{/*
Init container definition for waiting for the database to be ready
*/}}
{{- define "dremio.init-containers.copy-default-conf" -}}
- name: copy-default-conf
  image: {{ include "dremio.image" . }}
  imagePullPolicy: {{ .Values.dremio.image.pullPolicy }}
  {{- if .Values.defaultInitContainers.copyDefaultConf.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.copyDefaultConf.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.copyDefaultConf.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.copyDefaultConf.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.copyDefaultConf.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.copyDefaultConf.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      set -e
      echo "Copying configuration files from /opt/bitnami/dremio/conf to empty-dir volume"
      # First copy the default configuration files so we can fully replace the folder

      cp /opt/bitnami/dremio/conf/* /bitnami/dremio/conf/
  volumeMounts:
    - name: empty-dir
      mountPath: /bitnami/dremio/conf
      subPath: app-conf-dir
{{- end -}}

{{/*
Init container definition for waiting for the database to be ready
*/}}
{{- define "dremio.init-containers.upgrade-keystore" -}}
- name: upgrade-keystore
  image: {{ include "dremio.image" . }}
  imagePullPolicy: {{ .Values.dremio.image.pullPolicy }}
  {{- if .Values.defaultInitContainers.upgradeKeystore.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.upgradeKeystore.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.upgradeKeystore.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.upgradeKeystore.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.upgradeKeystore.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.upgradeKeystore.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - /opt/bitnami/scripts/dremio/entrypoint.sh
  args:
    - dremio-admin
    - upgrade
  env:
    - name: BITNAMI_DEBUG
      value: {{ ternary "true" "false" (or .Values.dremio.image.debug .Values.diagnosticMode.enabled) | quote }}
  volumeMounts:
    - name: empty-dir
      mountPath: /.dremio
      subPath: tmp-dir
    - name: data
      mountPath: {{ .Values.masterCoordinator.persistence.mountPath }}
      {{- if .Values.masterCoordinator.persistence.subPath }}
      subPath: {{ .Values.masterCoordinator.persistence.subPath }}
      {{- end }}
    - name: empty-dir
      mountPath: /tmp
      subPath: tmp-dir
    - name: empty-dir
      mountPath: /opt/bitnami/dremio/tmp
      subPath: app-tmp-dir
    - name: empty-dir
      mountPath: /opt/bitnami/dremio/run
      subPath: app-run-dir
    - name: empty-dir
      mountPath: /opt/bitnami/dremio/log
      subPath: app-log-dir
    - name: empty-dir
      mountPath: /opt/bitnami/dremio/conf
      subPath: app-conf-dir
    {{- if .Values.dremio.tls.enabled }}
    - name: empty-dir
      mountPath: /opt/bitnami/dremio/certs
      subPath: app-processed-certs-dir
    {{- end }}
{{- end -}}

{{/*
Init container definition for waiting for the database to be ready
*/}}
{{- define "dremio.init-containers.wait-for-s3" -}}
- name: wait-for-s3
  image: {{ include "dremio.init-containers.default-image" . }}
  imagePullPolicy: {{ .Values.defaultInitContainers.defaultImage.pullPolicy }}
  {{- if .Values.defaultInitContainers.wait.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.wait.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.wait.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.wait.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.wait.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.wait.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      #!/bin/bash
      retry_while() {
        local -r cmd="${1:?cmd is missing}"
        local -r retries="${2:-12}"
        local -r sleep_time="${3:-5}"
        local return_value=1

        read -r -a command <<< "$cmd"
        for ((i = 1 ; i <= retries ; i+=1 )); do
            "${command[@]}" && return_value=0 && break
            sleep "$sleep_time"
        done
        return $return_value
      }

      check_s3() {
          local -r s3_host="${1:-?missing s3}"
          if curl -k --max-time 5 "${s3_host}" | grep "RequestId"; then
             return 0
          else
             return 1
          fi
      }

      host={{ printf "%s://%v:%v" (include "dremio.s3.protocol" .) (include "dremio.s3.host" .) (include "dremio.s3.port" .) }}

      echo "Checking connection to $host"
      if retry_while "check_s3 $host"; then
        echo "Connected to $host"
      else
        echo "Error connecting to $host"
        exit 1
      fi

      echo "Connection success"
      exit 0
{{- end -}}

{{/*
Init container definition for waiting for the database to be ready
*/}}
{{- define "dremio.init-containers.wait-for-master-coordinator" -}}
- name: wait-for-master-coordinator
  image: {{ include "dremio.init-containers.default-image" . }}
  imagePullPolicy: {{ .Values.defaultInitContainers.defaultImage.pullPolicy }}
  {{- if .Values.defaultInitContainers.wait.containerSecurityContext.enabled }}
  securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.defaultInitContainers.wait.containerSecurityContext "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.defaultInitContainers.wait.resources }}
  resources: {{- toYaml .Values.defaultInitContainers.wait.resources | nindent 4 }}
  {{- else if ne .Values.defaultInitContainers.wait.resourcesPreset "none" }}
  resources: {{- include "common.resources.preset" (dict "type" .Values.defaultInitContainers.wait.resourcesPreset) | nindent 4 }}
  {{- end }}
  command:
    - bash
  args:
    - -ec
    - |
      #!/bin/bash
      retry_while() {
        local -r cmd="${1:?cmd is missing}"
        local -r retries="${2:-12}"
        local -r sleep_time="${3:-5}"
        local return_value=1

        read -r -a command <<< "$cmd"
        for ((i = 1 ; i <= retries ; i+=1 )); do
            "${command[@]}" && return_value=0 && break
            sleep "$sleep_time"
        done
        return $return_value
      }

      check_master_coordinator() {
          local -r master_coordinator_host="${1:-?missing master_coordinator}"
          if curl -k --max-time 5 "${master_coordinator_host}" | grep dremio; then
             return 0
          else
             return 1
          fi
      }

      host="{{ ternary "https" "http" .Values.dremio.tls.enabled }}://{{ include "dremio.master-coordinator.fullname" . }}-0.{{ printf "%s-headless" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}:{{ .Values.dremio.containerPorts.web }}"

      echo "Checking connection to $host"
      if retry_while "check_master_coordinator $host"; then
        echo "Connected to $host"
      else
        echo "Error connecting to $host"
        exit 1
      fi

      echo "Connection success"
      exit 0
{{- end -}}

{{/*
Return MinIO(TM) fullname
*/}}
{{- define "dremio.minio.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "minio" "chartValues" .Values.minio "context" $) -}}
{{- end -}}

{{/*
Return the S3 backend host
*/}}
{{- define "dremio.s3.host" -}}
    {{- if .Values.minio.enabled -}}
        {{- include "dremio.minio.fullname" . -}}
    {{- else -}}
        {{- print .Values.externalS3.host -}}
    {{- end -}}
{{- end -}}

{{/*
Return the S3 backend host
*/}}
{{- define "dremio.s3.protocol" -}}
    {{- if .Values.minio.enabled -}}
        {{- ternary "https" "http" .Values.minio.tls.enabled -}}
    {{- else -}}
        {{- .Values.externalS3.protocol -}}
    {{- end -}}
{{- end -}}

{{/*
Return the S3 bucket
*/}}
{{- define "dremio.s3.bucket" -}}
    {{- if .Values.minio.enabled -}}
        {{- print .Values.minio.defaultBuckets -}}
    {{- else -}}
        {{- print .Values.externalS3.bucket -}}
    {{- end -}}
{{- end -}}

{{/*
Return the S3 region
*/}}
{{- define "dremio.s3.region" -}}
    {{- if .Values.minio.enabled -}}
        {{- print "us-east-1"  -}}
    {{- else -}}
        {{- print .Values.externalS3.region -}}
    {{- end -}}
{{- end -}}

{{/*
Return the S3 port
*/}}
{{- define "dremio.s3.port" -}}
{{- ternary .Values.minio.service.ports.api .Values.externalS3.port .Values.minio.enabled -}}
{{- end -}}

{{/*
Return the S3 path
*/}}
{{- define "dremio.s3.path" -}}
{{- ternary "/dremio" .Values.externalS3.path .Values.minio.enabled -}}
{{- end -}}

{{/*
Return the S3 credentials secret name
*/}}
{{- define "dremio.s3.secretName" -}}
{{- if .Values.minio.enabled -}}
    {{- if .Values.minio.auth.existingSecret -}}
    {{- print .Values.minio.auth.existingSecret -}}
    {{- else -}}
    {{- print (include "dremio.minio.fullname" .) -}}
    {{- end -}}
{{- else if .Values.externalS3.existingSecret -}}
    {{- print .Values.externalS3.existingSecret -}}
{{- else -}}
    {{- printf "%s-%s" (include "common.names.fullname" .) "externals3" -}}
{{- end -}}
{{- end -}}

{{/*
Return the S3 access key id inside the secret
*/}}
{{- define "dremio.s3.accessKeyIDKey" -}}
    {{- if .Values.minio.enabled -}}
        {{- print "root-user"  -}}
    {{- else -}}
        {{- print .Values.externalS3.existingSecretAccessKeyIDKey -}}
    {{- end -}}
{{- end -}}

{{/*
Return the S3 secret access key inside the secret
*/}}
{{- define "dremio.s3.secretAccessKeyKey" -}}
    {{- if .Values.minio.enabled -}}
        {{- print "root-password"  -}}
    {{- else -}}
        {{- print .Values.externalS3.existingSecretKeySecretKey -}}
    {{- end -}}
{{- end -}}

{{/*
Return Zookeeper fullname
*/}}
{{- define "dremio.zookeeper.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "zookeeper" "chartValues" .Values.zookeeper "context" $) -}}
{{- end -}}

{{/*
Return zookeeper port
*/}}
{{- define "dremio.zookeeper.port" -}}
{{- if .Values.zookeeper.enabled -}}
    {{- print .Values.zookeeper.containerPorts.client -}}
{{- else -}}
    {{- print .Values.externalZookeeper.port  -}}
{{- end -}}
{{- end -}}

{{/*
Return zookeeper port
*/}}
{{- define "dremio.zookeeper.hosts-with-port" -}}
{{- $context := . -}}
{{- $res := list -}}
{{- if .Values.zookeeper.enabled -}}
  {{- $fullname := include "dremio.zookeeper.fullname" . -}}
  {{- $port := include "dremio.zookeeper.port" . | int -}}
  {{- range $i, $e := until (.Values.zookeeper.replicaCount | int) -}}
    {{- $res = append $res (printf "%s-%d.%s-headless.%s.svc:%d" $fullname $i $fullname $context.Release.Namespace $port) -}}
  {{- end -}}
{{- else -}}
  {{- $port := .Values.externalZookeeper.port | int -}}
  {{- range .Values.externalZookeeper.servers -}}
    {{- $res = append $res (printf "%s:%d" . $port) -}}
  {{- end -}}
{{- end -}}
{{- join "," $res -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "dremio.validateValues" -}}
{{- $messages := list -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}
