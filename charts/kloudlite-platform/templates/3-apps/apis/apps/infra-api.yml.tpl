apiVersion: crds.kloudlite.io/v1
kind: App
metadata:
  name: infra-api
  namespace: {{.Release.Namespace}}
spec:
  serviceAccount: {{.Values.clusterSvcAccount}}

  {{ include "node-selector-and-tolerations" . | nindent 4 }}

  services:
    - port: 80
      targetPort: 3000
      name: http
      type: tcp

  containers:
    - name: main
      image: {{.Values.apps.infraApi.image}}
      imagePullPolicy: {{.Values.apps.infraApi.ImagePullPolicy | default .Values.imagePullPolicy }}
      
      resourceCpu:
        min: "50m"
        max: "100m"
      resourceMemory:
        min: "50Mi"
        max: "100Mi"

      env:
        {{- /* - key: FINANCE_GRPC_ADDR */}}
        {{- /*   value: http://{{.Values.apps.financeApi.name}}:3001 */}}
        - key: ACCOUNTS_GRPC_ADDR
          value: "accounts-api:3001"

{{/*        - key: INFRA_DB_NAME*/}}
{{/*          value: {{.Values.managedResources.infraDb}}*/}}

        - key: INFRA_DB_URI
          type: secret
          refName: "mres-infra-db-creds"
          refKey: URI

        - key: HTTP_PORT
          value: "3000"

        - key: GRPC_PORT
          value: 3001

        - key: COOKIE_DOMAIN
          value: "{{.Values.cookieDomain}}"

        - key: NATS_URL
          value: "nats://nats:4222"

        - key: ACCOUNT_COOKIE_NAME
          value: kloudlite-account

        - key: PROVIDER_SECRET_NAMESPACE
          value: {{.Release.Namespace}}

        - key: IAM_GRPC_ADDR
          value: "iam-api:3001"

        - key: VPN_DEVICES_MAX_OFFSET
          value: {{.Values.apps.consoleApi.configuration.vpnDevicesMaxOffset | squote}}

        - key: VPN_DEVICES_OFFSET_START
          value: {{.Values.apps.consoleApi.configuration.vpnDevicesOffsetStart | squote}}
      
        - key: AWS_ACCESS_KEY
          value: {{.Values.apps.infraApi.configuration.aws.accessKey}}

        - key: AWS_SECRET_KEY
          value: {{.Values.apps.infraApi.configuration.aws.secretKey}}

        - key: AWS_CF_STACK_S3_URL
          value: {{.Values.apps.infraApi.configuration.aws.cloudformation.stackS3URL}}

        - key: AWS_CF_PARAM_TRUSTED_ARN
          value: {{.Values.apps.infraApi.configuration.aws.cloudformation.params.trustedARN}}
        
        - key: AWS_CF_STACK_NAME_PREFIX
          value: {{.Values.apps.infraApi.configuration.aws.cloudformation.stackNamePrefix}}

        - key: AWS_CF_ROLE_NAME_PREFIX
          value: {{.Values.apps.infraApi.configuration.aws.cloudformation.roleNamePrefix}}

        - key: AWS_CF_INSTANCE_PROFILE_NAME_PREFIX
          value: {{.Values.apps.infraApi.configuration.aws.cloudformation.instanceProfileNamePrefix}}

        - key: PUBLIC_DNS_HOST_SUFFIX
          value: {{.Values.baseDomain}}


