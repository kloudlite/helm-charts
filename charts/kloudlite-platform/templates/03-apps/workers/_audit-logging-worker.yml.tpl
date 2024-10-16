apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: audit-logging
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.global.normalSvcAccount}}
  tolerations: {{.Values.nodepools.stateless.tolerations | toYaml | nindent 4}}
  nodeSelector: {{.Values.nodepools.stateless.labels | toYaml | nindent 4}}

  services: []
  containers:
    - name: main
      image: {{.Values.apps.auditLoggingWorker.image.repository}}:{{.Values.apps.auditLoggingWorker.image.tag | default (include "image-tag" .) }}
      imagePullPolicy: {{ include "image-pull-policy" .}}
      resourceCpu:
        min: "50m"
        max: "70m"
      resourceMemory:
        min: "50Mi"
        max: "70Mi"
      env:
        - key: DB_URI
          type: secret
          refName: mres-events-db-creds
          refKey: .CLUSTER_LOCAL_URI

        - key: DB_NAME
          type: secret
          refName: mres-events-db-creds
          refKey: DB_NAME
        - key: NATS_URL
          value: {{.Values.envVars.nats.url}}
        - key: EVENT_LOG_NATS_STREAM
          value: {{.Values.envVars.nats.streams.events.name}}
