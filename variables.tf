# ---------------------------------------------------------------------------
# Certificate
# ---------------------------------------------------------------------------
variable "domain_name" {
  type        = string
  description = "The fully qualified domain name the certificate is issued for (e.g. \"api.example.com\" or a wildcard \"*.example.com\"). Must be lower-case."

  validation {
    condition     = !can(regex("[A-Z]", var.domain_name))
    error_message = "domain_name must be lower-case."
  }
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domains covered by the same certificate (SANs), e.g. [\"www.example.com\", \"*.example.com\"]. All entries must be lower-case."
  default     = []

  validation {
    condition     = length([for name in var.subject_alternative_names : name if can(regex("[A-Z]", name))]) == 0
    error_message = "All subject_alternative_names must be lower-case."
  }
}

variable "validation_method" {
  type        = string
  description = "How ACM verifies domain ownership: DNS (recommended — automatable, auto-renewing) or EMAIL."
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "validation_method must be DNS or EMAIL."
  }
}

variable "key_algorithm" {
  type        = string
  description = "Public/private key-pair algorithm for the certificate. RSA_2048 is the broadly compatible default; EC_* algorithms are smaller/faster where clients support them."
  default     = "RSA_2048"

  validation {
    condition     = contains(["RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096", "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"], var.key_algorithm)
    error_message = "key_algorithm must be one of: RSA_1024, RSA_2048, RSA_3072, RSA_4096, EC_prime256v1, EC_secp384r1, EC_secp521r1."
  }
}

# ---------------------------------------------------------------------------
# DNS validation (Route 53)
# ---------------------------------------------------------------------------
variable "zone_id" {
  type        = string
  description = "Route 53 hosted-zone id in which to create the DNS validation records. When set, the module writes the validation CNAMEs and waits for issuance. When null (default), only the certificate request is created and the caller validates out-of-band."
  default     = null
}

variable "validation_record_ttl" {
  type        = number
  description = "TTL (seconds) for the Route 53 DNS validation records. Only used when zone_id is set."
  default     = 300

  validation {
    condition     = var.validation_record_ttl >= 0
    error_message = "validation_record_ttl must be 0 or greater."
  }
}
