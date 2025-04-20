variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket"
  type        = bool
  default     = true
}