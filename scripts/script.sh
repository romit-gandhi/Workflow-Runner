# script.sh
if [ -z "$1" ]; then
  echo "Error: No argument provided"
  exit 1
fi
echo "Argument received (length: ${#1})"
echo "Argument: $1"

# Get the argument (secret)
SECRET="$1"


# Run terraform version command
echo "Running terraform version..."
terraform version

cd terraform/dev
export TF_VAR_my_secret="$SECRET"
terraform init -input=false
terraform plan -input=false
terraform apply -auto-approve -input=false