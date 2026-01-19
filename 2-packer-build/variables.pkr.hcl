variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  default = "UK South"
  type    = string
}

variable "admin_username" {
  #default= "minikubeadmin" # see credentials.vars
  sensitive = false
  type      = string
}

variable "admin_password" {
  #default = "M!n!kub34dm!n" # see credentials.vars
  sensitive = false
  type      = string
}
