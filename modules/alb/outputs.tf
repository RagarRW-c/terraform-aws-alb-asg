output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "target_group_arn" {
  value = aws_lb_target_group.alb_tg.arn
}

output "alb_arn" {
  value = aws_lb.web_alb.arn
}

output "alb_arn_suffix" {
  value = aws_lb.web_alb.arn_suffix
}