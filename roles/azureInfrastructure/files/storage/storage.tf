# Variables
variable "resourceGroupName" {
    type = "string"
}

variable "resourceGroupLocation" {
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