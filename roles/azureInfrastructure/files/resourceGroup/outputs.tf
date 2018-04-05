output "resourceGroupName" {
    value = "${azurerm_resource_group.resourceGroup1.name}"
}

output "resourceGroupLocation" {
    value = "${azurerm_resource_group.resourceGroup1.location}"
}
