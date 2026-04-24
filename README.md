# BIG-IP Next for Kubernetes on IBM ROKS — BNK Deployment build 2.3.0-ehf-2-3.2598.3-0.0.17

## About This Workspace

This Schematics-ready Terraform workspace deploys F5 BIG-IP Next for Kubernetes onto an **existing** IBM Cloud ROKS (OpenShift) cluster. It does not create cluster infrastructure — provide the name or ID of a running ROKS cluster and the workspace installs all BNK components in the correct dependency order.

### Testable Deployment Features

#### What's New in 2.3.0-EHF-2-3.2598.3-0.0.17

- Static routing control of IBM Cloud VPC routers
- GSLB disaggregation ingress across IBM Cloud availability zones for BIG-IP Virtual Edition DNS Services
- External client service delivery through static VPC routes with attached IBM Cloud Transit Gateway
- Inter-VPC client service delivery through static VPC routes

The engineering demonstration code provides the ability to test the following BIG-IP Next for Kubernetes on IBM ROKS cluster features.

#### VPC Static Route Orchestration via F5 CWC

F5 CWC controls IBM Cloud VPC static routes, using f5-tmm pod Self-IP addresses as next-hop addresses for ingress Gateway listeners and as egress SNAT addresses.

#### BIG-IP VE DNS Services / GSLB Integration

BIG-IP Virtual Edition DNS Services provides GSLB access to BIG-IP Next for Kubernetes ingress Gateway listener IP addresses.

#### Transit Gateway Client Access

Ingress and egress flows from an external VPC connected via IBM Cloud Transit Gateway (TGW), using a test client jump host or other TGW-connected clients.

#### In-VPC Ingress from VSIs

Direct ingress from other Virtual Server Instances (VSIs) in the same VPC as the IBM ROKS cluster.

## Prerequisites for BIG-IP Virtual Edition DNS Service Testing

A VPC-deployed BIG-IP Virtual Edition with DNS Services enabled should be deployed in an external VPC and connected through an IBM Cloud TGW to the IBM ROKS cluster VPC.

A DNS Services GSLB Data Center must be deployed so that the BIG-IP Next for Kubernetes CWC controller can add Wide IPs and automate Wide IP pool membership with Gateway listener IP addresses.

The GSLB Data Center name will be required for the Terraform `cneinstance_gslb_datacenter_name` variable.

Additionally, the iControl REST credentials to access the BIG-IP DNS Services appliance will be required:

| Variable | Description | Example |
| -------- | ----------- | ------- |
| `bigip_username` | BIG-IP username for CIS controller login | admin (default) |
| `bigip_password` | BIG-IP password for CIS controller login | (sensitive) password |
| `bigip_url` | BIG-IP URL for CIS controller login | https://10.100.100.22 |

The CIS controller, deployed within the IBM ROKS cluster, must be able to resolve the URL host and reach the iControl REST endpoint in the BIG-IP DNS Services appliance.

## Deploying with IBM Schematics

### Required IBM Provider and IAM Variables

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `ibmcloud_api_key` | API Key used to authorize all deployment resources | REQUIRED | `0q7N3CzUn6oKxEsr7fLc1mxkukBeAEcsjNRQOg1kdDSY` (note: not a real API key) |
| `ibmcloud_cluster_region` | IBM Cloud region where the target cluster resides | REQUIRED with default defined | `ca-tor` (default) |
| `ibmcloud_resource_group` | IBM Cloud resource group name (leave empty to use account default) | Optional | `default` |

### Target Cluster Variables

This workspace deploys BNK onto an existing cluster. Cluster VPC information is discovered automatically from the cluster data source.

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `cluster_name_or_id` | Name or ID of the existing OpenShift ROKS cluster | REQUIRED | `my-openshift-cluster` |
| `transit_gateway_name` | Name of an existing Transit Gateway to look up | Optional | `my-tgw` |

Get your existing cluster name or ID:
```bash
ibmcloud ks clusters --provider vpc-gen2
```

### Feature Flag Variables

