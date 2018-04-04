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

# Configure the Azure Provider
provider "azurerm" { 
  subscription_id   = "${var.subscription_id}"
  client_id         = "${var.client_id}"
  tenant_id         = "${var.tenant_id}"
  client_secret     = "${var.client_secret}"
}

module "resourceGroup" {
    source                  = "resourceGroup/resourceGroup.tf"
    resourceGroupName       = "${var.resourceGroupName}"
    resourceGroupLocation   = "${var.resourceGroupLocation}"
}

module "storage" {
    source  = "storage/storage.tf"
}

module "networking" {
    source                        = "networking/networking.tf"
    virtualNetworkName            = "${var.virtualNetworkName}"
    virtualNetworkDnsServer1      = "${var.virtualNetworkDnsServer1}"
    virtualNetworkDnsServer2      = "${var.virtualNetworkDnsServer2}"
    virtualNetworkAddressSpace    = "${var.virtualNetworkAddressSpace}"
    subnetName                    = "${var.subnetName}"
    subnetNetworkID               = "${var.subnetNetworkID}"
    storageAccountTier            = "${var.storageAccountTier}"
    sotrageAccountReplicationType = "${var.sotrageAccountReplicationType}"
    storageAccountName            = "${var.storageAccountName}"
    managementIP                  = "${var.managementIP}"
}
