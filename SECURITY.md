# Security Policy

This repository contains infrastructure-as-code and Kubernetes deployment examples. Security issues should be handled conservatively because infrastructure configuration can expose credentials, network boundaries, cloud resources, or deployment details.

## Do not commit secrets

Never commit:

- cloud access keys or service-account credentials;
- Terraform state files or plans containing sensitive values;
- populated `.tfvars` files with credentials or private environment data;
- Kubernetes Secret manifests containing real values;
- private keys, certificates, passwords, tokens, or webhook secrets;
- production account identifiers or sensitive endpoints that are not intended to be public.

Use environment variables, secret managers, CI secret stores, and Kubernetes secret references as appropriate. Example/template files must contain placeholders only.

## Reporting a vulnerability

Do not open a public issue containing an active credential or exploitable secret. Revoke or rotate exposed credentials first when you control them, then report the affected file/path and remediation context without reproducing secret values unnecessarily.

## Terraform state

Terraform state may contain sensitive data even when the configuration files do not. State is intentionally excluded by `.gitignore` and should be stored in an appropriately secured backend with access controls, encryption, and locking where supported.

## Scope

This repository is an engineering reference and is not a guarantee that the included infrastructure is suitable for a specific production environment. Network rules, IAM, secret management, image provenance, TLS, resource policies, and cloud-provider controls must be reviewed for the target deployment before use.
