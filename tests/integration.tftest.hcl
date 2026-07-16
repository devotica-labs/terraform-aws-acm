# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# No zone_id is supplied, so only the certificate request is created: a
# PENDING_VALIDATION cert is free, has no dependencies, and destroys cleanly
# without touching Route 53 or waiting for issuance.

provider "aws" {
  region = "ap-south-1"
}

variables {
  namespace   = "dvtca"
  stage       = "integ"
  name        = "acm"
  domain_name = "integ.example.com"

  tags = {
    Environment = "integration-test"
    Ephemeral   = "true"
  }
}

run "apply_and_assert" {
  command = apply

  assert {
    condition     = one([for c in aws_acm_certificate.this : c.arn]) != ""
    error_message = "Certificate must be created with an ARN."
  }
  assert {
    condition     = one([for c in aws_acm_certificate.this : c.validation_method]) == "DNS"
    error_message = "Certificate must request DNS validation."
  }
  assert {
    condition     = length(aws_acm_certificate_validation.this) == 0
    error_message = "Without zone_id, no validation wait resource is created."
  }
}
