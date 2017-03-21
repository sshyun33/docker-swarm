resource "google_compute_instance" "www" {
  count = 1

  name         = "tf-www-${count.index}"
  machine_type = "g1-small"
  zone         = "${var.region_zone}"
  tags         = ["www-node"]

  disk {
    image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20160602"
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.docker-asia-subnet.name}"
  }

  metadata {
    ssh-keys = "kkk:${file("${var.public_key_path}")}"
  }

  provisioner "file" {
    source      = "${var.install_script_src_path}"
    destination = "${var.install_script_dest_path}"

    connection {
      type        = "ssh"
      user        = "kkk"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "kkk"
      private_key = "${file("${var.private_key_path}")}"
      agent       = false
    }

    inline = [
      "chmod +x ${var.install_script_dest_path}",
      "sudo ${var.install_script_dest_path} ${count.index}",
    ]
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}
