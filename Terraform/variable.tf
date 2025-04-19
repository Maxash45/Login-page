variable "project_name" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "azs" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "aws_region" {
  default = "us-east-1"
}
