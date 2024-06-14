output "instance_id" {
  description = "The id of the instance."
  value       = module.ec2_instance.id
}

output "key_pair_name" {
  description = "The key pair name."
  value       = var.create_keypair ? module.key_pair.key_pair_key_name : var.instance_key_name
}

output "key_pair_private_key" {
  description = "The key pair private key content."
  value       = try(tls_private_key.this[0].private_key_openssh, "")
  sensitive   = true
}

output "custom_user_data" {
  description = "Decoded Custom User Data Script"
  value       = base64decode(local.user_data_base64)
}

output "private_ip" {
  description = "IP of instance"
  value       = module.ec2_instance.private_ip
}

output "instance_name" {
  description = "Name of instance"
  value       = var.instance_name
}
