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
# Not supported yet
#variable image_name_arm64 {
#  type = string
#}
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

