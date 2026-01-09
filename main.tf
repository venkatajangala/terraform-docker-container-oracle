terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "oracle" {
  name         = var.image
  keep_locally = false
}

resource "docker_volume" "oracle_data" {
  name = "${var.container_name}-volume"
}

resource "docker_container" "oracle" {
  name    = var.container_name
  image   = docker_image.oracle.name
  restart = "unless-stopped"

  depends_on = [docker_volume.oracle_data]

  env = [
    "ORACLE_PWD=${var.oracle_password}",
    "ORACLE_SID=FREE"
  ]

  ports {
    internal = 1521
    external = var.oracle_port
  }

  volumes {
    volume_name    = docker_volume.oracle_data.name
    container_path = "/opt/oracle/oradata"
  }
}
