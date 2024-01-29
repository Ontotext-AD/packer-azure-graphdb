# Packer Template Changelog

All notable changes to the Packer template for creating GraphDB Azure VM images will be documented in this file.

## 1.1.0

- Installed Azure CLI
- Removed features preventing build with Standard_B1ls VM.
- Fixed create_image_definition.sh
- Added subscription as an attribute in the [create_image_definition.sh](create_image_definition.sh) helper script.
- Added installation of Telegraf.
- Added provisioning of GraphDB backup script.
- Added keepalive and file max size settings.
- Improved logging of the GraphDB install script.

## 1.0.0

- Initial release of the Packer template.
- Added configuration to create GraphDB VM image on Azure.
- Added basic provisioning with installation scripts.
- Added README.md with usage instructions.
- Added CONTRIBUTING.md
- Added CHANGELOG.md
