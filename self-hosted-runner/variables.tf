variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-mongodump-runner"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US" # Choose your preferred region
}

variable "vm_name" {
  description = "Name for the Virtual Machine"
  type        = string
  default     = "terraform-runner-vm"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B1s" # Choose a cost-effective size
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

// It's better to generate an SSH key and use the public key
// or retrieve a password from a secure vault.
// For simplicity here, we'll allow a password, but secure this in production.
variable "admin_password" {
  description = "Admin password for the VM. Use a strong, unique password or SSH key."
  type        = string
  sensitive   = true
}

variable "github_runner_token" {
  description = "GitHub Actions Runner Registration Token (PAT or from runner settings)"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "URL of the GitHub repository (e.g., https://github.com/your_org/your_repo)"
  type        = string
}

variable "runner_labels" {
  description = "Labels for the self-hosted runner"
  type        = string
  default     = "azure-vm,mongodump-runner"
}