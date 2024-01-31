output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.mitil_lb.dns_name
}

output "acm_setup" {
  value = "Test this demo code by going to https://${aws_route53_record.mitil_app_route_alias.fqdn} and checking your have a valid SSL cert"
}