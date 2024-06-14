data "aws_ami" "this" {
  count = var.ami_filter_string != "" ? 1 : 0
  most_recent = true
  owners      = ["${var.ami_owner_id}"]

  filter {
    name   = "name"
    values = ["${var.ami_filter_string}"]
  }
}