output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ecs_service.id
}