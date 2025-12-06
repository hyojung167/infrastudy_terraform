resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = var.managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name 
}

resource "azurerm_key_vault" "key_vault" {
  name                        = "${var.project_name}-kv"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  sku_name                    = var.key_vault_sku
  tenant_id                   = var.tenant_id
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  rbac_authorization_enabled  = true

}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "tf_kv_cert_role" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# RBAC 전파 대기
resource "time_sleep" "wait_for_rbac" {
  depends_on      = [azurerm_role_assignment.tf_kv_cert_role]
  create_duration = "30s"
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

# cli에서 keyvault 배포 확인용 권한 부여 
resource "azurerm_role_assignment" "tf_kv_secret_reader" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User" # 또는 Reader
  principal_id         = data.azurerm_client_config.current.object_id
}




resource "azurerm_key_vault_certificate" "agw_cert" {
  name         = "agw-keepwise-cert"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [ time_sleep.wait_for_rbac ]

  certificate {
    contents = filebase64("/home/hyojung/certs/hyojung167.cloud/hyojung167-cloud-keepwise.pfx")
    password = var.agw_cert_password
  }

}
  