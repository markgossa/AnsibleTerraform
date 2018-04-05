# Create a resource group
resource "azurerm_resource_group" "resourceGroup1" {
  name     = "${var.resourceGroupName}"
  location = "${var.resourceGroupLocation}"
}
