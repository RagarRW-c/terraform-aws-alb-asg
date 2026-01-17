variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "scale_out_cpu_threshold" {
  type = number
  default = 60
}

variable "scale_in_cpu_threshold" {
  type = number
  default = 20
}

