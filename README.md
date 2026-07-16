# terraform-aws-acm

[![CI](https://github.com/devotica-labs/terraform-aws-acm/actions/workflows/ci.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-acm/actions/workflows/ci.yml)
[![Release](https://github.com/devotica-labs/terraform-aws-acm/actions/workflows/release.yml/badge.svg)](https://github.com/devotica-labs/terraform-aws-acm/actions/workflows/release.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

> Part of the **Devotica** Terraform catalog. Follows the cloudposse module standard (README.yaml-driven docs, the `enabled`/`namespace`/`environment`/`stage`/`name`/`attributes`/`tags`/`label_order` label surface, `examples/complete`, Makefile targets) implemented **natively** — no external naming or build-harness dependencies.

## Introduction

Terraform module for an **AWS ACM TLS certificate** — the public certificate that fronts an ALB, API Gateway, or CloudFront distribution. It requests the certificate and, when handed a Route 53 hosted-zone id, writes the DNS validation records and waits for ACM to issue it, so downstreams depend on a fully-issued cert rather than a pending request.

Defaults are opinionated: **DNS validation** (automatable and auto-renewing — never EMAIL), an **RSA_2048** key (broadly compatible), and **`create_before_destroy`** on the certificate so a renewal or replacement never leaves a listener without a valid cert.

## Usage

```hcl
module "acm" {
  source  = "devotica-labs/acm/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "api"

  domain_name = "api.example.com"

  # Supplying zone_id turns on automatic DNS validation via Route 53 and
  # waits for issuance.
  zone_id = module.dns.zone_id

  tags = local.tags
}
```

A wildcard certificate with extra SANs:

```hcl
module "acm" {
  source  = "devotica-labs/acm/aws"
  version = "~> 0.1"

  namespace = "dvtca"
  stage     = "prod"
  name      = "web"

  domain_name = "*.example.com"
  subject_alternative_names = [
    "example.com",
    "api.example.com",
  ]

  zone_id = module.dns.zone_id
}
```

Omit `zone_id` to create only the certificate request and handle validation out-of-band (the records are exposed via the `domain_validation_options` output).

See [`examples/basic`](examples/basic) and [`examples/complete`](examples/complete).

## Defaults that matter

| Setting | Default | Why |
|---------|---------|-----|
| `validation_method` | `DNS` | Automatable and auto-renewing; no human clicks an email link. |
| `key_algorithm` | `RSA_2048` | Broadly compatible with clients and load balancers. |
| `create_before_destroy` | on | A renewal/replacement never leaves a listener without a certificate. |
| `zone_id` | `null` | When set, DNS validation records are written and issuance is awaited; when null, only the request is created. |
| `validation_record_ttl` | `300` | TTL (seconds) for the Route 53 validation records. |

## How this fits the Devotica catalog

`terraform-aws-alb` terminates TLS with a certificate produced here — pass this module's `certificate_arn` into the listener. `terraform-aws-wafv2` protects the same edge. Route 53 hosted zones supply the `zone_id` used for automatic DNS validation.

## Makefile Targets

```
make fmt       # terraform fmt -recursive
make validate  # terraform init -backend=false && terraform validate
make test      # terraform test (unit + contract; integration needs AWS creds)
make readme    # regenerate the terraform-docs block below
```

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs regenerates this block via `make readme` / CI. Inputs and
     outputs are documented in variables.tf and outputs.tf. -->
<!-- END_TF_DOCS -->

## License

[Apache 2.0](LICENSE) © Devotica
