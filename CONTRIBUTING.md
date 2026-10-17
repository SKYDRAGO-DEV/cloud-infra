# Contributing to cloud-infra

This repository contains **reference Terraform and Kubernetes manifests**, not a verified production cloud deployment.

## Before you propose a change

- Open a focused issue or PR describing the infrastructure problem and target cloud/provider.
- Do not commit credentials, cloud state, kubeconfigs, private key material or `Secret.stringData` values.
- Avoid adding real resource identifiers, IPs or hostnames that should not be public.
- Explain security, IAM, networking and cost implications of any change.
- Use a real controlled target environment before claiming successful deployment; static validation does not prove a cloud resource can be created.

## Static verification

Run the validation appropriate to the directory you changed:

```bash
cd aws/terraform
terraform fmt -check
terraform init -backend=false
terraform validate
```

For GCP, run the same commands from `gcp/terraform`.

Also inspect Kubernetes manifest syntax, secret references and deployment script behaviour. Review the [CI workflow](.github/workflows/ci.yml) for current automated checks.

## Pull-request checklist

- [ ] Terraform format and validation pass for affected directories
- [ ] Kubernetes YAML and scripts are valid where applicable
- [ ] No real credentials, secret values or Terraform state are committed
- [ ] No cloud resources have been applied automatically for this PR
- [ ] IAM/network/security/cost impacts are documented
- [ ] README changed where the documented architecture changes

Security-sensitive findings should follow [SECURITY.md](SECURITY.md), not a public exploit report.
