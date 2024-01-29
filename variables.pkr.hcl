# The following 4 variables are for access via Service Principal

variable subscription_id {
  description = "ID of the subscription the VM image would be build in"
  type        = string
  default     = null
}

variable tenant_id {
  description = "Microsoft Entra tenant ID"
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

variable use_azure_cli_auth {
  description = "CLI auth will use the information from an active az login session to connect to Azure and set the subscription id and tenant id associated to the signed in account."
  type        = bool
  default     = true
}

# Generic variables

variable primary_location {
  description = "Azure datacenter in which your VM will build"
  type        = string
}

variable image_definition_name {
  description = "Image Name"
  type        = string
}

variable gdb_version {
  description = "Version of GraphDB which will be installed"
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

variable allowed_inbound_ip_addresses {
  description = "Specify the list of IP addresses and CIDR blocks that should be allowed access to the VM"
  type        = list(string)
}

variable replication_regions {
  description = "A list of regions to replicate the image version in"
  type        = list(string)
}

variable os_type {
  description = "Type of the OS, this configures an SSH authorized key"
  type        = string
  default     = "Linux"
}

variable image_offer {
  description = "Name of the publisher's offer to use for your base image"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable image_publisher {
  description = "Name of the publisher to use for your base image (Azure Marketplace Images only)"
  type        = string
  default     = "canonical"
}

variable image_sku {
  description = "SKU of the image offer to use for your base image (Azure Marketplace Images only)."
  type        = string
  default     = "22_04-lts-gen2"
}

variable vm_size {
  description = "Size of the VM used for building"
  type        = string
  default     = "Standard_B1ls"
}

variable image_replica_count {
  description = "The number of replicas of the Image Version to be created per region. Replica count must be between 1 and 100"
  type        = number
  default     = 1
}

variable shared_gallery_image_version_exclude_from_latest {
  description = "If set to true, Virtual Machines deployed from the latest version of the Image Definition won't use this Image Version"
  type        = bool
  default     = false
}

variable os_disk_size_gb {
  description = "Specify the size of the OS disk in GB (gigabytes). Values of zero or less than zero are ignored."
  type        = number
  default     = 30
}
