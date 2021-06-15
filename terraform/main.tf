terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.62.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_image" "existing" {
  name                = "k8s-lab_s3s-server"
  resource_group_name = azurerm_resource_group.k8s_lab.name
}
 
# Create Resource Group
resource "azurerm_resource_group" "k8s_lab" {
  name     = "k8s-lab"
  location = "East US"
}

# resource "azurerm_shared_image_gallery" "example" {
#   name                = "example_image_gallery"
#   resource_group_name = azurerm_resource_group.k8s_lab.name
#   location            = azurerm_resource_group.k8s_lab.location
#   description         = "Shared images and things."
# }

# resource "azurerm_shared_image" "example" {
#   name                = "my-image"
#   gallery_name        = azurerm_shared_image_gallery.example.name
#   resource_group_name = azurerm_shared_image_gallery.example.resource_group_name
#   location            = azurerm_shared_image_gallery.example.location
#   os_type             = "Linux"
#   hyper_v_generation  = "V2"

#   identifier {
#     publisher = "PublisherName"
#     offer     = "OfferName"
#     sku       = "ExampleSku"
#   }
# }

# resource "azurerm_shared_image_version" "example" {
#   name                = "0.0.1"
#   gallery_name        = azurerm_shared_image.example.gallery_name
#   image_name          = azurerm_shared_image.example.name
#   resource_group_name = azurerm_shared_image.example.resource_group_name
#   location            = azurerm_shared_image.example.location
#   managed_image_id    = data.azurerm_image.existing.id

#   target_region {
#     name                   = azurerm_shared_image.example.location
#     regional_replica_count = 1
#     storage_account_type   = "Standard_LRS"
#   }
# }

resource "azurerm_virtual_network" "k8s_lab" {
  name                = "k8s-lab-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.k8s_lab.location
  resource_group_name = azurerm_resource_group.k8s_lab.name
}

resource "azurerm_subnet" "k8s_lab" {
  name                 = "k8s-lab-subnet"
  resource_group_name  = azurerm_virtual_network.k8s_lab.resource_group_name
  virtual_network_name = azurerm_virtual_network.k8s_lab.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "staging" {
    name                = "staging-public-ip"
    location            = azurerm_virtual_network.k8s_lab.location
    resource_group_name = azurerm_virtual_network.k8s_lab.resource_group_name
    allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "k8s_lab_sg" {
    name                = "k8s-lab-sg"
    location            = azurerm_virtual_network.k8s_lab.location
    resource_group_name = azurerm_virtual_network.k8s_lab.resource_group_name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.k8s_lab_staging.id
    network_security_group_id = azurerm_network_security_group.k8s_lab_sg.id
}

resource "azurerm_network_interface" "k8s_lab_staging" {
  name                = "staging-nic"
  location            = azurerm_virtual_network.k8s_lab.location
  resource_group_name = azurerm_virtual_network.k8s_lab.resource_group_name

  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.k8s_lab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.staging.id
  }
}

resource "azurerm_linux_virtual_machine" "k3s_server_staging" {
  count               = 0
  name                = "k3s-server-staging"
  resource_group_name = azurerm_resource_group.k8s_lab.name
  location            = azurerm_resource_group.k8s_lab.location
  size                = "Standard_DS1_v2"
  computer_name       = "k3s-server-staging"
  disable_password_authentication = true
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.k8s_lab_staging.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./k8s-lab_ssh-rsa.pub")
  }

  os_disk {
    name                 = "k3s-server-staging-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.existing.id
}

# output "id" {
#   value = data.azurerm_image.existing.id
# }
