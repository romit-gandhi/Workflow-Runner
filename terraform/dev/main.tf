# main.tf

# Configure Terraform Cloud integration
terraform {
  # cloud {
  #   organization = "DemoRomitOrg"
  #   workspaces {
  #     name = "Workflow-Runner"
  #   }
  # }
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# Generate a random number
resource "random_integer" "example" {
  min = 1
  max = 1000
}

# Output the random number
output "random_number" {
  value = random_integer.example.result
}