# ============================================================
# Root Terraform Outputs
# F5 BNK Orchestrator for existing ROKS cluster
# ============================================================

# ============================================================
# Cluster Info (from data source lookup)
# ============================================================

output "cluster_id" {
  description = "ID of the target OpenShift cluster"
  value       = data.ibm_container_vpc_cluster.cluster.id
}

output "cluster_name" {
  description = "Name of the target OpenShift cluster"
  value       = data.ibm_container_vpc_cluster.cluster.name
}

output "cluster_crn" {
  description = "CRN of the target OpenShift cluster"
  value       = data.ibm_container_vpc_cluster.cluster.crn
}

output "cluster_vpc_id" {
  description = "ID of the cluster VPC (learned from cluster)"
  value       = data.ibm_is_vpc.cluster_vpc.id
}

output "cluster_vpc_name" {
  description = "Name of the cluster VPC (learned from cluster)"
  value       = data.ibm_is_vpc.cluster_vpc.name
}

output "cluster_vpc_crn" {
  description = "CRN of the cluster VPC (learned from cluster)"
  value       = data.ibm_is_vpc.cluster_vpc.crn
}

# ============================================================
# CNEInstance Outputs
# ============================================================

output "cneinstance_id" {
  description = "Name of the CNEInstance resource"
  value       = module.cneinstance.cneinstance_id
}

output "cneinstance_namespace" {
  description = "Namespace where CNEInstance is deployed"
  value       = module.cneinstance.cneinstance_namespace
}

output "cneinstance_pod_deployment_status" {
  description = "Pod deployment status after CNEInstance readiness validation"
  value       = module.cneinstance.pod_deployment_status
}
