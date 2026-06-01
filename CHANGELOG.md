# Packer Template Changelog

All notable changes to the Packer template for creating GraphDB Azure VM images will be documented in this file.

## 2.1.0

- Updated the GraphDB cluster proxy service to use an env file similar to the main GraphDB service
- Added manifest post-processor to create a manifest JSON with the AMI IDs
- Renamed the pkr.hcl files to follow a naming convention closer to Terraform
- Added retry count variable for the build provisioner
- Added a security hardening script that disables modules susceptible to attacks (copy fail, dirty flag)
- Separated the shell scripts to be in stages (setup, hardening, graphdb)

## 2.0.0

- Removed Telegraf from the VM image

## 1.4.0

- Updated Ubuntu version to 24.04 LTS
- Updated Java version to temurin-21-jdk
- Updated `github.com/hashicorp/azure` to 2.3.0

## 1.3.0

- GDB-11622 Disabled GDB JS plugin by default

## 1.2.2

- Disabled the GraphDB JS plugin by default (GDB-11622)

## 1.2.1

- Fixed the get `NODE_STATE` step in the `graphdb_backup` script.

## 1.2.0

### Changes

- The `gallery_subscription_id` is now a required variable instead of defaulting to `subscription_id`.

### Fixes

- Fixed [create_image_definition.sh](create_image_definition.sh) to use `gallery_subscription_id`

## 1.1.0

- Installed Azure CLI
- Removed features preventing build with Standard_B1ls VM.
- Fixed create_image_definition.sh
- Added subscription as an attribute in the [create_image_definition.sh](create_image_definition.sh) helper script.
- Added installation of Telegraf.
- Added provisioning of GraphDB backup script.
- Added keepalive and file max size settings.
- Improved logging of the GraphDB install script.
- Added proper prefixes to the variable names in variables.pck.hcl
- Grouped variables by usage in variables.pck.hcl
- Added new variables in variables.pck.hcl
  - `tags` - Additional tags to apply to the build resources
  - `build_temp_resource_group_name` - Name of the temporary resource group created by Packer during the build
  - `build_resource_group_name` - Name of a resource group to be used by Packer during the build
  - `gallery_subscription_id` - ID of the subscription where the Shared Image Gallery is located
- Updated [create_image_definition.sh](create_image_definition.sh) to just create the definition and to skip invoking `packer build`

## 1.0.0

- Initial release of the Packer template.
- Added configuration to create GraphDB VM image on Azure.
- Added basic provisioning with installation scripts.
- Added README.md with usage instructions.
- Added CONTRIBUTING.md
- Added CHANGELOG.md
