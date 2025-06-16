terraform {
  required_providers {
    local = {
      source  = "hashiCorp/local"
      version = "~> 2.4"
    }
  }
}

provider "local" {}

# variable "my_secret" {
#   type      = string
#   sensitive = true # Marks the variable as sensitive to avoid logging
# }

resource "local_file" "example" {
  content  = "Generated file with secret: Demo"
  filename = "${path.module}/output-demo.txt"
}

output "file_path" {
  value     = local_file.example.filename
}