This deployment controls each BNK component independently through per-module feature flags. Deployment order is always: `cert-manager → flo → cneinstance → license`.

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `deploy_cert_manager` | Deploy cert-manager (required prerequisite for flo) | REQUIRED with default defined | true (default) |
| `deploy_flo` | Deploy F5 Lifecycle Operator | REQUIRED with default defined | true (default) |
| `deploy_cneinstance` | Deploy CNEInstance custom resource | REQUIRED with default defined | true (default) |
| `deploy_license` | Deploy F5 BNK License custom resource | REQUIRED with default defined | true (default) |

### Deployment Variables for BIG-IP Next for Kubernetes

Deploying BIG-IP Next for Kubernetes requires access to the F5 Artifact Repository (FAR software download) and a license JWT token (subscription license).

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `far_repo_url` | FAR Repository URL for Docker and Helm registry | REQUIRED with default defined | repo.f5.com (default) |
| `f5_bigip_k8s_manifest_version` | Version of f5-bigip-k8s-manifest chart to install | REQUIRED with default defined | 2.3.0-bnpp-ehf-2-3.2598.3-0.0.17 (default) |
| `license_mode` | License operation mode (connected or disconnected) | REQUIRED with default defined | connected (default) |

#### IBM COS for F5 Artifact Repository and License JWT Token

The FAR container pull credentials and JWT license token are fetched from an IBM Cloud Object Storage (COS) instance. Download these items from myf5.com and place them in a COS bucket before deploying.

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `ibmcloud_cos_bucket_region` | IBM Cloud region where the COS bucket is located | REQUIRED with default defined | us-south (default) |
| `ibmcloud_cos_instance_name` | IBM Cloud COS instance name | REQUIRED with default defined | bnk-orchestration (default) |
| `ibmcloud_resources_cos_bucket` | IBM Cloud COS bucket for file resources | REQUIRED with default defined | bnk-schematics-resources (default) |
| `f5_cne_far_auth_file` | FAR auth key filename in COS bucket (.tgz file from myf5.com) | REQUIRED with default defined | f5-far-auth-key.tgz (default) |
| `f5_cne_subscription_jwt_file` | Subscription JWT filename in COS bucket (.jwt file from myf5.com) | REQUIRED with default defined | trial.jwt (default) |

As an example using the variable defaults:

1. Create an IBM COS instance named `bnk-orchestration`
2. With a bucket named `bnk-schematics-resources` and then
3. Upload the FAR pull secret archive file `f5-far-auth-key.tgz` and
4. Upload the license JWT token file `trial.jwt`

```
bnk-orchestrator # IBM COS Instance
├── bnk-schematics-resources  # IBM COS Bucket
│   ├── f5-far-auth-key.tgz   # IBM COS Resource (key)
│   └── trial.jwt             # IBM COS Resource (key)
```

```bash
# Create the COS instance
ibmcloud resource service-instance-create bnk-orchestration cloud-object-storage standard global

# Create the COS bucket (replace RESOURCE_INSTANCE_ID with the CRN from the previous command)
ibmcloud cos bucket-create \
  --bucket bnk-schematics-resources \
  --ibm-service-instance-id RESOURCE_INSTANCE_ID \
  --region us-south

# Upload the FAR auth key archive
ibmcloud cos object-put \
  --bucket bnk-schematics-resources \
  --key f5-far-auth-key.tgz \
  --body ./f5-far-auth-key.tgz \
  --region us-south

# Upload the license JWT token
ibmcloud cos object-put \
  --bucket bnk-schematics-resources \
  --key trial.jwt \
  --body ./trial.jwt \
  --region us-south
```

#### Community Cert-Manager Certificate Management

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `cert_manager_namespace` | Kubernetes namespace for cert-manager | Optional | cert-manager (default) |
| `cert_manager_version` | Helm chart version | Optional | v1.17.3 (default) |

#### F5 Lifecycle Operator (FLO) Installer

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `flo_namespace` | Namespace for F5 Lifecycle Operator | Optional | f5-bnk (default) |

#### F5 Control Plane Shared Utilities

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `utils_namespace` | Namespace for F5 utility components | Optional | f5-utils (default) |

#### F5 CIS Controller

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `bigip_username` | BIG-IP username for CIS controller login | Optional | admin (default) |
| `bigip_password` | BIG-IP password for CIS controller login | Optional | (sensitive) |
| `bigip_url` | BIG-IP URL for CIS controller login | Optional | https://10.100.100.1 |

