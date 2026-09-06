# cloud-infra

Infrastructure-as-code and deployment examples covering **AWS, GCP, Terraform, and Kubernetes**.

This repository is retained as supporting engineering work for data/API infrastructure. It is not presented as a production trading platform, and the documentation intentionally describes only components that exist in the current tree.

## Implemented

### AWS

`aws/terraform/` contains Terraform configuration for AWS networking and application-infrastructure primitives, including VPC/subnet/routing and security-related resources.

### GCP

`gcp/terraform/` contains Terraform configuration for Google Cloud infrastructure.

### Kubernetes

`kubernetes/prod/` contains production-style Kubernetes manifests for an API workload, including namespace and deployment configuration. Sensitive database configuration is referenced through a Kubernetes Secret rather than committed directly.

### Automation

- `.github/workflows/ci.yml` validates Terraform formatting/configuration and Kubernetes YAML.
- `scripts/deploy.sh` provides a deployment helper for the repository's infrastructure workflow.

## Repository layout

```text
cloud-infra/
├── aws/
│   └── terraform/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── gcp/
│   └── terraform/
│       └── main.tf
├── kubernetes/
│   └── prod/
│       ├── api-deployment.yaml
│       └── namespace.yaml
├── scripts/
│   └── deploy.sh
└── .github/workflows/ci.yml
```

## Validation

CI performs real failing checks rather than swallowing errors:

```text
Terraform fmt
    ↓
Terraform init -backend=false
    ↓
Terraform validate
    ↓
Kubernetes YAML parse validation
```

Cloud credentials are not required for static validation because Terraform initializes with the backend disabled and no apply is performed.

## Security notes

- Do not commit cloud credentials, kubeconfigs, database passwords, API tokens, or Terraform state containing secrets.
- The AWS backend configuration contains a state-bucket identifier, not credentials. Adapt backend/state configuration before using this repository in another environment.
- Kubernetes Secret values must be provisioned separately; they are intentionally not stored in the manifests.
- Review ingress, egress, IAM, network, and secret-management requirements before any real deployment.

## Scope boundaries

The current repository does **not** contain Azure, Pulumi, AWS CDK, or the broader cloud-service inventory previously described in this README. Those claims have been removed to keep public documentation aligned with the implementation.

## Relationship to trading systems

The repository demonstrates infrastructure patterns that can support market-data APIs, research services, internal tooling, or other containerized workloads. It does not claim live broker connectivity, trading execution, or production financial-system deployment.
