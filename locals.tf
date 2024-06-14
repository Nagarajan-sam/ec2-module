locals {
    key_name  = var.create_keypair ? module.key_pair.key_pair_key_name : var.instance_key_name
    ami_id    = try(data.aws_ami.this[0].id, var.ami_id)
    user_data_base64 = var.enable_domain_join ? base64encode(data.template_file.domain_join.rendered) : var.user_data_base64
}