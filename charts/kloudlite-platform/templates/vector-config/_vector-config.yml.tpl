apiVersion: v1
kind: ConfigMap
metadata:
  name: {{.Release.Name}}-vector
  namespace: {{.Release.Namespace}}
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
data:
  vector.yaml: |
    api:
      address: 127.0.0.1:8686
      enabled: true
      playground: false
    data_dir: /vector-data-dir
    sinks:
      loki:
        encoding:
          codec: logfmt
        endpoint: http://loki.helm-loki:3100
        inputs:
          - vector
        labels:
          source: vector
          kl_app: '{{printf "{{ kubernetes.pod_labels.app }}" }}'
          kl_app2: '{{ printf "{{ kubernetes.pod_labels.kloudlite_io_app_name }}" }}'
          # app.kubernetes.io/instance: kloudlite-agent
        type: loki
      prom_exporter:
        address: 0.0.0.0:9090
        flush_period_secs: 20
        inputs:
          - vector
        type: prometheus_exporter
      stdout:
        encoding:
          codec: logfmt
        inputs:
          - vector
        type: console
    sources:
      vector:
        address: 0.0.0.0:6000
        type: vector
        version: "2"
