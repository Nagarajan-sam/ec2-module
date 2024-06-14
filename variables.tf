variable "ad_username" {
  type = string
  sensitive = true
  description = "The username to connect to fsx shared"
  default = ""
}

variable "ad_password" {
  type = string
  sensitive = true
  description = "The password to connect to fsx shared"
  default = ""
}
variable "ami_filter_string" {
  description = "Filter string for finding suitable AMI"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "Image Id we will use with servers"
  type        = string
  default     = ""
}

variable "ami_owner_id" {
  description = "Owner id for the AMI"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "(LC) Associate a public ip address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "create_keypair" {
  description = "Whether to create ec2 key pair"
  type        = bool
  default     = false
}

variable "custom_domain_join_script" {
  description = "Custom domain join script"
  type        = string
  default     = ""
}

variable "directory_id" {
  description = "AWS active directory id which is used for domain join"
  type        = string
  default     = ""
}

variable "dns_record_name" {
  description = "Name of specific EC2 record for Route53"
  type        = string
  default     = null
}

variable "dynatrace_api_token" {
  type = string
  description = "dynatrace API key"
  default = ""
}

variable "dynatrace_host_grp" {
  type = string
  description = "dynatrace host group"
  default = ""
}

variable "ebs_block_device" {
  type        = list(map(any))
  description = "Additional EBS block devices to attach to the instance"
  default     = [{}]
}

variable "ebs_optimized" {
  description = "Whether we should enable ebs_optimized"
  type        = bool
  default     = true
}

variable "enable_domain_join" {
  description = "Whether user data config is required for ec2 instances"
  type        = string
  default     = false
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to associate with launched instances"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name to be used on EC2 instance created"
  type        = string
}

variable "instance_type" {
  description = "Instance Type To Use"
  type        = string
}

variable "instance_key_name" {
  description = "Instance Key Name to Inject to Instances"
  type        = string
}

variable "instance_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "root_block_device" {
  type        = list(map(any))
  description = "Customize details about the root block device of the instance"
  default     = [{}]
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}

variable "server_hostname" {
  description = "Variable to change the hostname of the Windows Server"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = string
  default     = null
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting EC2 instance resources"
  type        = map(string)
  default     = {}
}

variable "user_data_base64" {
  description = "The Base64-encoded user data to provide when launching the instance"
  type        = string
  default     = ""
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set."
  type        = bool
  default     = false
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "windows_version" {
  description = "Version of Windows Server that is being used (CloudCommon2016 or CloudCommon2019)"
  type = string
  default = "CloudCommon2019"
}

variable "create_dns_record" {
  description = "Define whether we should create the DNS record required. "
  type        = bool
  default     = false
}

variable "zone_ids" {
  description = "Ids of Route53 zones you want the instance added too."
  type        = map(string)
  default     = null
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type        = list(map(string))
  default     = []
}