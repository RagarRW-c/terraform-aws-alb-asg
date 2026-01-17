variable "vpc_cidr" {
  type = string
  description = "CIDR block for vpc"
}

variable "public_subnets" {
  type = list(string)
  description = "CIDRs for public subnet"
}

variable "private_subnets" {
  type = list(string)
  description = "CIDRs for private subnets"
}

variable "azs" {
  type = list(string)
  description = "Availability zones"
}

variable "tags" {
  type = map(string)
  default = {}
}
