output "subnet_ids"{
    description = "서브넷 id"
    value = module.network.subnet_ids
}

output "vnet_id" {
    description = "vnet_id"
    value = module.network.vnet_id  
}

output "vm_public_ip_id" {
  value       = module.vm.public_ip_id
  description = "VM public IP (null if not created)"
}

output "agw_cert_secret_id" {
  description = "Certificate secret ID for the Application Gateway"
  value       = module.security.agw_cert_secret_id
}

output "managed_identity_id" {
  description = "User Assigned Managed Identity resource ID for the Application Gateway"
  value       = module.security.managed_identity_id
}
