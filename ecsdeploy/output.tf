output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.mitil_lb.dns_name
}

