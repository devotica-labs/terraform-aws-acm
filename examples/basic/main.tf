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

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/acm/aws"
#   version = "~> 0.1"

# A single-domain certificate, DNS-validated in a Route 53 hosted zone: the
# module writes the validation CNAME and waits for ACM to issue the cert.
module "acm" {
  source = "../.."

  namespace = "dvtca"
  stage     = "sandbox"
  name      = "api"

  domain_name = "api.sandbox.example.com"

  # Supplying zone_id turns on automatic DNS validation via Route 53.
  zone_id = "Z01234567890ABCDEFGHI"

  # Fintech defaults cover the rest: DNS validation, RSA_2048 key, and
  # create_before_destroy on the certificate.

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-acm"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-acm"
  }
}
