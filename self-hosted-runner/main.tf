terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
  # Configure your backend here (RECOMMENDED)
  backend "azurerm" {
    # You'll set these via CLI arguments or environment variables in the workflow
    # resource_group_name  = "your-tfstate-rg"
    # storage_account_name = "yourtfstatestorageaccount"
    # container_name       = "tfstate"
    # key                  = "prod/runner-vm/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  # Credentials will be supplied by environment variables in GitHub Actions
  # or by the azure/login action.
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the resources."
  type        = string
  default     = "eastus"
}

variable "vm_name_prefix" {
  description = "Prefix for the VM name."
  type        = string
  default     = "gh-runner"
}

variable "vm_size" {
  description = "Size of the VM."
  type        = string
  default     = "Standard_DS2_v2" # Choose an appropriate size
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM. Ensure this is strong if not using SSH keys."
  type        = string
  sensitive   = true # Mark as sensitive
}

variable "github_token" {
  description = "GitHub PAT for registering the runner."
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "URL of the GitHub repository (e.g., https://github.com/your-org/your-repo)."
  type        = string
}

variable "runner_labels" {
  description = "Comma-separated list of labels for the runner (e.g., self-hosted,linux,mongodb-access)."
  type        = string
  default     = "self-hosted,linux,x64,azure-vm" # self-hosted, linux, x64 are added by default
}

resource "random_pet" "runner_suffix" {
  length = 2
}

locals {
  vm_name      = "${var.vm_name_prefix}-${random_pet.runner_suffix.id}"
  runner_scope = trimsuffix(trimsuffix(var.github_repo_url, "/"), ".git") # Extracts owner/repo
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${local.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${local.vm_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic" # Or Static if needed
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" # Restrict this to your IP for better security if possible
    destination_address_prefix = "*"
  }
  # Add other rules as needed (e.g., for outbound access if restricted by default)
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.vm_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "${local.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS" # Or Standard_LRS
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal" # Ubuntu 20.04 LTS
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = local.vm_name # Hostname
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false # Set to true if using SSH keys exclusively

  # Custom script to install and configure GitHub Actions runner
  custom_data = base64encode(data.template_file.runner_script.rendered)

  # If using SSH keys (recommended over password)
  # admin_ssh_key {
  #   username   = var.admin_username
  #   public_key = file("~/.ssh/id_rsa.pub") # Or pass public key as a variable
  # }
}

data "template_file" "runner_script" {
  template = file("${path.module}/runner_setup.sh")
  vars = {
    GH_TOKEN      = var.github_token
    GH_REPO_URL   = local.runner_scope # Using the extracted owner/repo or full URL
    RUNNER_NAME   = local.vm_name
    RUNNER_LABELS = var.runner_labels
  }
}

output "vm_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}