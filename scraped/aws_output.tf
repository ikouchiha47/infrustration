
output "vpcs" {
  value = {
    "talon_vpc_cidr_block" = aws_vpc.talon_vpc.cidr_block
    "talon_vpc_id"         = aws_vpc.talon_vpc.id
  }
}


