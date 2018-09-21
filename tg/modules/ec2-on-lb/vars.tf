#
variable "component"          { }
variable "load_balancer_name" { }
variable "load_balancer_sg"   { }
variable "environment"		    { }

# variable "env_subdomain"      { }
# variable "env_fqdn"           { }
variable "hostnames"          { type = "list" }

variable "vpc_id"             { }
variable "subnet_ids"         { type = "list" }
variable "product" 				    { }
variable "aws_region"			    { default = "us-east-1" }

# instances
variable "instance_type"	      { default = "t2.micro" }
variable "instance_count"	      { default = 2 }
variable "ami"                  { default = "" }
variable "root_fs_size"         { default = "8" }
variable "public_key_path"		  { default = "./ssh/insecure-deployer.pub" }

# other configs
variable "health_check_path"          { default = "/" }
variable "health_check_status_match"  { default = "200" }
variable "listener_rule_priority"     { }


# define outputs for variables that need sharing
