provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file(var.account_file_path)}"
}

# Instance
resource "google_compute_instance" "swarm-manager" {
  count        = 1
  name         = "tf-swarm-manager2"
  machine_type = "g1-small"
  zone         = "${var.region_zone}"

  tags = ["swarm"]

  disk {
    image = "docker-ubuntu-xenial-1489217103"
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  provisioner "remote-exec" {
    connection {
      user = "ubuntu"
    }
    inline = [
    ]
  }

  metadata {
    sshKeys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
   }
}

output "swarm_manager_init" {
  value = "${var.swarm_init}"
}
