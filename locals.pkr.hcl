locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  #  https://github.com/hashicorp/packer-plugin-azure/issues/65
  version_timestamp = formatdate("YYYY.MM.DD", timestamp())
}