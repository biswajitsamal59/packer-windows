source "azure-arm" "windows" {
  managed_image_resource_group_name = var.resource_group
  managed_image_name                = "windows-vs2022-npm-maven-java"
  location                          = var.location

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"

  vm_size = "Standard_DS2_v2"

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "3m"
  winrm_username = "packer"

  allowed_inbound_ip_addresses = ["13.82.189.132"]
}