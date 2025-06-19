variable "name_length" {
  description = "The number of words in the generated pet name."
  type        = number
  default     = 2
}

variable "auth0_domain" {
  description = "Auth0 domain URL"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Auth0 client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Auth0 client secret"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, test, demo, prod)"
  type        = string
}