variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}