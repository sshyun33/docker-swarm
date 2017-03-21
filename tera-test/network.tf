resource "google_compute_network" "docker-net" {
  name = "docker-net"
  description = "docker swarm cluster network"
}

resource "google_compute_subnetwork" "docker-asia-subnet" {
  name          = "docker-asia-subnet"
  ip_cidr_range = "${var.docker_asia_subnet_range}"
  network       = "${google_compute_network.docker-net.self_link}"
  region        = "asia-northeast1"
}

resource "google_compute_firewall" "docker-firewall-external" {
  name = "docker-firewall-external"
  network = "${google_compute_network.docker-net.name}"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports = [
      "22",   # SSH
      "80",   # HTTP
      "443",  # HTTPS
      "2375", # Docker Swarm
    ]
  }
}

resource "google_compute_firewall" "docker-firewall-internal" {
  name = "docker-firewall-internal"
  network = "${google_compute_network.docker-net.name}"
  source_ranges = ["${google_compute_subnetwork.docker-asia-subnet.ip_cidr_range}"]

  allow {
    protocol = "tcp"
    ports = [
      "2377", # cluster management communications
      "7946", # communication among nodes 
    ]
  }

  allow {
    protocol = "udp"
    ports = [
      "7946", 
      "4789", # overlay network traffic
    ]
  }
}
