{{- $chartName := "nats" }}

---
{{- if .Values.helmCharts.nats.enabled }}
apiVersion: crds.kloudlite.io/v1
kind: HelmChart
metadata:
  name: {{$chartName}}
  namespace: {{.Release.Namespace}}
spec:
  chartRepo:
    name: nats
    url: https://nats-io.github.io/k8s/helm/charts/
  chartName: nats/nats
  chartVersion: 1.1.5
  jobVars:
    tolerations:
      - operator: Exists
  values:
    global:
      labels:
        kloudlite.io/helmchart: "{{$chartName}}"

    fullnameOverride: {{$chartName}}
    namespaceOverride: {{.Release.Namespace}}

    config:
      cluster:
        enabled: {{gt (.Values.helmCharts.nats.configuration.replicas| int64) 1}}
        replicas: {{.Values.helmCharts.nats.configuration.replicas}}

        routeURLs:
          user: sample
          password: sample
          useFQDN: true
          k8sClusterDomain: cluster.local

      jetstream:
        enabled: true
        fileStore:
          enabled: true
          dir: /data
          pvc:
            enabled: true
            size: 10Gi
            storageClassName: {{.Values.persistence.storageClasses.xfs}}
            name: {{$chartName}}-jetstream-pvc

      podTemplate:
        {{- if gt (.Values.helmCharts.nats.configuration.replicas | int64) 1 }}
        topologySpreadConstraints:
          {{.Values.helmCharts.nats.configuration.topologySpreadConstraintsKey}}:
            maxSkew: 1
            whenUnsatisfiable: DoNotSchedule
            nodeAffinityPolicy: Honor
            nodeTaintsPolicy: Honor
        {{- end }}
{{- end }}
