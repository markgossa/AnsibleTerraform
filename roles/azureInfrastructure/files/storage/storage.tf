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
  resource_group_name       = "${var.resourceGroupName}"
  location                  = "${var.resourceGroupLocation}"
  account_tier              = "${var.storageAccountTier}"
  account_replication_type  = "${var.storageAccountReplicationType}"
  name                      = "${var.storageAccountName}"
  enable_blob_encryption    = "True"
  enable_file_encryption    = "True"
}
