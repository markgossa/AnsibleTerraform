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

variable "managementIP" {
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

# Configure the Azure Provider
provider "azurerm" { 
  subscription_id                 = "${var.subscription_id}"
  client_id                       = "${var.client_id}"
  tenant_id                       = "${var.tenant_id}"
  client_secret                   = "${var.client_secret}"
}

# Create infrastructure
module "resourceGroup" {
    source                        = "resourceGroup"
    resourceGroupName             = "${var.resourceGroupName}"
    resourceGroupLocation         = "${var.resourceGroupLocation}"
}

module "storage" {
    source                        = "storage"   
    resourceGroupName             = "${module.resourceGroup.resourceGroupName}"
    resourceGroupLocation         = "${module.resourceGroup.resourceGroupLocation}"
    storageAccountTier            = "${var.storageAccountTier}"
    storageAccountReplicationType = "${var.storageAccountReplicationType}"
    storageAccountName            = "${var.storageAccountName}"

}

module "networking" {
    source                        = "networking"
    resourceGroupName             = "${module.resourceGroup.resourceGroupName}"
    resourceGroupLocation         = "${module.resourceGroup.resourceGroupLocation}"
    virtualNetworkName            = "${var.virtualNetworkName}"
    virtualNetworkDnsServer1      = "${var.virtualNetworkDnsServer1}"
    virtualNetworkDnsServer2      = "${var.virtualNetworkDnsServer2}"
    virtualNetworkAddressSpace    = "${var.virtualNetworkAddressSpace}"
    subnetName                    = "${var.subnetName}"
    subnetNetworkID               = "${var.subnetNetworkID}"
    managementIP                  = "${var.managementIP}"
}
