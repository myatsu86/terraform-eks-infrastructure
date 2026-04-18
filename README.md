# EKS Cluster Terraform

Production-ready Amazon EKS cluster infrastructure as code.

## Architecture

- **VPC**: 192.168.0.0/16 with 3 public + 3 private subnets across 3 AZs
- **EKS Cluster**: Kubernetes 1.35 with managed control plane
- **Node Groups**: Auto-scaling worker nodes in private subnets
- **Networking**: NAT Gateway, Internet Gateway, route tables
- **Security**: IAM roles, security groups, encrypted EBS volumes

## Prerequisites

- AWS Account with appropriate permissions
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- [Terraform](https://www.terraform.io/downloads) >= 1.3.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region         = "ap-southeast-1"
cluster_name       = "my-eks-cluster"
cluster_admin_arns = [
  "arn:aws:iam::YOUR-ACCOUNT-ID:user/YOUR-USERNAME"
]
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy (takes ~15 minutes)
terraform apply
```

### 3. Configure kubectl

```bash
aws eks update-kubeconfig \
  --name my-eks-cluster \
  --region ap-southeast-1

# Verify connection
kubectl get nodes
```

## EKS Access Policies

Configure who can access your cluster in `terraform.tfvars`:

```hcl
cluster_admin_arns = [
  "arn:aws:iam::ACCOUNT-ID:user/username",
  "arn:aws:iam::ACCOUNT-ID:role/rolename"
]
```

### Available Access Levels

| Policy | Description | ARN |
|--------|-------------|-----|
| **Cluster Admin** | Full cluster and EKS API access | `arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy` |
| **Admin** | Full Kubernetes access (no EKS API) | `arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy` |
| **Edit** | Create/modify resources | `arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy` |
| **View** | Read-only access | `arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy` |

Default configuration grants **Cluster Admin** access. To customize, edit `eks-access.tf`.

## Accessing the Cluster

### First Time Setup

```bash
# Configure kubectl
aws eks update-kubeconfig \
  --name my-eks-cluster \
  --region ap-southeast-1

# Verify access
kubectl get nodes
kubectl get pods --all-namespaces
```

### Common Commands

```bash
# View cluster info
kubectl cluster-info

# Get all resources
kubectl get all --all-namespaces

# Deploy test application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check service
kubectl get service nginx
```

### Multiple Clusters

```bash
# List available contexts
kubectl config get-contexts

# Switch between clusters
kubectl config use-context <context-name>

# Rename context for easier switching
kubectl config rename-context \
  arn:aws:eks:ap-southeast-1:XXX:cluster/my-eks-cluster \
  my-cluster
```

## Configuration

### Main Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `ap-southeast-1` |
| `cluster_name` | EKS cluster name | `my-eks-cluster` |
| `kubernetes_version` | Kubernetes version | `1.35` |
| `instance_types` | Node instance types | `["t3.small"]` |
| `desired_capacity` | Desired number of nodes | `2` |
| `min_capacity` | Minimum nodes | `1` |
| `max_capacity` | Maximum nodes | `4` |

### Scaling Nodes

Edit `terraform.tfvars`:

```hcl
desired_capacity = 3
min_capacity     = 2
max_capacity     = 6
instance_types   = ["t3.medium"]
```

Apply changes:

```bash
terraform apply
```

## Cost Estimate

Monthly cost for default configuration:

```
EKS Control Plane:        $73
2x t3.small nodes:        $30
NAT Gateway:              $33
EBS Storage:              $4
Data Transfer:            ~$10
─────────────────────────────
TOTAL:                    ~$150/month
```

## Cleanup

**Important**: This destroys all resources and data!

```bash
# Delete all AWS resources
terraform destroy

# Confirm with: yes
```

## File Structure

```
.
├── provider.tf           # AWS provider configuration
├── variables.tf          # Variable definitions
├── vpc.tf                # VPC and networking
├── security-groups.tf    # Security groups
├── iam.tf                # IAM roles and policies
├── eks-cluster.tf        # EKS cluster and addons
├── eks-node-groups.tf    # Worker node groups
├── eks-access.tf         # EKS access entries
├── outputs.tf            # Output values
├── terraform.tfvars      # Your configuration (not in git)
└── README.md             # This file
```

## Troubleshooting

### Can't connect to cluster

```bash
# Update kubeconfig
aws eks update-kubeconfig \
  --name my-eks-cluster \
  --region ap-southeast-1

# Verify AWS credentials
aws sts get-caller-identity
```

### Nodes not appearing

```bash
# Check node group status
aws eks describe-nodegroup \
  --cluster-name my-eks-cluster \
  --nodegroup-name my-eks-cluster-nodegroup \
  --region ap-southeast-1

# Wait 2-3 minutes for nodes to join
kubectl get nodes -w
```

### Permission denied

Ensure your IAM user/role ARN is in `cluster_admin_arns` in `terraform.tfvars`, then run:

```bash
terraform apply
```

## Security Best Practices

- ✅ Nodes in private subnets (no public IPs)
- ✅ Security groups with minimal access
- ✅ IAM roles (no long-term credentials)
- ✅ EBS volumes encrypted
- ✅ Control plane logging enabled
- ✅ IMDSv2 required

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Support

For issues and questions:
- Check [Troubleshooting](#troubleshooting) section
- Review AWS EKS documentation
- Open an issue on GitHub