data "template_file" "domain_join" {
  template = var.custom_domain_join_script == "" ? file("${path.cwd}/templates/deluxe-domain-join.ps1") : var.custom_domain_join_script
  vars = {
    directory_id = var.directory_id
    windows_version = var.windows_version
    server_hostname = var.server_hostname
  }
}

data "template_cloudinit_config" "domain_join_config" {
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.domain_join.rendered
  }
}