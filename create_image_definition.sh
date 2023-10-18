#!/bin/bash

# Required when running the script on Windows
alias az=az.cmd || true

# Specify the path to the variables file
variables_file="variables.pkrvars.hcl"

# Check if the file exists
if [ -f "$variables_file" ]; then
    # Use grep to extract the variable values
    
    image_definition_name=$(grep 'image_definition_name' "$variables_file" | cut -d '"' -f 2)
    gdb_version=$(grep 'gdb_version' "$variables_file" | cut -d '"' -f 2)
    gallery_resource_group=$(grep 'gallery_resource_group' "$variables_file" | cut -d '"' -f 2)
    gallery_name=$(grep 'gallery_name' "$variables_file" | cut -d '"' -f 2)
    
    # Check if any of the required variables is empty
    if [ -z "$image_definition_name" ] || [ -z "$gdb_version" ] || [ -z "$gallery_resource_group" ] || [ -z "$gallery_name" ]; then
        echo "One or more required variables are not defined in $variables_file."
        exit 1
    fi
    # Construct the az sig image-definition create command
    az_command="az sig image-definition create \
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
    eval "$az_command"
    az sig image-definition wait -i "$image_name_x86_64" -r "$gallery_name" -g "$gallery_resource_group"  --created
    packer build -var-file="variables.pkrvars.hcl" .
else
    echo "The variables file $variables_file does not exist."
    exit 1
fi
