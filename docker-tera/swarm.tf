# Instance
resource "google_compute_instance" "swarm-manager" {
  count        = 1
  name         = "tf-swarm-manager"
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

  connection {
    user = "${var.gce_ssh_user}"
    key_file = "${var.gce_ssh_private_key_file}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "date >> ~/test1",
      "if [ \"${var.swarm_init}\" != \"true\" ]; then date >> ~/test2; fi",
      "date >> ~/test3"
    ]
  }

}

output "test-val" {
  value = "${var.swarm_init}"
}
