variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "Public subnet IDs for ALB"
}
variable "enable_https" {
  type = bool
  description = "enable https listener and acm certificate"
  default = false
}

variable "domain_name" {
  type        = string
  description = "Domain name for HTTPS certificate (e.g. app.example.com)"
  default = ""
}

variable "hosted_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID"
  default = ""
}


variable "tags"{
    type = map(string)
    default = {}
}

