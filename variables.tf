variable "cluster_id" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "private_subnet_cidrs" {}
variable "engine_version" {}
variable "parameter_group_name" {}
variable "instance_type" { default = "cache.t2.micro" }
variable "maintenance_window" { default = "sun:05:00-sun:06:00" }
variable "function_name" {}
variable "function_handler" { default = "index.handler" }
variable "file_name" { default = "demo-lambda-redis.zip"}
variable "attach_vpc_config" { default = false}

# tags
variable "tag_name" {}
variable "tag_contact-email" {}
