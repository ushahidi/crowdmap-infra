# CDN configuration
variable "static_compress"     { default = true }

variable "static_min_ttl"	  	{ default = 0 }
variable "static_default_ttl"	{ default = 0 }
variable "static_max_ttl"	  	{ default = 0 }
variable "static_cdn_price_class"	{ default = "PriceClass_100" }

output "stack_static_cdn_present" { value = "true" }
