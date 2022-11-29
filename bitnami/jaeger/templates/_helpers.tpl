{{/* vim: set filetype=mustache: */}}


{{/*
Return the proper jaeger image name
*/}}
{{- define "jaeger.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper cassandra external image name
*/}}
{{- define "jaeger.cqlshImage" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.cqlshImage "global" .Values.global) }}
{{- end -}}


{{/*
Create the name of the query deployment
*/}}
{{- define "jaeger.query.fullname" -}}
    {{ printf "%s-query" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Create a container for checking cassandra availability
*/}}
{{- define "jaeger.waitForDBInitContainer" -}}
- name: jaeger-cassandra-ready-check
  image: {{ include "jaeger.cqlshImage" . }}
  command:
    - /bin/bash
  args:
    - -ec
    - |
      #!/bin/bash

      set -o errexit
      set -o nounset
      set -o pipefail

      . /opt/bitnami/scripts/libos.sh

      check_cassandra_keyspace_schema() {
          echo "SELECT 1" | cqlsh -u $CASSANDRA_USERNAME -p $CASSANDRA_PASSWORD -e "SELECT COUNT(*) FROM ${CASSANDRA_KEYSPACE}.traces"
      }

      info "Connecting to the Cassandra instance $CQLSH_HOST:$CQLSH_PORT"
      if ! retry_while "check_cassandra_keyspace_schema" 12 30; then
        error "Could not connect to the database server"
        exit 1
      else
        info "Connection check success"
      fi
  env:
    - name: CQLSH_HOST
      value: {{ if not .Values.cassandra.enabled }}
        {{ .Values.externalDatabase.host | quote }}
      {{ else }}
        {{ printf "%s-cassandra" (include "common.names.fullname" .) }}
      {{ end }}
    - name: CQLSH_PORT
      value: {{ if not .Values.cassandra.enabled }}
        {{ .Values.externalDatabase.port | quote }}
      {{ else }}
        {{ .Values.cassandra.service.ports.cql | quote }}
      {{ end }}
    - name: CASSANDRA_USERNAME
      value: {{ if not .Values.cassandra.enabled }}
        {{ .Values.externalDatabase.dbUser.user | quote }}
      {{ else }}
        {{ .Values.cassandra.dbUser.user | quote }}
      {{ end }}
    - name: CASSANDRA_PASSWORD
      valueFrom:
        secretKeyRef:
          name: {{ if not .Values.cassandra.enabled }}
            {{ .Values.externalDatabase.existingSecret }}
          {{ else }}
            {{ printf "%s-cassandra" (include "common.names.fullname" .) }}
          {{ end }}
          key: {{ if .Values.cassandra.enabled }}
            cassandra-password
          {{ else }}
            {{ .Values.externalDatabase.existingSecretPasswordKey }}
          {{ end }}
    - name: CASSANDRA_KEYSPACE
    value: {{ .Values.cassandra.keyspace }}
{{- end -}}

{{/*
Create the name of the service account to use for the collector
*/}}
{{- define "jaeger.collector.serviceAccountName" -}}
{{- if .Values.collector.serviceAccount.create -}}
    {{ default (include "jaeger.collector.fullname" .) .Values.collector.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.collector.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the agent
*/}}
{{- define "jaeger.agent.serviceAccountName" -}}
{{- if .Values.agent.serviceAccount.create -}}
    {{ default (include "jaeger.agent.fullname" .) .Values.agent.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.agent.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the query
*/}}
{{- define "jaeger.query.serviceAccountName" -}}
{{- if .Values.query.serviceAccount.create -}}
    {{ default (include "jaeger.query.fullname" .) .Values.query.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.query.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the collector deployment
*/}}
{{- define "jaeger.collector.fullname" -}}
    {{ printf "%s-collector" (include "common.names.fullname" .) }}
{{- end -}}

{{/*
Create the name of the collector deployment. This name includes 2 hyphens due to
an issue about env vars collision with the chart name when the release name is set to just 'jaeger'
ref. https://github.com/jaegertracing/jaeger-operator/issues/1158
*/}}
{{- define "jaeger.agent.fullname" -}}
    {{ printf "%s--agent" (include "common.names.fullname" .) }}
{{- end -}}
