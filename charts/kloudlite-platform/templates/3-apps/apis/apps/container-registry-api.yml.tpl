{{- if .Values.apps.containerRegistryApi.enabled }}
apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: container-registry-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.clusterSvcAccount}}

  {{ include "node-selector-and-tolerations" . | nindent 2 }}

  services:
    - port: 80
      targetPort: 3000
      name: http
      type: tcp

    - port: 4001
      targetPort: 3001
      name: grpc
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.containerRegistryApi.image}}
      imagePullPolicy: {{.Values.apps.containerRegistryApi.ImagePullPolicy | default .Values.imagePullPolicy }}
      resourceCpu:
        min: "30m"
        max: "50m"
      resourceMemory:
        min: "50Mi"
        max: "80Mi"
      env:
        - key: PORT
          value: {{.Values.apps.containerRegistryApi.configuration.httpPort | squote}}

        - key: COOKIE_DOMAIN
          value: {{.Values.cookieDomain}}

        - key: ACCOUNT_COOKIE_NAME
          value: {{.Values.accountCookieName}}

        {{- /* registry db */}}
        - key: DB_URI
          type: secret
          refName: mres-container-registry-db-creds
          refKey: URI

        - key: IAM_GRPC_ADDR
          value: "iam-api:3001"

        - key: AUTH_GRPC_ADDR
          value: "auth-api:3001"

        - key: JOB_BUILD_NAMESPACE
          value: {{.Values.apps.containerRegistryApi.configuration.jobBuildNamespace}}
  
        {{- /* git provider setup */}}
        - key: GITHUB_CLIENT_ID
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITHUB_CLIENT_ID

        - key: GITHUB_CLIENT_SECRET
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITHUB_CLIENT_SECRET

        - key: GITHUB_CALLBACK_URL
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITHUB_CALLBACK_URL

        - key: GITHUB_APP_ID
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITHUB_APP_ID

        - key: GITHUB_APP_PK_FILE
          value: /github/github-app-pk.pem

        - key: GITHUB_SCOPES
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITHUB_SCOPES

        {{- /* gitlab setup */}}
        - key: GITLAB_CLIENT_ID
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITLAB_CLIENT_ID

        - key: GITLAB_CLIENT_SECRET
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITLAB_CLIENT_SECRET

        - key: GITLAB_CALLBACK_URL
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITLAB_CALLBACK_URL

        - key: GITLAB_SCOPES
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          refKey: GITLAB_SCOPES

        - key: GITLAB_WEBHOOK_URL
          value: https://webhooks.{{.Values.baseDomain}}/git/gitlab

        - key: GITLAB_WEBHOOK_AUTHZ_SECRET
          value: {{.Values.apps.webhooksApi.configuration.webhookAuthz.gitlabSecret}}

        - key: BUILD_CLUSTER_ACCOUNT_NAME
          value: {{.Values.apps.containerRegistryApi.configuration.buildClusterAccountName}}

        - key: BUILD_CLUSTER_NAME
          value: {{.Values.apps.containerRegistryApi.configuration.buildClusterName}}

        - key: REGISTRY_HOST
          value: {{.Values.apps.containerRegistryApi.configuration.registryHost | squote}}

        - key: REGISTRY_SECRET_KEY
          value: {{.Values.apps.containerRegistryApi.configuration.registrySecret | squote}}

        - key: REGISTRY_AUTHORIZER_PORT
          value: {{.Values.apps.containerRegistryApi.configuration.authorizerPort | squote}}

      volumes:
        - mountPath: /github
          type: secret
          refName: {{.Values.secretNames.oAuthSecret}}
          items:
            - key: github-app-pk.pem
              fileName: github-app-pk.pem
---
{{- end }}
