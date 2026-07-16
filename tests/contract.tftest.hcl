# Contract tests — the fintech defaults (DNS validation, RSA_2048 key) and the
# request/validate surface stay stable across versions. Config-set values only,
# since provider-computed attributes are unknown under mocks.

mock_provider "aws" {}

variables {
  namespace   = "dvtca"
  stage       = "test"
  name        = "contract"
  domain_name = "contract.example.com"
}

run "default_validation_method_is_dns" {
  command = plan
  assert {
    condition     = one([for c in aws_acm_certificate.this : c.validation_method]) == "DNS"
    error_message = "validation_method must default to DNS (never EMAIL)."
  }
}

run "default_key_algorithm_is_rsa_2048" {
  command = plan
  assert {
    condition     = one([for c in aws_acm_certificate.this : c.key_algorithm]) == "RSA_2048"
    error_message = "key_algorithm must default to RSA_2048."
  }
}

run "certificate_domain_from_input" {
  command = plan
  assert {
    condition     = one([for c in aws_acm_certificate.this : c.domain_name]) == "contract.example.com"
    error_message = "Certificate domain_name must be the supplied domain."
  }
}
