#!/bin/bash

# Deployment script to upload Hugo static site to Azure Blob Storage

set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

# Configuration from terraform.tfvars
RESOURCE_GROUP="hugo-coder-rg"
LOCATION="westeurope"
STORAGE_ACCOUNT="hugocoderstorage"
CONTAINER="\$web"  # special container for static website hosting

# Service Principal login credentials (set these environment variables before running)
SP_CLIENT_ID="${SP_CLIENT_ID:-}"
SP_CLIENT_SECRET="${SP_CLIENT_SECRET:-}"
TENANT_ID="${TENANT_ID:-}"

if [[ -z "$SP_CLIENT_ID" || -z "$SP_CLIENT_SECRET" || -z "$TENANT_ID" ]]; then
  echo "Error: SP_CLIENT_ID, SP_CLIENT_SECRET, and TENANT_ID environment variables must be set."
  exit 1
fi

echo "Logging into Azure CLI using Service Principal..."

az login --service-principal -u "$SP_CLIENT_ID" -p "$SP_CLIENT_SECRET" --tenant "$TENANT_ID"

echo "Building Hugo site in exampleSite directory..."
cd ./exampleSite

hugo

echo "Uploading static files to Azure Blob Storage..."

# Upload the contents of 'public/' directory to the blob container
az storage blob upload-batch \
  --account-name "$STORAGE_ACCOUNT" \
  --destination "$CONTAINER" \
  --source "public" \
  --overwrite

echo "Deployment complete."