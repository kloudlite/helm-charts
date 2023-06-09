---
apiVersion: crds.kloudlite.io/v1
kind: ManagedResource
metadata:
  name: {{.Values.managedResources.financeRedis}}
  namespace: {{.Release.Namespace}}
  labels:
    
spec:
  inputs:
    keyPrefix: finance
  mresKind:
    kind: ACLAccount
  msvcRef:
    apiVersion: redis.msvc.kloudlite.io/v1
    kind: StandaloneService
    name: {{.Values.managedServices.redisSvc}}

---
