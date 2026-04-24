# ============================================================
# Root Terraform Outputs
# F5 BNK Orchestrator for existing ROKS cluster
# ============================================================

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
