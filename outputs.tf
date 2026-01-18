output "bucket_name" {
  value = aws_s3_bucket.test.bucket
}

output "private_instance_id" {
  value = aws_instance.private_runner.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "s3_vpc_endpoint_id" {
  value = try(aws_vpc_endpoint.s3_gateway[0].id, null)
}

output "ssm_start_session_command" {
  value = "aws ssm start-session --target ${aws_instance.private_runner.id} --region ${var.aws_region}"
}
