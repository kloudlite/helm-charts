{{- if .Values.serviceAccount.create }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{.Values.serviceAccount.name}}
  namespace: {{.Release.Namespace}}

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{.Release.Namespace}}-{{.Values.serviceAccount.name}}-rb
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: "ClusterRole"
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: {{.Values.serviceAccount.name}}
    namespace: {{.Release.Namespace}}
---

{{- end }}
