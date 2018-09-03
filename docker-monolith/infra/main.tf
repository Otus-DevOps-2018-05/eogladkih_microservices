provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "docker" {
  count        = "${var.num_of_nodes}"
  name         = "docker-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  tags = ["docker"]

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.priv_key)}"
  }
}
