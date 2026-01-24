# domain/main.tf

data "aws_region" "current" {}

# -----------------------
# Zone resolution
# -----------------------
locals {
  zone_name_effective = length(trimspace(var.zone_name)) > 0 ? trimsuffix(trimspace(var.zone_name), ".") : null
}

data "aws_route53_zone" "this" {
  count        = var.zone_id == "" ? 1 : 0
  name         = "${local.zone_name_effective}."
  private_zone = false
}

locals {
  zone_id              = var.zone_id != "" ? var.zone_id : data.aws_route53_zone.this[0].zone_id
  ses_domain_effective = length(trimspace(var.ses_domain)) > 0 ? trimsuffix(trimspace(var.ses_domain), ".") : local.zone_name_effective
}

# -----------------------
# Frontend DNS (Render)
# -----------------------

# www -> Render (CNAME)
resource "aws_route53_record" "www" {
  zone_id = local.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 300
  records = [var.render_www_target]
}

# apex/root -> Render (A record to Render's fallback IP; ALIAS can't target onrender.com)
resource "aws_route53_record" "root_a" {
  count   = var.create_root_a ? 1 : 0
  zone_id = local.zone_id
  name    = ""
  type    = "A"
  ttl     = 300
  records = [var.root_a_ip]
}

# Optional extra subdomains (CNAMEs)
resource "aws_route53_record" "extra_cnames" {
  for_each = var.additional_cnames
  zone_id  = local.zone_id
  name     = each.key
  type     = "CNAME"
  ttl      = 300
  records  = [each.value]
}

# -----------------------
# SES domain + DKIM (optional)
# -----------------------
resource "aws_ses_domain_identity" "ses" {
  count  = var.manage_ses ? 1 : 0
  domain = local.ses_domain_effective
}

# TXT for SES domain verification
resource "aws_route53_record" "ses_verification" {
  count   = var.manage_ses ? 1 : 0
  zone_id = local.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.ses[0].domain}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.ses[0].verification_token]
}

# DKIM tokens (3 CNAMEs)
resource "aws_ses_domain_dkim" "ses" {
  count  = var.manage_ses ? 1 : 0
  domain = aws_ses_domain_identity.ses[0].domain
}

resource "aws_route53_record" "ses_dkim" {
  count   = var.manage_ses ? 3 : 0
  zone_id = local.zone_id
  name    = "${element(aws_ses_domain_dkim.ses[0].dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.ses[0].domain}"
  type    = "CNAME"
  ttl     = 600
  records = ["${element(aws_ses_domain_dkim.ses[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# Optional: MAIL FROM subdomain (MX + SPF TXT)
resource "aws_ses_domain_mail_from" "this" {
  count            = var.manage_ses && var.create_mail_from ? 1 : 0
  domain           = aws_ses_domain_identity.ses[0].domain
  mail_from_domain = "${var.mail_from_subdomain}.${aws_ses_domain_identity.ses[0].domain}"
}

resource "aws_route53_record" "mail_from_mx" {
  count   = var.manage_ses && var.create_mail_from ? 1 : 0
  zone_id = local.zone_id
  name    = aws_ses_domain_mail_from.this[0].mail_from_domain
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

resource "aws_route53_record" "mail_from_txt" {
  count   = var.manage_ses && var.create_mail_from ? 1 : 0
  zone_id = local.zone_id
  name    = aws_ses_domain_mail_from.this[0].mail_from_domain
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com -all"]
}

# -----------------------
# DMARC (recommended)
# -----------------------
resource "aws_route53_record" "dmarc" {
  count   = var.enable_dmarc ? 1 : 0
  zone_id = local.zone_id
  name    = "_dmarc.${local.ses_domain_effective}"
  type    = "TXT"
  ttl     = 300
  records = [join("; ", compact([
    "v=DMARC1",
    "p=${var.dmarc_policy}",
    "sp=${var.dmarc_sp != "" ? var.dmarc_sp : var.dmarc_policy}",
    "adkim=${var.dmarc_adkim}",
    "aspf=${var.dmarc_aspf}",
    "pct=${var.dmarc_pct}",
    var.dmarc_rua != "" ? "rua=mailto:${var.dmarc_rua}" : "",
    var.dmarc_ruf != "" ? "ruf=mailto:${var.dmarc_ruf}" : ""
  ]))]
}
