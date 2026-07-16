# Plan-only unit tests — no AWS credentials required. domain_validation_options
# is provider-computed (unknown under mocks), so validation-record cardinality is
# asserted via the count-driven aws_acm_certificate_validation resource, whose
# presence is a pure function of config (zone_id), not of computed attributes.

mock_provider "aws" {}

variables {
  namespace   = "dvtca"
  stage       = "test"
  name        = "unit"
  domain_name = "api.test.example.com"
}

run "certificate_planned_by_default" {
  command = plan
  assert {
    condition     = length(aws_acm_certificate.this) == 1
    error_message = "Exactly one ACM certificate must be planned."
  }
}

run "no_validation_without_zone_id" {
  command = plan
  # zone_id unset (default null) → request only, no Route 53 wiring / wait.
  assert {
    condition     = length(aws_acm_certificate_validation.this) == 0
    error_message = "No certificate-validation resource unless zone_id is set."
  }
}

run "validation_when_zone_id_set" {
  command = plan
  variables {
    zone_id = "Z01234567890ABCDEFGHI"
  }
  assert {
    condition     = length(aws_acm_certificate_validation.this) == 1
    error_message = "A certificate-validation resource must be planned when zone_id is set."
  }
  assert {
    condition     = length(aws_route53_record.validation) == 1
    error_message = "One Route 53 validation record for a single-domain certificate."
  }
}

run "validation_record_per_domain" {
  command = plan
  variables {
    zone_id                   = "Z01234567890ABCDEFGHI"
    subject_alternative_names = ["www.test.example.com", "app.test.example.com"]
  }
  assert {
    condition     = length(aws_route53_record.validation) == 3
    error_message = "One validation record per domain (apex + each SAN)."
  }
}

run "sans_pass_through" {
  command = plan
  variables {
    subject_alternative_names = ["www.test.example.com", "app.test.example.com"]
  }
  assert {
    condition     = one([for c in aws_acm_certificate.this : length(c.subject_alternative_names)]) == 2
    error_message = "subject_alternative_names must pass through to the certificate."
  }
}

run "disabled_creates_nothing" {
  command = plan
  variables {
    enabled = false
  }
  assert {
    condition     = length(aws_acm_certificate.this) == 0
    error_message = "enabled = false must create no certificate."
  }
}
