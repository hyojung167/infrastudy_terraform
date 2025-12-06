variable "resource_group_name" {
  description = "The name of the resource group in which to create the VM."
  type        = string
}

variable "location" {
    description = "The Azure location where the VM will be created."
    type        = string
}

variable "project_name" {
    description = "The name of the project."
    type        = string
}

variable "managed_identity_name" {
    description = "The name of the managed identity to be associated with the VM."
    type        = string  
}

variable "key_vault_sku" {
    description = "The SKU of the Key Vault."
    type        = string
    default     = "standard"
}

variable "tenant_id" {
    description = "The Azure Active Directory tenant ID."
    type        = string
}

variable "agw_cert_password" {
    description = "The password for the Application Gateway certificate. (https only)"
    type        = string
    sensitive = true
  
}




