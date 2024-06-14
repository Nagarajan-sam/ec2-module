# AWS EC2 Instance

This terraform module will be used for creating an EC2 instance. Also able to join ec2 instance into domain and control above resources creation using input variables.

## Using EC2 Module

This module assumes, you creating an individual ec2 instance based on your server requirements.

```bash
# Calling Module from an EC2 Stack
module "ec2-instance" {
  source = "git::ssh://git@bitbucket.org/deluxe-development/aws-ec2.git//?ref=1.0.0"

  instance_name = var.instance_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  instance_key_name = var.instance_key_name
  iam_instance_profile = local.iam_instance_profile
  subnet_id = var.subnet_id
  enable_domain_join = true
  directory_id = var.directory_id
  custom_domain_join_script = var.custom_domain_join_script
  windows_version = var.windows_version
  server_hostname = var.server_hostname
  security_group_ids = var.security_group_ids
  root_block_device = var.root_block_device
  ebs_block_device = var.ebs_block_device
  monitoring = var.monitoring
  instance_tags = var.instance_tags
}

#Calling from Terragrunt
locals {
    # Automatically load environment-level variables
    environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    global_ami = read_terragrunt_config("${get_terragrunt_dir()}/../../_global/global_ami.hcl")

    # Extract out common variables for reuse
    infra_envronment = local.environment_vars.locals.infra_environment
    app_environment = local.environment_vars.locals.app_environment
    app_name = local.environment_vars.locals.application
    server_prefix = upper("${local.app_name}-${local.app_environment}")
    instance_name = "${local.server_prefix}-APP"
    server_hostname = "AwsR360${title(local.app_environment)}App22"
    global_ami_id = local.global_ami.locals.ami_id
    module_version = "initial-1.0.0"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::ssh://git@bitbucket.org/deluxe-development/aws-r360v2-non-fnts.git//?ref=${local.module_version}"

  extra_arguments "common_var" {
    commands = [
      "apply",
      "apply-all",
      "plan-all",
      "destroy-all",
      "plan",
      "import",
      "push",
      "refresh"
    ]
  }
}

dependency "common-tags" {
    config_path = "${get_terragrunt_dir()}/../../_global/common-tags"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        common_tags = {
            "AppName" = "R360"
        },
        asg_common_tags = [
            {
                "AppName" = "R360"
            }
        ]
    }
}

dependency "vpc-info" {
    config_path = "${get_terragrunt_dir()}/../../_global/vpc-info"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        app_subnets = [["subnet-123", "subnet-123"]],
        baseline_sg_id = "abc",
        app_sg_id = "abc",
        web_sg_id = "abc"
    }
}

dependency "r360-networking-stack" {
  config_path = "${get_terragrunt_dir()}/../../_global/networking-stack"

  mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
  mock_outputs = {
    vpc_id = "123"
    alb_subnets = ["subnet-123","subnet-456"]
    db_prim_subnet_ids = ["subnet-123","subnet-456","subnet-789","subnet-111"]
    app_subnets = ["app-123", "app-456"]
    alb_security_groups = ["sg-1", "sg-2"]
    alb_sg_ids = ["alb-1", "alb-2"]
    app_sg_id = "app-sg-id-1"
    baseline_sg_id = "baseline-sg-id-1"
    db_sg_id = "db-sg-id-1"
    web_sg_id = "web-sg-id-1"
  }
}

dependency "key-pair" {
    config_path = "${get_terragrunt_dir()}/../ec2-key-pair"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        key_pair_key_name = "r360v2"
    }
}

dependency "hosted-zone" {
    config_path = "${get_terragrunt_dir()}/../../_global/rc_hosted_zone"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        zone_ids = "1234"
    }
}

dependency "iam-role" {
    config_path = "${get_terragrunt_dir()}/../iam-application-role"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        iam_instance_profile_id = "r360v2"
    }
}

# Include all settings from the root terragrunt.hcl file
include {
   path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
    #EC2 Inputs
    instance_name = local.instance_name
    ami_id = local.global_ami_id
    instance_type = "m5.xlarge"
    instance_key_name = dependency.key-pair.outputs.key_pair_key_name
    subnet_id = dependency.vpc-info.outputs.app_subnets[0][0]
    iam_instance_profile = dependency.iam-role.outputs.iam_instance_profile_id
    enable_domain_join = true
    directory_id = "d-9067aefcf8"
    custom_domain_join_script = file("${get_terragrunt_dir()}/../../_global/templates/deluxe-domain-join-rc.ps1")
    windows_version = "CloudCommon2022"
    server_hostname = local.server_hostname
    monitoring = true
    security_group_ids = [
        dependency.vpc-info.outputs.baseline_sg_id,
        dependency.vpc-info.outputs.app_sg_id,
        dependency.vpc-info.outputs.web_sg_id
    ]
    root_block_device = [{
        delete_on_termination = true
        encrypted = true
        volume_size = 100
        volume_type = "gp3"
    }]
    ebs_block_device = [{
        device_name           = "xvdb"
        delete_on_termination = true
        volume_size           = 500
        volume_type           = "gp3"
        encrypted             = true
    }]
    instance_tags = {
        TerraformPath = path_relative_to_include()
        Domain = "deluxe.com"
        Onwer = local.environment_vars.locals.env_tags.Application
        Application = "R360V2"
        Environment = upper(local.infra_envronment)
        OSType = "Windows"
        OSFlavor = "Windows Server 2022"
        ManagedBy = "R360V2 DevOps Team"
        CostCenter = "17150048"
    }
}
```
### Create EC2 with Route53 Update

