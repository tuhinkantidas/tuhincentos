variable "location" {
  description = "Azure region for the demo"
  type        = string
  default     = "Central India"
}
variable "resource_group_name" {
  description = "Dedicated resource group for this demo; cleanup deletes the whole group"
  type        = string
  default     = "rg-acc-azure-reliability"
}
variable "vm_name" {
  type    = string
  default = "acc-azure-demo-vm"
}
variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "admin_ssh_public_key" {
  description = "SSH public key contents; never provide a private key"
  type        = string
  sensitive   = true
}
variable "allowed_http_cidr" {
  description = "Your public IPv4 address with /32, e.g. 203.0.113.10/32"
  type        = string
}
variable "vm_size" {
  description = "Check regional availability and current Azure pricing before apply"
  type        = string
  default     = "Standard_B2s"
}
