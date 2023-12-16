apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: message-office
  namespace: {{.Release.Namespace}}
spec:
  {{/* serviceAccount: {{.Values.normalSvcAccount}} */}}
  serviceAccount: {{.Values.clusterSvcAccount}}

  {{ include "node-selector-and-tolerations" . | nindent 2 }}

  services:
    - port: 80
      targetPort: 3000
      name: http
      type: tcp

    - port: 3001
      targetPort: 3001
      name: grpc
      type: tcp

    - port: 3002
      targetPort: 3002
      name: internal-grpc
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.messageOfficeApi.image}}
      imagePullPolicy: {{.Values.apps.messageOfficeApi.imagePullPolicy | default .Values.imagePullPolicy }}
      resourceCpu:
        min: "100m"
        max: "150m"
      resourceMemory:
        min: "100Mi"
        max: "150Mi"
      env:
        - key: HTTP_PORT
          value: "3000"

        - key: EXTERNAL_GRPC_PORT
          value: "3001"

        - key: INTERNAL_GRPC_PORT
          value: "3002"

        - key: DB_URI
          type: secret
          refName: "mres-message-office-db-creds"
          refKey: URI

        - key: DB_NAME
          value: message-office-db

        - key: NATS_URL
          value: "nats://nats:4222"

        - key: NATS_STREAM
          value: resource-sync

        - key: VECTOR_GRPC_ADDR
          value: {{printf "%s:6000" (include "vector.name" .) | quote}}

        - key: TOKEN_HASHING_SECRET
          value: {{.Values.apps.messageOfficeApi.configuration.tokenHashingSecret | squote}}

        - key: PLATFORM_ACCESS_TOKEN
          value: {{ include "msg-office-platform-access-token" $ }}

