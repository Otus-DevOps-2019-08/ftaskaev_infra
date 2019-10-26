variable zone {
  description = "Zone"
  default     = "europe-west1-b"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable app_provision {
  description = "Define whether install reddit-app or not"
  type        = bool
  default     = true
}

variable db_internal_ip {
  description = "DB instance internal IP"
  default     = "127.0.0.1"
}
