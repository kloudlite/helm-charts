{{ if .Values.operators.agentOperator.enabled }}
{{ $name := .Values.operators.agentOperator.name }}

---
{{- $k3sParams := (lookup "v1" "Secret" "kube-system" "k3s-params") -}}

{{- if not $k3sParams }}
{{ fail "secret k3s-params is not present in namespace kube-system, could not proceed with helm installation" }}
{{- end }}

apiVersion: v1
kind: Secret
metadata:
  name: k3s-params
  namespace: {{.Release.Namespace}}
data: {{ $k3sParams.data | toYaml | nindent 2 }}

---

{{- $hasAwsVPC := and (.Values.operators.agentOperator.configuration.nodepools.enabled) (eq .Values.operators.agentOperator.configuration.nodepools.cloudprovider "aws") .Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.readFromCluster }}

{{- if $hasAwsVPC }}

{{- $awsSettings := (lookup "v1" "Secret" .Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.namespace .Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.name ) -}}

{{- if not $awsSettings }}
{{ fail "secret kloudlite-aws-settings is not present in namespace kube-system, could not proceed with helm installation" }}
{{- end }}

apiVersion: v1
kind: Secret
metadata:
  name: {{.Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.name}}
  namespace: {{.Release.Namespace}}
data: {{ $awsSettings.data | toYaml | nindent 2 }}

{{- end }}

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{$name}}
  namespace: {{.Release.Namespace}}
  labels: &labels
    app: {{$name}}
    control-plane: {{$name}}
    vector.dev/exclude: "true" # to exclude pods from being monitored by vector
  annotations:
    checksum/cluster-identity-secret: {{ include (print $.Template.BasePath "/secrets/cluster-identity-secret.yml.tpl") . | sha256sum }}
