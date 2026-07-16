locals {
  # Auto DNS-validation is driven entirely by whether a hosted-zone id is given.
  # No zone_id → request only; the caller wires up validation out-of-band.
  create_validation = local.enabled && var.zone_id != null

  # Static set of domains that need a validation record (the apex plus each SAN).
  # These are configured inputs, so they are known at plan time and can key the
  # Route 53 for_each; the record name/type/value are looked up per-domain from
  # the certificate's provider-computed domain_validation_options.
  validation_domains = local.create_validation ? distinct(concat([var.domain_name], var.subject_alternative_names)) : []
}
