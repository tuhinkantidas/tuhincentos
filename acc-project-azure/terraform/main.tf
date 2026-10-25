terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = null
}
resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location
  tags = { project = "acc-cloud-reliability", environment = "student-demo" }
}
resource "azurerm_virtual_network" "demo" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.30.0.0/16"]
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
}
resource "azurerm_subnet" "demo" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.demo.name
  virtual_network_name = azurerm_virtual_network.demo.name
  address_prefixes     = ["10.30.1.0/24"]
}
resource "azurerm_network_security_group" "demo" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  security_rule {
    name                       = "AllowHttpFromPresenterIP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = var.allowed_http_cidr
    destination_address_prefix = "*"
  }
}
resource "azurerm_public_ip" "demo" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_network_interface" "demo" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.demo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo.id
  }
}
resource "azurerm_network_interface_security_group_association" "demo" {
  network_interface_id      = azurerm_network_interface.demo.id
  network_security_group_id = azurerm_network_security_group.demo.id
}
resource "azurerm_linux_virtual_machine" "demo" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.demo.name
  location                        = azurerm_resource_group.demo.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.demo.id]
  custom_data                     = base64encode(file("${path.module}/cloud-init.sh"))
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  identity { type = "SystemAssigned" }
  boot_diagnostics {}
  tags = { project = "acc-cloud-reliability" }
}
output "resource_group_name" { value = azurerm_resource_group.demo.name }
output "vm_name" { value = azurerm_linux_virtual_machine.demo.name }
output "public_ip" { value = azurerm_public_ip.demo.ip_address }
output "application_url" { value = "http://${azurerm_public_ip.demo.ip_address}" }
