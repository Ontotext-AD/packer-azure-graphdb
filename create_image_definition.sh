#!/usr/bin/env bash

# This script sets up Azure Shared Image Gallery (SIG) image definition and builds an image using Packer.
# It checks for a variables file, extracts necessary parameters, constructs an Azure CLI command for image definition creation,
# executes the command, waits for creation completion,
# and finally uses Packer to build the image based on the specified variables.

set -euo pipefail

# Required when running the script on Windows
alias az=az.cmd || true

# Specify the path to the variables file
variables_file="variables.pkrvars.hcl"

# Check if the file exists
if ! [ -f "$variables_file" ]; then
  echo "The variables file $variables_file does not exist."
  exit 1
fi

# Extracts required variables from the variables_file
subscription_id=$(grep 'subscription_id' "$variables_file" | cut -d '"' -f 2)
echo "Subscription ID: $subscription_id"
gallery_image_definition=$(grep 'gallery_image_definition' "$variables_file" | cut -d '"' -f 2)
echo "Image definition name: $gallery_image_definition"
graphdb_version=$(grep 'graphdb_version' "$variables_file" | cut -d '"' -f 2)
echo "GraphDB version: $graphdb_version"
gallery_resource_group=$(grep 'gallery_resource_group' "$variables_file" | cut -d '"' -f 2)
echo "Resource group: $gallery_resource_group"
gallery_name=$(grep 'gallery_name' "$variables_file" | cut -d '"' -f 2)
echo "Gallery: $gallery_name"

# Checks if any of the required variables is empty
if [ -z "$gallery_image_definition" ] || [ -z "$graphdb_version" ] || [ -z "$gallery_resource_group" ] || [ -z "$gallery_name" ] || [ -z "$subscription_id" ]; then
  echo "One or more required variables are not defined in $variables_file."
  exit 1
fi

# Constructs the az sig image-definition create command
az_command="az sig image-definition create \
     --subscription $subscription_id \
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

# TODO: defuk is this :
echo "Extracted variables and constructed Azure CLI command:"
echo "Creating SIG"
eval "$az_command"
# Waits for the Shared Image Gallery to be created
az sig image-definition wait -i "$gallery_image_definition" -r "$gallery_name" -g "$gallery_resource_group" --created --subscription $subscription_id
echo "Begin building of the Azure VM image"
