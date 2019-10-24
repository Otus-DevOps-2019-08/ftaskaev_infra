variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default = "europe-west1"
}

variable zone {
  description = "Zone"
  default = "europe-west1-b"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default = "reddit-db-base"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default = "reddit-app-base"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
  default = "~/.ssh/appuser.pub"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
  default = "~/.ssh/appuser"
}

variable app_provision {
  description = "Define whether install reddit-app or not"
  type = bool
  default = true
}
