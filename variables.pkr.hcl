variable subscription_id {
  type = string
}

variable tenant_id {
  type = string
}

variable client_id {
  type = string
}

variable client_secret {
  type = string
}

variable primary_location {
  type = string
}

variable image_definition_name {
  type = string
}

variable gdb_version {
  type = string
}

variable gallery_resource_group {
  type = string
}

variable gallery_name {
  type = string
}

variable my_ip_address {
  type = string
}

variable replication_regions {
  type = list(string)
}

variable os_type {
  type    = string
  default = "Linux"
}

variable image_offer {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable image_publisher {
  type    = string
  default = "canonical"
}

variable image_sku {
  type    = string
  default = "22_04-lts-gen2"
}

variable vm_size {
  type    = string
  default = "Standard_B1ls"
  # TODO replace with B2pts_v2 when quota is available in order to build with IsAcceleratedNetworkSupported=true DiskControllerTypes=SCSI,NVMe features
  #   default = "Standard_B2ats_v2"
}

variable image_replica_count {
  type    = number
  default = 1
}

variable shared_gallery_image_version_exclude_from_latest {
  type    = bool
  default = false
}

variable os_disk_size_gb {
  type    = number
  default = 30
}
