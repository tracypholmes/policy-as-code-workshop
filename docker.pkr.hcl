packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "pac" {
  image  = "ubuntu"
  commit = true
  changes = []
}

build {
  sources = ["source.docker.pac"]
  provisioner "shell" {
    environment_vars = [
      "VERSION=0.21.0",
    ]
    inline = [
      "apt-get update",
      "apt-get install -y wget unzip",
      "wget https://github.com/nicholasjackson/fake-service/releases/download/v$${VERSION}/fake_service_linux_amd64.zip",
      "unzip fake_service_linux_amd64.zip",
      "chmod +x fake-service",
      "mv fake-service /usr/local/bin"
    ]
  }
  post-processor "manifest" {}
}
