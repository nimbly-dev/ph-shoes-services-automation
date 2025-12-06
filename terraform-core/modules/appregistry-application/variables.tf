variable "name" {
  description = "AppRegistry application name"
  type        = string
}

variable "description" {
  description = "Optional description"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags attached to the application"
  type        = map(string)
  default     = {}
}
