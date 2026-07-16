# A single DNS-validated ACM certificate. Fintech defaults: DNS validation (not
# EMAIL — no human in the loop, fully automatable), an RSA_2048 key, and
# create_before_destroy so a renewal/replacement never leaves a listener without
# a certificate. When var.zone_id is set, the module also writes the Route 53
# validation records and waits for issuance; otherwise it emits only the request
# and the caller validates out-of-band.
resource "aws_acm_certificate" "this" {
  count = local.enabled ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  key_algorithm             = var.key_algorithm

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

# One validation record per certificate domain (the apex plus each SAN), created
# only when a zone_id is supplied. Keys are the configured domains (known at
# plan); the record fields are read from the certificate's computed
# domain_validation_options by matching on domain_name. allow_overwrite
# tolerates the duplicate CNAME that arises when a wildcard and its apex share a
# validation record.
resource "aws_route53_record" "validation" {
  for_each = toset(local.validation_domains)

  zone_id         = var.zone_id
  name            = one([for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.resource_record_name if dvo.domain_name == each.key])
  type            = one([for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.resource_record_type if dvo.domain_name == each.key])
  records         = [one([for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.resource_record_value if dvo.domain_name == each.key])]
  ttl             = var.validation_record_ttl
  allow_overwrite = true
}

# Blocks until ACM observes the DNS records and issues the certificate. Created
# only alongside the Route 53 validation records (zone_id set).
resource "aws_acm_certificate_validation" "this" {
  count = local.create_validation ? 1 : 0

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
