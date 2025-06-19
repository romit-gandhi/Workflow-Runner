terraform {
}

output auth0_domain {
  value = var.auth0_domain
}

output auth0_client_id {
  value = var.auth0_client_id
}

output auth0_client_secret {
  value = var.auth0_client_secret
  sensitive = true
}