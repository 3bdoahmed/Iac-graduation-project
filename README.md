# IaC Graduation Project

A practical Infrastructure as Code project that demonstrates cloud architecture patterns. This project has two stages: serverless backend infrastructure and a Kubernetes cluster on AWS.

---

## 📋 Quick Overview

### Stage 1: Serverless Solar Monitoring System
- Upload sensor data to S3
- Automatically process with Lambda
- Store in DynamoDB
- Expose data via REST APIs

### Stage 2: Kubernetes Cluster
- Deploy a Kubernetes cluster on AWS EC2
- Master node + Worker node setup
- Ready for containerized applications

---

## 📁 Project Structure

```
Iac-graduation-project/
├── first step/
│   ├── modules/              # Terraform modules
│   │   ├── s3/               # S3 buckets
│   │   ├── lambda/           # Lambda functions
│   │   ├── dynamodb/         # DynamoDB tables
│   │   ├── api_gateway/      # API endpoints
│   │   ├── sns/              # Email notifications
│   │   ├── iam/              # User permissions
│   │   └── api_lambda/       # API Lambda functions
│   ├── lambda/               # Lambda function code
│   ├── main.tf               # Main configuration
│   ├── provider.tf           # AWS settings
│   └── variables.tf          # Variables
│
├── second step/
│   ├── modules/
│   │   ├── aws_vpc/          # Network configuration
│   │   ├── aws_sg/           # Security groups
│   │   ├── key-pair/         # SSH key pair
│   │   └── aws_vms/          # EC2 instances
│   ├── userdata/
│   │   ├── master.sh         # Master node setup
│   │   └── worker.sh         # Worker node setup
│   ├── main.tf               # Main configuration
│   └── provider.tf           # AWS settings
│
└── README.md                 # This file
```

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/3bdoahmed/Iac-graduation-project.git
cd Iac-graduation-project
```

### 2. Set Up AWS Credentials

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Enter default region (e.g., us-east-1)
# Enter default output format (json)
```

---

## 🔧 Stage 1: Serverless Solar Monitoring

### What Gets Created

| Resource | Purpose |
|----------|---------|
| **S3 Buckets** | Store sensor data |
| **Lambda** | Process data automatically |
| **DynamoDB** | Store processed data |
| **API Gateway** | Expose 3 REST APIs |
| **SNS** | Send email notifications |
| **IAM** | User permissions |

### Deploy

```bash
cd "first step"

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create everything
terraform apply
```

### Configuration

Create `first step/terraform.tfvars`:

```hcl
notification_email = "your-email@example.com"
```

### Test the APIs

After deployment, you'll get API endpoints. Test them:

```bash
# Get solar data
curl https://your-api-endpoint/solar

# Get battery data
curl https://your-api-endpoint/battery

# Get system status
curl https://your-api-endpoint/system
```

### Upload Sample Data

```bash
# Upload a file to trigger the Lambda
aws s3 cp sensor_data.json s3://solar-data-bucket-xxx/
```

### View Logs

```bash
# See Lambda execution logs
aws logs tail /aws/lambda/data-processor --follow
```

### Delete Everything

```bash
terraform destroy
```

---

## 🚀 Stage 2: Kubernetes Cluster

### What Gets Created

| Resource | Details |
|----------|---------|
| **VPC** | Network: 10.0.0.0/16 |
| **Subnet** | 10.0.1.0/24 |
| **Security Group** | Allow K8s traffic |
| **Master Node** | c7i-flex.large (Control Plane) |
| **Worker Node** | c7i-flex.large (Run containers) |
| **Key Pair** | SSH access |

### Deploy

```bash
cd "second step"

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Create everything
terraform apply

# Save the outputs (IPs and key name)
terraform output
```

### Access the Cluster

```bash
# Get your SSH key
aws ssm get-parameter --name /ec2/keypair/k8s-key --query 'Parameter.Value' --output text > k8s-key.pem
chmod 600 k8s-key.pem

# SSH to master node
ssh -i k8s-key.pem ec2-user@<master-public-ip>

# SSH to worker node
ssh -i k8s-key.pem ec2-user@<worker-public-ip>
```

