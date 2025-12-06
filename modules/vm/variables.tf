variable "resource_group_name" {
    description = "The name of the resource group in which to create the VM."
    type        = string
    default = "rg-study"
  
}

variable "location" {
    description = "The Azure region where the VM will be created."
    type        = string
    default = "korea central"
  
}

variable "vm_name" {
    description = "The name of the virtual machine."
    type        = string
  
}

variable "vm_size" {
    description = "The size of the virtual machine."
    type        = string
    default = "Standard_B1s"
  
}

variable "admin_username" {
    description = "The admin username for the virtual machine."
    type        = string
    default     = "azureuser"
  
}

variable "ssh_public_key" {
    description = "The SSH public key for the virtual machine."
    type        = string 
}



variable "subnet_id" {
    description = "subnet IDs to attach the VM's network interface to."
    type        = string
  
}

variable "nsg_id" {
    description = "Network Security Group ID to associate with the VM's network interface."
    type        = string
    default     = null
}

variable "create_public_ip" {
    description = "Whether to create a public IP for the VM."
    type        = bool
    default     = true
  
}

variable "project_name" {
    description = "The name of the project"
    type        = string
    default = "keepwise"
}

variable "public_lp_id" {
  description = "Public IP address ID to associate with the VM's network interface."
  type        = string
  default = null
}