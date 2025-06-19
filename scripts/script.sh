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

# Create terraform.tfvars file
TFVARS_FILE="terraform.tfvars"
echo "# Auto-generated terraform variables for $ENVIRONMENT environment" > "$TFVARS_FILE"
echo "# Generated on: $(date)" >> "$TFVARS_FILE"
echo "" >> "$TFVARS_FILE"

# Add environment variable
echo "environment = \"$ENVIRONMENT\"" >> "$TFVARS_FILE"
echo "" >> "$TFVARS_FILE"

# Parse JSON and convert each key-value pair to terraform variable
echo "$JSON_SECRETS" | jq -r 'to_entries[] | "\(.key) = \"\(.value)\""' >> "$TFVARS_FILE"

echo "Terraform variables file created: $TFVARS_FILE"
echo "Variables generated:"

# Display the generated variables (hide sensitive values)
while IFS= read -r line; do
    if [[ $line == *"="* ]] && [[ $line != "#"* ]]; then
        key=$(echo "$line" | cut -d'=' -f1 | xargs)
        echo "  ✓ $key"
    fi
done < "$TFVARS_FILE"

# Optional: Create environment variables for current shell session
echo ""
echo "Setting environment variables..."
while IFS= read -r line; do
    if [[ $line == *"="* ]] && [[ $line != "#"* ]]; then
        # Convert terraform format to environment variable format
        key=$(echo "$line" | cut -d'=' -f1 | xargs | tr '[:lower:]' '[:upper:]')
        value=$(echo "$line" | cut -d'=' -f2- | xargs | sed 's/^"//' | sed 's/"$//')
        export "TF_VAR_$key=$value"
        echo "  ✓ TF_VAR_$key"
    fi
done < "$TFVARS_FILE"

cd "environments/$ENVIRONMENT"
pwd
# Optional: Initialize and plan Terraform

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