apiVersion: v1
kind: ConfigMap
metadata:
  name: gateway-supergraph
  namespace: {{.Release.Namespace}}
data:
  config: |+
    serviceList:
      - name: auth-api
        url: http://auth-api/query
      - name: accounts-api
        url: http://accounts-api/query

      {{- if .Values.apps.containerRegistryApi.enabled }}
      - name: container-registry-api
        url: http://container-registry-api/query
      {{- end }}

      - name: console-api
        url: http://console-api/query
      
      - name: infra-api
        url: http://infra-api/query

{{/*      - name: {{.Values.apps.messageOfficeApi.name}}*/}}
{{/*        url: http://{{.Values.apps.messageOfficeApi.name}}.{{.Release.Namespace}}.svc.{{.Values.clusterInternalDNS}}/query*/}}
---
