
variable "common" {}

variable "name" {}

variable "counts" {
  description = "EC2 Instance Counts"
  default = 1
}

variable "vpc_subnet_id" {}

variable "launch_template_id" {}