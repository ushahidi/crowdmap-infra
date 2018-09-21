#
variable "component"          { }
variable "environment"		    { }

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

# other configurations
## format: "cidr from_port to_port proto", i.e. :
##   "0.0.0.0/0 22 22 tcp"
##   "::/0 22 22 tcp"
variable "open_ports"           { type = "list"  }
