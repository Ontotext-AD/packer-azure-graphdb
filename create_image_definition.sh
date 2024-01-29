#!/bin/bash

# This script sets up Azure Shared Image Gallery (SIG) image definition and builds an image using Packer.
# It checks for a variables file, extracts necessary parameters, constructs an Azure CLI command for image definition creation,
# executes the command, waits for creation completion,
# and finally uses Packer to build the image based on the specified variables.

set -euxo pipefail

# Required when running the script on Windows
alias az=az.cmd || true

# Specify the path to the variables file
variables_file="variables.pkrvars.hcl"

# Check if the file exists
if [ -f "$variables_file" ]; then
  # Extracts required variables from the variables_file
  subscription_id=$(grep 'subscription_id' "$variables_file" | cut -d '"' -f 2)
  echo "Subscription ID: $subscription_id"
  image_definition_name=$(grep 'image_definition_name' "$variables_file" | cut -d '"' -f 2)
  echo "Image definition name: $image_definition_name"
  gdb_version=$(grep 'gdb_version' "$variables_file" | cut -d '"' -f 2)
  echo "GraphDB version: $gdb_version"
  gallery_resource_group=$(grep 'gallery_resource_group' "$variables_file" | cut -d '"' -f 2)
  echo "Resource group: $gallery_resource_group"
  gallery_name=$(grep 'gallery_name' "$variables_file" | cut -d '"' -f 2)
  echo "Gallery: $gallery_name"

  # Checks if any of the required variables is empty
  if [ -z "$image_definition_name" ] || [ -z "$gdb_version" ] || [ -z "$gallery_resource_group" ] || [ -z "$gallery_name" ] || [ -z "$subscription_id" ]; then
    echo "One or more required variables are not defined in $variables_file."
    exit 1
  fi

  # Constructs the az sig image-definition create command
  az_command="az sig image-definition create \
       --subscription $subscription_id \
       -g $gallery_resource_group \
       --gallery-name $gallery_name \
       --gallery-image-definition "$image_definition_name" \
       --publisher Ontotext \
       --offer GraphDB \
       --sku "$gdb_version" \
       --os-type Linux \
       --hyper-v-generation v2 \
       --minimum-cpu-core 4 \
       --maximum-cpu-core 64 \
       --minimum-memory 4 \
       --maximum-memory 128 "

  echo "Extracted variables and constructed Azure CLI command:"
  echo "Creating SIG"
  eval "$az_command"
  # Waits for the Shared Image Gallery to be created
  az sig image-definition wait -i "$image_definition_name" -r "$gallery_name" -g "$gallery_resource_group" --created --subscription $subscription_id
  echo "Begin building of the Azure VM image"
  packer build -var-file="variables.pkrvars.hcl" .
else
  echo "The variables file $variables_file does not exist."
  exit 1
fi
