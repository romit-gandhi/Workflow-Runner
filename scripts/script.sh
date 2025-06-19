#!/bin/bash

# script.sh - Deploy infrastructure using Terraform
set -e  # Exit on any error

# Validate arguments
if [ $# -ne 4 ]; then
  echo "Error: Expected 4 arguments (auth0_domain, client_id, client_secret, environment)"
  echo "Usage: $0 <auth0_domain> <client_id> <client_secret> <environment>"
  exit 1
fi

# Get the arguments
AUTH0_DOMAIN="$1"
CLIENT_ID="$2"
CLIENT_SECRET="$3"
ENVIRONMENT="$4"

# Validate required arguments are not empty
if [ -z "$AUTH0_DOMAIN" ] || [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ] || [ -z "$ENVIRONMENT" ]; then
  echo "Error: All arguments must be non-empty"
  exit 1
fi

echo "========================================="
echo "Starting deployment for environment: $ENVIRONMENT"
echo "========================================="
echo "Auth0 Domain: $AUTH0_DOMAIN"
echo "Client ID: $CLIENT_ID"
echo "Client Secret: [HIDDEN]"
echo "========================================="

# Set Terraform variables
export TF_VAR_auth0_domain="$AUTH0_DOMAIN"
export TF_VAR_client_id="$CLIENT_ID"
export TF_VAR_client_secret="$CLIENT_SECRET"
export TF_VAR_environment="$ENVIRONMENT"

# Additional environment variables that might be useful
export TF_IN_AUTOMATION=true
export TF_INPUT=false

# Run terraform version command
echo "Checking Terraform version..."
terraform version

# Check if terraform directory exists
TERRAFORM_DIR="terraform/$ENVIRONMENT"
if [ ! -d "$TERRAFORM_DIR" ]; then
  echo "Error: Terraform directory '$TERRAFORM_DIR' does not exist"
  exit 1
fi

# Navigate to the appropriate terraform directory based on environment
echo "Navigating to $TERRAFORM_DIR..."
cd "$TERRAFORM_DIR"

# Verify terraform configuration
echo "Validating Terraform configuration..."
terraform fmt -check=true -diff=true || {
  echo "Warning: Terraform files are not properly formatted"
  terraform fmt
}

# Initialize terraform
echo "Initializing Terraform..."
terraform init -input=false -upgrade

# Validate terraform configuration
echo "Validating Terraform configuration..."
terraform validate

# Create terraform plan
echo "Creating Terraform plan..."
terraform plan -input=false -out=tfplan

# Apply terraform plan
echo "Applying Terraform plan..."
terraform apply -input=false -auto-approve tfplan

# Clean up plan file
rm -f tfplan

echo "========================================="
echo "Deployment completed successfully!"
echo "========================================="