data "azurerm_virtual_network" "vnet" {
  name                = "vnet-homelab"
  resource_group_name = "homelab-terraform"
}

data "azurerm_subnet" "int_subnet" {
  name                 = "int-subnet-homelab"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = "homelab-terraform"
}

data "azurerm_key_vault" "vault" {
  name                = "vm-cred-homelab" # replace with your Key Vault name
  resource_group_name = "homelab-terraform"
}

data "azurerm_key_vault_secret" "vm_username" {
  name         = "vm-admin-username" # replace with your secret name
  key_vault_id = data.azurerm_key_vault.vault.id
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password" # replace with your secret name
  key_vault_id = data.azurerm_key_vault.vault.id
}
