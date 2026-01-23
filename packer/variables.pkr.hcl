variable "minikube_subscription_id" {
  type = string
}

variable "minikube_resource_group" {
  type = string
}

variable "minikube_shared_image_gallery" {
  type = string
}

variable "vm_image_name" {
  type = string
}

variable "vm_image_version" {
  type = string
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
