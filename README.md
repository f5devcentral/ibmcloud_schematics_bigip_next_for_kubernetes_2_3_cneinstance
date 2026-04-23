# BIG-IP Next for Kubernetes 2.3 — Step 3: CNEInstance

## About This Workspace

Deploys the CNEInstance custom resource and applies privileged SCC bindings required by BIG-IP Next for Kubernetes. This is the third step in the deployment sequence.

The FLO workspace **must be fully applied** before this workspace is planned or applied. The CNEInstance CRD is registered by FLO, and three output values from the FLO workspace are required as inputs here.

## Deployment Sequence

```
Step 1 → cert-manager
Step 2 → flo
Step 3 → cneinstance   (this workspace)
Step 4 → license
```

## What This Workspace Deploys

- CNEInstance custom resource (BIG-IP Next for Kubernetes gateway provider)
- Privileged SCC bindings (16 service accounts across `f5-bnk` and `f5-utils` namespaces)
- Pod readiness validation

## Prerequisites

- FLO workspace applied (Step 2)
- Three output values from the FLO workspace:

```bash
cd ../ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo

terraform output trusted_profile_id
terraform output cluster_issuer_name
terraform output cneinstance_network_attachments
```

Set these as the `cneinstance_ibm_trusted_profile_id`, `cluster_issuer_name`, and `cneinstance_network_attachments` variables in `terraform.tfvars`.

## Variables

### IBM Cloud / Cluster

| Variable | Description | Required | Default |
| -------- | ----------- | -------- | ------- |
| `ibmcloud_api_key` | IBM Cloud API Key | REQUIRED | |
| `ibmcloud_cluster_region` | IBM Cloud region where the cluster resides | REQUIRED with default | `ca-tor` |
| `ibmcloud_resource_group` | IBM Cloud Resource Group name | Optional | `""` |
| `cluster_name_or_id` | Name or ID of the existing OpenShift ROKS cluster | REQUIRED | |

### Namespaces / Registry

| Variable | Description | Required | Default |
| -------- | ----------- | -------- | ------- |
| `flo_namespace` | Namespace where FLO is installed | Optional | `f5-bnk` |
| `utils_namespace` | Namespace for F5 utility components | Optional | `f5-utils` |
| `f5_bigip_k8s_manifest_version` | f5-bigip-k8s-manifest chart version | REQUIRED with default | `2.3.0-bnpp-ehf-2-3.2598.3-0.0.17` |
| `far_repo_url` | FAR Repository URL | REQUIRED with default | `repo.f5.com` |

### CNEInstance Configuration

| Variable | Description | Required | Default |
| -------- | ----------- | -------- | ------- |
| `cneinstance_deployment_size` | Deployment size (Small, Medium, Large) | Optional | `Small` |
| `cneinstance_gslb_datacenter_name` | GSLB datacenter name | Optional | `""` |

### Values from FLO Workspace Outputs

| Variable | Description | Required | Source |
| -------- | ----------- | -------- | ------ |
| `cneinstance_ibm_trusted_profile_id` | IBM Trusted Profile ID | REQUIRED | flo output: `trusted_profile_id` |
| `cluster_issuer_name` | CA ClusterIssuer name | REQUIRED with default | flo output: `cluster_issuer_name` |
| `cneinstance_network_attachments` | Network attachment names | Optional | flo output: `cneinstance_network_attachments` |

## OCP Security Context Constraints Bindings

Privileged SCC bindings applied by this workspace:

| Namespace | Service Accounts |
|-----------|------------------|
| `f5-bnk` | `tmm-sa`, `f5-dssm`, `f5-downloader`, `f5-afm`, `f5-cne-controller-*`, `f5-cne-env-discovery-serviceaccount` |
| `f5-utils` | `crd-installer`, `cwc`, `f5-coremond`, `f5-rabbitmq`, `f5-observer-operator`, `f5-ipam-ctlr`, `otel-sa`, `f5-crdconversion`, `default` |

## Outputs

| Output | Description |
| ------ | ----------- |
| `cneinstance_id` | Name of the CNEInstance resource |
| `cneinstance_namespace` | Namespace where CNEInstance is deployed |
| `cneinstance_pod_deployment_status` | Pod deployment status after readiness validation |

## Deployment

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Cleanup

```bash
terraform destroy -auto-approve
```

## Project Directory Structure

```
ibmcloud_schematics_bigip_next_for_kubernetes_2_3_cneinstance/
├── main.tf                   # Calls CNEInstance module
├── variables.tf              # Input variables
├── outputs.tf                # Outputs
├── providers.tf              # IBM, kubernetes providers
├── data.tf                   # Cluster, VPC, subnet data sources
├── terraform.tfvars.example  # Example variable values
└── modules/
    └── cneinstance/
        ├── main.tf           # CNEInstance CR, SCC bindings, pod validation
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tf
```
