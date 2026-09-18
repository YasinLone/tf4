variable "subnets" {
  description = "Subnets to deploy the load balancer"
  type        = list(string)
}

variable "security_groups" {
  description = "Security groups to associate with the load balancer"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "ec2_instance_id" {
  description = "EC2 instance ID"
}
