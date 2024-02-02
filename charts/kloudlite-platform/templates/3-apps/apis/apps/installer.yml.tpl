apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: kl-installer
  namespace: {{.Release.Namespace}}
spec:
  {{ include "node-selector-and-tolerations" . | nindent 2 }}
  services:
    - port: 80
      targetPort: 3000
      name: grpc
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.klInstaller.image.repository}}:{{.Values.apps.klInstaller.image.tag | default (include "image-tag" .) }}
      imagePullPolicy: {{ include "image-pull-policy" .}}
      

