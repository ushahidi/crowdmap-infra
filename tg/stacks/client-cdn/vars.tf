# CDN configuration
variable "client_compress"     { default = true }

variable "client_min_ttl"	  	{ default = 0 }
variable "client_default_ttl"	{ default = 0 }
variable "client_max_ttl"	  	{ default = 0 }
variable "client_cdn_price_class"	{ default = "PriceClass_100" }

output "stack_client_cdn_present" { value = "true" }
