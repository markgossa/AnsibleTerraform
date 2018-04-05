# VM 1 - Create NIC
resource "azurerm_network_interface" "vm" {
  name                      = "${var.dc1Name}-nic1"
  location                  = "${var.resourceGroupLocation}"
  resource_group_name       = "${var.resourceGroupName}"
  dns_servers               = ["${var.virtualNetworkDnsServer1}", "${var.virtualNetworkDnsServer2}"]

  ip_configuration {
    name                          = "ipconfig1"
    subnetId                      = "${var.subnetId}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.dc1IPAddress}"
    public_ip_address_id          = "${azurerm_public_ip.vm.id}"
  }
}

# VM 1 - Create public IP
resource "azurerm_public_ip" "vm" {
  name                         = "${var.dc1Name}-public-ip"
  location                     = "${var.resourceGroupLocation}"
  resource_group_name          = "${var.resourceGroupName}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30
  domain_name_label            = "${var.dc1Name}-azurevm"
}

# VM 1 - Image details
data "azurerm_image" "image" {
  name                = "contdc01-image-1709-dns"
  resource_group_name = "Data"
}

# VM 1 - Create VM
resource "azurerm_virtual_machine" "vm" {
  name                              = "${var.dc1Name}"
  location                          = "${var.resourceGroupLocation}"
  resource_group_name               = "${var.resourceGroupName}"
  network_interface_ids             = ["${azurerm_network_interface.vm.id}"]
  vm_size                           = "${var.dc1Size}"
  delete_os_disk_on_termination     = "True"
  delete_data_disks_on_termination  = "True"
  
  storage_image_reference {
    id="${data.azurerm_image.image.id}"
  }

  storage_os_disk {
    name                = "${var.dc1Name}-c"
    caching             = "${var.dc1DiskCaching}"
    create_option       = "FromImage"
    managed_disk_type   = "${var.dc1ManagedDiskType}"
    disk_size_gb        = "128"
  }

  os_profile_windows_config {
    provision_vm_agent  = "True"
  }

  os_profile {
    computer_name       = "${var.dc1Name}"
    admin_username      = "${var.vmUserName}"
    admin_password      = "${var.vmPassword}"
  }
}

# VM 1 - Create VM extension to configure Ansible remoting
resource "azurerm_virtual_machine_extension" "vm" {
  name                       = "ConfigureRemotingForAnsible"
  location                   = "${var.resourceGroupLocation}"
  resource_group_name        = "${var.resourceGroupName}"
  virtual_machine_name       = "${azurerm_virtual_machine.vm.name}"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.7"
  auto_upgrade_minor_version =  true
  settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"]
    }
  SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1 -SkipNetworkProfileCheck -EnableCredSSP -ForceNewSSLCert"
    }
  PROTECTED_SETTINGS
}
