variable "aws_region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for resources."
  default     = "vpc-endpoints-demo"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.1.0.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.1.1.0/24"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "enable_s3_endpoint" {
  type        = bool
  description = "Enable the S3 Gateway VPC Endpoint. Keep false for baseline NAT run; set true for endpoint run."
  default     = false
}
