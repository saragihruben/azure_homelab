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
      version = ">= 3.75.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "Japan East"
}

resource "azurerm_network_interface" "homelab_nic" {
  name                = "nic-homelab"
  location            = var.location
  resource_group_name = "homelab-terraform"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.int_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "homelab"
  }
}

resource "azurerm_network_security_group" "homelab_nsg" {
  name                = "nsg-homelab"
  location            = var.location
  resource_group_name = "homelab-terraform"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.homelab_nic.id
  network_security_group_id = azurerm_network_security_group.homelab_nsg.id
}

resource "azurerm_linux_virtual_machine" "homelab_vm" {
  name                = "homelab-vm"
  resource_group_name = "homelab-terraform"
  location            = var.location
  size                = "Standard_B2as_v2"
  admin_username      = data.azurerm_key_vault_secret.vm_username.value
  admin_password      = data.azurerm_key_vault_secret.vm_password.value
  network_interface_ids = [azurerm_network_interface.homelab_nic.id]
  zone                = "1"

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "homelab-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 64
  }

  tags = {
    environment = "homelab"
  }
}
