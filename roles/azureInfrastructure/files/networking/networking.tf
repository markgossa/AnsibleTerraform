# Variables
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

variable "managementIP" {
    type = "string"
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
