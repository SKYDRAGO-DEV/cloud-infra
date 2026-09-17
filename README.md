# cloud-infra

Infrastructure-as-code and deployment examples covering **AWS, GCP, Terraform, and Kubernetes**.

This repository is supporting engineering work for data/API infrastructure. It is not presented as a production trading platform, and documentation is intentionally limited to components that exist in the current tree.

## Implemented

### AWS

`aws/terraform/` contains Terraform configuration for AWS networking and application-infrastructure primitives, including VPC/subnet/routing, NAT gateways, and a workload security group.

### GCP

`gcp/terraform/` contains a custom VPC/subnet, explicit GKE pod/service secondary IP ranges, a VPC-native GKE cluster, and a PostgreSQL Cloud SQL instance configured for private networking. Private Service Access is provisioned explicitly through a reserved peering range and Service Networking connection.

### Kubernetes

`kubernetes/prod/` contains production-style manifests for an API workload, including namespaces, Deployment, Service, HPA, and Ingress configuration. The workload references an `api-secrets` Kubernetes Secret, but secret values are deliberately **not** committed to this repository.

### Automation

- `.github/workflows/ci.yml` validates Terraform formatting/configuration, parses Kubernetes YAML, rejects tracked plaintext `Secret.stringData`, and syntax-checks the deployment helper.
- `scripts/deploy.sh` targets the repository's real `kubernetes/prod/` path and refuses to deploy the API until the required `api-secrets` Secret exists.

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

CI performs failing checks rather than swallowing errors:

```text
Terraform fmt
    ↓
Terraform init -backend=false
    ↓
Terraform validate
    ↓
Kubernetes YAML parse + plaintext-secret guard
    ↓
Deployment-script syntax check
```

Cloud credentials are not required for static Terraform validation because CI initializes with the backend disabled and performs no plan/apply.

Static validation is not equivalent to a real cloud deployment. Provider permissions, quotas, APIs, CIDR availability, regional capacity, DNS, certificates, external controllers, and account-specific policies still have to be validated in the target environment.

## Secret provisioning

The production Deployment expects:

```text
Secret: api-secrets
Key:    database-url
Namespace: production
```

Provision that value through your secret-management/deployment system rather than committing it. For a local or controlled manual workflow, Kubernetes can create the Secret from a local environment file, for example:

```bash
kubectl create secret generic api-secrets \
  --namespace production \
  --from-env-file=/secure/path/api-secrets.env
```

The environment file must stay outside this repository and source control.

## Deployment helper

The helper currently supports the production manifests only:

```bash
./scripts/deploy.sh prod
# or
./scripts/deploy.sh production
```

Before applying the API workload it:

1. verifies `kubectl` exists;
2. prints the active Kubernetes context;
3. applies namespace definitions;
4. verifies `api-secrets` exists in `production`;
5. applies the production manifests;
6. waits for the API Deployment rollout.

This is intentionally fail-closed around missing secret configuration.

## Security notes

- Do not commit cloud credentials, kubeconfigs, database passwords, API tokens, private keys, or Terraform state containing secrets.
- The AWS/GCP backend configuration contains state-bucket identifiers, not credentials. Adapt backend/state configuration before using this repository in another environment.
- Kubernetes Secret values must be provisioned separately; CI rejects tracked `stringData` in Kubernetes Secret manifests.
- Review ingress, egress, IAM, workload identity, network policy, secret-management, image provenance, and supply-chain requirements before any real deployment.
- The Kubernetes image reference is an example deployment contract, not a guarantee that a compatible image exists or is immutable.

## Scope boundaries

The current repository does **not** contain Azure, Pulumi, AWS CDK, or a complete production platform. It also does not prove successful cloud apply/deployment from CI; CI validates configuration statically.

## Relationship to trading systems

The repository demonstrates infrastructure patterns that can support market-data APIs, research services, internal tooling, or other containerized workloads. It does not claim live broker connectivity, trading execution, or production financial-system deployment.
