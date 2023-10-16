locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  #  https://github.com/hashicorp/packer-plugin-azure/issues/65
  version_timestamp = formatdate("YYYY.MM.DD", timestamp())
}

source azure-arm ubuntu-x86-64 {
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  location        = var.primary_location

  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.gallery_resource_group
    gallery_name        = var.gallery_name
    image_name          = var.image_name_x86_64
    image_version       = local.version_timestamp
    replication_regions = var.replication_regions
  }

  azure_tags = {
    GDB_Version      = "${var.gdb_version}"
    CPU_Architecture = "x86-64"
    Build_Timestamp  = "${local.timestamp}"
  }

  communicator              = "ssh"
  ssh_clear_authorized_keys = true
  os_type                   = var.os_type
  image_offer               = var.image_offer
  image_publisher           = var.image_publisher
  image_sku                 = var.image_sku

  vm_size = var.vm_size 
          
  allowed_inbound_ip_addresses = [var.my_ip_address]
}

# Not yet supported by Packer https://github.com/hashicorp/packer/issues/12188#issuecomment-1380736642 
#source azure-arm ubuntu-arm64 {
#  client_id       = var.client_id
#  client_secret   = var.client_secret
#  subscription_id = var.subscription_id
#  tenant_id       = var.tenant_id
#
#  location                          = var.primary_location
#  shared_image_gallery_destination {
#    subscription        = var.subscription_id
#    resource_group      = var.gallery_resource_group
#    gallery_name        = var.gallery_name
#    image_name          = var.image_name_arm64
#    image_version       = local.version_timestamp
#    replication_regions = var.replication_regions
#  }
#
#  azure_tags = {
#    GDB_Version      = "${var.gdb_version}"
#    CPU_Architecture = "arm64"
#    Build_Timestamp  = "${local.timestamp}"
#  }
#
#  communicator    = "ssh"
#  os_type         = "Linux"
#  image_offer     = "0001-com-ubuntu-server-jammy"
#  image_publisher = "canonical"
#  image_sku       = "22_04-lts-arm64"
#
#  vm_size = "Standard_D2ps_v5"
#
#  allowed_inbound_ip_addresses = [var.my_ip_address]
#}