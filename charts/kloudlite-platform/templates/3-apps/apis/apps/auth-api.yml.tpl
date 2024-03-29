apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: auth-api
  namespace: {{.Release.Namespace}}
  annotations:
    kloudlite.io/checksum.oauth-secrets: {{ include (print $.Template.BasePath "/3-apps/apis/secrets/oauth-secrets.yml.tpl") . | sha256sum }}
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
      image: {{.Values.apps.authApi.image.repository}}:{{.Values.apps.authApi.image.tag | default (include "image-tag" .) }}
      imagePullPolicy: {{ include "image-pull-policy" .}}
      {{if .Values.global.isDev}}
      args:
       - --dev
      {{end}}
      resourceCpu:
        min: "50m"
        max: "60m"
      resourceMemory:
        min: "80Mi"
        max: "120Mi"
      env:
        - key: MONGO_URI
          type: secret
          refName: mres-{{.Values.envVars.db.authDB}}-creds
          refKey: URI

        - key: MONGO_DB_NAME
          type: secret
          refName: mres-{{.Values.envVars.db.authDB}}-creds
          refKey: DB_NAME

        - key: COMMS_SERVICE
          value: "comms:3001"

        - key: PORT
          value: "3000"

        - key: GRPC_PORT
          value: "3001"

        - key: SESSION_KV_BUCKET
          value: {{.Values.envVars.nats.buckets.sessionKVBucket.name}}

        - key: RESET_PASSWORD_TOKEN_KV_BUCKET
          value: {{.Values.envVars.nats.buckets.resetTokenBucket.name}}

        - key: VERIFY_TOKEN_KV_BUCKET
          value: {{.Values.envVars.nats.buckets.verifyTokenBucket.name}}

        - key: NATS_URL
          value: {{.Values.envVars.nats.url}}

        - key: ORIGINS
          value: "https://kloudlite.io,https://studio.apollographql.com"

        - key: COOKIE_DOMAIN
          value: "{{.Values.global.cookieDomain}}"

        {{- if .Values.oAuth.providers.github.enabled }}
        - key: GITHUB_APP_PK_FILE
          value: /github/github-app-pk.pem
        {{- end }}

      envFrom:
        - type: secret
          refName: {{.Values.oAuth.secretName}}

      {{- if .Values.oAuth.providers.github.enabled }}
      volumes:
        - mountPath: /github
          type: secret
          refName: {{.Values.oAuth.secretName}}
          items:
            - key: github-app-pk.pem
              fileName: github-app-pk.pem
      {{- end }}
