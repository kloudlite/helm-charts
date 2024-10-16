{{- $chartOpts := .Values.helmCharts.ingressNginx }} 
{{- if $chartOpts.enabled }}
{{- $ingressClassName := $chartOpts.configuration.ingressClassName }} 

apiVersion: crds.kloudlite.io/v1
kind: HelmChart
metadata:
  name: {{$chartOpts.name}}
  namespace: {{.Release.Namespace}}
spec:
  chartRepoURL: https://kubernetes.github.io/ingress-nginx
  chartName: ingress-nginx
  chartVersion: 4.8.0

  {{ $isDaemonSet := eq $chartOpts.configuration.controllerKind "DaemonSet"}}
  jobVars:
    backOffLimit: 1

    {{- if $isDaemonSet }}
    tolerations:
      - operator: Exists
    {{- end }}
  values:
    nameOverride: {{$chartOpts.name}}

    rbac:
      create: true

    serviceAccount:
      create: true

    controller:
      # -- ingress nginx controller configuration
      {{- if not $isDaemonSet }}
      kind: Deployment
      service:
        type: LoadBalancer
      {{- end }}

      {{- if $isDaemonSet }}
      kind: DaemonSet
      service:
        type: "ClusterIP"

      hostNetwork: true
      hostPort:
        enabled: true
        ports:
          http: 80
          https: 443
          healthz: 10254

      dnsPolicy: ClusterFirstWithHostNet
      nodeSelector: 
        node-role.kubernetes.io/control-plane: "true"
      tolerations:
        - operator: Exists
      affinity:
        nodeAffinity: {{ include "required-node-affinity-to-masters" . | nindent 10 }}
      {{- end }}

      watchIngressWithoutClass: false
      ingressClassByName: true
      ingressClass: {{$ingressClassName}}
      electionID: {{$ingressClassName}}
      ingressClassResource:
        enabled: false
        name: {{$ingressClassName}}
        controllerValue: "k8s.io/{{$ingressClassName}}"

      resources:
        requests:
          cpu: 100m
          memory: 200Mi

      admissionWebhooks:
        enabled: false
        failurePolicy: Ignore

{{- end }}