```bash
# Calling Module from an EC2 Stack
module "ec2-instance" {
  source = "git::ssh://git@bitbucket.org/deluxe-development/aws-ec2.git//?ref=1.0.0"

  instance_name = var.instance_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  instance_key_name = var.instance_key_name
  iam_instance_profile = local.iam_instance_profile
  subnet_id = var.subnet_id
  enable_domain_join = true
  directory_id = var.directory_id
  custom_domain_join_script = var.custom_domain_join_script
  windows_version = var.windows_version
  server_hostname = var.server_hostname
  security_group_ids = var.security_group_ids
  root_block_device = var.root_block_device
  ebs_block_device = var.ebs_block_device
  monitoring = var.monitoring
  instance_tags = var.instance_tags
}

#Calling from Terragrunt
locals {
    # Automatically load environment-level variables
    environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
    account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
    global_ami = read_terragrunt_config("${get_terragrunt_dir()}/../../_global/global_ami.hcl")

    # Extract out common variables for reuse
    infra_envronment = local.environment_vars.locals.infra_environment
    app_environment = local.environment_vars.locals.app_environment
    app_name = local.environment_vars.locals.application
    server_prefix = upper("${local.app_name}-${local.app_environment}")
    instance_name = "${local.server_prefix}-APP"
    server_hostname = "AwsR360${title(local.app_environment)}App22"
    global_ami_id = local.global_ami.locals.ami_id
    module_version = "initial-1.0.0"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::ssh://git@bitbucket.org/deluxe-development/aws-r360v2-non-fnts.git//?ref=${local.module_version}"

  extra_arguments "common_var" {
    commands = [
      "apply",
      "apply-all",
      "plan-all",
      "destroy-all",
      "plan",
      "import",
      "push",
      "refresh"
    ]
  }
}

dependency "common-tags" {
    config_path = "${get_terragrunt_dir()}/../../_global/common-tags"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        common_tags = {
            "AppName" = "R360"
        },
        asg_common_tags = [
            {
                "AppName" = "R360"
            }
        ]
    }
}

dependency "vpc-info" {
    config_path = "${get_terragrunt_dir()}/../../_global/vpc-info"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        app_subnets = [["subnet-123", "subnet-123"]],
        baseline_sg_id = "abc",
        app_sg_id = "abc",
        web_sg_id = "abc"
    }
}

dependency "r360-networking-stack" {
  config_path = "${get_terragrunt_dir()}/../../_global/networking-stack"

  mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
  mock_outputs = {
    vpc_id = "123"
    alb_subnets = ["subnet-123","subnet-456"]
    db_prim_subnet_ids = ["subnet-123","subnet-456","subnet-789","subnet-111"]
    app_subnets = ["app-123", "app-456"]
    alb_security_groups = ["sg-1", "sg-2"]
    alb_sg_ids = ["alb-1", "alb-2"]
    app_sg_id = "app-sg-id-1"
    baseline_sg_id = "baseline-sg-id-1"
    db_sg_id = "db-sg-id-1"
    web_sg_id = "web-sg-id-1"
  }
}

dependency "key-pair" {
    config_path = "${get_terragrunt_dir()}/../ec2-key-pair"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        key_pair_key_name = "r360v2"
    }
}

dependency "hosted-zone" {
    config_path = "${get_terragrunt_dir()}/../../_global/rc_hosted_zone"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        zone_ids = "1234"
    }
}

dependency "iam-role" {
    config_path = "${get_terragrunt_dir()}/../iam-application-role"

    mock_outputs_allowed_terraform_commands = ["validate","plan","destroy"]
    mock_outputs = {
        iam_instance_profile_id = "r360v2"
    }
}

dependency "route53-zone" {
  config_path                             = "${get_terragrunt_dir()}/../route53-zone"
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

# Include all settings from the root terragrunt.hcl file
include {
   path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
    #EC2 Inputs
    instance_name = local.instance_name
    ami_id = local.global_ami_id
    instance_type = "m5.xlarge"
    instance_key_name = dependency.key-pair.outputs.key_pair_key_name
    subnet_id = dependency.vpc-info.outputs.app_subnets[0][0]
    iam_instance_profile = dependency.iam-role.outputs.iam_instance_profile_id
    enable_domain_join = true
    directory_id = "d-9067aefcf8"
    custom_domain_join_script = file("${get_terragrunt_dir()}/../../_global/templates/deluxe-domain-join-rc.ps1")
    windows_version = "CloudCommon2022"
    server_hostname = local.server_hostname
    monitoring = true
    security_group_ids = [
        dependency.vpc-info.outputs.baseline_sg_id,
        dependency.vpc-info.outputs.app_sg_id,
        dependency.vpc-info.outputs.web_sg_id
    ]
    root_block_device = [{
        delete_on_termination = true
        encrypted = true
        volume_size = 100
        volume_type = "gp3"
    }]
    ebs_block_device = [{
        device_name           = "xvdb"
        delete_on_termination = true
        volume_size           = 500
        volume_type           = "gp3"
        encrypted             = true
    }]
    instance_tags = {
        TerraformPath = path_relative_to_include()
        Domain = "deluxe.com"
        Onwer = local.environment_vars.locals.env_tags.Application
        Application = "R360V2"
        Environment = upper(local.infra_envronment)
        OSType = "Windows"
        OSFlavor = "Windows Server 2022"
        ManagedBy = "R360V2 DevOps Team"
        CostCenter = "17150048"
    }
  zone_ids = dependency.route53-zone.outputs.route53_zone_zone_id
  create_dns_record         = true
}
```

