{{- $appName := "iam" }}

apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: {{$appName}}
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.global.normalSvcAccount}}

  nodeSelector: {{include "stateless-node-selector" . | nindent 4 }}
  tolerations: {{include "stateless-tolerations" . | nindent 4 }}
  
  topologySpreadConstraints:
    {{ include "tsc-hostname" (dict "kloudlite.io/app.name" $appName) | nindent 4 }}
    {{ include "tsc-nodepool" (dict "kloudlite.io/app.name" $appName) | nindent 4 }}

  replicas: {{.Values.apps.iamApi.configuration.replicas}}

  services:
    - port: 3001 #grpc
  containers:
    - name: main
      image: {{.Values.apps.iamApi.image.repository}}:{{.Values.apps.iamApi.image.tag | default (include "image-tag" .) }}
      imagePullPolicy: {{ include "image-pull-policy" .}}
      {{if .Values.global.isDev}}
      args:
       - --dev
      {{end}}
      
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

        - key: MONGO_DB_NAME
          type: secret
          refName: mres-iam-db-creds
          refKey: DB_NAME

        - key: COOKIE_DOMAIN
          value: "{{.Values.global.cookieDomain}}"

        - key: GRPC_PORT
          value: "3001"

        - key: CONSOLE_SERVICE
          value: "console-api:3001"
