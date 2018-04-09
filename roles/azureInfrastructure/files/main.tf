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

module "dc1_compute" {
    source                        = "compute"
    resourceGroupName             = "${module.resourceGroup.resourceGroupName}"
    resourceGroupLocation         = "${module.resourceGroup.resourceGroupLocation}"
    vmSize                        = "${var.vmSize}"
    vmDiskCaching                 = "${var.vmDiskCaching}"
    vmManagedDiskType             = "${var.vmManagedDiskType}"
    vmUserName                    = "${var.vmUserName}"
    vmPassword                    = "${var.vmPassword}"
    vmSku                         = "${var.dcVMSku}"
    vmOffer                       = "${var.dcVMOffer}"
    subnetId                      = "${module.networking.subnetId}"
    virtualNetworkDnsServer1      = "${var.virtualNetworkDnsServer1}"
    virtualNetworkDnsServer2      = "${var.virtualNetworkDnsServer2}"
    vmName                        = "${var.dc1Name}"
    vmIPAddress                   = "${var.dc1IPAddress}"
    vmCustomImage                 = "${var.dcVMCustomImage}"
}

module "dc2_compute" {
    source                        = "compute"
    resourceGroupName             = "${module.resourceGroup.resourceGroupName}"
    resourceGroupLocation         = "${module.resourceGroup.resourceGroupLocation}"
    vmSize                        = "${var.vmSize}"
    vmDiskCaching                 = "${var.vmDiskCaching}"
    vmManagedDiskType             = "${var.vmManagedDiskType}"
    vmUserName                    = "${var.vmUserName}"
    vmPassword                    = "${var.vmPassword}"
    vmSku                         = "${var.dcVMSku}"
    vmOffer                       = "${var.dcVMOffer}"
    subnetId                      = "${module.networking.subnetId}"
    virtualNetworkDnsServer1      = "${var.virtualNetworkDnsServer1}"
    virtualNetworkDnsServer2      = "${var.virtualNetworkDnsServer2}"
    vmName                        = "${var.dc2Name}"
    vmIPAddress                   = "${var.dc2IPAddress}"
    vmCustomImage                 = "${var.dcVMCustomImage}"
}

module "web1_compute" {
    source                        = "compute"
    resourceGroupName             = "${module.resourceGroup.resourceGroupName}"
    resourceGroupLocation         = "${module.resourceGroup.resourceGroupLocation}"
    vmSize                        = "${var.vmSize}"
    vmDiskCaching                 = "${var.vmDiskCaching}"
    vmManagedDiskType             = "${var.vmManagedDiskType}"
    vmUserName                    = "${var.vmUserName}"
    vmPassword                    = "${var.vmPassword}"
    vmSku                         = "${var.webVMSku}"
    vmOffer                       = "${var.webVMOffer}"
    subnetId                      = "${module.networking.subnetId}"
    virtualNetworkDnsServer1      = "${var.virtualNetworkDnsServer1}"
    virtualNetworkDnsServer2      = "${var.virtualNetworkDnsServer2}"
    vmName                        = "${var.web1Name}"
    vmIPAddress                   = "${var.web1IPAddress}"
    vmCustomImage                 = "${var.webVMCustomImage}"
}
