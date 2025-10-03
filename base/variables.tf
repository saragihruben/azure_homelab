variable "users" {
  type    = map(object({
    user_principal_name = string
    display_name        = string
    password            = string
  }))
  default = {}  # Empty map by default
}

variable "groups" {
  type    = map(object({
    display_name = string
  }))
  default = {}  # Empty map by default
}

variable "memberships" {
  description = "Mapping of user_id to group_id for group membership assignments"
  type        = map(object({
    user_id  = string
    group_id = string
  }))
  default     = {}
}