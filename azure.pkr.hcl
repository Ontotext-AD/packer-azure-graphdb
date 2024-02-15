locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  # See https://github.com/hashicorp/packer-plugin-azure/issues/65
  version_timestamp = formatdate("YYYY.MM.DD", timestamp())
}

source azure-arm ubuntu-x86-64 {
  use_azure_cli_auth = var.use_azure_cli_auth
  client_id          = var.client_id
  client_secret      = var.client_secret
  subscription_id    = var.subscription_id
  tenant_id          = var.tenant_id

  location                  = var.build_location
  temp_resource_group_name  = var.build_temp_resource_group_name
  build_resource_group_name = var.build_resource_group_name

  image_offer     = var.base_image_offer
  image_publisher = var.base_image_publisher
  image_sku       = var.base_image_sku

  shared_image_gallery_destination {
    subscription        = var.gallery_subscription_id
    resource_group      = var.gallery_resource_group
    gallery_name        = var.gallery_name
    image_name          = var.gallery_image_definition
    image_version       = local.version_timestamp
    replication_regions = var.gallery_image_replication_regions
  }

  shared_image_gallery_replica_count               = var.gallery_image_replica_count
  shared_gallery_image_version_exclude_from_latest = var.gallery_image_version_exclude_from_latest

  azure_tags = merge({
    GraphDB_Version  = "${var.graphdb_version}"
    CPU_Architecture = "x86-64"
    Build_Timestamp  = "${local.timestamp}"
  }, var.tags)

  communicator                 = "ssh"
  ssh_clear_authorized_keys    = true
  os_type                      = var.build_os_type
  os_disk_size_gb              = var.build_os_disk_size_gb
  vm_size                      = var.build_vm_size
  allowed_inbound_ip_addresses = var.build_allowed_inbound_ip_addresses
}
