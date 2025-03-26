####################
# Common variables #
####################

variable tags {
  description = "Additional tags to apply to the build resources, including the image version"
  type        = map(string)
  default     = {}
}

############################
# Authentication variables #
############################

# The following 4 variables are for access via Service Principal

variable subscription_id {
  description = "ID of the subscription where the VM image would be built"
  type        = string
  default     = null
}

variable tenant_id {
  description = "Microsoft Entra tenant ID for the subscription_id"
  type        = string
  default     = null
}

variable client_id {
  description = "Client ID of the service principle"
  type        = string
  default     = null
}

variable client_secret {
  description = "Client secret of the service principal"
  type        = string
  default     = null
}

# Or you can use an existing auth session from Azure CLI

variable use_azure_cli_auth {
  description = "CLI auth will use the information from an active az login session to connect to Azure and set the subscription id and tenant id associated to the signed in account."
  type        = bool
  default     = true
}

#####################
# GraphDB variables #
#####################

variable graphdb_version {
  description = "Version of GraphDB which will be installed and packaged as VM image"
  type        = string
}

###################
# Build variables #
###################

variable build_location {
  description = "The Azure region where the VM image will be built with Packer"
  type        = string
  default     = null
}

variable build_temp_resource_group_name {
  description = "Name of the temporary resource group created by Packer during the build. The default is a random generated name."
  type        = string
  default     = null
}

variable build_resource_group_name {
  description = "Name of a resource group to be used by Packer during the build. Cannot specify this together with build_location or build_temp_resource_group_name."
  type        = string
  default     = null
}

variable build_allowed_inbound_ip_addresses {
  description = "List of IP addresses and CIDR blocks that should be allowed access to the VM during the building"
  type        = list(string)
}

// Note: Architecture specific
variable build_vm_size {
  description = "Size of the VM used for building"
  type        = string
  default     = "Standard_B1ls"
}

variable build_os_type {
  description = "Type of the OS, this configures the SSH authorized key"
  type        = string
  default     = "Linux"
}

variable build_os_disk_size_gb {
  description = "Size of the OS disk in GB (gigabytes). Values of zero or less than zero are ignored."
  type        = number
  default     = 30
}

########################
# Base image variables #
########################

// Note: Architecture specific
variable base_image_offer {
  description = "Name of the publisher's offer to use for your base image"
  type        = string
  default     = "ubuntu-24_04-lts"
}

variable base_image_publisher {
  description = "Name of the publisher to use for your base image (Azure Marketplace Images only)"
  type        = string
  default     = "canonical"
}

// Note: Architecture specific
variable base_image_sku {
  description = "SKU of the image offer to use for your base image (Azure Marketplace Images only)."
  type        = string
  default     = "server"
}

########################################
# Shared Image Gallery (SIG) variables #
########################################

variable gallery_subscription_id {
  description = "ID of the subscription where the Shared Image Gallery is located. Can be the same as subscription_id."
  type        = string
}

variable gallery_resource_group {
  description = "Name of the resource group where the Shared Image Gallery is located"
  type        = string
}

variable gallery_name {
  description = "Name of the Shared Image Gallery"
  type        = string
}

// Note: Architecture specific
variable gallery_image_definition {
  description = "Name of the gallery definition for the built images of particular GraphDB version"
  type        = string
}

variable gallery_image_replication_regions {
  description = "A list of regions to replicate the image version in"
  type        = list(string)
  default     = []
}

variable gallery_image_replica_count {
  description = "The number of replicas of the Image Version to be created per region. Replica count must be between 1 and 100"
  type        = number
  default     = 1
}

variable gallery_image_version_exclude_from_latest {
  description = "If set to true, Virtual Machines deployed from the latest version of the Image Definition won't use this Image Version"
  type        = bool
  default     = false
}
