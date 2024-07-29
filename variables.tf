variable "create" {
  description = "Determines whether to create a launch template or not."
  type        = bool
  default     = true
}

variable "name" {
  description = "Simple name of the EC2 Launch Template"
  type        = string
}

variable "description" {
  description = "Description of the launch template"
  type        = string
  default     = null
}

variable "fullname" {
  description = "Fullname of launch template to be created"
  type        = string
  default     = null
}

variable "launch_template_id" {
  description = "The ID of an existing launch template to use."
  type        = string
  default     = null
}

variable "image_id" {
  description = "The AMI ID from which to launch the instance."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance. If present then `instance_requirements` cannot be present"
  type        = string
  default     = null
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance(s) will be EBS-optimized"
  type        = bool
  default     = null
}

variable "key_name" {
  description = "The key name that should be used for the instance(s)"
  type        = string
  default     = null
}

variable "user_data" {
  type        = string
  default     = null

  description = <<EOF
The Base64-encoded user data to provide when launching the instance

  locals {
    user_data = jsondecode(templatefile("$${path.module}/ec2.template.tpl",{port = 22, bucket_name = "mybucket"}))
  }

  user_data = base64encode(local.user_data)
EOF
}

variable "security_group_ids" {
  type = list(string)
  default = []
  description = <<EOF
A list of security group IDs to associate

  security_group_ids = [
    "sg-ed25519",
    "sg-ed98238"
  ]
EOF

}

variable "cluster_primary_security_group_id" {
  description = "The ID of the EKS cluster primary security group to associate with the instance(s). This is the security group that is automatically created by the EKS service"
  type        = string
  default     = null
}

variable "launch_template_default_version" {
  description = "Default version of the launch template"
  type        = string
  default     = null
}

variable "update_launch_template_default_version" {
  description = "Whether to update the launch templates default version on each update. Conflicts with `launch_template_default_version`"
  type        = bool
  default     = true
}

variable "default_version" {
  description = "Default Version of the launch template"
  type        = number
  default     = null
}

variable "update_default_version" {
  description = "Whether to update Default Version each update. Conflicts with `default_version`"
  type        = bool
  default     = null
}

variable "disable_api_termination" {
  description = "If true, enables EC2 instance termination protection"
  type        = bool
  default     = null
}

variable "disable_api_stop" {
  description = "If true, enables EC2 instance stop protection"
  type        = bool
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)"
  type        = string
  default     = null
}

variable "kernel_id" {
  description = "The kernel ID"
  type        = string
  default     = null
}

variable "ram_disk_id" {
  description = "The ID of the ram disk"
  type        = string
  default     = null
}

variable "block_device_mappings" {
  type        = any
  default = {}
  description = <<EOF
Specify volumes to attach to the instance besides the volumes specified by the AMI
Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp3).

  block_device_mappings = [{
    device_name           = "/dev/xvda" # ROOT Volume
    volume_type           = "gp3"
    volume_size           = 100
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = data.aws_kms_key.your-kms-key.arn
    iops                  = 3000
    throughput            = 125
  }]
EOF

}

variable "capacity_reservation_specification" {
  type        = any
  default = {}
  description = <<EOF
Targeting for EC2 capacity reservations

  capacity_reservation_specification = {
    capacity_reservation_target = {
      capacity_reservation_id = aws_ec2_capacity_reservation.open.id
    }
  }
EOF

}

variable "cpu_options" {
  type = map(string)
  default = {}
  description = <<EOF
The CPU options for the instance

  cpu_options = {
    core_count       = 2
    threads_per_core = 1
  }
EOF

}

variable "credit_specification" {
  description = "Customize the credit specification of the instance"
  type = map(string)
  default = {}
}

variable "elastic_gpu_specifications" {
  description = "The elastic GPU to attach to the instance"
  type        = any
  default = {}
}

variable "elastic_inference_accelerator" {
  description = "Configuration block containing an Elastic Inference Accelerator to attach to the instance"
  type = map(string)
  default = {}
}

variable "enclave_options" {
  description = "Enable Nitro Enclaves on launched instances"
  type = map(string)
  default = {}
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance"
  type        = any
  default = {}
}

variable "maintenance_options" {
  description = "The maintenance options for the instance"
  type        = any
  default = {}
}

variable "license_specifications" {
  description = "A map of license specifications to associate with"
  type        = any
  default = {}
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type = map(string)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
}

variable "enable_monitoring" {
  description = "Enables/disables detailed monitoring"
  type        = bool
  default     = true
}

variable "network_interfaces" {
  type = map(string)
  default = {}
  description = <<EOF
Customize network interfaces to be attached at instance boot time

  network_interfaces = {
    delete_on_termination       = true
    associate_public_ip_address = true
    security_groups             = ["sg-2312"]
    subnet_id                   = "sn-123"
  }
EOF

}

variable "placement" {
  type = map(string)
  default = {}
  description = <<EOF
The placement of the instance

  placement = {
    delete_on_termination       = true
    associate_public_ip_address = true
    security_groups             = ["sg-2312"]
    subnet_id                   = "sn-123"
    spread_domain               = "my-company.local"
    tenancy                     = "default"
  }
EOF

}

variable "private_dns_name_options" {
  type = map(string)
  default = {}
  description = <<EOF
The options for the instance hostname. The default values are inherited from the subnet

  private_dns_name_options = {
    hostname_type                         = "resource-name" # resource-name or ip-name
    enable_resource_name_dns_a_record     = true
    enable_resource_name_dns_aaaa_record  = true
  }
EOF

}

variable "tags" {
  description = "A map of additional tags to add to the tag_specifications of launch template created"
  type = map(string)
  default = {}
}

variable "tag_specifications" {
  description = "The tags to apply to the resources during launch"
  type = list(string)
  default = ["instance", "volume", "network-interface"]
}
