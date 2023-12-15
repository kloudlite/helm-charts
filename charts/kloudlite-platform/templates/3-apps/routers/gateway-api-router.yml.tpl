---
apiVersion: crds.kloudlite.io/v1
kind: Router
metadata:
  name: gateway-api
  namespace: {{.Release.Namespace}}
spec:
  ingressClass: {{ (index .Values.helmCharts "ingress-nginx").configuration.ingressClassName }}
  domains:
    - "gateway-api.{{.Values.baseDomain}}"
  https:
    enabled: true
    clusterIssuer: {{.Values.clusterIssuer.name}}
    forceRedirect: true
  cors:
    enabled: true
    origins:
      - https://studio.apollographql.com
    allowCredentials: true
  basicAuth:
    enabled: true
    username: {{.Values.apps.gatewayApi.name}}
  routes:
    - app: {{.Values.apps.gatewayApi.name}}
      path: /
      port: 80
