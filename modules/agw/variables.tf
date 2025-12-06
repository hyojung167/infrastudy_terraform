variable   "resource_group_name" {
    description = "The name of the resource group"
    type = string
  
}

variable   "location" {
    description = "The location of the resources"
    type = string 
}

variable "subnet_id" {
    description = "The ID of the subnet to attach the NIC"
    type        = string
    #subnet-agw의 ID가 들어감
}

variable "project_name" {
    description = "The project name"
    type = string
}

variable "sku_name" {
    description = "The SKU name for the Application Gateway"
    type = string
    default = "Standard_v1"
}

variable "capacity" {
    description = "The capacity for the Application Gateway"
    type = number
    default = 4
}

variable "managed_identity_id" {
    description = "The ID of the managed identity to be associated with the Application Gateway."
    type        = string
}

variable "agw_cert_secret_id" {
    description = "The secret ID of the Application Gateway certificate in Key Vault."
    type        = string
}