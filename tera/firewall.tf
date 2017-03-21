resource "google_compute_network" "default" {
  name                    = "docker-net"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "default" {
  name    = "docker"
  network = "docker-net"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_tags = ["docker-tag"]
}
