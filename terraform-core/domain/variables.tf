# domain/variables.tf

variable "zone_id" {
  description = "Existing Route 53 hosted zone ID. If not set, zone_name must be provided."
  type        = string
  default     = ""
}

variable "zone_name" {
  description = "Existing Route 53 hosted zone name (e.g., phshoesproject.com). Used when zone_id is not provided."
  type        = string
  default     = ""
}

variable "render_www_target" {
  description = "Your Render frontend hostname (e.g., ph-shoes-frontend.onrender.com). Used for www CNAME."
  type        = string
}

variable "create_root_a" {
  description = "Create an A record for the apex/root pointing to Render's IP."
  type        = bool
  default     = true
}

variable "root_a_ip" {
  description = "IPv4 to point the root/apex to when using Render (fallback when ALIAS to non-AWS host not supported)."
  type        = string
  default     = "216.24.57.1"
}

variable "additional_cnames" {
  description = "Optional extra CNAMEs: map(subdomain_without_zone => target hostname). Example: { api = \"my-api.onrender.com\" }"
  type        = map(string)
  default     = {}
}

variable "manage_ses" {
  description = "Whether to create SES domain identity + DKIM and the necessary Route53 records."
  type        = bool
  default     = true
}

variable "ses_domain" {
  description = "Domain to verify with SES (defaults to zone_name when empty)."
  type        = string
  default     = ""
}

variable "create_mail_from" {
  description = "Whether to configure a MAIL FROM subdomain with MX+TXT (SPF)."
  type        = bool
  default     = false
}

variable "mail_from_subdomain" {
  description = "MAIL FROM subdomain (only used when create_mail_from = true)."
  type        = string
  default     = "mail"
}

variable "enable_dmarc" {
  description = "Create a DMARC TXT record for the domain."
  type        = bool
  default     = true
}

variable "dmarc_policy" {
  description = "DMARC policy: none | quarantine | reject."
  type        = string
  default     = "none"
}

variable "dmarc_rua" {
  description = "Aggregate report mailbox (e.g., dmarc-reports@phshoesproject.com). Leave blank to omit."
  type        = string
  default     = ""
}

variable "dmarc_ruf" {
  description = "Forensic report mailbox (optional). Leave blank to omit."
  type        = string
  default     = ""
}

variable "dmarc_pct" {
  description = "Percent of messages DMARC applies to (1–100)."
  type        = number
  default     = 100
}

variable "dmarc_adkim" {
  description = "DKIM alignment: r (relaxed) or s (strict)."
  type        = string
  default     = "s"
}

variable "dmarc_aspf" {
  description = "SPF alignment: r (relaxed) or s (strict)."
  type        = string
  default     = "s"
}

variable "dmarc_sp" {
  description = "Subdomain policy (defaults to same as dmarc_policy when empty)."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags for any created AWS resources (SES identity)."
  type        = map(string)
  default     = {}
}
