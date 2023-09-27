{{ if .Values.operators.project.enabled }}
{{ $name := .Values.operators.project.name }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{$name}}
  namespace: {{.Release.Namespace}}
  labels: &labels
    app: {{$name}}
    control-plane: {{$name}}
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

      {{- if .Values.tolerations }}
      tolerations: {{.Values.tolerations | toYaml | nindent 8}}
      {{- end }}

      {{- if .Values.nodeSelector}}
      nodeSelector: {{.Values.nodeSelector | toYaml | nindent 8}}
      {{- end }}

      {{- if .Values.preferOperatorsOnMasterNodes }}
      affinity:
        nodeAffinity: {{include "preferred-node-affinity-to-masters" . | nindent 10 }}
      {{- end }}


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

        - command:
            - /manager
          args:
            - --health-probe-bind-address=:8081
            - --metrics-bind-address=127.0.0.1:8080
            - --leader-elect
          env:
            - name: RECONCILE_PERIOD
              value: "30s"

            - name: MAX_CONCURRENT_RECONCILES
              value: "5"

            - name: DOCKER_SECRET_NAME
              value: {{.Values.defaultImagePullSecretName}}

            - name: ADMIN_ROLE_NAME
              value: ns-admin

            - name: SVC_ACCOUNT_NAME
              value: kloudlite-svc-account

            - name: OPERATORS_NAMESPACE
              value: {{.Release.Namespace}}
          
          image: {{.Values.operators.project.image}}
          imagePullPolicy: {{.Values.operators.project.ImagePullPolicy | default .Values.imagePullPolicy }}
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
              cpu: 40m
              memory: 40Mi
            requests:
              cpu: 20m
              memory: 20Mi
      serviceAccountName: {{.Values.svcAccountName}}
      terminationGracePeriodSeconds: 10

---

apiVersion: v1
kind: Service
metadata:
  labels: &labels
    app: {{$name}}
    control-plane: {{$name}}
  name: {{$name}}-metrics-service
  namespace: {{.Release.Namespace}}
spec:
  ports:
    - name: https
      port: 8443
      protocol: TCP
      targetPort: https
  selector: *labels
{{ end}}