spec:
  selector:
    matchLabels: *labels
  replicas: 1
  template:
    metadata:
      annotations:
        kubectl.kubernetes.io/default-container: manager
      labels: *labels
    spec:
      securityContext:
        runAsNonRoot: true
      nodeSelector: {{.Values.operators.agentOperator.nodeSelector | default .Values.nodeSelector | toYaml | nindent 8}}
      tolerations: {{.Values.operators.agentOperator.tolerations | default .Values.tolerations | toYaml | nindent 8}}

      {{- if .Values.preferOperatorsOnMasterNodes }}
      affinity:
        nodeAffinity:
          {{include "preferred-node-affinity-to-masters" . | nindent 12 }}
      {{- end }}

      priorityClassName: kloudlite-critical

      containers:
        - args:
            - --secure-listen-address=0.0.0.0:8443
            - --upstream=http://127.0.0.1:8080/
            - --logtostderr=true
            - --v=0
          image: gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0
          name: kube-rbac-proxy
          ports:
            - containerPort: 8443
              name: https
              protocol: TCP
          resources:
            limits:
              cpu: 20m
              memory: 20Mi
            requests:
              cpu: 5m
              memory: 10Mi

        - args:
            - --health-probe-bind-address=:8081
            - --metrics-bind-address=127.0.0.1:8080
            - --leader-elect
          env:
            - name: MAX_CONCURRENT_RECONCILES
              value: "5"

            - name: CLUSTER_INTERNAL_DNS
              value: {{.Values.clusterInternalDNS}}

            {{- /* for: project operator */}}
            - name: SVC_ACCOUNT_NAME
              value: "kloudlite-svc-account"

            {{- /* for: environment controller */}}
            - name: DEFAULT_INGRESS_CLASS
              value: "{{.Values.helmCharts.ingressNginx.configuration.ingressClassName}}"

            {{- /* for: resource watcher */}}
            - name: OPERATORS_NAMESPACE
              value: {{.Release.Namespace}}

            - name: DEVICE_NAMESPACE
              value: {{.Values.operators.agentOperator.configuration.wireguard.deviceNamespace}}

            - name: CLUSTER_NAME
              valueFrom:
                secretKeyRef:
                  key: CLUSTER_NAME
                  name: {{.Values.clusterIdentitySecretName}}

            - name: ACCOUNT_NAME
              valueFrom:
                secretKeyRef:
                  key: ACCOUNT_NAME
                  name: {{.Values.clusterIdentitySecretName}}

            - name: GRPC_ADDR
              value: {{.Values.messageOfficeGRPCAddr}}

            - name: CLUSTER_IDENTITY_SECRET_NAME
              value: {{.Values.clusterIdentitySecretName}}

            - name: CLUSTER_IDENTITY_SECRET_NAMESPACE
              value: {{.Release.Namespace}}

            - name: ACCESS_TOKEN
              valueFrom:
                secretKeyRef:
                  name: {{.Values.clusterIdentitySecretName}}
                  key: ACCESS_TOKEN
                  optional: true

            {{- /* for: nodepool operator */}}
            - name: "IAC_JOB_IMAGE"
              {{- $iacjobimageTag := .Values.operators.agentOperator.configuration.nodepools.iacJobImage.tag | default (include "image-tag" .) }}
              value: {{.Values.operators.agentOperator.configuration.nodepools.iacJobImage.repository}}:{{$iacjobimageTag}}

            - name: "K3S_JOIN_TOKEN"
              valueFrom:
                secretKeyRef:
                  name: k3s-params
                  key: k3s_agent_join_token

            - name: "K3S_SERVER_PUBLIC_HOST"
              valueFrom:
                secretKeyRef:
                  name: k3s-params
                  key: k3s_masters_public_dns_host

            - name: CLOUD_PROVIDER_NAME
              valueFrom:
                secretKeyRef:
                  name: k3s-params
                  key: cloudprovider_name

            - name: CLOUD_PROVIDER_REGION
              valueFrom:
                secretKeyRef:
                  name: k3s-params
                  key: cloudprovider_region

            - name: ENABLE_NODEPOOLS
              value: {{.Values.operators.agentOperator.configuration.nodepools.enabled | squote }}

            {{- if $hasAwsVPC }}
            - name: AWS_VPC_ID
              valueFrom:
                secretKeyRef:
                  name: {{.Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.name}}
                  key: {{.Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.keys.vpcId}}

            - name: AWS_VPC_PUBLIC_SUBNETS
              valueFrom:
                secretKeyRef:
                  name: {{.Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.name}}
                  key: {{.Values.operators.agentOperator.configuration.nodepools.aws.vpc_params.secret.keys.vpcPublicSubnets}}
            {{- end }}

            - name: KLOUDLITE_RELEASE
              value: {{include "image-tag" .}}

            {{- /* for: routers */}}
            - name: WORKSPACE_ROUTE_SWITCHER_SERVICE
              value: "env-route-switcher"

            - name: WORKSPACE_ROUTE_SWITCHER_PORT
              value: "80"

            - name: DEFAULT_CLUSTER_ISSUER
              value: {{ .Values.helmCharts.certManager.configuration.defaultClusterIssuer | quote }}

            - name: DEFAULT_INGRESS_CLASS
              value: "{{.Values.helmCharts.ingressNginx.configuration.ingressClassName}}"

            {{- /* for buildrun */}}
            - name: BUILD_NAMESPACE
              value: {{.Values.jobsNamespace}}

            {{- /* for wireguard controller */}}
            - name: CLUSTER_POD_CIDR
              value: {{.Values.operators.agentOperator.configuration.wireguard.podCIDR}}

            - name: CLUSTER_SVC_CIDR
              value: {{.Values.operators.agentOperator.configuration.wireguard.svcCIDR}}

            - name: DNS_HOSTED_ZONE
              valueFrom:
                secretKeyRef:
                  name: k3s-params
                  namespace: kloudlite
                  key: k3s_masters_public_dns_host

            {{ include "helmchart-operator-env" . | nindent 12 }}

          {{- $imageTag := .Values.operators.agentOperator.image.tag | default (include "image-tag" .) }}
          image: {{.Values.operators.agentOperator.image.repository}}:{{$imageTag}}
          imagePullPolicy: {{ include "image-pull-policy" $imageTag}}
          name: manager
          securityContext:
            allowPrivilegeEscalation: false
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8081
            initialDelaySeconds: 15
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /readyz
              port: 8081
            initialDelaySeconds: 5
            periodSeconds: 10
          resources:
            limits:
              cpu: 200m
              memory: 200Mi
            requests:
              cpu: 100m
              memory: 100Mi
      serviceAccountName: {{include "serviceAccountName" .}}
      terminationGracePeriodSeconds: 10

---

apiVersion: v1
kind: Service
metadata:
  name: {{$name}}-metrics-service
  namespace: {{.Release.Namespace}}
  labels: &labels
    app: {{$name}}
    control-plane: {{$name}}
spec:
  ports:
    - name: https
      port: 8443
      protocol: TCP
      targetPort: https
  selector: *labels
{{end}}
