apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: accounts-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{ .Values.global.clusterSvcAccount }}
  tolerations: {{.Values.nodepools.stateless.tolerations | toYaml | nindent 4}}
  nodeSelector: {{.Values.nodepools.stateless.labels | toYaml | nindent 4}}

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
      image: {{.Values.apps.accountsApi.image.repository}}:{{.Values.apps.accountsApi.image.tag | default (include "image-tag" .) }}
      imagePullPolicy: {{ include "image-pull-policy" .}}
      {{if .Values.global.isDev}}
      args:
       - --dev
      {{end}}
      resourceCpu:
        min: "50m"
        max: "80m"
      resourceMemory:
        min: "75Mi"
        max: "100Mi"
      env:
        - key: HTTP_PORT
          value: "3000"

        - key: GRPC_PORT
          value: "3001"

        - key: MONGO_URI
          type: secret
          refName: mres-accounts-db-creds
          refKey: URI

        - key: MONGO_DB_NAME
          type: secret
          refName: mres-accounts-db-creds
          refKey: DB_NAME

        - key: SESSION_KV_BUCKET
          value: {{.Values.envVars.nats.buckets.sessionKVBucket.name}}

        - key: NATS_URL
          value: {{.Values.envVars.nats.url}}

        - key: COOKIE_DOMAIN
          value: "{{.Values.global.cookieDomain}}"

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

