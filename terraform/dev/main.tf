terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1" # Use a recent version
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.32.0"
    }
  }

  # This block is OPTIONAL for this simple example if you are using Terraform Cloud directly.
  # TFC workspaces manage their own backend state by default.
  # If you were running this locally and wanted to use TFC for state, you'd uncomment this.
  # cloud {
  #   organization = "DemoRomitOrg" # Replace with your TFC org name

  #   workspaces {
  #     name = "Workflow-Runner" # Replace with your desired TFC workspace name
  #   }
  # }
  
}

provider "random" {
  # No configuration needed for this provider
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = "my-terraform-azure-login-rg" # This will be the actual name of the RG in Azure
  location = "East US"         # Choose an Azure region that makes sense for you
}

resource "random_pet" "server_name" {
  length    = var.name_length
  separator = "-"
}

output "generated_pet_name" {
  value       = random_pet.server_name.id
  description = "A randomly generated pet name for a server."
}