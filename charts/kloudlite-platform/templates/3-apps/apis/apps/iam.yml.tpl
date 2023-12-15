apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: iam
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.normalSvcAccount}}

  {{ include "node-selector-and-tolerations" . | nindent 2 }}

  services:
    - port: 3001
      targetPort: 3001
      name: grpc
      type: tcp
  containers:
    - name: main
      image: {{.Values.apps.iamApi.image}}
      imagePullPolicy: {{.Values.apps.iamApi.ImagePullPolicy | default .Values.imagePullPolicy }}
      
      resourceCpu:
        min: "30m"
        max: "50m"
      resourceMemory:
        min: "50Mi"
        max: "100Mi"
      env:

        - key: MONGO_DB_URI
          type: secret
          refName: mres-iam-db-creds
          refKey: URI

        - key: COOKIE_DOMAIN
          value: "{{.Values.cookieDomain}}"

        - key: GRPC_PORT
          value: 3001

        - key: CONSOLE_SERVICE
          value: "console-api:3001"