#### Deploy CNE Instance as a Gateway Provider

| Variable | Description | Required | Example |
| -------- | ----------- | -------- | ------- |
| `cneinstance_deployment_size` | Deployment size for CNEInstance | Optional | Small (default) |
| `cneinstance_gslb_datacenter_name` | GSLB datacenter name for CNEInstance | Optional | |
| `cneinstance_ibm_trusted_profile_id` | IBM Trusted Profile ID — only needed when `deploy_flo` is false | Optional | |

> When `deploy_flo = true`, the FLO module creates the IBM IAM Trusted Profile automatically and passes its ID to CNEInstance. Only set `cneinstance_ibm_trusted_profile_id` when skipping the FLO module and using an existing trusted profile.

## OCP Security Context Constraints Bindings Detail

BIG-IP Next for Kubernetes required bindings grant `system:openshift:scc:privileged` for the following resources:

| Module | Namespace | Service Accounts |
|--------|-----------|------------------|
| FLO | `f5-bnk` | `flo-f5-lifecycle-operator`, `f5-bigip-ctlr-serviceaccount`, `default` (CIS) |
| CNEInstance | `f5-bnk` | `tmm-sa`, `f5-dssm`, `f5-downloader`, `f5-afm`, `f5-cne-controller-*`, `f5-cne-env-discovery-serviceaccount` |
| CNEInstance | `f5-utils` | `crd-installer`, `cwc`, `f5-coremond`, `f5-rabbitmq`, `f5-observer-operator`, `f5-ipam-ctlr`, `otel-sa`, `f5-crdconversion`, `default` |

## Project Directory Structure

```
ibmcloud_schematics_bigip_next_for_kubernetes_2_3_roks_single_nic/
├── main.tf                    # Root module configuration
├── variables.tf               # Root module variables
├── outputs.tf                 # Root module outputs
├── providers.tf               # Provider configuration
├── data.tf                    # Data sources (cluster, VPC, transit gateway)
├── terraform.tfvars.example   # Example variable values
├── modules/
│   ├── cert-manager/          # Cert-manager module
│   │   ├── main.tf            # Cert-manager helm release and namespace
│   │   ├── variables.tf       # Cert-manager variables
│   │   └── outputs.tf         # Cert-manager outputs
│   ├── flo/                   # FLO (F5 Lifecycle Operator) module
│   │   ├── main.tf            # FLO deployment resources (includes CIS helm chart)
│   │   ├── variables.tf       # FLO module variables
│   │   ├── outputs.tf         # FLO module outputs
│   │   └── versions.tf        # FLO provider requirements
│   ├── cneinstance/           # CNEInstance deployment module
│   │   ├── main.tf            # CNEInstance custom resource
│   │   ├── variables.tf       # CNEInstance variables
│   │   ├── outputs.tf         # CNEInstance outputs
│   │   └── terraform.tf       # CNEInstance provider requirements
│   └── license/               # License CR module
│       ├── main.tf            # License CR resource
│       ├── variables.tf       # License module variables
│       ├── outputs.tf         # License module outputs
│       └── terraform.tf       # License provider requirements
```

## Module Dependency Chain

```
┌──────────────────────────────────┐
│  DATA SOURCES                    │
│  (Existing IBM Cloud Resources)  │
│                                  │
│  - Existing ROKS Cluster         │
│  - Cluster VPC (auto-discovered) │
│  - Transit Gateway (optional)    │
└─────────────┬────────────────────┘
              │ (provides kubeconfig)
              ▼
┌──────────────────────────────────┐
│  1. CERT-MANAGER                 │
│  (Certificate Management CRDs)   │
│                                  │
│  - Namespace                     │
│  - Helm Release                  │
│  - CRD Registration              │
└─────────────┬────────────────────┘
              │ (cert-manager.io CRDs: ClusterIssuer, Certificate)
              ▼
┌──────────────────────────────────┐
│  2. FLO                          │
│  (F5 Lifecycle Operator)         │
│                                  │
│  - Cert-Manager ClusterIssuer    │
│  - Certificates                  │
│  - NAD (Network Attachments)     │
│  - Node Labels                   │
│  - F5 Lifecycle Operator Helm    │
│  - F5 BNK CIS Helm               │
│  - BIG-IP Login Secret           │
│  - IBM IAM Trusted Profile       │
│  - privileged SCC (3 bindings)   │
└─────────────┬────────────────────┘
              │ (FLO deployed, CRDs ready)
              ▼
┌──────────────────────────────────┐
│  3. CNEINSTANCE                  │
│  (CNEInstance Deployment)        │
│                                  │
│  - CNEInstance Custom Resource   │
│  - privileged SCC (16 bindings)  │
│  - Pod Health Validation         │
└─────────────┬────────────────────┘
              │ (License CRD registered)
              ▼
┌──────────────────────────────────┐
│  4. LICENSE                      │
│  (F5 BNK License CR)             │
│                                  │
│  - License Custom Resource       │
│    (k8s.f5net.com/v1)            │
│  - JWT + Operation Mode          │
└──────────────────────────────────┘
```

