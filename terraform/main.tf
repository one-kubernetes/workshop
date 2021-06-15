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
 
data "azurerm_client_config" "current" {}
 
# Create Resource Group
resource "azurerm_resource_group" "flux-lab" {
  name     = var.resource_group_name
  location = "East US"
}
 
# # Create Storage account
# resource "azurerm_storage_account" "marjoh" {
#   name                = var.storage_account_name
#   resource_group_name = var.resource_group_name
#   location                 = "eastus"
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind             = "StorageV2"
 
#   static_website {
#     index_document = "index.html"
#   }
# }
 
# # Add index.html to blob storage
# resource "azurerm_storage_blob" "index" {
#   name                   = "index.html"
#   storage_account_name   = var.storage_account_name
#   storage_container_name = "$web"
#   type                   = "Block"
#   content_type           = "text/html"
#   source                 = "index.html"
# }

# #Add error.html to blob storage
# resource "azurerm_storage_blob" "error" {
#   name                   = "error.html"
#   storage_account_name   = var.storage_account_name
#   storage_container_name = "$web"
#   type                   = "Block"
#   content_type           = "text/html"
#   source                 = "error.html"
# }

data "azurerm_image" "existing" {
  name                = "my-image"
  resource_group_name = "k8s-lab"
}

resource "azurerm_shared_image_gallery" "example" {
  name                = "example_image_gallery"
  resource_group_name = azurerm_resource_group.flux-lab.name
  location            = azurerm_resource_group.flux-lab.location
  description         = "Shared images and things."

  tags = {
    Hello = "There"
    World = "Example"
  }
}

resource "azurerm_shared_image" "example" {
  name                = "my-image"
  gallery_name        = azurerm_shared_image_gallery.example.name
  resource_group_name = azurerm_shared_image_gallery.example.resource_group_name
  location            = azurerm_shared_image_gallery.example.location
  os_type             = "Linux"
  hyper_v_generation  = "V2"

  identifier {
    publisher = "PublisherName"
    offer     = "OfferName"
    sku       = "ExampleSku"
  }
}

resource "azurerm_shared_image_version" "example" {
  name                = "0.0.1"
  gallery_name        = azurerm_shared_image.example.gallery_name
  image_name          = azurerm_shared_image.example.name
  resource_group_name = azurerm_shared_image.example.resource_group_name
  location            = azurerm_shared_image.example.location
  managed_image_id    = data.azurerm_image.existing.id

  target_region {
    name                   = azurerm_shared_image.example.location
    regional_replica_count = 1
    storage_account_type   = "Standard_LRS"
  }
}


# resource "azurerm_virtual_network" "example" {
#   name                = "example-network"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.flux-lab.location
#   resource_group_name = azurerm_resource_group.flux-lab.name
# }

# resource "azurerm_subnet" "example" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.flux-lab.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

# resource "azurerm_network_interface" "example" {
#   name                = "example-nic"
#   location            = azurerm_resource_group.flux-lab.location
#   resource_group_name = azurerm_resource_group.flux-lab.name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.example.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_linux_virtual_machine" "example" {
#   name                = "example-machine"
#   resource_group_name = azurerm_resource_group.flux-lab.name
#   location            = azurerm_resource_group.flux-lab.location
#   size                = "Standard_DS1_v2"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.example.id,
#   ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-focal-daily"
#     sku       = "20_04-daily-lts-gen2"
#     version   = "latest"
#   }
# }

# data "azurerm_platform_image" "example" {
#   location  = "East US"
#   publisher = "Canonical"
#   offer     = "0001-com-ubuntu-server-focal-daily"
#   sku       = "20_04-daily-lts-gen2"
# }

# output "id" {
#   value = data.azurerm_platform_image.example.id
# }
