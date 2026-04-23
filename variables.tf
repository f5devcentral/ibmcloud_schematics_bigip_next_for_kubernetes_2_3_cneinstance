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
  default     = ""
}

variable "cluster_name_or_id" {
  description = "Name or ID of the existing OpenShift ROKS cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name_or_id) > 0
    error_message = "cluster_name_or_id cannot be empty."
  }
}

variable "flo_namespace" {
  description = "Namespace where FLO is installed"
  type        = string
  default     = "f5-bnk"
}

variable "utils_namespace" {
  description = "Namespace for F5 utility components"
  type        = string
  default     = "f5-utils"
}

variable "f5_bigip_k8s_manifest_version" {
  description = "Version of the f5-bigip-k8s-manifest chart"
  type        = string
  default     = "2.3.0-bnpp-ehf-2-3.2598.3-0.0.17"
}

variable "far_repo_url" {
  description = "FAR Repository URL for Docker and Helm registry"
  type        = string
  default     = "repo.f5.com"
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

# ============================================================
# Outputs from the flo project — set these from:
#   terraform -chdir=../ibmcloud_schematics_bigip_next_for_kubernetes_2_3_flo output
# ============================================================

variable "cneinstance_ibm_trusted_profile_id" {
  description = "IBM Trusted Profile ID — from flo project output: trusted_profile_id"
  type        = string
}

variable "cluster_issuer_name" {
  description = "CA ClusterIssuer name — from flo project output: cluster_issuer_name"
  type        = string
  default     = "sample-issuer"
}

variable "cneinstance_network_attachments" {
  description = "Network attachment names — from flo project output: cneinstance_network_attachments"
  type        = list(string)
  default     = []
}
