# IBM Provider - infrastructure and IAM resources
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibmcloud_cluster_region
}

# Fetch cluster credentials dynamically — no kubeconfig on disk required
data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.roks_cluster_name_or_id
  region          = var.ibmcloud_cluster_region
}

provider "kubernetes" {
  host                   = try(data.ibm_container_cluster_config.cluster_config.host, "")
  token                  = try(data.ibm_container_cluster_config.cluster_config.token, "")
  cluster_ca_certificate = try(base64decode(data.ibm_container_cluster_config.cluster_config.ca_certificate), null)
}
