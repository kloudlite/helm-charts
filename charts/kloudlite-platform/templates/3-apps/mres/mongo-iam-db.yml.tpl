---
apiVersion: crds.kloudlite.io/v1
kind: ManagedResource
metadata:
  name: iam-db
  namespace: {{.Release.Namespace}}
spec:
  resourceTemplate:
    apiVersion: mongodb.msvc.kloudlite.io/v1
    kind: Database

    msvcRef:
      apiVersion: mongodb.msvc.kloudlite.io/v1
      kind: StandaloneService
      name: mongo-svc

    spec:
      resourceName: iam-db
---
