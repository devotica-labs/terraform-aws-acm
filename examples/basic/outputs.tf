output "certificate_arn" {
  description = "ARN of the issued certificate."
  value       = module.acm.certificate_arn
}

output "certificate_domain_name" {
  description = "Primary domain the certificate covers."
  value       = module.acm.certificate_domain_name
}
