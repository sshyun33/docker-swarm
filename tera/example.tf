provider "google" {
  credentials = "${file("My-Project-01-01a160ea71b0.json")}"
  project     = "my-project-01-157810"
  region      = "asia-northeast1-a"
}

resource "google_compute_instance" "default" {
  name         = "test-terraform"
  machine_type = "g1-small"
  zone         = "asia-northeast1-a"

  tags = ["docker"]

  disk {
    image = "docker-ubuntu-xenial-1489217103"
  }

  network_interface {
    network = "docker-net"
    access_config {
    }
  }

  provisioner "remote-exec" {
    inline = [
      "if ${var.swarm_init}; then docker swarm init --advertise-addr ${self.network_interface.0.address}; fi",
      "if ! ${var.swarm_init}; then docker swarm join --token ${var.swarm_manager_token} --advertise-addr ${self.network_interface.0.address} ${var.swarm_manager_ip}:2377; fi"
    ]
  }
}
