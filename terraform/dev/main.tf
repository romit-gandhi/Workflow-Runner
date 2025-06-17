terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1" # Use a recent version
    }
  }

  # This block is OPTIONAL for this simple example if you are using Terraform Cloud directly.
  # TFC workspaces manage their own backend state by default.
  # If you were running this locally and wanted to use TFC for state, you'd uncomment this.
  /*
  cloud {
    organization = "your-tfc-organization-name" # Replace with your TFC org name

    workspaces {
      name = "random-number-demo" # Replace with your desired TFC workspace name
    }
  }
  */
}

provider "random" {
  # No configuration needed for this provider
}

resource "random_pet" "server_name" {
  length    = var.name_length
  separator = "-"
}

output "generated_pet_name" {
  value       = random_pet.server_name.id
  description = "A randomly generated pet name for a server."
}