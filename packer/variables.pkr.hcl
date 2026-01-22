variable "minikube_subscription_id" {
  type = string
}

variable "minikube_resource_group" {
  type = string
}

variable "minikube_shared_image_gallery" {
  type = string
  default = "minikube" # TODO: Parametrize this in here and gallery.bicep template
}

variable "vm_image_name" {
  type = string
  default = "minikube-windows-11-ci" # TODO: Load from env and Bicep parmeter accordingly?
}

variable "vm_image_version" {
  type      = string
  default   = "1.0.0"
}

variable "vm_admin_username" {
  default   = "minikubeadmin"
  sensitive = false
  type      = string
}

variable "vm_admin_password" {
  default   = "M!n!kub34dm!n"
  sensitive = false
  type      = string
}
