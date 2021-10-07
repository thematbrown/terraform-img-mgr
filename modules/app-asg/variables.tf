variable "public_subnets" {
  type = list
}

variable "private_subnets" {
  type = list
}

variable "vpc_id" {
  type = any
}

variable "vpc" {
  type = any
}

variable "vpc_cidr" {
  type = string
}