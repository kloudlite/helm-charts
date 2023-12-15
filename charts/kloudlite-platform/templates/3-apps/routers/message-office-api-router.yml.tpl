---
apiVersion: crds.kloudlite.io/v1
kind: Router
metadata:
  name: message-office
  namespace: {{.Release.Namespace}}
spec:
  ingressClass: {{ (index .Values.helmCharts "ingress-nginx").configuration.ingressClassName }}
  backendProtocol: GRPC
  maxBodySizeInMB: 50
  domains:
    - "message-office.{{.Values.baseDomain}}"
  https:
    enabled: true
    clusterIssuer: {{.Values.clusterIssuer.name}}
    forceRedirect: true
  routes:
    - app: {{.Values.apps.messageOfficeApi.name}}
      path: /
      port: {{.Values.apps.messageOfficeApi.configuration.externalGrpcPort}}
---
