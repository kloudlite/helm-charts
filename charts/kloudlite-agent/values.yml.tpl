imagePullPolicy: Always

accountName: &accountName {{.AccountName}}
clusterName: &clusterName {{.ClusterName}}

clusterToken: {{.ClusterToken}}
accessToken: {{.AccessToken}}
clusterIdentitySecretName: {{.ClusterIdentitySecretName}}

messageOfficeGRPCAddr: &messageOfficeGRPCAddr {{.MessageOfficeGRPCAddr}}

svcAccountName: &svcAccountName {{.ClusterSvcAccountName}}

agent:
  enabled: true
  name: kl-agent
  image: {{.ImageRegistryHost}}/kloudlite/{{.EnvName}}/kl-agent:{{.ImageTag}}

operators:
  statusAndBilling:
    enabled: true
    name: kl-status-and-billing
    image: {{.ImageRegistryHost}}/kloudlite/operators/{{.EnvName}}/status-n-billing:{{.ImageTag}}
  byocClientOperator:
    enabled: true
    name: kl-byoc-client
    image: {{.ImageRegistryHost}}/kloudlite/operators/{{.EnvName}}/byoc-client-operator:{{.ImageTag}}
