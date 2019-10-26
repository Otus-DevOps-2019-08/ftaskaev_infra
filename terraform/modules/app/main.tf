resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params { image = var.app_disk_image }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "null_resource" "post-install" {
  # This code should run if app_provision is set true
  count = "${var.app_provision ? 1 : 0}"

  connection {
    type        = "ssh"
    host        = google_compute_instance.app.network_interface.0.access_config.0.nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  # Copy systemd unit
  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }
  # Copy EnvironmentFile
  provisioner "remote-exec" {
    inline = [
      "sudo echo DATABASE_URL=${var.db_internal_ip} > /tmp/puma.env"
    ]
  }
  # Run installation script
  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

}
