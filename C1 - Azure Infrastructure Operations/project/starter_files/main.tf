provider "azurerm" {
  tenant_id       = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  features {}
}

resource "azurerm_resource_group" "test" {
 name     = "${var.resource_group}"
 location = "${var.location}"
 tags = {
   environment = "UdaProject"
 }
}

resource "azurerm_virtual_network" "test" {
 name                = "acctvn"
 address_space       = "${var.address_space}"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name
 tags = {
   environment = "UdaProject"
 }
}

resource "azurerm_subnet" "test" {
 name                 = "acctsub"
 resource_group_name  = azurerm_resource_group.test.name
 virtual_network_name = azurerm_virtual_network.test.name
 address_prefixes       = "${var.address_prefix_test}"
}

resource "azurerm_public_ip" "test" {
 name                         = "publicIPForLB"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 allocation_method            = "Static"
 tags = {
   environment   = "UdaProject"
 }
}

resource "azurerm_network_security_group" "test" {
    name                = "myNetworkSecurityGroup"
    location                     = azurerm_resource_group.test.location
    resource_group_name          = azurerm_resource_group.test.name
    
   
    security_rule {
        name                       = "Internet"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }


    tags = {
         environment   = "UdaProject"
    }
}

resource "azurerm_lb" "test" {
 name                = "loadBalancer"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.test.id
 }

 tags = {
   environment = "UdaProject"
 }
}

resource "azurerm_lb_backend_address_pool" "test" {
 resource_group_name = azurerm_resource_group.test.name
 loadbalancer_id     = azurerm_lb.test.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_interface" "test" {
 count               = "${var.vm_count}"
 name                = "acctni${count.index}"
 location            = azurerm_resource_group.test.location
 resource_group_name = azurerm_resource_group.test.name

 ip_configuration {
   name                          = "testConfiguration"
   subnet_id                     = azurerm_subnet.test.id
   private_ip_address_allocation = "dynamic"
 }
 tags = {
   environment = "UdaProject"
 }
}

resource "azurerm_network_interface_security_group_association" "example" {
    count               = "${var.vm_count}"
    network_interface_id      = azurerm_network_interface.test[count.index].id
    network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_managed_disk" "test" {
 count                = "${var.vm_count}"
 name                 = "datadisk_existing_${count.index}"
 location             = azurerm_resource_group.test.location
 resource_group_name  = azurerm_resource_group.test.name
 storage_account_type = "Standard_LRS"
 create_option        = "Empty"
 disk_size_gb         = "10"
 tags = {
   environment = "UdaProject"
 }
}


data "azurerm_image" "image" {
  name                = "UdaPackerImage"
  resource_group_name = "UdaResourceGroup"
}

output "image_id" {
  value = "${var.packer_image_id}"
}

resource "azurerm_availability_set" "avset" {
 name                         = "avset"
 location                     = azurerm_resource_group.test.location
 resource_group_name          = azurerm_resource_group.test.name
 platform_fault_domain_count  = 2
 platform_update_domain_count = 2
 managed                      = true
 tags = {
   environment = "UdaProject"
 }
}

resource "azurerm_virtual_machine" "test" {
 count                 = "${var.vm_count}"
 name                  = "acctvm${count.index}"
 location              = azurerm_resource_group.test.location
 availability_set_id   = azurerm_availability_set.avset.id
 resource_group_name   = azurerm_resource_group.test.name
 network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
 vm_size               = "Standard_B1s"

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 # delete_data_disks_on_termination = true

#  storage_image_reference {
#    publisher = "Canonical"
#    offer     = "UbuntuServer"
#    sku       = "16.04-LTS"
#    version   = "latest"
#  }

 storage_image_reference {
    id = "${data.azurerm_image.image.id}"
  }

 storage_os_disk {
   name              = "myosdisk${count.index}"
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 # Optional data disks
 storage_data_disk {
   name              = "datadisk_new_${count.index}"
   managed_disk_type = "Standard_LRS"
   create_option     = "Empty"
   lun               = 0
   disk_size_gb      = "10"
 }

 storage_data_disk {
   name            = element(azurerm_managed_disk.test.*.name, count.index)
   managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
   create_option   = "Attach"
   lun             = 1
   disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
 }

 os_profile {
   computer_name  = "hostname${count.index}"
   admin_username = ""
   admin_password = ""
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }

 tags = {
   environment = "UdaProject"
 }
}
