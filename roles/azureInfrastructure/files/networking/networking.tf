# Create a virtual network
resource "azurerm_virtual_network" "network1" {
  name                              = "${var.virtualNetworkName}"
  address_space                     = ["${var.virtualNetworkAddressSpace}"]
  location                          = "${var.resourceGroupLocation}"
  resource_group_name               = "${var.resourceGroupName}"
  dns_servers                       = ["${var.virtualNetworkDnsServer1}", "${var.virtualNetworkDnsServer2}"]
}

# Create subnet
resource azurerm_subnet "subnet1" {
  name                              = "${var.subnetName}"
  address_prefix                    = "${var.subnetNetworkID}"
  resource_group_name               = "${var.resourceGroupName}"
  virtual_network_name              = "${azurerm_virtual_network.network1.name}"
  network_security_group_id         = "${azurerm_network_security_group.nsg1.id}"
}

# Create network security group
resource "azurerm_network_security_group" "nsg1" {
  name                              = "nsg1"
  resource_group_name               = "${var.resourceGroupName}"
  location                          = "${var.resourceGroupLocation}"

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
