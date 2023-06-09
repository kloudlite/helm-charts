# kloudlite-agent

[kloudlite-agent](https://github.com/kloudlite.io/helm-charts/charts/kloudlite-agent) Kloudlite Agent to make your kubernetes cluster communicate securely with kloudlite control plane

![Version: 1.0.5-nightly](https://img.shields.io/badge/Version-1.0.5--nightly-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.5-nightly](https://img.shields.io/badge/AppVersion-1.0.5--nightly-informational?style=flat-square)

## Get Repo Info

```console
helm repo add kloudlite https://kloudlite.github.io/helm-charts
helm repo update
```

## Install Chart

**Important:** only helm3 is supported</br>
**Important:** [kloudlite-operators](../kloudlite-operators) must be installed beforehand</br>
**Important:** ensure kloudlite CRDs have been installed</br>

```console
helm install [RELEASE_NAME] kloudlite/kloudlite-agent --namespace [NAMESPACE]
```

The command deploys kloudlite-agent on the Kubernetes cluster in the default configuration.

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Installing Nightly Releases

To list all nightly versions (**NOTE**: nightly versions are suffixed by `-nightly`)

```console
helm search repo kloudlite/kloudlite-agent --devel
```

To install
```console
helm install  [RELEASE_NAME] kloudlite/kloudlite-agent --version [NIGHTLY_VERSION] --namespace [NAMESPACE] --create-namespace
```

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME] -n [NAMESPACE]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] kloudlite/kloudlite-agent --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values kloudlite/kloudlite-agent
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| accessToken | string | `""` | kloudlite issued access token (if already have) |
| accountName | string | `"‼️ Required"` | kloudlite account name |
| agent.enabled | bool | `true` | enable/disable kloudlite agent |
| agent.image | string | `"ghcr.io/kloudlite/agents/kl-agent:v1.0.5-nightly"` | kloudlite agent image name and tag |
| clusterIdentitySecretName | string | `"kl-cluster-identity"` | cluster identity secret name, which keeps cluster token and access token |
| clusterName | string | `"‼️ Required"` | kloudlite cluster name |
| clusterToken | string | `"‼️ Required"` | kloudlite issued cluster token |
| defaultImagePullSecretName | string | `"kl-image-pull-creds"` | default image pull secret name, defaults to kl-image-pull-creds |
| imagePullPolicy | string | `"Always"` | container image pull policy |
| messageOfficeGRPCAddr | string | `"message-office-api.dev.kloudlite.io:443"` | kloudlite message office api grpc address, should be in the form of 'grpc-host:grcp-port' |
| operators | object | `{"resourceWatcher":{"enabled":true,"image":"ghcr.io/kloudlite/agents/resource-watcher:v1.0.5-nightly"},"wgOperator":{"configuration":{"baseDomain":"<wg-base-domain>","nameserver":{"basicAuth":{"enabled":true,"password":"<dns-api-basic-auth-password>","username":"<dns-api-basic-auth-username>"},"endpoint":"<https://dns-api-endpoint>"},"podCidr":"10.42.0.0/16","svcCidr":"10.43.0.0/16"},"enabled":true,"image":"ghcr.io/kloudlite/agent/operator/wg:v1.0.5-nightly"}}` | configuration for different kloudlite operators used in this chart |
| operators.resourceWatcher.enabled | bool | `true` | enable/disable kloudlite resource watcher |
| operators.resourceWatcher.image | string | `"ghcr.io/kloudlite/agents/resource-watcher:v1.0.5-nightly"` | kloudlite resource watcher image name and tag |
| operators.wgOperator.configuration | object | `{"baseDomain":"<wg-base-domain>","nameserver":{"basicAuth":{"enabled":true,"password":"<dns-api-basic-auth-password>","username":"<dns-api-basic-auth-username>"},"endpoint":"<https://dns-api-endpoint>"},"podCidr":"10.42.0.0/16","svcCidr":"10.43.0.0/16"}` | wireguard configuration options |
| operators.wgOperator.configuration.baseDomain | string | `"<wg-base-domain>"` | baseDomain for wireguard service, to be exposed |
| operators.wgOperator.configuration.nameserver | object | `{"basicAuth":{"enabled":true,"password":"<dns-api-basic-auth-password>","username":"<dns-api-basic-auth-username>"},"endpoint":"<https://dns-api-endpoint>"}` | dns nameserver http endpoint |
| operators.wgOperator.configuration.nameserver.basicAuth | object | `{"enabled":true,"password":"<dns-api-basic-auth-password>","username":"<dns-api-basic-auth-username>"}` | basic auth configurations for dns nameserver http endpoint |
| operators.wgOperator.configuration.nameserver.basicAuth.enabled | bool | `true` | whether to enable basic auth for dns nameserver http endpoint |
| operators.wgOperator.configuration.nameserver.basicAuth.password | string | `"<dns-api-basic-auth-password>"` | if enabled, basic auth password for dns nameserver http endpoint |
| operators.wgOperator.configuration.nameserver.basicAuth.username | string | `"<dns-api-basic-auth-username>"` | if enabled, basic auth username for dns nameserver http endpoint |
| operators.wgOperator.configuration.podCidr | string | `"10.42.0.0/16"` | cluster pods CIDR range |
| operators.wgOperator.configuration.svcCidr | string | `"10.43.0.0/16"` | cluster services CIDR range |
| operators.wgOperator.enabled | bool | `true` | whether to enable wg operator |
| operators.wgOperator.image | string | `"ghcr.io/kloudlite/agent/operator/wg:v1.0.5-nightly"` | wg operator image and tag |
| svcAccountName | string | `"cluster-svc-account"` | k8s service account name, which all the pods installed by this chart uses |
