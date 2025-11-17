# Terraform Modules: Creating an EC2 Instance with Nginx

This repository demonstrates how to use **Terraform modules** to create reusable and organized infrastructure code. The project deploys an EC2 instance running Nginx in a Docker container on AWS, showcasing best practices for modular Terraform architecture.

## Overview

This Terraform project creates a complete AWS infrastructure including:

- **VPC** (Virtual Private Cloud)
- **Subnet** with internet gateway and routing
- **EC2 instance** running Amazon Linux 2023
- **Security groups** for controlled access
- **Nginx web server** running in a Docker container

## Project Structure

```
.
├── main.tf                      # Root module - orchestrates all resources
├── variables.tf                 # Root module variable declarations
├── outputs.tf                   # Root module outputs
├── providers.tf                 # Terraform and provider configuration
├── terraform.tfvars.example     # Example variable values
├── start-up.sh                  # User data script for EC2 initialization
└── modules/
    ├── subnet/                  # Subnet module
    │   ├── main.tf             # Subnet, internet gateway, and route table
    │   ├── variables.tf        # Module input variables
    │   └── output.tf           # Module outputs (subnet ID)
    └── webserver/              # Webserver module
        ├── main.tf             # EC2 instance, security groups, and SSH key
        ├── variables.tf        # Module input variables
        └── output.tf           # Module outputs (public IP)
```

## 🧩 Module Architecture

### Root Module (`main.tf`)

The root module creates the VPC and orchestrates two custom modules:

1. **`nginx-app-subnet-1`** - Creates the networking infrastructure
2. **`nginx-webserver`** - Creates the web server and security configuration

### Subnet Module (`modules/subnet/`)

**Purpose**: Manages networking resources

**Resources Created**:

- AWS Subnet in the specified availability zone
- Internet Gateway for internet connectivity
- Default Route Table with internet access

**Inputs**:

- `vpc_id` - VPC ID where subnet will be created
- `subnet_cidr_block` - CIDR block for the subnet
- `avail_zone` - AWS availability zone
- `env_prefix` - Environment prefix for resource naming
- `default_route_table_id` - VPC's default route table ID

**Outputs**:

- `subnet-id` - ID of the created subnet (used by webserver module)

### Webserver Module (`modules/webserver/`)

**Purpose**: Manages compute and security resources

**Resources Created**:

- Security Group with ingress rules (SSH on port 22, HTTP on port 8080)
- Egress rule allowing all outbound traffic
- SSH Key Pair for instance access
- EC2 Instance with Nginx running in Docker

**Inputs**:

- `vpc_id` - VPC ID for security group
- `env_prefix` - Environment prefix for resource naming
- `my_ip_cidr` - Your IP address for SSH access restriction
- `pubic_key_filepath` - Path to SSH public key
- `ec2_instance_type` - EC2 instance type (e.g., t2.micro)
- `subnet_id` - Subnet ID where instance will be launched
- `avail_zone` - AWS availability zone

**Outputs**:

- `public-ip` - Public IP address of the EC2 instance

## Getting Started

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- SSH key pair generated

### Setup Instructions

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd terraform-practice
   ```

2. **Create your variables file**

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit `terraform.tfvars`** with your values:

   ```hcl
   vpc_cidr_block     = "10.10.0.0/16"
   subnet_cidr_block  = "10.10.0.0/24"
   avail_zone         = "us-east-1a"
   env_prefix         = "dev"
   my_ip_cidr         = "YOUR_IP/32"  # Get your IP from https://whatismyip.com
   ec2_instance_type  = "t2.micro"
   pubic_key_filepath = "~/.ssh/id_rsa.pub"
   ```

4. **Initialize Terraform**

   ```bash
   terraform init
   ```

5. **Review the execution plan**

   ```bash
   terraform plan
   ```

6. **Apply the configuration**

   ```bash
   terraform apply
   ```

7. **Access your Nginx server**

   After successful deployment, Terraform will output the public IP:

   ```bash
   terraform output public-ip
   ```

   Visit `http://<public-ip>:8080` in your browser to see the Nginx welcome page.

## Key Concepts Demonstrated

### 1. **Module Reusability**

The subnet and webserver modules can be reused across different projects or environments. Simply adjust the input variables to fit your needs.

### 2. **Module Dependencies**

Notice how the webserver module depends on the subnet module's output:

```hcl
subnet_id = module.nginx-app-subnet-1.subnet-id
```

This creates an implicit dependency chain that Terraform manages automatically.

### 3. **Variable Passing**

Variables flow from root → module, demonstrating proper encapsulation and interface design.

### 4. **Output Chaining**

Outputs from one module become inputs to another, showing how to build complex infrastructure from simple building blocks.

### 5. **Resource Tagging**

All resources use the `env_prefix` variable for consistent naming, making it easy to identify resources by environment.

## Resources Created

| Resource Type    | Name Pattern                | Purpose                       |
| ---------------- | --------------------------- | ----------------------------- |
| VPC              | `{env_prefix}-vpc`          | Main network container        |
| Subnet           | `{env_prefix}-subnet-1`     | Network segment for resources |
| Internet Gateway | `{env_prefix}-gw`           | Internet connectivity         |
| Route Table      | `{env_prefix}-route-table`  | Network traffic routing       |
| Security Group   | `{env_prefix}-sg`           | Firewall rules                |
| EC2 Instance     | `{env_prefix}-nginx-server` | Web server                    |

## Security Configuration

- **SSH Access**: Restricted to your IP address only (`my_ip_cidr`)
- **Web Access**: Port 8080 open to the internet (0.0.0.0/0)
- **Outbound Traffic**: All allowed for package downloads and updates

## Cleanup

To destroy all resources and avoid AWS charges:

```bash
terraform destroy
```

## Notes

- The EC2 instance uses Amazon Linux 2023 AMI
- Nginx runs in a Docker container (installed via user data script)
- The instance has a public IP address assigned automatically
- User data script updates the system and starts Nginx on boot

## Learning Objectives

This project is ideal for understanding:

- How to structure Terraform code using modules
- Passing data between modules using outputs
- Creating reusable infrastructure components
- Managing dependencies between resources
- AWS networking basics (VPC, Subnet, Internet Gateway)
- EC2 instance configuration and user data

## Further Reading

- [Terraform Modules Documentation](https://www.terraform.io/docs/language/modules/index.html)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---
