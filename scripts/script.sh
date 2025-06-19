#!/bin/bash

# script.sh - Process environment secrets and convert to Terraform variables
# Usage: ./script.sh "<JSON_SECRETS>" "<ENVIRONMENT>"

set -e  # Exit on any error

# Check if required arguments are provided
if [ $# -ne 2 ]; then
    echo "Error: Script requires exactly 2 arguments"
    echo "Usage: $0 '<JSON_SECRETS>' '<ENVIRONMENT>'"
    exit 1
fi

JSON_SECRETS="$1"
ENVIRONMENT="$2"

echo "Processing secrets for environment: $ENVIRONMENT"

# Validate JSON format
if ! echo "$JSON_SECRETS" | jq empty 2>/dev/null; then
    echo "Error: Invalid JSON format in secrets"
    exit 1
fi

# Set environment variable for environment
export TF_VAR_ENVIRONMENT="$ENVIRONMENT"
echo "  ✓ TF_VAR_ENVIRONMENT"

# Convert every JSON key to TF_VAR_ environment variable
echo "Setting Terraform environment variables..."
while IFS="=" read -r key value; do
    # Add TF_VAR_ prefix without changing case
    tf_var_name="TF_VAR_$key"
    # Remove quotes from value
    clean_value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
    # Export the variable
    export "$tf_var_name=$clean_value"
    echo "  ✓ $tf_var_name"
done < <(echo "$JSON_SECRETS" | jq -r 'to_entries[] | "\(.key)=\(.value)"')

echo "*-*-*-*-*-*-*-*-*-"
echo "Sample variables:"
echo "TF_VAR_auth0_domain: $TF_VAR_auth0_domain"
echo "TF_VAR_client_id: $TF_VAR_auth0_client_id"
echo "TF_VAR_client_secret: $TF_VAR_auth0_client_secret"
echo "*-*-*-*-*-*-*-*-*-"

cd "environments/$ENVIRONMENT"
pwd

echo "Initializing Terraform..."
terraform init -input=false

echo "Terraform Plan"
echo "Running Terraform plan..."
terraform plan -input=false

echo "Terraform Apply"
echo "Running Terraform apply..."
terraform apply -auto-approve -input=false

echo ""
echo "Script completed successfully!"