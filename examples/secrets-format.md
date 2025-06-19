# GitHub Secrets Format

This document shows the expected JSON format for environment secrets in GitHub.

## Secret Names in GitHub

Create these secrets in your GitHub repository:
- `DEV_SECRETS` - Development environment secrets
- `TEST_SECRETS` - Test environment secrets  
- `DEMO_SECRETS` - Demo environment secrets
- `PROD_SECRETS` - Production environment secrets

## JSON Format

Each secret should contain a JSON object with all the required variables for that environment:

### Example DEV_SECRETS
```json
{
  "auth0_domain": "dev-example.auth0.com",
  "client_id": "dev_client_id_here",
  "client_secret": "dev_client_secret_here",
  "database_url": "postgresql://user:pass@dev-db:5432/myapp",
  "redis_url": "redis://dev-redis:6379",
  "api_key": "dev_api_key_here",
  "jwt_secret": "dev_jwt_secret_here",
  "aws_access_key_id": "AKIADEV123456789",
  "aws_secret_access_key": "dev_aws_secret_here",
  "stripe_public_key": "pk_test_dev_key_here",
  "stripe_secret_key": "sk_test_dev_secret_here",
  "sendgrid_api_key": "SG.dev_sendgrid_key_here",
  "google_client_id": "dev_google_client_id.googleusercontent.com",
  "google_client_secret": "dev_google_client_secret",
  "facebook_app_id": "dev_facebook_app_id",
  "facebook_app_secret": "dev_facebook_app_secret",
  "github_client_id": "dev_github_client_id",
  "github_client_secret": "dev_github_client_secret",
  "encryption_key": "dev_32_char_encryption_key_here",
  "webhook_secret": "dev_webhook_secret_here",
  "monitoring_api_key": "dev_monitoring_key_here",
  "cdn_url": "https://dev-cdn.example.com",
  "app_url": "https://dev-app.example.com",
  "admin_email": "admin-dev@example.com",
  "support_email": "support-dev@example.com",
  "log_level": "debug",
  "max_file_size": "10485760",
  "session_timeout": "3600",
  "rate_limit": "1000",
  "backup_retention_days": "7",
  "ssl_cert_path": "/etc/ssl/certs/dev-cert.pem",
  "ssl_key_path": "/etc/ssl/private/dev-key.pem"
}
```

### Example PROD_SECRETS
```json
{
  "auth0_domain": "prod-example.auth0.com",
  "client_id": "prod_client_id_here",
  "client_secret": "prod_client_secret_here",
  "database_url": "postgresql://user:pass@prod-db:5432/myapp",
  "redis_url": "redis://prod-redis:6379",
  "api_key": "prod_api_key_here",
  "jwt_secret": "prod_jwt_secret_here",
  "aws_access_key_id": "AKIAPROD123456789",
  "aws_secret_access_key": "prod_aws_secret_here",
  "stripe_public_key": "pk_live_prod_key_here",
  "stripe_secret_key": "sk_live_prod_secret_here",
  "sendgrid_api_key": "SG.prod_sendgrid_key_here",
  "google_client_id": "prod_google_client_id.googleusercontent.com",
  "google_client_secret": "prod_google_client_secret",
  "facebook_app_id": "prod_facebook_app_id",
  "facebook_app_secret": "prod_facebook_app_secret",
  "github_client_id": "prod_github_client_id",
  "github_client_secret": "prod_github_client_secret",
  "encryption_key": "prod_32_char_encryption_key_here",
  "webhook_secret": "prod_webhook_secret_here",
  "monitoring_api_key": "prod_monitoring_key_here",
  "cdn_url": "https://cdn.example.com",
  "app_url": "https://app.example.com",
  "admin_email": "admin@example.com",
  "support_email": "support@example.com",
  "log_level": "info",
  "max_file_size": "52428800",
  "session_timeout": "7200",
  "rate_limit": "5000",
  "backup_retention_days": "30",
  "ssl_cert_path": "/etc/ssl/certs/prod-cert.pem",
  "ssl_key_path": "/etc/ssl/private/prod-key.pem"
}
```

## How It Works

1. **GitHub Workflow**: Selects the appropriate secret based on the environment input
2. **Bash Script**: Receives the complete JSON and parses it
3. **Terraform Variables**: Each JSON key becomes a terraform variable

### Generated terraform.tfvars
```hcl
# Auto-generated terraform variables for dev environment
# Generated on: Mon Jan 15 10:30:45 UTC 2024

environment = "dev"

auth0_domain = "dev-example.auth0.com"
client_id = "dev_client_id_here"
client_secret = "dev_client_secret_here"
database_url = "postgresql://user:pass@dev-db:5432/myapp"
redis_url = "redis://dev-redis:6379"
# ... all other variables
```

### Generated Environment Variables
```bash
export TF_VAR_ENVIRONMENT=dev
export TF_VAR_AUTH0_DOMAIN=dev-example.auth0.com
export TF_VAR_CLIENT_ID=dev_client_id_here
export TF_VAR_CLIENT_SECRET=dev_client_secret_here
# ... all other variables as TF_VAR_*
```

## Benefits

1. **Scalability**: Easy to add new secrets without modifying workflow
2. **Maintainability**: All secrets for an environment in one place
3. **Security**: Secrets stay encrypted in GitHub
4. **Flexibility**: Same workflow works for any number of secrets
5. **Automation**: Automatic conversion to Terraform format 