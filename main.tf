terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
     time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Private DNS zones for private endpoints
resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_link" {
  name                  = "cosmos-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = module.network.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
  name                  = "blob-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = module.network.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_link" {
  name                  = "openai-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = module.network.vnet_id
}

module "network" {
  source              = "./modules/network"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "vnet-${var.project_name}"
  address_space       = ["10.0.0.0/16"]

subnets = [
    {
      name             = "subnet-agw"
      address_prefixes = ["10.0.1.0/24"]
      public = true
    },
    {
      name             = "subnet-web"
      address_prefixes = ["10.0.2.0/24"]
      public = false
    },
    {
      name             = "subnet-was"
      address_prefixes = ["10.0.3.0/24"]
      public = false
    },
    {
      name             = "subnet-db"
      address_prefixes = ["10.0.4.0/24"]
      public = false
    },
    {
      name             = "subnet-openai"
      address_prefixes = ["10.0.5.0/24"]
      public = false
      }
  ]
}


module "vm" {
  source              = "./modules/vm"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  vm_name        = "vm-${var.project_name}"
  vm_size        = "Standard_B1s"

  project_name        = var.project_name
  admin_username      = var.admin_username
  ssh_public_key      = file(var.ssh_public_key)
  subnet_id = module.network.subnet_ids["subnet-web"]
  nsg_id    = lookup(module.network.nsg_ids, "subnet-web", null)
  create_public_ip = true
}


module "agw" {
  source              = "./modules/agw"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  project_name = var.project_name
  subnet_id    = module.network.subnet_ids["subnet-agw"]

  agw_cert_secret_id   = module.security.agw_cert_secret_id
  managed_identity_id  = module.security.managed_identity_id
}


module "db" {
  source              = "./modules/db"

  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  project_name               = var.project_name
  subnet_id                  = module.network.subnet_ids["subnet-db"]
  cosmos_private_dns_zone_id = azurerm_private_dns_zone.cosmos.id
  blob_private_dns_zone_id   = azurerm_private_dns_zone.blob.id
}

module "security" {
  source              = "./modules/security"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  project_name = var.project_name
  tenant_id    = var.tenant_id
  managed_identity_name = "managed-${var.project_name}-identity"
  agw_cert_password = var.agw_cert_password
}

module "openai" {
  source              = "./modules/openai"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  project_name                = var.project_name
  subnet_id                   = module.network.subnet_ids["subnet-openai"]
  openai_private_dns_zone_id  = azurerm_private_dns_zone.openai.id
  openai_name                 = "openai-${var.project_name}"
}

module "function" {
  source              = "./modules/function"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  project_name = var.project_name

  log_analytics_workspace_name = "law-${var.project_name}"
  log_analytics_retention_in_days = 30

  storage_account_name       = module.db.storage_account_name
  storage_account_primary_access_key = module.db.storage_account_primary_access_key

  
}

module "apim" {
  source              = "./modules/apim"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  project_name     = var.project_name
}
