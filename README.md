# cloud-infra

> Cloud Infrastructure as Code | AWS | GCP | Azure | Terraform | Pulumi | Kubernetes | SRE best practices

[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat-square&logo=amazon-aws)](https://aws.amazon.com/)
[![GCP](https://img.shields.io/badge/GCP-4285F4?style=flat-square&logo=google-cloud)](https://cloud.google.com/)
[![Terraform](https://img.shields.io/badge/Terraform-7B36BC?style=flat-square&logo=terraform)](https://www.terraform.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes)](https://kubernetes.io/)

## Providers

| Cloud | Tools | Modules |
|-------|-------|---------|
| AWS | Terraform, Pulumi, CDK | VPC, ECS, RDS, EKS |
| GCP | Terraform, Pulumi | VPC, GKE, Cloud SQL |
| Azure | Terraform, Pulumi | VNet, AKS, Azure SQL |

## Infrastructure Layout

\`\`\`
cloud-infra/
├── aws/
│   ├── terraform/    # AWS Terraform modules
│   └── cdk/          # AWS CDK TypeScript
├── gcp/
│   └── terraform/    # GCP Terraform modules
└── kubernetes/       # K8s configurations
    ├── dev/
    ├── staging/
    └── prod/
\`\`\`

## License

MIT © SKYDRAGO-DEV
