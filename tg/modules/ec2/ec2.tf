provider "template" {
	version = "~> 1.0"
}

# insecure key pair
# to be replaced after the instance is bootstrapped
resource "aws_key_pair" "deployer" {
  key_name = "${var.product}-${var.environment}-${var.component}-deployer-key"
  public_key = "${file("${path.module}/${var.public_key_path}")}"
}

# instance security group/s
resource "aws_security_group" "instance" {
	name = "${var.component}-${var.product}-${var.environment}-instance"
	description = "Allow necessary traffic to instance"
	vpc_id = "${var.vpc_id}"

	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
		ush-component = "${var.component}"
	}
}

resource "aws_security_group" "open_ports" {
	name = "${var.component}-${var.product}-${var.environment}-open-ports"
	description = "Open requested ports to instance"
	vpc_id = "${var.vpc_id}"

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
		ush-component = "${var.component}"
	}
}

resource "aws_security_group_rule" "open_port" {
	count           = "${length(var.open_ports)}"
  type            = "ingress"
  from_port       = "${element(split(" ", element(var.open_ports, count.index)), 1)}"
  to_port         = "${element(split(" ", element(var.open_ports, count.index)), 2)}"
  protocol        = "${element(split(" ", element(var.open_ports, count.index)), 3)}"
  cidr_blocks     = ["${element(split(" ", element(var.open_ports, count.index)), 0)}"]

  security_group_id = "${aws_security_group.open_ports.id}"
}


resource "aws_iam_instance_profile" "api" {
  name  = "${var.component}-${var.product}-${var.environment}-profile"
  role = "${aws_iam_role.api.name}"
}

resource "aws_iam_role" "api" {
  name = "${var.component}-${var.product}-${var.environment}-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# ec2 instances
data "template_file" "user_data" {
  template = "${file("${path.module}/cloud-init.yml")}"
	vars {}
}

data "aws_kms_key" "default" {
	key_id = "alias/${var.product}-${var.environment}-default"
}

resource "aws_ami_copy" "copy" {
  name              = "${var.component}-${var.product}-${var.environment}"
  description       = "Encrypted copy of AMI ${var.ami}"
  source_ami_id     = "${var.ami}"
  source_ami_region = "${var.aws_region}"
	encrypted         = true
	kms_key_id        = "${data.aws_kms_key.default.arn}"

  tags {
    Name = "${var.component}-${var.product}-${var.environment}"
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
		ush-component = "${var.component}"
  }
}

resource "aws_instance" "instance" {
	count = "${var.instance_count}"
	ami = "${aws_ami_copy.copy.id}"
	instance_type = "${var.instance_type}"
	subnet_id = "${var.subnet_ids[0]}"
	vpc_security_group_ids = [ "${aws_security_group.instance.id}", "${aws_security_group.open_ports.id}" ]
	key_name = "${aws_key_pair.deployer.key_name}"
	iam_instance_profile = "${aws_iam_instance_profile.api.name}"
	associate_public_ip_address = true
	monitoring = true
	user_data = "${data.template_file.user_data.rendered}"

	root_block_device {
		volume_size = "${var.root_fs_size}"
	}

	tags {
		Name = "${var.component}-${var.product}-${var.environment}-${count.index}"
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
		ush-component = "${var.component}"
		sshUser = "ubuntu"
		ec2-group-leader = "${count.index == 0 ? "true" : "false"}"
	}
}

output "instances_public_ips" {
	value = ["${aws_instance.instance.*.public_ip}"]
}
output "instances_private_ips" {
	value = ["${aws_instance.instance.*.private_ip}"]
}
