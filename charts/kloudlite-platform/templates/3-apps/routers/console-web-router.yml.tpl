---
apiVersion: crds.kloudlite.io/v1
kind: Router
metadata:
  name: console
  namespace: {{.Release.Namespace}}
spec:
  ingressClass: {{ (index .Values.helmCharts "ingress-nginx").configuration.ingressClassName }}
  domains:
    - "console.{{.Values.baseDomain}}"
  https:
    enabled: true
    clusterIssuer: {{.Values.clusterIssuer.name}}
    forceRedirect: true
  routes:
    - app: {{.Values.apps.consoleWeb.name}}
      path: /
      port: 80
---
