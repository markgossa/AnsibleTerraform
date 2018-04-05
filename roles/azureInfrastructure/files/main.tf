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

module "compute" {
    source                        = "compute"
    resourceGroupName             = "${module.resourceGroup.resourceGroupName}"
    resourceGroupLocation         = "${module.resourceGroup.resourceGroupLocation}"
    dc1Name                       = "${var.dc1Name}"
    dc1Size                       = "${var.dc1Size}"
    dc1DiskCaching                = "${var.dc1DiskCaching}"
    dc1ManagedDiskType            = "${var.dc1ManagedDiskType}"
    vmUserName                    = "${var.vmUserName}"
    vmPassword                    = "${var.vmPassword}"
    vmSku                         = "${var.vmSku}"
    dc1IPAddress                  = "${var.dc1IPAddress}"
    vmOffer                       = "${var.vmOffer}"
    subnetId                      = "${module.networking.subnetId}"
    virtualNetworkDnsServer1      = "${var.virtualNetworkDnsServer1}"
    virtualNetworkDnsServer2      = "${var.virtualNetworkDnsServer2}"
    vmList                        = "${var.vmList}"
}
