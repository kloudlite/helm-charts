apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: console-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.clusterSvcAccount}}

  {{ include "node-selector-and-tolerations" . | nindent 2 }}
  
  services:
    - port: 80
      targetPort: 3000
      name: http
      type: tcp

    - port: {{.Values.apps.consoleApi.configuration.logsAndMetricsHttpPort | int }}
      targetPort: {{.Values.apps.consoleApi.configuration.logsAndMetricsHttpPort | int }}
      name: http
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.consoleApi.image}}
      imagePullPolicy: {{.Values.apps.consoleApi.ImagePullPolicy | default .Values.imagePullPolicy }}
      resourceCpu:
        min: "80m"
        max: "150m"
      resourceMemory:
        min: "80Mi"
        max: "150Mi"
      env:
        - key: HTTP_PORT
          value: 3000

        - key: LOGS_AND_METRICS_HTTP_PORT
          value: {{.Values.apps.consoleApi.configuration.logsAndMetricsHttpPort | squote}}
          {{- /* LOGS_AND_METRICS_HTTP_PORT=9999 */}}

        - key: COOKIE_DOMAIN
          value: "{{.Values.cookieDomain}}"

        - key: CONSOLE_DB_URI
          type: secret
          refName: "mres-console-db-creds"
          refKey: URI

        - key: ACCOUNT_COOKIE_NAME
          value: {{.Values.accountCookieName}}

        - key: CLUSTER_COOKIE_NAME
          value: {{.Values.clusterCookieName}}

        - key: NATS_URL
          value: "nats://nats.kloudlite.svc.cluster.local:4222"

        - key: IAM_GRPC_ADDR
          value: "iam:3001"

        - key: INFRA_GRPC_ADDR
          value: "infra-api:3001"

        - key: DEFAULT_PROJECT_WORKSPACE_NAME
          value: {{.Values.defaultProjectWorkspaceName}}

        - key: MSVC_TEMPLATE_FILE_PATH
          value: /console.d/templates/managed-svc-templates.yml

        - key: LOKI_SERVER_HTTP_ADDR
          value: http://{{ (index .Values.helmCharts "loki-stack").name }}.{{.Release.Namespace}}.svc.{{.Values.clusterInternalDNS}}:3100

        - key: PROM_HTTP_ADDR
          value: http://{{ (index .Values.helmCharts "kube-prometheus").name }}-prometheus.{{.Release.Namespace}}.svc.{{.Values.clusterInternalDNS}}:9090

        - key: PROM_HTTP_ADDR
          value: http://{{ (index .Values.helmCharts "kube-prometheus").name }}-prometheus.{{.Release.Namespace}}.svc.{{.Values.clusterInternalDNS}}:9090

      volumes:
        - mountPath: /console.d/templates
          type: config
          refName: {{.Values.apps.consoleApi.name}}-managed-svc-template
          items:
            - key: managed-svc-templates.yml