module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= v5.2.0"

  name = var.instance_name

  ami                         = local.ami_id
  instance_type               = var.instance_type
  iam_instance_profile        = var.iam_instance_profile
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  key_name                    = local.key_name
  monitoring                  = var.monitoring
  user_data_base64            = local.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change
  ebs_optimized               = var.ebs_optimized
  private_ip                  = var.private_ip

  root_block_device           = var.root_block_device
  ebs_block_device            = var.ebs_block_device
  network_interface           = var.network_interface

  timeouts = {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  tags        = merge({ "Name" = var.instance_name }, var.instance_tags)
  volume_tags = var.enable_volume_tags ? merge({ "Name" = var.instance_name }, var.volume_tags) : null

}
