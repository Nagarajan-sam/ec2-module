module "dns_record" {
  source = "git::ssh://git@bitbucket.org/deluxe-development/aws-route53.git//?ref=1.0.3"

  count = var.create_dns_record ? 1 : 0
  create_zone = false
  create_public_record = true
  create_private_record = true
  zone_ids             = var.zone_ids
  records = [
    {
      name           = coalesce(var.dns_record_name, var.instance_name)
      type           = "A"
      ttl            = 60
      records        = [module.ec2_instance.private_ip]
    }
  ]
}
