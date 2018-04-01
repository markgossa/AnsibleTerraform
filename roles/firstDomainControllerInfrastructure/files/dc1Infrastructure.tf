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

variable "virtualNetworkDnsServer1" {
    type = "string"
}

variable "virtualNetworkDnsServer2" {
    type = "string"
}

variable "virtualNetworkAddressSpace" {
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

variable "dc1Name" {
    type = "string"
}

variable "dc1Size" {
    type = "string"
}

variable "dc1DiskCaching" {
    type = "string"
}

variable "dc1ManagedDiskType" {
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

variable "dc1IPAddress" {
    type = "string"
}

variable "vmOffer" {
    type = "string"
}

variable "managementIP" {
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
  dns_servers         = ["${var.virtualNetworkDnsServer1}", "${var.virtualNetworkDnsServer2}"]
}

# Create subnet
resource azurerm_subnet "subnet1" {
  name                    = "${var.subnetName}"
  address_prefix          = "${var.subnetNetworkID}"
  resource_group_name     = "${azurerm_resource_group.resourceGroup1.name}"
  virtual_network_name    = "${azurerm_virtual_network.network1.name}"
  network_security_group_id = "${azurerm_network_security_group.nsg1.id}"
}

# Create a storage account
resource "azurerm_storage_account" "storage" {
  resource_group_name       = "${azurerm_resource_group.resourceGroup1.name}"
  location                  = "${azurerm_resource_group.resourceGroup1.location}"
  account_tier              = "${var.storageAccountTier}"
  account_replication_type  = "${var.storageAccountReplicationType}"
  name                      = "${var.storageAccountName}"
  enable_blob_encryption    = "True"
  enable_file_encryption    = "True"
}

# Create network security group
resource "azurerm_network_security_group" "nsg1" {
  name                      = "nsg1"
  resource_group_name       = "${azurerm_resource_group.resourceGroup1.name}"
  location                  = "${azurerm_resource_group.resourceGroup1.location}"

  security_rule {
      name                          = "RDP"
      protocol                      = "TCP"
      destination_port_range        = "3389"
      destination_address_prefix    = "${var.subnetNetworkID}"
      source_address_prefix         = "${var.managementIP}"
      direction                     = "inbound"
      access                        = "allow"
      priority                      = "101"
      source_port_range             = "*"
  }

  security_rule {
      name                          = "WinRM"
      protocol                      = "TCP"
      destination_port_range        = "5986"
      destination_address_prefix    = "${var.subnetNetworkID}"
      source_address_prefix         = "${var.managementIP}"
      direction                     = "inbound"
      access                        = "allow"
      priority                      = "102"
      source_port_range             = "*"
  }
}

# VM 1 - Create NIC
resource "azurerm_network_interface" "dc1" {
  name                      = "${var.dc1Name}-nic1"
  location                  = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name       = "${azurerm_resource_group.resourceGroup1.name}"
  dns_servers               = ["8.8.8.8"]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.dc1IPAddress}"
    public_ip_address_id          = "${azurerm_public_ip.dc1.id}"
  }
}

# VM 1 - Create public IP
resource "azurerm_public_ip" "dc1" {
  name                         = "${var.dc1Name}-public-ip"
  location                     = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name          = "${azurerm_resource_group.resourceGroup1.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30
  domain_name_label            = "${var.dc1Name}-azurevm"
}

# VM 1 - Create VM
resource "azurerm_virtual_machine" "dc1" {
  name                  = "${var.dc1Name}"
  location              = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name   = "${azurerm_resource_group.resourceGroup1.name}"
  network_interface_ids = ["${azurerm_network_interface.dc1.id}"]
  vm_size               = "${var.dc1Size}"
  
  storage_os_disk {
    name                = "${var.dc1Name}-c"
    caching             = "${var.dc1DiskCaching}"
    create_option       = "FromImage"
    managed_disk_type   = "${var.dc1ManagedDiskType}"
    disk_size_gb        = "128"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "${var.vmOffer}"
    sku       = "${var.vmSku}"
    version   = "latest"
  }

  os_profile_windows_config {
    provision_vm_agent  = "True"
  }

  os_profile {
    computer_name       = "${var.dc1Name}"
    admin_username      = "${var.vmUserName}"
    admin_password      = "${var.vmPassword}"
  }
}

# VM 1 - Create VM extension to configure Ansible remoting
resource "azurerm_virtual_machine_extension" "dc1" {
  name                       = "ConfigureRemotingForAnsible"
  location                   = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name        = "${azurerm_resource_group.resourceGroup1.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.dc1.name}"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version =  true
  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1 -SkipNetworkProfileCheck -EnableCredSSP"
    }
  PROTECTED_SETTINGS
}

# Modify DNS servers on virtual network
resource "azurerm_network_interface" "dc1-update" {
  name                      = "${var.dc1Name}-nic1"
  location                  = "${azurerm_resource_group.resourceGroup1.location}"
  resource_group_name       = "${azurerm_resource_group.resourceGroup1.name}"
  dns_servers               = ["${var.virtualNetworkDnsServer1}", "${var.virtualNetworkDnsServer2}"]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "static"
  }

  depends_on          = ["azurerm_virtual_machine_extension.dc1"]
}
