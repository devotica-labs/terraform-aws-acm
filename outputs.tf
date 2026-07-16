output "certificate_arn" {
  description = "ARN of the certificate. When zone_id is set this is the arn from the aws_acm_certificate_validation resource (so downstreams depend on a fully-issued cert); otherwise it is the aws_acm_certificate arn."
  value       = local.create_validation ? join("", aws_acm_certificate_validation.this[*].certificate_arn) : join("", aws_acm_certificate.this[*].arn)
}

output "certificate_domain_name" {
  description = "The primary domain name the certificate was issued for."
  value       = try(aws_acm_certificate.this[0].domain_name, null)
}

output "domain_validation_options" {
  description = "The CNAME records ACM requires to validate domain ownership (apex + each SAN). Useful when zone_id is null and validation is handled out-of-band."
  value       = try(aws_acm_certificate.this[0].domain_validation_options, toset([]))
}
