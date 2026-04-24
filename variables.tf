# ============================================================
# Root Terraform Variables
# F5 BNK Orchestrator for existing ROKS cluster
# ============================================================


# ============================================================
# IBM Cloud Variables
# ============================================================

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the cluster resides"
  type        = string
  default     = "ca-tor"
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud Resource Group name (leave empty to use account default)"
  type        = string
  default     = "default"
}

# ============================================================
# Cluster Inputs
# ============================================================

variable "cluster_name_or_id" {
  description = "Name or ID of the existing OpenShift ROKS cluster to deploy BNK onto"
  type        = string

  validation {
    condition     = length(var.cluster_name_or_id) > 0
    error_message = "cluster_name_or_id cannot be empty — an existing cluster is required."
  }
}

# ============================================================
# FAR / Registry Configuration
# ============================================================

variable "far_repo_url" {
  description = "FAR Repository URL for Docker and Helm registry"
  type        = string
  default     = "repo.f5.com"
}

# ============================================================
# FLO Namespace Configuration
# ============================================================

variable "flo_namespace" {
  description = "Namespace for F5 Lifecycle Operator"
  type        = string
  default     = "f5-bnk"
}

variable "utils_namespace" {
  description = "Namespace for F5 utility components"
  type        = string
  default     = "f5-utils"
}


# ============================================================
# CNEInstance Configuration
# ============================================================

variable "f5_bigip_k8s_manifest_version" {
  description = "Version of f5-bigip-k8s-manifest chart - used by flo, cneinstance modules"
  type        = string
  default     = "2.3.0-bnpp-ehf-2-3.2598.3-0.0.17"
}

variable "cneinstance_deployment_size" {
  description = "Deployment size for CNEInstance (Small, Medium, Large)"
  type        = string
  default     = "Small"
}

variable "cneinstance_gslb_datacenter_name" {
  description = "GSLB datacenter name for CNEInstance (optional)"
  type        = string
  default     = ""
}

variable "cneinstance_network_attachments" {
  description = "The Multus Network Attachment Definitions for the CNEInstance TMM deployments"
  type = list(string)
  default = ["ens3-ipvlan-l2", "macvlan-conf"]
}

variable "trusted_profile_id" {
  description = "IBM IAM Trusted Profile ID for provisioning VPC routes"
  type = string
  default = ""
}

variable "cluster_issuer_name" {
  description = "mTLS certificate issuer name"
  type = string
  default = ""
}