## Local Host Installation & Deployment

### Why Four Separate Modules?

**Dependency Resolution**: Terraform validates CRDs during planning, not apply:
1. **Cert-Manager** must deploy first to register CRDs before FLO resources are validated
2. **FLO** must deploy second to register its CRD before CNEInstance is validated. Also deploys CIS, BIG-IP login secret, and IBM IAM Trusted Profile
3. **CNEInstance** deploys third after FLO is fully operational
4. **License** deploys fourth after CNEInstance registers the License CRD

This sequential approach avoids validation errors and ensures proper dependency ordering.

### Prerequisites

1. An existing IBM Cloud ROKS (OpenShift) cluster
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your values
3. Run `terraform init` to initialize all modules

Get your cluster name or ID:
```bash
ibmcloud ks clusters --provider vpc-gen2
```

### Recommended Deployment Order

#### Step 1: Deploy Cert-Manager (2–3 min)
```bash
terraform plan -target=module.cert_manager
terraform apply -target=module.cert_manager -auto-approve
```

#### Step 2: Deploy FLO — F5 Lifecycle Operator (5–10 min)
```bash
terraform plan -target=module.flo
terraform apply -target=module.flo -auto-approve
```

#### Step 3: Deploy CNEInstance (5–10 min)
```bash
terraform plan -target=module.cneinstance
terraform apply -target=module.cneinstance -auto-approve
```

#### Step 4: Deploy License (1–2 min)
```bash
terraform plan -target=module.license
terraform apply -target=module.license -auto-approve
```

### Deploying All Modules in One Step

```bash
terraform plan
terraform apply -auto-approve
```

### Cleanup (Reverse Order)

```bash
# Destroy in reverse dependency order
terraform destroy -target=module.license -auto-approve
terraform destroy -target=module.cneinstance -auto-approve
terraform destroy -target=module.flo -auto-approve
terraform destroy -target=module.cert_manager -auto-approve
```

## Configuration

### Module-Level Variables

#### Cert-Manager Module
- `enabled`: Enable/disable cert-manager deployment (controlled by `deploy_cert_manager`)
- `namespace`: Kubernetes namespace for cert-manager (default: `cert-manager`)
- `chart_version`: Helm chart version (default: `v1.17.3`)
- `chart_repository`: Helm repository URL (default: `https://charts.jetstack.io`)
- `wait_for_deployment`: Wait for deployment to be ready (default: true)
- `post_deployment_delay`: Time to wait after deployment for CRD registration (default: 30s)

#### FLO (F5 Lifecycle Operator) Module
- `enabled`: Enable/disable module (controlled by `deploy_flo`)
- `cert_manager_crd_ready`: **CRITICAL** — Dependency trigger from cert-manager module (ensures CRDs exist before plan validates manifests)
- `bigip_username`: BIG-IP username for CIS controller login (default: admin)
- `bigip_password`: BIG-IP password for CIS controller login (sensitive)
- `bigip_url`: BIG-IP URL for CIS controller login (`https://` prefix is stripped automatically)
- `nad_cni_type`: CNI type for Network Attachment Definition — `ipvlan` or `host-device` (default: `ipvlan`)
- `nad_interface_name`: Network interface name for NAD (default: `ens3`)
- `nad_ipvlan_mode`: IPVLAN mode — `l2` or `l3` (default: `l2`)

