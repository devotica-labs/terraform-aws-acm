# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: an AWS ACM TLS certificate with fintech-safe defaults — DNS
  validation (never EMAIL), an RSA_2048 key, and `create_before_destroy` on the
  certificate. When `zone_id` is supplied the module also creates the Route 53
  validation records and an `aws_acm_certificate_validation` resource that waits
  for issuance; when `zone_id` is null it emits only the request and exposes the
  `domain_validation_options` for out-of-band validation. Supports
  `subject_alternative_names` (wildcard + SANs). Native `label.tf` naming;
  derived from `cloudposse/terraform-aws-acm-request-certificate`.
