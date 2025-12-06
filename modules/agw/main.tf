resource "azurerm_public_ip" "agw_pip" {
  name                = "pip-agw-${var.project_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "agw" {
    name                = "agw-${var.project_name}"
    location            = var.location
    resource_group_name = var.resource_group_name

    identity {
        type = "UserAssigned"
        identity_ids = [var.managed_identity_id]
    }
    

    ssl_certificate {
        name                = "agw-ssl-cert"
        key_vault_secret_id = var.agw_cert_secret_id
    }

    sku {
        name     = "Standard_v2"
        tier     = "Standard_v2"
        capacity = 2
    }
    
    gateway_ip_configuration {
        name      = "agw-ipconfig"
        subnet_id = var.subnet_id
    }
    
    frontend_port {
        name = "agw-frontend-port-https"
        port = 443
    }
    
    frontend_ip_configuration {
        name                 = "agw-frontend-ip"
        public_ip_address_id = azurerm_public_ip.agw_pip.id
    }

    backend_address_pool {
        name = "agw-backend-pool"
    }

    backend_http_settings {
        name                  = "agw-backend-http"
        cookie_based_affinity = "Disabled"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 20
        probe_name            = "agw-health-probe"
        pick_host_name_from_backend_address = true
    }

    probe {
        name                = "agw-health-probe"
        protocol            = "Http"
        path                = "/"
        interval            = 30
        timeout             = 30
        unhealthy_threshold = 3
        port                = 80
        pick_host_name_from_backend_http_settings = true
    }

    http_listener {
        name                           = "agw-https-listener"
        frontend_ip_configuration_name = "agw-frontend-ip"
        frontend_port_name             = "agw-frontend-port-https"
        protocol                       = "Https"
        ssl_certificate_name           = "agw-ssl-cert"
    }

    request_routing_rule {
        name                       = "agw-routing-rule"
        rule_type                  = "Basic"
        http_listener_name         = "agw-https-listener"
        backend_address_pool_name  = "agw-backend-pool"
        backend_http_settings_name = "agw-backend-http"
        priority                   = 100
    } 
}