## Input Variables

| Variable Name | Description | Default Value | Usage Notes |
|--|--|--|--|
| ad_username | The username to connect to fsx shared | "" | Used in custom Domain Join |
| ad_password | The password to connect to fsx shared | "" | Used in custom Domain Join |
| ami_filter_string | Filter string for finding suitable AMI | false | "" | This will filter for AMI based on string |
| ami_id | Image Id for ec2 instance creation | "" | This will be used for ec2 instance creation |
| ami_owner_id | Owner id for the AMI | "" | This will be used for filtering ami using owner id |
| associate_public_ip_address | Associate a public ip address with an instance in a VPC | false | This will be used for associating public ip to ec2 instance |
| create_keypair | Determines whether to create ec2 keypair or not. | false | This will opt is to create ec2 keypair |
| custom_domain_join_script | Custom domain join script | "" | This will be used for choosing custom domain join script for Windows servers |
| directory_id | AWS directory service id to join the domain with file system | "" | This will be used for Managed Microsoft AD instead of Self Managed AD |
| dynatrace_api_token | Dynatrace API Key | "" | Used in custom domain join script |
| dynatrace_host_grp | Dynatrace host group | "" | Used in custom domain join script |
| ebs_block_device | Additional EBS block devices to attach to the instance | [] | This will be used for attaching extra ebs volume to ec2 instance |
| ebs_optimized | Whether we should enable ebs_optimized | true | This will opt is to enable ebs_optimized or not |
| enable_domain_join | Whether user data config is required for ec2 instances | false | This will be used to enable domain join or not |
| enable_volume_tags | Whether to enable volume tags (if enabled it conflicts with root_block_device tags) | false | This will enable volume tags or not |
| iam_instance_profile | EC2 Instance IAM profile or role | "" | This will be used for attaching IAM role or profile to ec2 instance |
| instance_name | EC2 Instance Name | "" | This will be used for choosing instance name |
| instance_type | EC2 Instance Type | "t4g.micro" | This will be used for choosing instance type |
| instance_key_name | EC2 Instance keypair name | "" | This will be used for attaching key pair to ec2 instance while creation |
| instance_tags | A mapping of tags to assign to instance at launch time | {} | This will add resource tags for ec2 instance |
| monitoring | If true, the launched EC2 instance will have detailed monitoring enabled | true | This will enable detailed monitoring for ec2 instance |
| private_ip | Private IP address to associate with the instance in a VPC | null | This will allow you to choose a private IP from the VPC |
| root_block_device | Customize details about the root block device of the instance | [] | This will be used for resizing root volume in or from ec2 instance |
| security_group_ids | A list of security group IDs to associate with | list(string) | This will allow a list of security groups to be attached to the instance |
| subnet_id | The VPC Subnet ID for ec2 instance | "" | This specifies subnet id for ec2 instance |
| timeouts | The timeout settings for create,update and delete lifecycle | {} | This will be used to change terraform api timeout for create, delete, update action |
| user_data_base64 | The Base64-encoded user data to provide when launching the instance | "" | This will be used for passing encoded format of userdata script |
| user_data_replace_on_change | When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true | false | This will be used for replacing instance based on userdata script changes |
| volume_tags | A mapping of tags to assign to the devices created by the instance at launch time | {} | This will add resource tags for ebs volumes |
| windows_version | Names the version of Windows server used in the userdata Powershell script | "CloudCommon2019" | This will be used to manage the version of Windows used in the userdata script |
| create_dns_record | Define whether you want the module to create a DNS record for you. | false | This will create an A record for the server that was created. |
| zone_ids | Map of Zone Ids to update DNS | null | This will be a map that defines the which zones to create.  The format would be in the following manner.
```bash
{
  internal = "Internal Zone ID"
  private = "Private Zone ID"
} |
