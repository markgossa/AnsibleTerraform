# Variables
variable "resourceGroupName" {
    type = "string"
}

variable "resourceGroupLocation" {
    type = "string"
}

# Create a resource group
resource "azurerm_resource_group" "resourceGroup1" {
  name     = "${var.resourceGroupName}"
  location = "${var.resourceGroupLocation}"
}

# Outputs
output "resourceGroupName" {
    value = "${azurerm_resource_group.resourceGroup1.name}"
}

output "resourceGroupLocation" {
    value = "${azurerm_resource_group.resourceGroup1.location}"
}
