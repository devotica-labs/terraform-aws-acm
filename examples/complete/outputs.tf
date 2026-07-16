output "certificate_arn" {
  description = "ARN of the issued wildcard certificate."
  value       = module.acm.certificate_arn
}

output "certificate_domain_name" {
  description = "Primary (wildcard) domain the certificate covers."
  value       = module.acm.certificate_domain_name
}

output "domain_validation_options" {
  description = "The DNS validation records ACM required (apex + each SAN)."
  value       = module.acm.domain_validation_options
}