**IBM IAM Trusted Profile** (created by FLO module, passed to CNEInstance):
- `openshift_cluster_name`: Name of the OpenShift cluster — used to make the trusted profile name unique per cluster (sourced from cluster data source)
- `openshift_cluster_crn`: CRN of the OpenShift cluster — used to link the trusted profile to the ROKS service account `f5-cne-controller-<flo_namespace>-f5-cne-controller-serviceaccount` in `flo_namespace` (sourced from cluster data source)
- `cluster_vpc_id`: ID of the cluster VPC — grants the trusted profile Viewer and Editor IAM roles on this VPC (sourced from cluster data source)

> The trusted profile is created only when `enabled = true` and `openshift_cluster_crn` is non-empty. The resulting profile ID is output as `trusted_profile_id` and automatically passed to the CNEInstance module as `cneinstance_ibm_trusted_profile_id`.

**COS Bucket Integration** (FAR auth key and JWT fetched from IBM Cloud Object Storage):
- `ibmcloud_cos_bucket_region`: IBM Cloud region where the COS bucket is located (default: `us-south`)
- `ibmcloud_cos_instance_name`: IBM Cloud COS instance name (default: `bnk-orchestration`)
- `ibmcloud_resources_cos_bucket`: COS bucket name containing FAR auth key and JWT files (default: `bnk-schematics-resources`)
- `f5_cne_far_auth_file`: FAR auth key filename in COS bucket, must be `.tgz` (default: `f5-far-auth-key.tgz`)
- `f5_cne_subscription_jwt_file`: Subscription JWT filename in COS bucket (default: `trial.jwt`)

> The FLO module uses the IBM Cloud API key to exchange for an IAM token, then downloads the FAR auth key archive and JWT from the COS bucket via the S3 REST API. The `.tgz` archive is automatically extracted and the JSON key file inside is auto-detected. The JWT fetched from COS is passed to the License module.

#### CNEInstance Module
- `enabled`: Enable/disable module (controlled by `deploy_cneinstance`)
- `cneinstance_deployment_size`: Deployment size — `Small`, `Medium`, or `Large` (default: `Small`)
- `cneinstance_gslb_datacenter_name`: GSLB datacenter name (optional)
- `cneinstance_ibm_trusted_profile_id`: IBM Trusted Profile ID — auto-populated from FLO when `deploy_flo = true`
- `cneinstance_vpc_name`: VPC name — auto-discovered from cluster data source
- `cneinstance_cloud_region`: Cloud region — sourced from `ibmcloud_cluster_region`

#### License Module
- `enabled`: Enable/disable license deployment (controlled by `deploy_license`)
- `utils_namespace`: Namespace where License CR is deployed (default: `f5-utils`)
- `jwt_token`: JWT token for F5 license authentication — fetched from the COS bucket by the FLO module and passed automatically
- `license_mode`: License operation mode — `connected` or `disconnected` (default: `connected`)
- `cneinstance_dependency`: Explicit dependency on CNEInstance module

### Required Variables (terraform.tfvars)

```hcl
# IBM Cloud Credentials
ibmcloud_api_key        = "YOUR_API_KEY"
ibmcloud_cluster_region = "ca-tor"
ibmcloud_resource_group = ""

# Target Cluster (required)
cluster_name_or_id = "my-openshift-cluster"

# Transit Gateway (optional — leave empty to skip)
transit_gateway_name = ""

# Feature Flags
deploy_cert_manager = true
deploy_flo          = true
deploy_cneinstance  = true
deploy_license      = true

# FAR Registry
far_repo_url                  = "repo.f5.com"
f5_bigip_k8s_manifest_version = "2.3.0-bnpp-ehf-2-3.2598.3-0.0.17"

# COS Bucket — FAR auth key and JWT fetched from IBM COS
ibmcloud_cos_bucket_region    = "us-south"
ibmcloud_cos_instance_name    = "bnk-orchestration"
ibmcloud_resources_cos_bucket = "bnk-schematics-resources"
f5_cne_far_auth_file          = "f5-far-auth-key.tgz"
f5_cne_subscription_jwt_file  = "trial.jwt"

# Namespace Configuration
cert_manager_namespace = "cert-manager"
cert_manager_version   = "v1.17.3"
flo_namespace          = "f5-bnk"
utils_namespace        = "f5-utils"

# BIG-IP CIS (optional)
bigip_username = "admin"
bigip_password = "YOUR_BIGIP_PASSWORD"
bigip_url      = "https://your-bigip-url"

# License
license_mode = "connected"

# CNEInstance
cneinstance_deployment_size      = "Small"
cneinstance_gslb_datacenter_name = ""

# IBM Trusted Profile ID — only needed when deploy_flo = false
cneinstance_ibm_trusted_profile_id = ""
```

