resource "azuread_user" "users" {
  for_each = var.users

  user_principal_name   = each.value.user_principal_name
  display_name          = each.value.display_name
  password              = each.value.password
  force_password_change = true
}

resource "azuread_group" "groups" {
  for_each       = var.groups
  display_name   = each.value.display_name
  security_enabled = true
}

resource "azuread_group_member" "memberships" {
  for_each = var.memberships

  group_object_id  = each.value.group_id
  member_object_id = each.value.user_id
  
}