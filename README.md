# Packer Configuration for Creating GraphDB Azure VM

This guide explains how to use Packer to create Azure VM Image for GraphDB.
The Packer configuration in this repository automates the process of installing and configuring GraphDB on an Ubuntu-based VM instance.

## Prerequisites

Before you begin, make sure you have the following prerequisites in place:

1. **Packer**: Ensure that you have Packer installed on your local machine.
   You can download it from the official Packer website: [Packer Downloads](https://www.packer.io/downloads).
2. **Azure Account**: You should have an Azure account with necessary permissions to create VM instances and AMIs.
3. **Azure Resource group**: You should create a Resource group.
4. **Azure compute gallery**: You should create an Azure compute gallery
5. **VM image definition**:  You should create an Azure Image definition in the Azure compute gallery.
6. **AAD Service Principal**: You should create an Azure Active Directory Service Principal.

## Usage

Follow these steps to build an AMI for GraphDB using Packer:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Ontotext-AD/packer-azure-graphdb.git
   ```

2. **Set Your Azure Credentials**:

   Ensure that your Azure credentials are correctly configured in the Azure CLI configuration.

3. **Edit Variables**:

   The Packer configuration allows you to customize various parameters, such as the GraphDB version, Azure build and
   replication regions, subscription, client and tenant IDs. To do so, create a variables file `variables.pkrvars.hcl`,
   example file:
      ```bash
      subscription_id                    = "<your_azure_subscription_id>"
      tenant_id                          = "<your_azure_tenant_id>"
      client_id                          = "<your_azure_service_principal_id>"
      client_secret                      = "<your_azure_service_principal_secret>"
      build_location                     = "East US"
      graphdb_version                    = "10.4.0"
      gallery_image_definition           = "10.4.0-x86_64"
      gallery_resource_group             = "Packer-RG"
      gallery_name                       = "GraphDB"
      gallery_image_replication_regions  = ["North Europe", "UK South"]
      build_allowed_inbound_ip_addresses = "<your_public_IP_address>"
      ```

4. **Build the AMI**:

   Run Packer to build the AMI:
   ```bash
   packer build -var-file="variables.pkrvars.hcl" .
   ```
   This command will initiate the Packer build process. Packer will launch an VM instance, install GraphDB,
   and create an image based on the instance.

   Please note that the image definition you specify in `gallery_image_definition` must exist in the SIG.
   To automate this process you can use the `create_image_definition.sh` script, which will read the variables in
   `variables.pkrvars.hcl` and create the image definition in the gallery.
   This script utilizes the Azure CLI, so you need to install and configure it beforehand.
   The image definition will be built with the following settings:
   ```bash
      az_command="az sig image-definition create \
       -g $gallery_resource_group \
       --gallery-name $gallery_name \
       --gallery-image-definition "$gallery_image_definition" \
       --publisher Ontotext \
       --offer GraphDB \
       --sku "$graphdb_version" \
       --os-type Linux \
       --hyper-v-generation v2 \
       --minimum-cpu-core 4 \
       --maximum-cpu-core 64 \
       --minimum-memory 4 \
       --maximum-memory 128 "
   ```

## Customization

You can customize the Packer configuration and provisioning scripts to suit your specific requirements.

The following points can be customized in a packer variables file `variables.pkrvars.hcl`:

**Subscription Configuration**

* `subscription_id` (string): Your Azure subscription ID.
* `tenant_id` (string): Your Azure Active Directory tenant ID.
* `client_id` (string): The client ID (Service Principal ID) used for authentication.
* `client_secret` (string): The client secret (Service Principal Secret) used for authentication.
* `use_azure_cli_auth` (bool): Use the information from an active az login session instead of authenticating with a client secret

**GraphDB Configuration**

* `graphdb_version` (string): The version of GraphDB to install and package as VM

**Build and OS Configuration**

* `build_location` (string): The primary Azure location you want to use for building the image
* `build_temp_resource_group_name` (string): Name of the temporary resource group created by Packer during the build. The default is a random
  generated name.
* `build_resource_group_name` (string): Name of a resource group to be used by Packer during the build. Cannot specify this together with
  build_location or build_temp_resource_group_name.
* `build_allowed_inbound_ip_addresses` (string): Specify the list of IP addresses and CIDR blocks that should be allowed access to the VM.
* `build_vm_size` (string): The Azure VM size (default is "Standard_B1ls").
* `build_os_type` (string): The operating system type (default is "Linux").
* `build_os_disk_size_gb` (number): size of the OS disk in GB (default is 30). Depends on base VM image limitation,
  e.g., Ubuntu Server image has `build_os_disk_size_gb = 30`.

**Base Image Configuration**

* `base_image_offer` (string): The offer for the base image (default is "0001-com-ubuntu-server-jammy").
* `base_image_publisher` (string): The publisher for the base image (default is "canonical").
* `base_image_sku` (string): The SKU for the base image (default is "22_04-lts-gen2").

**Gallery Configuration**

* `gallery_subscription_id` (string): ID of the subscription where the Shared Image Gallery is located. Will use subscription_id as default if
  unspecified
* `gallery_resource_group` (string): The resource group where the image gallery is located.
* `gallery_name` (string): The name of the image gallery.
* `gallery_image_definition` (string): The name of the x86_64 image to use.
* `gallery_image_replication_regions` (list(string)): A list of Azure regions for replication of the created image.
* `gallery_image_replica_count` (number): The number of replicas of the Image Version to be created per region. (default is 1).
* `gallery_image_version_exclude_from_latest` (bool):  If set to true, Virtual Machines deployed from the latest
  version of the Image Definition won't use this Image Version (default is false)

**Provisioning Scripts**: You can replace or modify the provisioning scripts located in the `./files/` directory.
These scripts and files are copied and executed during the AMI creation process.

## Limitations

Timestamp is used for `image_version`, therefore if you want to build more than a single image per day, you should either
delete the previously created image version or change the `image_version` property in `shared_image_gallery_destination`
to something else.

## Support

For questions or issues related to this Packer configuration, please [submit an issue](https://github.com/Ontotext-AD/packer-aws-graphdb/issues).
