provider "aws" {
	# provider bound to us-east-1 , where the cloudfront ACM certificates should be
	alias = "east_1"
	region = "us-east-1"
}

data "aws_acm_certificate" "client" {
	domain = "*.${data.null_data_source.env_constants.outputs.env_fqdn}"
	statuses = ["ISSUED"]
	most_recent = true
	provider = "aws.east_1"
}

data "aws_iam_policy_document" "client_s3_cloudfront" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::ush-${var.product}-${var.environment}-client/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.client.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::ush-${var.product}-${var.environment}-client"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.client.iam_arn}"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "client" {
  comment = "Access identity for ${var.product} ${var.environment} client S3 bucket"
}

resource "aws_s3_bucket_policy" "s3_cdn_bucket_policy" {
  bucket = "${data.null_data_source.env_constants.outputs.client_bucket}"
  policy = "${data.aws_iam_policy_document.client_s3_cloudfront.json}"
}

resource "aws_cloudfront_distribution" "client" {
  origin {
    origin_id = "S3-client-origin"
    domain_name = "${data.null_data_source.env_constants.outputs.client_bucket}.s3.amazonaws.com"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.client.cloudfront_access_identity_path}"
    }
  }

  enabled = true
  comment = "${var.product} ${var.environment} client distribution"
  default_root_object = "index.html"
  aliases = [ "*.${data.null_data_source.env_constants.outputs.env_fqdn}" ]
  price_class = "${var.client_cdn_price_class}"
	http_version = "http2"
	is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods = [ "GET", "HEAD" ]
    cached_methods = [ "GET", "HEAD" ]
    target_origin_id = "S3-client-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = "${var.client_min_ttl}"
    default_ttl = "${var.client_default_ttl}"
    max_ttl = "${var.client_max_ttl}"
    compress = "${var.client_compress}"
  }

  custom_error_response {
    error_code = "404"
    error_caching_min_ttl = "0"
    response_code = "200"
    response_page_path = "/index.html"
  }

  viewer_certificate {
    acm_certificate_arn = "${data.aws_acm_certificate.client.arn}"
    minimum_protocol_version = "TLSv1"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    ush-environment = "${var.environment}"
    ush-product = "${var.product}"
  }
}

# route53 names
resource "aws_route53_record" "wildcard_client" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "*.${var.env_subdomain}"
  type = "A"

  alias {
    name = "${aws_cloudfront_distribution.client.domain_name}"
    zone_id = "${aws_cloudfront_distribution.client.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "wildcard_client_ipv6" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "*.${var.env_subdomain}"
  type = "AAAA"

  alias {
    name = "${aws_cloudfront_distribution.client.domain_name}"
    zone_id = "${aws_cloudfront_distribution.client.hosted_zone_id}"
    evaluate_target_health = false
  }
}
