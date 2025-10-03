## If running manually without pipeline dont forget to run this
# az login --service-principal --username "881f3a90-70fc-4a5c-af8e-dc9c44d97f31" --password "baf8Q~F759OM.o_Qxi7CgT7m94ZM2Mxg2HUCkazh" --tenant "b1300899-1d95-488c-aa1b-cd5323c7676b"
# $env:ARM_CLIENT_ID="881f3a90-70fc-4a5c-af8e-dc9c44d97f31"
# $env:ARM_CLIENT_SECRET="baf8Q~F759OM.o_Qxi7CgT7m94ZM2Mxg2HUCkazh"
# $env:ARM_SUBSCRIPTION_ID="6bbef8d1-9f53-4ce6-bf6c-ff06a0761e74"
# $env:ARM_TENANT_ID="b1300899-1d95-488c-aa1b-cd5323c7676b"

data "azurerm_key_vault" "example" {
  name                = "rootcertificates"
  resource_group_name = "homelab-terraform"
}

data "azurerm_key_vault_secret" "root_cert" {
  name         = "vpn-root-cert"
  key_vault_id = data.azurerm_key_vault.example.id
}

