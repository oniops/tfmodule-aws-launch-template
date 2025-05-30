# tfmodule-aws-launch-template

tfmodule-aws-launch-template is terraform module which creates AWS EC2 Launch Template resources

## Git

```
git clone https://github.com/oniops/tfmodule-aws-launch-template.git

cd tfmodule-aws-launch-template
```

## Build

```
terraform init
terraform plan
terraform apply
```

## Usage


### for EKS Node 

```hcl
locals {
  cluster_name        = "demo-eks"
  cluster_auth_base64 = "secret"
  cluster_endpoint    = "https://api.me?"
  cluster_dns_ip      = "1.2.1.1"
  user_data           = <<EOF
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${local.cluster_name} \
  --b64-cluster-ca ${local.cluster_auth_base64} \
  --apiserver-endpoint ${local.cluster_endpoint} \
  --dns-cluster-ip ${local.cluster_dns_ip} \
  --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${data.aws_ami.this.id}'
  EOF
}

module "ctx" {
  source = "git::https://github.com/oniops/tfmodule-context.git?ref=v1.0.0"
  context = {
    project     = "demo"
    region      = "us-east-1"
    environment = "Development"
    owner       = "demo@opsnow.com"
    department  = "DevOps Team"
    customer    = "OpsNow. INC."
    pri_domain  = "opsnow.local"
    domain      = "demo.opsnow360.io"
  }
}

data "aws_ami" "this" {
  most_recent = true
  filter {
    name = "name"
    values = ["amazon-eks-node-al2023-arm64-standard-1.30-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self", "amazon"]
}

module "demo" {
  source          = "git::https://github.com/oniops/tfmodule-aws-launch-template.git"
  # source          = "../"
  context         = module.ctx.context
  name            = "demo"
  description     = "demo for eks worker node"
  default_version = 1
  image_id        = data.aws_ami.this.id
  user_data = base64encode(<<EOF
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${local.cluster_name} \
  --b64-cluster-ca ${local.cluster_auth_base64} \
  --apiserver-endpoint ${local.cluster_endpoint} \
  --dns-cluster-ip ${local.cluster_dns_ip} \
  --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${data.aws_ami.this.id}'
  EOF
  )
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      volume_type = "gp3"
      volume_size = 100
      encrypted   = true
      kms_key_id  = "arn:aws:kms:us-east-1:111122223333:key/sdjflsdjflsfdjl"
    },
  ]
  security_group_ids = ["sg-12345"]

}

```

## Resources


## Input Variables

### Input Variables for Cluster

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Example</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>name</td>
        <td>템플릿 이름 입니다.</td>
        <td>any</td>
        <td>"demo"</td>
        <td>yes</td>
    </tr>
    <tr>
        <td>block_device_mappings</td>
        <td>EBS 볼륨을 추가합니다.</td>
        <td>any</td>
        <td><pre>
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
</pre></td>
        <td>no</td>
    </tr>
</tbody>
</table>


### Input Variables for Worker Nodes

<table>
<thead>
    <tr>
        <th>Name</th>
        <th>Description</th>
        <th>Type</th>
        <th>Example</th>
        <th>Required</th>
    </tr>
</thead>
<tbody>
    <tr>
        <td>enabled_node_security_group_rules</td>
        <td>생성된 노드 보안 그룹에 대해 권장 하는 보안 그룹 규칙을 활성화할지 여부를 결정합니다. 여기에는 임시 포트의 노드 간 TCP 수신이 포함되며 모든 Outbound 송신 트래픽을 허용합니다.</td>
        <td>bool</td>
        <td>true</td>
        <td>no</td>
    </tr>
</tbody>
</table>

## Output Values



## Hands-on

### EKS Cluster 컨텍스트 설정

```
aws eks update-kubeconfig --name <eks_cluster_name> --region <aws_region_name>
```

### Kubectl 명령어를 통한 EKS Cluster 정보 확인

- 워커노드 확인
```
kubectl get nodes -o wide
```

- Pods 확인
```
kubectl get po -a -o wide
```

