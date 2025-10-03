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

resource "azurerm_storage_account" "file_storage" {
  name                     = "azfilesharehomelab"
  resource_group_name      = "homelab-terraform"
  location                 = "japan east"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Cool"
  min_tls_version          = "TLS1_2"
  large_file_share_enabled = true

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [data.azurerm_subnet.int_subnet.id]
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  share_properties {
    retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "lab"
    category    = "storage"
  }
}

# Networking dependencies

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-homelab"
  resource_group_name = "homelab-terraform"
}

data "azurerm_subnet" "int_subnet" {
  name                 = "int-subnet-homelab"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = "homelab-terraform"
}

# File share creation
resource "azurerm_storage_share" "nfs_share" {
  name                 = "nfs-homelab"
  storage_account_id = azurerm_storage_account.file_storage.id
  quota                = 5120 # in GiB (5 TiB)
  enabled_protocol     = "SMB" # NFS not available via azurerm_storage_share yet

  depends_on = [azurerm_storage_account.file_storage]
}
