provider "google" {
  region = "${var.region}"
  project = "${var.project_name}"
  credentials = "${file(var.account_file_path)}"
}

resource "google_compute_address" "www" {
    name = "tf-www-address"
}



resource "google_compute_instance" "www" {
  count = 2
  name = "tf-www-${count.index}"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["www-node"]

  disk {
    image = "ubuntu-1510-wily-v20160315"
  }
  network_interface {
    network = "default"
    access_config {
        # Ephemeral
    }
  }
  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  metadata_startup_script = <<SCRIPT
aptitude -y update
#aptitude -y safe-upgrade
aptitude install -y salt-minion
echo -e "master: ${google_compute_instance.salt.name}" > /etc/salt/minion.d/master.conf
echo -e "grains:\n  roles:\n    - webserver" > /etc/salt/minion.d/grains.conf
service salt-minion restart
SCRIPT

  metadata {
    sshKeys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_instance" "salt" {
  count = 1
  name = "tf-salt"
  machine_type = "f1-micro"
  zone = "${var.region_zone}"
  tags = ["salt", "letsencrypt"]

  disk {
    image = "ubuntu-1510-wily-v20160315"
  }
  network_interface {
    network = "default"
    access_config {
        # Ephemeral
    }
  }
  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  metadata_startup_script = <<SCRIPT
aptitude -y update
#aptitude -y safe-upgrade
aptitude -y install salt-master salt-minion salt-ssh salt-cloud salt-doc
echo -e "master: $HOSTNAME" > /etc/salt/minion.d/master.conf
echo -e "grains:\n  roles:\n    - salt\n    - letsencrypt" > /etc/salt/minion.d/grains.conf
echo -e "file_roots:\n  base:\n    - /srv/gwadeloop-states/salt\npillar_roots:\n  base:\n    - /srv/gwadeloop-states/pillar" > /etc/salt/master.d/path_roots.conf
mkdir /srv/gwadeloop-states/
chown -R ubuntu:root /srv/gwadeloop-states/
SCRIPT

  provisioner "file" {
    connection {
      user = "ubuntu"
   }

    source = "/srv/gwadeloop-states"
    destination = "/home/ubuntu/"
  }

  provisioner "remote-exec" {
    connection {
     user = "ubuntu"
    }
   inline = [
     "sudo cp -r /home/ubuntu/gwadeloop-states /srv/gwadeloop-states",
     "sudo chown -R ubuntu:root /srv/gwadeloop-states"
   ]
  }

  metadata {
    sshKeys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
   }
}

