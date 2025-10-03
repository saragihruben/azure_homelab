## If running manually without pipeline dont forget to run this
# az login --service-principal --username "881f3a90-70fc-4a5c-af8e-dc9c44d97f31" --password "baf8Q~F759OM.o_Qxi7CgT7m94ZM2Mxg2HUCkazh" --tenant "b1300899-1d95-488c-aa1b-cd5323c7676b"
# $env:ARM_CLIENT_ID="881f3a90-70fc-4a5c-af8e-dc9c44d97f31"
# $env:ARM_CLIENT_SECRET="baf8Q~F759OM.o_Qxi7CgT7m94ZM2Mxg2HUCkazh"
# $env:ARM_SUBSCRIPTION_ID="6bbef8d1-9f53-4ce6-bf6c-ff06a0761e74"
# $env:ARM_TENANT_ID="b1300899-1d95-488c-aa1b-cd5323c7676b"

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  vpn_client_configuration = {
    # Use address_space instead of address_pool
    address_space         = ["10.100.254.0/28"]  # Updated here
    vpn_client_protocols = ["IkeV2", "OpenVPN"]
    root_cert = {
      name             = "RootCertificates"
      public_cert_data = data.azurerm_key_vault_secret.root_cert.value
    }
  }
}


resource "azurerm_public_ip" "vpn_gateway_ip" {
  name                = "ip-public-vpngw-homelab"
  location            = "japan east"
  resource_group_name = "homelab-terraform"
  allocation_method   = "Static"
  sku                 = "Standard"

  # Add this line to specify zone(s)
  zones               = ["1"]

  tags = {
    environment = "lab"
    category    = "network"
  }
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-homelab"
  resource_group_name = "homelab-terraform"
}

data "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = "homelab-terraform"
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "vpn-gateway-homelab"
  location            = "japan east"
  resource_group_name = "homelab-terraform"
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  generation          = "Generation2"
  sku                 = "VpnGw2AZ"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_ip.id
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  vpn_client_configuration {
    address_space         = local.vpn_client_configuration.address_space
    vpn_client_protocols = local.vpn_client_configuration.vpn_client_protocols

    root_certificate {
      name             = local.vpn_client_configuration.root_cert.name
      public_cert_data = local.vpn_client_configuration.root_cert.public_cert_data
    }
  }

  tags = {
    environment = "lab"
    category    = "network"
  }
}