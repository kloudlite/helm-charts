apiVersion: clusters.kloudlite.io/v1
kind: NodePool
metadata:
  name: stateful
spec:
  minCount: {{.Values.nodepools.stateful.min}}
  maxCount: {{.Values.nodepools.stateful.max}}

  nodeTaints: {{.Values.nodepools.stateful.taints | toYaml | nindent 4}}
  nodeLabels: {{.Values.nodepools.stateful.labels | toYaml | nindent 4}}

  cloudProvider: aws
  iac:
    cloudProviderAccessKey:
      name: k3s-params
      namespace: {{.Release.Namespace}}
      key: accessKey
    cloudProviderSecretKey:
      name: k3s-params
      namespace: {{.Release.Namespace}}
      key: secretKey
  aws:
    vpcId: {{.Values.nodepools.stateful.aws.vpcId}}
    vpcSubnetId: {{.Values.nodepools.stateful.aws.vpcSubnetId}}
    availabilityZone: ap-south-1a
    nvidiaGpuEnabled: false
    rootVolumeSize: 50
    rootVolumeType: gp3

    poolType: ec2
    ec2Pool:
      instanceType: c6a.xlarge
