apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: audit-logging
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.normalSvcAccount}}
  {{ include "node-selector-and-tolerations" . | nindent 2 }}

  services: []
  containers:
    - name: main
      image: {{.Values.apps.auditLoggingWorker.image}}
      imagePullPolicy: {{.Values.apps.auditLoggingWorker.imagePullPolicy | default .Values.imagePullPolicy }}
      resourceCpu:
        min: "50m"
        max: "70m"
      resourceMemory:
        min: "50Mi"
        max: "70Mi"
      env:
        - key: EVENTS_DB_URI
          type: secret
          refName: mres-events-db
          refKey: URI
        - key: EVENTS_DB_NAME
          value: events-db
