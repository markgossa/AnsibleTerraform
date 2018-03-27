# Variables
variable "subscription_id" {
    type = "string"
}

variable "client_id" {
    type = "string"
}

variable "tenant_id" {
    type = "string"
}

variable "client_secret" {
    type = "string"
}

variable "resourceGroupName" {
    type = "string"
}

variable "resourceGroupLocation" {
    type = "string"
}
variable "virtualNetworkName" {
    type = "string"
}
variable "virtualNetworkAddressSpace" {
    type = "string"
}

variable "virtualNetworkDnsServer1" {
    type = "string"
}

variable "virtualNetworkDnsServer2" {
    type = "string"
}

variable "subnetName" {
    type = "string"
}

variable "subnetNetworkID" {
    type = "string"
}

variable "storageAccountTier" {
    type = "string"
}

variable "storageAccountReplicationType" {
    type = "string"
}

variable "storageAccountName" {
    type = "string"
}

variable "vm1Name" {
    type = "string"
}

variable "vm1Size" {
    type = "string"
}

variable "vm1DiskCaching" {
    type = "string"
}

variable "vm1ManagedDiskType" {
    type = "string"
}

variable "vmUserName" {
    type = "string"
}

variable "vmPassword" {
    type = "string"
}

variable "vmSku" {
    type = "string"
}

variable "vm1IPAddress" {
    type = "string"
}

# Configure the Azure Provider
provider "azurerm" { 
  subscription_id   = "${var.subscription_id}"
  client_id         = "${var.client_id}"
  tenant_id         = "${var.tenant_id}"
  client_secret     = "${var.client_secret}"
}

# Create a resource group
resource "azurerm_resource_group" "resourceGroup1" {
  name     = "${var.resourceGroupName}"
  location = "${var.resourceGroupLocation}"
}

# Create a virtual network
resource "azurerm_virtual_network" "network1" {
  name                = "${var.virtualNetworkName}"
  address_space       = ["${var.virtualNetworkAddressSpace}"]
  location            = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup1.name}"
  dns_servers         = "[${var.virtualNetworkDnsServer1}, ${var.virtualNetworkDnsServer1}]"
}

# Create subnet
resource azurerm_subnet "subnet1" {
    name                    = "${var.subnetName}"
    address_prefix          = "${var.subnetNetworkID}"
    resource_group_name     = "${azurerm_resource_group.resourceGroup1.name}"
    virtual_network_name    = "${azurerm_virtual_network.network1.name}"
}

# Create a storage account
resource "azurerm_storage_account" "storage" {
  resource_group_name       = "${azurerm_resource_group.resourceGroup1.name}"
  location                  = "${azurerm_resource_group.resourceGroup1.location}"
  account_tier              = "${var.storageAccountTier}"
  account_replication_type  = "${var.storageAccountReplicationType}"
  name                      = "${var.storageAccountName}"
}

# VM 1 - Create NIC
resource "azurerm_network_interface" "vm1" {
  name                = "nic1"
  location            = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name = "${azurerm_resource_group.resourceGroup1.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.vm1IPAddress}"
  }
}

# VM 1 - Create VM
resource "azurerm_virtual_machine" "vm1" {
  name                  = "${var.vm1Name}"
  location              = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name   = "${azurerm_resource_group.resourceGroup1.name}"
  network_interface_ids = ["${azurerm_network_interface.vm1.id}"]
  vm_size               = "${var.vm1Size}"
  
  storage_os_disk {
    name                = "${var.vm1Name}-OS"
    caching             = "${var.vm1DiskCaching}"
    create_option       = "FromImage"
    managed_disk_type   = "${var.vm1ManagedDiskType}"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "${var.vmSku}"
    version   = "latest"
  }

  os_profile_windows_config {
    
  }

  os_profile {
    computer_name  = "${var.vm1Name}"
    admin_username = "${var.vmUserName}"
    admin_password = "${var.vmPassword}"
  }
}

# VM 1 - Create VM extension to configure Ansible remoting
resource "azurerm_virtual_machine_extension" "vm1" {
  name                  = "ConfigureRemotingForAnsible"
  location              = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name   = "${azurerm_resource_group.resourceGroup1.name}"
  virtual_machine_name  = "${var.vm1Name}"
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.7"
  settings = <<SETTINGS
    {
        "fileUris": "[https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1]"
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1 -SkipNetworkProfileCheck -EnableCredSSP"
    }
  PROTECTED_SETTINGS
}