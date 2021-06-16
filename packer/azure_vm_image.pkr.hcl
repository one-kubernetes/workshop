# todo: add flux install
# add cp /etc/rancher/k3s/k3s.yaml .kube/config && export KUBECONFIG=.kube/config


source "azure-arm" "k8s-lab-image" {
  subscription_id = "92c69a02-47c5-4c5b-a49e-442d56f1ab8a"
  tenant_id = "44d4dd21-a02e-4538-b021-e72217f58698"

  # shared_image_gallery_destination {
  #   subscription = "92c69a02-47c5-4c5b-a49e-442d56f1ab8a"
  #   resource_group = "k8s-lab"
  #   gallery_name = "k8s-lab_image_gallery"
  #   image_name = "k8s-lab_K3S-server"
  #   image_version = "1.0.0"
  #   replication_regions = ["East US"]
  # }
  managed_image_name = "k8s-lab_k3s-server"
  managed_image_resource_group_name = "k8s-lab"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal-daily"
  image_sku       = "20_04-daily-lts-gen2"
  image_version   = "latest"

  # azure_tags = {
  #   dept = "engineering"
  # }

  location = "East US"
  vm_size  = "Standard_DS1_v2"
}

build {
  sources = ["sources.azure-arm.k8s-lab-image"]

  provisioner "shell" {
    # execute_command = "echo '{{user `ssh_pass`}}' | {{ .Vars }} sudo -S -E sh '{{ .Path }}'"
    inline_shebang = "/bin/sh -x"
    inline = [
      # "echo provisioning all the things",
      "curl -sfL https://get.k3s.io | sh -",
      # "ls -al /etc/rancher/k3s/k3s.yaml",
      # "chmod o+r /etc/rancher/k3s/k3s.yaml",
    ]
  }
}
