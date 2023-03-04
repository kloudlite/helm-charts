---
apiVersion: crds.kloudlite.io/v1
kind: ManagedResource
metadata:
  name: {{.Values.managedResources.ciRedis}}
  namespace: {{.Release.Namespace}}
  labels:
    kloudlite.io/account-ref: {{.Values.accountName}}
spec:
  inputs:
    keyPrefix: ci
  mresKind:
    kind: ACLAccount
  msvcRef:
    apiVersion: redis.msvc.kloudlite.io/v1
    kind: StandaloneService
    name: {{.Values.managedServices.redisSvc}}

---
