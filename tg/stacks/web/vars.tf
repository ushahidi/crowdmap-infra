module "ami" {
	source = "github.com/terraform-community-modules/tf_aws_ubuntu_ami"
	region = "${var.aws_region}"
	distribution = "${var.ubuntu_distribution}"
	architecture = "amd64"
	virttype = "hvm"
	storagetype = "ebs-ssd"
}

module "ec2" {
  source = "../../modules/ec2-on-lb"
  aws_region = "${var.aws_region}"
  product = "${var.product}"
  environment = "${var.environment}"
  component = "web"
	instance_count = "${var.instance_count}"
	instance_type = "${var.instance_type}"
  hostnames = [ "*.${data.null_data_source.env_constants.outputs.env_fqdn}", "${data.null_data_source.env_constants.outputs.env_fqdn}" ]
  listener_rule_priority = "10"
  load_balancer_name = "${data.null_data_source.env_constants.outputs.load_balancer}"
  load_balancer_sg = "${data.null_data_source.env_constants.outputs.load_balancer_sg}"
	health_check_path = "/"
	health_check_status_match = "200,301,302"
  ami = "${coalesce(var.ami, module.ami.ami_id)}"
	root_fs_size = "${var.root_fs_size}"
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = [ "${module.vpc.subnet_ids}" ]
}

resource "aws_route53_record" "instance" {
	count = "${var.instance_count}"
	zone_id = "${data.aws_route53_zone.services.zone_id}"
	name = "web-${count.index+1}.1nfra.${data.null_data_source.env_constants.outputs.services_subdomain}"
	type = "A"
	ttl = 300
	records = ["${element(module.ec2.instances_public_ips, count.index)}"]
}

# web instances
variable "instance_type"	      { default = "t2.micro" }
variable "instance_count"	      { default = 2 }
variable "ami"                  { default = "" }   # force ami (otherwise uses AMI lookup module)
variable "root_fs_size"         { default = "8" }
variable "public_key_path"		  { default = "./ssh/insecure-deployer.pub" }
variable "ubuntu_distribution"  { default = "xenial" }

# define outputs for variables that need sharing with ansible
output "aws_region"			      { value = "${var.aws_region}" }
output "r53_dns_zone"			    { value = "${var.r53_dns_zone}" }
output "environment_name"     { value = "${var.environment}" }

output "stack_web_present" 		{ value = "true" }
