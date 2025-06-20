terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  // Optional: Configure remote backend for state file (recommended for collaboration)
  // backend "azurerm" {
  //   resource_group_name  = "rg-terraform-state"
  //   storage_account_name = "tfstategithubactions"
  //   container_name       = "tfstate"
  //   key                  = "mongodump-vm.tfstate"
  // }
}

provider "azurerm" {
  features {}
  // Credentials will be supplied by GitHub Actions secrets
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static" # Static so it doesn't change on stop/start
  sku                 = "Standard" # Required for some VM SKUs and availability zones
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  // Allow SSH for debugging if needed (restrict source IP in production)
  // security_rule {
  //   name                       = "SSH"
  //   priority                   = 1001
  //   direction                  = "Inbound"
  //   access                     = "Allow"
  //   protocol                   = "Tcp"
  //   source_port_range          = "*"
  //   destination_port_range     = "22"
  //   source_address_prefix      = "YOUR_HOME_IP_FOR_SSH" // Or "*" for testing, then lock down
  //   destination_address_prefix = "*"
  // }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password // Consider using ssh_key instead for better security
  disable_password_authentication = false // Set to true if using SSH keys
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" // Or Premium_LRS
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2" # Using Ubuntu 22.04 LTS Gen2
    version   = "latest"
  }

  // Cloud-init script to install Docker, GitHub Runner, and MongoDB tools
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg jq

    # Install Docker (optional, but good for consistent environments)
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Install MongoDB Database Tools (for mongodump)
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-database-tools

    # Create a directory for the runner
    mkdir /actions-runner && cd /actions-runner

    # Download the latest runner package
    LATEST_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/v//')
    curl -o actions-runner-linux-x64-${LATEST_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${LATEST_VERSION}/actions-runner-linux-x64-${LATEST_VERSION}.tar.gz
    tar xzf ./actions-runner-linux-x64-${LATEST_VERSION}.tar.gz

    # Configure the runner (as a service)
    # The GITHUB_RUNNER_TOKEN will be passed via Terraform variables
    # The GITHUB_REPO_URL will be passed via Terraform variables
    sudo ./bin/installdependencies.sh
    ./config.sh --url "${var.github_repo_url}" --token "${var.github_runner_token}" --name "${var.vm_name}-runner" --labels "${var.runner_labels}" --unattended --replace --ephemeral
    
    # Install and start the runner service
    sudo ./svc.sh install
    sudo ./svc.sh start
    EOF
  )

  tags = {
    environment = "terraform-runner"
    managedBy   = "terraform-githubactions"
  }
}

output "vm_public_ip" {
  description = "Public IP address of the VM runner"
  value       = azurerm_public_ip.pip.ip_address
}

output "vm_id" {
  description = "ID of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.vm.id
}