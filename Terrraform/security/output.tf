variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "ingress_port" {
  description = "Port to allow ingress traffic"
  type        = number
  default     = 80
}