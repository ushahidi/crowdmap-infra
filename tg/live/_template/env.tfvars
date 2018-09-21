# set the environment name, no underscores allowed
# environment = "..."

# Route 53 DNS zones where the r
r53_dns_zone = "ush.zone"               # main, most publicly accessed records
r53_dns_services_zone = "ush.systems"   # internal server and instance records
# env_subdomain = "..."            # SET ME! this will be prepended to the DNS
# services_subdomain" = ""      # optional, prepended to services zone records
                                                 # (defaults to env_subdomain)

# Region, VPC and availability zone selection
aws_region = "eu-west-1"
vpc_environment = "staging"                        # "staging" or "production"
availability_zones = [ "b", "c" ]             # our AZs of choice in eu-west-1
