terraform {
  required_version = ">= 1.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.60.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
  }
}

module "cneinstance" {
  source = "./modules/cneinstance"

  depends_on = [data.ibm_container_cluster_config.cluster_config]

  providers = {
    kubernetes = kubernetes
  }

  enabled = true

  flo_namespace   = var.flo_namespace
  utils_namespace = var.utils_namespace

  f5_bigip_k8s_manifest_version = var.f5_bigip_k8s_manifest_version
  cneinstance_gateway_api       = true
  cneinstance_whole_cluster     = true
  cneinstance_logging_subsystem = true
  cneinstance_metric_subsystem  = true
  cneinstance_deployment_size   = var.cneinstance_deployment_size
  cneinstance_dynamic_routing   = false
  cneinstance_firewall_acl      = true
  cneinstance_pseudocni         = true
  cneinstance_env_discovery     = false
  cneinstance_cloud_env         = true
  cneinstance_cloud_provider    = "ibm"

  cneinstance_vpc_name    = data.ibm_is_vpc.cluster_vpc.name
  cneinstance_cloud_region = var.ibmcloud_cluster_region

  cneinstance_ibm_trusted_profile_id = var.cneinstance_ibm_trusted_profile_id
  cneinstance_gslb_datacenter_name   = var.cneinstance_gslb_datacenter_name
  cneinstance_network_attachments    = var.cneinstance_network_attachments

  cluster_issuer_name = var.cluster_issuer_name
  far_repo_url        = var.far_repo_url
}
