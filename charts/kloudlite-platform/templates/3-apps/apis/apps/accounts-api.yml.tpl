apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: accounts-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{ .Values.clusterSvcAccount }}

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
  containers:
    - name: main
      image: {{.Values.apps.accountsApi.image}}
      imagePullPolicy: {{.Values.apps.accountsApi.ImagePullPolicy | default .Values.imagePullPolicy }}
      resourceCpu:
        min: "50m"
        max: "80m"
      resourceMemory:
        min: "75Mi"
        max: "100Mi"
      env:
        - key: HTTP_PORT
          value: 3000

        - key: GRPC_PORT
          value: 3001

        - key: MONGO_URI
          type: secret
          refName: mres-accounts-db-creds
          refKey: URI

        - key: COOKIE_DOMAIN
          value: "{{.Values.cookieDomain}}"

        - key: IAM_GRPC_ADDR
          value: "iam:3001"

        - key: COMMS_GRPC_ADDR
          value: "comms:3001"

        - key: CONTAINER_REGISTRY_GRPC_ADDR
          value: "container-registry-api:3001"

        - key: CONSOLE_GRPC_ADDR
          value: "console-api:3001"

        - key: AUTH_GRPC_ADDR
          value: "auth-api:3001"

