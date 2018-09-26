terraform {
  backend "s3" {}
}

# aws setup
variable "environment"		    { }
variable "product" 				    { default = "crowdmap" }
variable "aws_region"			    { default = "us-east-1" }
variable "availability_zones"	{ default = [ "c", "d" ] }
variable "vpc_environment"    { default = "staging" }
variable "vpc_product"        { default = "crowdmap" }

# route53 zones for dns
variable "r53_dns_zone"	    {}
variable "r53_dns_services_zone"  {}    # for ancillary services (i.e. lumen exporter)
variable "env_subdomain"    {}
variable "services_subdomain" { default = "" }

# systems

data "aws_route53_zone" "zone" {
	name = "${var.r53_dns_zone}."
}
data "aws_route53_zone" "services" {
	name = "${var.r53_dns_services_zone}."
}

data "null_data_source" "env_constants" {
  inputs = {
    services_subdomain = "${coalesce(var.services_subdomain, var.env_subdomain)}"
    env_fqdn = "${var.env_subdomain}${var.env_subdomain != "" ? "." : ""}${var.r53_dns_zone}"
    env_services_fqdn = "${coalesce(var.services_subdomain, var.env_subdomain)}.${var.r53_dns_services_zone}"
    iam_groups_path = "/${var.product}/${var.environment}/"
    iam_ci_group_name = "${var.product}-${var.environment}-ci"
    static_bucket = "ush-${var.product}-${var.environment}-static"
    load_balancer = "${var.product}-${var.environment}-lb"
    load_balancer_sg = "${var.product}-${var.environment}-lb"
    load_balancer_records_main_zone = "${var.env_subdomain} *.${var.env_subdomain} www.${var.env_subdomain}"
    load_balancer_records_services_zone = "${coalesce(var.services_subdomain, var.env_subdomain)} *.${coalesce(var.services_subdomain, var.env_subdomain)}"
  }
}

provider "aws" {
	# credentials would be coming from the environment
	region = "${var.aws_region}"
	version = "~> 1.15"
}

provider "null" {
	version = "~> 1.0"
}

data "null_data_source" "vpc_lookup" {
	inputs = {
		environment = "${coalesce(var.vpc_environment, var.environment)}"
		product = "${coalesce(var.vpc_product, var.product)}"
	}
}

data "aws_caller_identity" "current" {}

module "vpc" {
	source = "git@github.com:ushahidi/terraform-common-modules//aws/vpc-lookup"

	aws_region = "${var.aws_region}"
	environment = "${data.null_data_source.vpc_lookup.outputs["environment"]}"
	product = "${data.null_data_source.vpc_lookup.outputs["product"]}"
	availability_zones = ["${var.availability_zones}"]
}
