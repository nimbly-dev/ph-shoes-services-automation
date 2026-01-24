# domain/outputs.tf

output "zone_id" {
  value       = local.zone_id
  description = "Hosted zone ID used by the module"
}

output "www_fqdn" {
  value       = "www.${local.zone_name_effective}"
  description = "The www host configured via CNAME"
}

output "root_a_set" {
  value       = var.create_root_a
  description = "Whether an A record was created for the apex/root"
}

output "ses_domain_identity_arn" {
  value       = try(aws_ses_domain_identity.ses[0].arn, null)
  description = "SES domain identity ARN (when manage_ses = true)"
}
