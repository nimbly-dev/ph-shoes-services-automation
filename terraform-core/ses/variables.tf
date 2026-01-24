variable "aws_region" {
  description = "Region to optionally lock SES sending to"
  type        = string
}

variable "service_name" {
  description = "For naming the IAM policy (e.g., ph-shoes-account-service)"
  type        = string
}

variable "attach_to_role_name" {
  description = "Optional: IAM role name to attach the SES send policy to"
  type        = string
  default     = ""
}

variable "restrict_to_region" {
  description = "If true, require aws:RequestedRegion == aws_region"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the IAM policy"
  type        = map(string)
  default     = {}
}

variable "enable_event_destination" {
  description = "When true, create an SES configuration set, SNS topic, and webhook subscription."
  type        = bool
  default     = false
}

variable "configuration_set_name" {
  description = "SES configuration set name used for event publishing."
  type        = string
  default     = ""
}

variable "event_destination_name" {
  description = "Name for the SES event destination."
  type        = string
  default     = "sns-event-destination"
}

variable "sns_topic_name" {
  description = "SNS topic that receives SES events."
  type        = string
  default     = ""
}

variable "webhook_endpoint" {
  description = "HTTPS endpoint (your service webhook) subscribed to the SNS topic."
  type        = string
  default     = ""
}

variable "matching_event_types" {
  description = "SES event types to publish to SNS."
  type        = list(string)
  default     = ["BOUNCE", "COMPLAINT"]
}
