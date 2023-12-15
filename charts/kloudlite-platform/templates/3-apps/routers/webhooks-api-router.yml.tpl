---
apiVersion: crds.kloudlite.io/v1
kind: Router
metadata:
  name: webhooks
  namespace: {{.Release.Namespace}}
spec:
  ingressClass: {{ (index .Values.helmCharts "ingress-nginx").configuration.ingressClassName }}
  domains:
    - "webhooks.{{.Values.baseDomain}}"
  https:
    enabled: true
    clusterIssuer: {{.Values.clusterIssuer.name}}
    forceRedirect: true
  routes:
    - app: {{.Values.apps.webhooksApi.name}}
      path: /
      port: 80
---