### Check Kubernetes Status

```bash
# Connect to master
ssh -i k8s-key.pem ec2-user@<master-ip>

# Check nodes
kubectl get nodes

# Check all pods
kubectl get pods -A

# Check cluster info
kubectl cluster-info
```

### Deploy a Test Application

```bash
# Create a simple deployment
kubectl create deployment nginx --image=nginx:latest

# Expose it
kubectl expose deployment nginx --type=NodePort --port=80

# Check services
kubectl get services
```

### Delete Everything

```bash
cd "second step"
terraform destroy
```

---

## 📊 API Endpoints

### Solar Panel API
```
GET /solar

Response:
{
  "inverter_id": "INV-001",
  "panel_id": "PANEL-001",
  "power": 3648,
  "timestamp": "2024-05-10T10:30:00Z"
}
```

### Battery API
```
GET /battery

Response:
{
  "battery_id": "BATT-001",
  "soc": 85,
  "voltage": 48.2,
  "temperature": 25.3,
  "timestamp": "2024-05-10T10:30:00Z"
}
```

### System Status API
```
GET /system

Response:
{
  "total_solar_power": 3648,
  "battery_soc": 85,
  "grid_status": "connected",
  "efficiency": 94.2,
  "timestamp": "2024-05-10T10:30:00Z"
}
```

---

## 📈 Architecture Diagrams

### Stage 1: Data Flow

```
Sensor Data (S3)
       ↓
    Lambda Processor
       ↓
    DynamoDB Tables
       ├─ battery_data
       ├─ solar_data
       └─ system_status
       ↓
    API Gateway
       ↓
REST API Endpoints
```

### Stage 2: Infrastructure

```
VPC (10.0.0.0/16)
    ├─ Internet Gateway
    ├─ Public Subnet (10.0.1.0/24)
    ├─ Master Node
    │   └─ Kubernetes Control Plane
    ├─ Worker Node
    │   └─ Pod Containers
    └─ Security Groups
```

---

## 🔍 Monitoring

### View Lambda Logs

```bash
aws logs tail /aws/lambda/data-processor --follow
```

### Check DynamoDB Usage

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/DynamoDB \
  --metric-name ConsumedReadCapacityUnits \
  --dimensions Name=TableName,Value=battery_data \
  --start-time 2024-05-10T00:00:00Z \
  --end-time 2024-05-10T23:59:59Z \
  --period 3600 \
  --statistics Sum
```
---

## ⚠️ Important Notes

- **Costs**: This project uses real AWS resources (not free tier). Destroy resources when not in use.
- **Credentials**: Never commit AWS keys to Git. Use `aws configure` instead.
- **Region**: Default is `us-east-1`. Change in `provider.tf` if needed.
- **Time**: First deployment takes ~5-10 minutes.

---

## 🔐 Security

- ✅ Lambda has minimal required permissions
- ✅ Security groups restrict network access
- ✅ DynamoDB is encrypted at rest
- ✅ S3 has server-side encryption

---

## 📝 Essential Commands

### Terraform
```bash
terraform init          # Initialize Terraform
terraform plan          # See what will be created
terraform apply         # Create resources
terraform destroy       # Delete everything
terraform output        # Show outputs
```

### AWS CLI
```bash
aws s3 ls                      # List S3 buckets
aws logs tail <log-group>      # View logs
aws ec2 describe-instances     # List EC2 instances
```

### Kubernetes
```bash
kubectl get nodes       # List nodes
kubectl get pods -A     # List all pods
kubectl logs <pod-name> # Pod logs
kubectl apply -f file.yaml  # Deploy
```

---

## ✅ What This Project Teaches

- Infrastructure as Code (Terraform)
- Serverless Architecture
- Event-Driven Design
- AWS Services Integration
- Kubernetes Cluster Setup
- DevOps Best Practices

---

## 👨‍💻 Author

**AbdelRahman Ahmed**
