output "managed_identity_id" {
  description = "The ID of the managed identity associated with the VM."
  value       = azurerm_user_assigned_identity.managed_identity.id
}

output "managed_identity_principal_id" {
    description = "The principal ID of the managed identity associated with the VM."
    value       = azurerm_user_assigned_identity.managed_identity.principal_id
}

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault_url" {
    description = "The URL of the Key Vault."
    value       = azurerm_key_vault.key_vault.vault_uri
}

output "agw_cert_secret_id" {
    description = "The secret ID of the Application Gateway certificate(PFX) in Key Vault."
    value       = azurerm_key_vault_certificate.agw_cert.secret_id
}