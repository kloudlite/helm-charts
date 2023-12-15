kubectl apply -f crds
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml
helm upgrade --install --namespace=testing --create-namespace testing . --set=operators.platformOperator.image=ghcr.io/kloudlite/operators/platform-operator:v1.0.5-nightly-test