## Outputs

View all outputs:
```bash
terraform output                    # All outputs
terraform output cluster_id         # Specific output
```

| Output | Description |
| ------ | ----------- |
| `cluster_id` | ID of the target OpenShift cluster |
| `cluster_name` | Name of the target OpenShift cluster |
| `cluster_crn` | CRN of the target OpenShift cluster |
| `cluster_vpc_id` | ID of the cluster VPC (auto-discovered) |
| `cluster_vpc_name` | Name of the cluster VPC (auto-discovered) |
| `cluster_vpc_crn` | CRN of the cluster VPC (auto-discovered) |
| `transit_gateway_id` | ID of the Transit Gateway (empty when not specified) |
| `transit_gateway_crn` | CRN of the Transit Gateway (empty when not specified) |
| `cert_manager_namespace` | Namespace where cert-manager is deployed |
| `cert_manager_version` | Installed cert-manager Helm chart version |
| `flo_release_name` | Name of the f5-lifecycle-operator Helm release |
| `flo_namespace` | Namespace where f5-lifecycle-operator is installed |
| `flo_version` | Installed f5-lifecycle-operator version |
| `trusted_profile_id` | IBM IAM Trusted Profile ID created for the CNE controller service account |
| `flo_pod_deployment_status` | FLO pod deployment status |
| `cneinstance_id` | Name of the CNEInstance resource |
| `cneinstance_namespace` | Namespace where CNEInstance is deployed |
| `cneinstance_pod_deployment_status` | Pod deployment status after CNEInstance readiness validation |
| `license_id` | Name of the License custom resource |
| `license_namespace` | Namespace where the License CR is deployed |

## Debugging & Troubleshooting

**Plan all modules at once:**

`terraform plan` (no `-target`) plans every module together and is safe to run at any time against an existing deployment where all CRDs are already registered. Against a fresh cluster it will fail with "no matches for kind" errors because Terraform validates CRD-backed resources during planning before any modules have run. In that case, use the per-target plan commands below.

```bash
terraform plan
```

**View module-specific changes:**
```bash
terraform plan -target=module.cert_manager
terraform plan -target=module.flo
terraform plan -target=module.cneinstance
terraform plan -target=module.license
```

**List resources by module:**
```bash
terraform state list module.cert_manager
terraform state list module.flo
terraform state list module.cneinstance
terraform state list module.license
```

**Validate configuration:**
```bash
terraform validate
terraform state list
```

**Common issues:**

| Issue | Solution |
|-------|----------|
| "no matches for kind ClusterIssuer" during plan | Wait for cert-manager module. Follow step-by-step deployment order. |
| "no matches for kind CNEInstance" during plan | Wait for FLO module to deploy. CNEInstance CRD registered by FLO. |
| "no matches for kind License" during plan | Wait for CNEInstance module to deploy. License CRD registered by crd-installer. |
| "field manager conflict" on CNEInstance | The `force_conflicts = true` field_manager is already set. If it persists, check for manual edits to the CR. |
| "clusterrolebinding already exists" for SCC | The SCC binding was created by another module (e.g., CIS SCC in flo). Remove from cneinstance scc_policy_assignments if duplicate. |
| License CR stuck in "Registering" state | Verify the JWT token is valid and the cluster has internet access for `connected` mode. |
| Cluster not found | Verify `cluster_name_or_id` matches output of `ibmcloud ks clusters --provider vpc-gen2`. Ensure `ibmcloud_cluster_region` matches the cluster's region. |
| VPC lookup fails | The cluster VPC is auto-discovered from the cluster. Ensure the cluster is in `Running` state before applying. |
