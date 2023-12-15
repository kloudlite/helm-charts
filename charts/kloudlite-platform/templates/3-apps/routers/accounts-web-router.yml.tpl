---
apiVersion: crds.kloudlite.io/v1
kind: Router
metadata:
  name: accounts
  namespace: {{.Release.Namespace}}
spec:
  ingressClass: {{ (index .Values.helmCharts "ingress-nginx").configuration.ingressClassName }}
  domains:
    - "accounts.{{.Values.baseDomain}}"
  https:
    enabled: true
    clusterIssuer: {{.Values.clusterIssuer.name}}
    forceRedirect: true
  routes:
    - app: {{.Values.apps.accountsWeb.name}}
      path: /
      port: 80
---
