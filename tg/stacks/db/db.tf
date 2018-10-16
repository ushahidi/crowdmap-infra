data "aws_kms_key" "default" {
	key_id = "alias/${var.product}-${var.environment}-default"
}

resource "aws_security_group" "db" {
	name = "db-${var.product}-${var.environment}"
	description = "Allow necessary traffic to db"
	vpc_id = "${module.vpc.vpc_id}"

	ingress {
		from_port = 3306
		to_port = 3306
		protocol = "tcp"
		cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
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
		ush-component = "db"
	}
}

resource "aws_db_option_group" "db" {
	name = "options-${var.product}-${var.environment}${var.db_instance_suffix}"
	option_group_description = "Option Group ${var.product} - ${var.environment}"
	engine_name = "mysql"
	major_engine_version = "${var.mysql_major_version}"

#	option { ... }
}

resource "aws_db_parameter_group" "db" {
	name = "params-${var.product}-${var.environment}${var.db_instance_suffix}"
	family = "mysql${var.mysql_major_version}"

	parameter {
		name = "character_set_client"
		value = "utf8mb4"
	}

	parameter {
		name = "character_set_server"
		value = "utf8mb4"
	}

	parameter {
		name = "character_set_database"
		value = "utf8mb4"
	}

	parameter {
		name = "character_set_results"
		value = "utf8mb4"
	}

	parameter {
		name = "character_set_connection"
		value = "utf8mb4"
	}

	parameter {
		name = "collation_connection"
		value = "utf8mb4_unicode_ci"
	}

	parameter {
		name = "collation_server"
		value = "utf8mb4_unicode_ci"
	}

	parameter {
		name = "innodb_flush_log_at_trx_commit"
		value = "${var.db_innodb_flush_log_at_trx_commit}"
	}

	parameter {
		name = "innodb_file_per_table"
		value = "0"
	}
}

resource "aws_db_subnet_group" "db" {
	name = "${var.product}-${var.environment}"
	subnet_ids = [ "${module.vpc.subnet_ids}" ]
	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
	}
}

resource "aws_db_instance" "db" {
	identifier = "${var.product}-${var.environment}${var.db_instance_suffix}"
	engine = "mysql"
	engine_version = "${var.mysql_version}"
	instance_class = "${var.db_instance_type}"
	allocated_storage = "${var.allocated_storage}"
	storage_type = "${var.storage_type}"
	iops = "${var.provisioned_iops}"
	vpc_security_group_ids = [ "${aws_security_group.db.id}" ]
	storage_encrypted = "${var.storage_encrypted}"
	kms_key_id = "${var.storage_encrypted ? data.aws_kms_key.default.arn : ""}"

	username = "${var.db_admin_username}"
	password = "${var.db_admin_password}"

	db_subnet_group_name = "${aws_db_subnet_group.db.id}"
	parameter_group_name = "${aws_db_parameter_group.db.id}"
	option_group_name = "${aws_db_option_group.db.id}"
	multi_az = "${var.multi_az}"
	publicly_accessible = false
	skip_final_snapshot = true

	backup_retention_period = "${var.db_backup_retention_period}"
	backup_window = "${var.db_backup_window}"
	copy_tags_to_snapshot = true

	apply_immediately = "${var.db_apply_immediately}"

	tags {
		ush-environment = "${var.environment}"
		ush-product = "${var.product}"
		ush-component = "db"
	}
}

resource "aws_route53_record" "db" {
	zone_id = "${data.aws_route53_zone.services.zone_id}"
	name = "db.1nfra.${var.environment}"
	type = "CNAME"
	ttl = 300
	records = ["${aws_db_instance.db.address}"]
}

resource "aws_cloudwatch_metric_alarm" "db_disk_space" {
	alarm_name = "${var.product}-${var.environment}${var.db_instance_suffix}-db-disk-space"
	comparison_operator = "LessThanOrEqualToThreshold"
	evaluation_periods = "12"
	metric_name = "FreeStorageSpace"
	namespace = "AWS/RDS"
	period = "300"
	statistic = "Minimum"
	threshold = "${1024 * 1024 * 1024}"
	alarm_description = "Free Storage for the Database [Urgent]"
	dimensions {
		DBInstanceIdentifier = "${aws_db_instance.db.id}"
	}
	alarm_actions = [ "${data.aws_sns_topic.alarm_notification.arn}" ]
	ok_actions = [ "${data.aws_sns_topic.alarm_notification.arn}" ]
	insufficient_data_actions = [ "${data.aws_sns_topic.alarm_notification.arn}" ]
}


output "db_host" {
	value = "${aws_route53_record.db.fqdn}"
}

output "db_canonical_host" {
	value = "${aws_db_instance.db.address}"
}
