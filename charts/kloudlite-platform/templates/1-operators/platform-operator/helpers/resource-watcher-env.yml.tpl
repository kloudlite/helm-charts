{{- define "resource-watcher-env" -}}
- name: ACCOUNT_NAME
  value: {{.Values.accountName}}

- name: CLUSTER_NAME
  value: {{.Values.clusterName}}

- name: PLATFORM_ACCESS_TOKEN
  value: {{.Values.apps.messageOfficeApi.configuration.platformAccessToken}}

- name: GRPC_ADDR
  value: {{.Values.apps.messageOfficeApi.name}}:{{.Values.apps.messageOfficeApi.configuration.externalGrpcPort}}

{{- end -}}
