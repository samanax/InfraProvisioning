#!/bin/bash
# Create Terraform backend to Azure

# Workspace name required as parameter.
WORKSPACE=$1

if [ -z "$WORKSPACE" ]; then
  echo "Missing argument: workspace name (dev, staging or prod)"
  exit 1
fi

RESOURCE_GROUP_NAME="SaaS-Shared-$WORKSPACE"
STORAGE_ACCOUNT_NAME="SaaSterraform$WORKSPACE"
LOCATION="westeurope"

az login --service-principal -u $ARM_CLIENT_ID --tenant $ARM_TENANT_ID -p $ARM_CLIENT_SECRET

echo "Creating resource group..\n"
az group create \
  --location $LOCATION \
  --name $RESOURCE_GROUP_NAME \
  --subscription $ARM_SUBSCRIPTION_ID

echo "Creating storage account..\n"
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --subscription $ARM_SUBSCRIPTION_ID \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind BlobStorage \
  --access-tier Hot

echo "Enabling soft-delete to storage account..\n"
az storage blob service-properties delete-policy update \
  --days-retained 7 \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --enable true

echo "Creating storage container..\n"
az storage container create \
  --name "terraformstate" \
  --subscription $ARM_SUBSCRIPTION_ID \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --subscription $ARM_SUBSCRIPTION_ID --query "[?keyName=='key1'].value" --output tsv)" \
  --public-access off
