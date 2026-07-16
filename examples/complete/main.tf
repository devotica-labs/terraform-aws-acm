# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# A wildcard certificate that also covers the apex and several service
# subdomains as SANs, DNS-validated in a Route 53 hosted zone. One certificate
# fronts every host under the domain; ACM auto-renews it as long as the
# validation records stay in place.
module "acm" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "web"

  # Wildcard primary domain, plus the apex and specific hosts as SANs.
  domain_name = "*.example.com"
  subject_alternative_names = [
    "example.com",
    "api.example.com",
    "app.example.com",
  ]

  # Explicit fintech defaults (shown for clarity; these are the module defaults).
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  # Automatic DNS validation via Route 53, with a tuned record TTL.
  zone_id               = "Z01234567890ABCDEFGHI"
  validation_record_ttl = 60

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-acm"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-acm"
  }
}
