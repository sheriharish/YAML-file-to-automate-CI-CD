#resource group creation
resource "azurerm_resource_group" "TFRG" {
  name     = "RG"
  location = "eastus"

}

#virtual network creation
resource "azurerm_virtual_network" "TFVnet" {
    name = "Vnet"
    location = azurerm_resource_group.TFRG.location
    resource_group_name = azurerm_resource_group.TFRG.name
    address_space = ["10.0.0.0/16"]
  
}

#subnet creation
resource "azurerm_subnet" "TFsubnet" {
    name = "subent"
    resource_group_name = azurerm_resource_group.TFRG.name
    address_prefixes = ["10.0.1.0/24"]
    virtual_network_name = azurerm_virtual_network.TFVnet.name

}

#public ip creation
resource "azurerm_public_ip" "TFPIP" {
    name = "publicIP"
    location = azurerm_resource_group.TFRG.location
    resource_group_name = azurerm_resource_group.TFRG.name
    allocation_method = "Static"
  
}

#NIC card creation
resource "azurerm_network_interface" "TFNIC" {
    name = "NIC"
    location = azurerm_resource_group.TFRG.location
    resource_group_name = azurerm_resource_group.TFRG.name

    ip_configuration {
        name = "interanal"
      subnet_id = azurerm_subnet.TFsubnet.id
      private_ip_address_allocation = "Dynamic"

    }
  
}

#NSG creation
resource "azurerm_network_security_group" "TFNSG" {
    name = "NSG"
    location = azurerm_resource_group.TFRG.location
    resource_group_name = azurerm_resource_group.TFRG.name

}
#writing of NSG rules
resource "azurerm_network_security_rule" "allow_ssh" {
  name                         = "AllowSSH"
  priority                     = 100
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "22"
  source_address_prefix        = "*"
  destination_address_prefix = "*"
  resource_group_name          = azurerm_resource_group.TFRG.name
  network_security_group_name  = azurerm_network_security_group.TFNSG.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name                         = "AllowHTTP"
  priority                     = 110
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "80"
  source_address_prefix        = "*"
  destination_address_prefix = "*"
  resource_group_name          = azurerm_resource_group.TFRG.name
  network_security_group_name  = azurerm_network_security_group.TFNSG.name

} 

# Assigning of NSG to the subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.TFsubnet.id
  network_security_group_id = azurerm_network_security_group.TFNSG.id
}

#virtual machine creation
resource "azurerm_linux_virtual_machine" "TFVM" {
  name                            = "VM-0"
  resource_group_name             = azurerm_resource_group.TFRG.name
  location                        = azurerm_resource_group.TFRG.location
  size                            = "Standard_B1s"
  admin_username                  = "harish"
  admin_password                  = "Harish@123456789"
  network_interface_ids = [azurerm_network_interface.TFNIC.id]

  disable_password_authentication = false  # Important: Allow password auth

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy" # Ubuntu 22.04 LTS
    sku       = "22_04-lts-gen2" # or "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
  
