source "azure-arm" "basic-example" {
  subscription_id = "92c69a02-47c5-4c5b-a49e-442d56f1ab8a"
  tenant_id = "44d4dd21-a02e-4538-b021-e72217f58698"

  # shared_image_gallery_destination {
  #   subscription = "92c69a02-47c5-4c5b-a49e-442d56f1ab8a"
  #   resource_group = "flux-lab-ressgroup"
  #   gallery_name = "example_image_gallery"
  #   image_name = "my-image"
  #   image_version = "1.0.0"
  #   replication_regions = ["East US"]
  # }
  managed_image_name = "k8s-lab_K3S-server"
  managed_image_resource_group_name = "k8s-lab"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal-daily"
  image_sku       = "20_04-daily-lts-gen2"
  image_version   = "latest"

  azure_tags = {
    dept = "engineering"
  }

  location = "East US"
  vm_size  = "Standard_DS1_v2"
}

build {
  sources = ["sources.azure-arm.basic-example"]

  provisioner "shell" {
    inline = [
      "echo provisioning all the things",
      # "echo the value of 'foo' is '${var.foo}'",
      curl -sfL https://get.k3s.io | sh -
    ]
  }

}


