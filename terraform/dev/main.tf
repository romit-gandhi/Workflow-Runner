terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "DemoRomitOrg"
    workspaces {
      name = "Workflow-Runner"
    }
  }
  required_providers {
    local = {
      source  = "hashiCorp/local"
      version = "~> 2.4"
    }
  }
}

provider "local" {}

variable "my_secret" {
  type      = string
  sensitive = true
}

resource "local_file" "example" {
  content  = "Generated file with secret: ${var.my_secret}"
  filename = "${path.module}/output-${var.my_secret}.txt"
}