terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.17.0"
    }
  }
}

provider "docker"{
    host = "npipe:////.//pipe//docker_engine"
}

resource "docker_network" "terraform-network" {
    name = "terraform-network"
}

resource "docker_image" "tweb1" {
  name = "dockercloud/hello-world"
}

resource "docker_container" "tweb1" {
    image = docker_image.tweb1.name
    name = "tweb1"
    ports {
        external = 8081     
        internal = 80
    }
    networks_advanced {
        name = docker_network.terraform-network.name 
    }
}

resource "docker_image" "tweb2" {
    name = "dockercloud/hello-world"
}

resource "docker_container" "tweb2" {
    image = docker_image.tweb2.name
    name = "tweb2"
    ports {
        external = 8082     
        internal = 80
    }
    networks_advanced {
        name = docker_network.terraform-network.name 
    }
}

resource "docker_image" "haproxy" {
    name = "haproxy"
    build {
        path = "./haproxy"
        tag = ["haproxy:test"]
        no_cache = true
    }
}

resource "docker_container" "haproxy" {
    image = docker_image.haproxy.name
    name = "haproxy"

    ports {
        external = 8080     
        internal = 80
    }
    networks_advanced {
        name = docker_network.terraform-network.name 
    }
}

output "web_url" {
    value = "http://localhost:${docker_container.haproxy.ports[0].external}"
}

output "web_url1" {
    value = "http://localhost:${docker_container.tweb1.ports[0].external}"
}

output "web_url2" {
    value = "http://localhost:${docker_container.tweb2.ports[0].external}"
}