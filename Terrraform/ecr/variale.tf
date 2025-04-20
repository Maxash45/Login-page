variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "Whether to force delete the repository"
  type        = bool
  default     = true
}