{{- $appName := "container-registry-api" }}

apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: container-registry-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.global.clusterSvcAccount}}

  nodeSelector: {{include "stateless-node-selector" . | nindent 4 }}
  tolerations: {{include "stateless-tolerations" . | nindent 4 }}
  
  topologySpreadConstraints:
    {{ include "tsc-hostname" (dict "kloudlite.io/app.name" $appName) | nindent 4 }}

  replicas: {{.Values.apps.containerRegistryApi.configuration.replicas}}

  services:
    - port: {{.Values.apps.containerRegistryApi.configuration.httpPort}}
    - port: {{.Values.apps.containerRegistryApi.configuration.grpcPort}}
    - port: {{.Values.apps.containerRegistryApi.configuration.authorizerPort | int}}

  containers:
    - name: main
      image: {{.Values.apps.containerRegistryApi.image.repository}}:{{.Values.apps.containerRegistryApi.image.tag | default (include "image-tag" .) }}
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
        max: "80Mi"
      env:
        - key: PORT
          value: "{{.Values.apps.containerRegistryApi.configuration.httpPort}}"

        - key: GRPC_PORT
          value: "{{.Values.apps.containerRegistryApi.configuration.grpcPort}}"

        - key: COOKIE_DOMAIN
          value: {{.Values.global.cookieDomain}}

        - key: ACCOUNT_COOKIE_NAME
          value: {{.Values.global.accountCookieName}}

        {{- /* registry db */}}
        - key: DB_URI
          type: secret
          refName: mres-registry-db-creds
          refKey: .CLUSTER_LOCAL_URI

        - key: DB_NAME
          type: secret
          refName: mres-registry-db-creds
          refKey: DB_NAME

        - key: IAM_GRPC_ADDR
          value: "iam:3001"

        - key: AUTH_GRPC_ADDR
          value: "auth-api:3001"

        - key: JOB_BUILD_NAMESPACE
          value: {{.Values.apps.containerRegistryApi.configuration.jobBuildNamespace}}
  
        {{- /* git provider setup */}}
        - key: GITHUB_CLIENT_ID
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITHUB_CLIENT_ID

        - key: GITHUB_CLIENT_SECRET
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITHUB_CLIENT_SECRET

        - key: GITHUB_CALLBACK_URL
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITHUB_CALLBACK_URL

        - key: GITHUB_APP_ID
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITHUB_APP_ID

        - key: GITHUB_APP_PK_FILE
          value: /github/github-app-pk.pem

        - key: GITHUB_SCOPES
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITHUB_SCOPES

        {{- /* gitlab setup */}}
        - key: GITLAB_CLIENT_ID
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITLAB_CLIENT_ID

        - key: GITLAB_CLIENT_SECRET
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITLAB_CLIENT_SECRET

        - key: GITLAB_CALLBACK_URL
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITLAB_CALLBACK_URL

        - key: GITLAB_SCOPES
          type: secret
          refName: {{.Values.oAuth.secretName}}
          refKey: GITLAB_SCOPES

        - key: GITLAB_WEBHOOK_URL
          value: https://webhooks.{{include "router-domain" .}}/git/gitlab

        - key: GITLAB_WEBHOOK_AUTHZ_SECRET
          value: {{.Values.webhookSecrets.gitlabSecret}}

        - key: BUILD_CLUSTER_ACCOUNT_NAME
          value: {{.Values.apps.containerRegistryApi.configuration.buildClusterAccountName}}

        - key: BUILD_CLUSTER_NAME
          value: {{.Values.apps.containerRegistryApi.configuration.buildClusterName}}

        - key: REGISTRY_HOST
          value: registry.{{include "router-domain" .}}

        - key: REGISTRY_SECRET_KEY
          value: {{.Values.apps.containerRegistryApi.configuration.registrySecret | squote}}

        - key: REGISTRY_AUTHORIZER_PORT
          value: {{.Values.apps.containerRegistryApi.configuration.authorizerPort | squote}}

        - key: NATS_URL
          value: {{.Values.envVars.nats.url}}

        - key: RESOURCE_NATS_STREAM
          value: {{.Values.envVars.nats.streams.resourceSync.name}}

        - key: EVENTS_NATS_STREAM
          value: {{.Values.envVars.nats.streams.events.name}}

        - key: SESSION_KV_BUCKET
          value: {{.Values.envVars.nats.buckets.sessionKVBucket.name}}

      volumes:
        - mountPath: /github
          type: secret
          refName: {{.Values.oAuth.secretName}}
          items:
            - key: github-app-pk.pem
              fileName: github-app-pk.pem
---

