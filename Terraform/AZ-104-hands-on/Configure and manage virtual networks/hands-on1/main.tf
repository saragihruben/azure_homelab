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

# Define Resource Group
resource "azurerm_resource_group" "homelab" {
  name     = "homelab-terraform"
  location = "Japan East"
}

# Define Address Space 
resource "azurerm_virtual_network" "vnet_homelab" {
  name                = "vnet-homelab"
  location            = azurerm_resource_group.homelab.location
  resource_group_name = azurerm_resource_group.homelab.name
  address_space       = ["10.29.0.0/16"]

  tags = {
    environment = "lab"
    category    = "network"
  }
}

# Define Internal Subnet
resource "azurerm_subnet" "int_subnet_homelab" {
  name                 = "int-subnet-homelab"
  resource_group_name  = azurerm_resource_group.homelab.name
  virtual_network_name = azurerm_virtual_network.vnet_homelab.name
  address_prefixes     = ["10.29.0.0/24"]

  service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
}

# Define VPN Gateway Subnet
resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.vnet_homelab.name
  resource_group_name  = azurerm_resource_group.homelab.name
  address_prefixes     = ["10.29.1.0/24"]
}


# Define ContainerInstance Subnet
resource "azurerm_subnet" "aci_subnet_homelab" {
  name                 = "aci-subnet-homelab"
  resource_group_name  = azurerm_resource_group.homelab.name
  virtual_network_name = azurerm_virtual_network.vnet_homelab.name
  address_prefixes     = ["10.29.2.0/24"]

  delegation {
    name = "aci-delegation"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

## Output variables to display values after the execution

output "vnet_id" {
  value = azurerm_virtual_network.vnet_homelab.id
}

output "int_subnet_id" {
  value = azurerm_subnet.int_subnet_homelab.id
}

output "gateway_subnet_id" {
  value = azurerm_subnet.gateway_subnet.id
}

output "aci_subnet_id" {
  value = azurerm_subnet.aci_subnet_homelab.id
}
