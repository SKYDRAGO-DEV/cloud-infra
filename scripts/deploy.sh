#!/bin/bash
# Kubernetes deployment helper for the production manifests in this repository.

set -euo pipefail

ENVIRONMENT="${1:-prod}"
DEPLOYMENT_NAME="api-deployment"

case "$ENVIRONMENT" in
    prod|production)
        NAMESPACE="production"
        MANIFEST_DIR="kubernetes/prod"
        ;;
    *)
        echo "Unsupported environment: $ENVIRONMENT" >&2
        echo "Supported values: prod, production" >&2
        exit 2
        ;;
esac

if ! command -v kubectl >/dev/null 2>&1; then
    echo "kubectl is required but was not found in PATH" >&2
    exit 127
fi

if [[ ! -d "$MANIFEST_DIR" ]]; then
    echo "Manifest directory not found: $MANIFEST_DIR" >&2
    exit 1
fi

echo "Deploying $ENVIRONMENT manifests to namespace $NAMESPACE..."

# Make the active target explicit before any mutation.
kubectl config current-context

# Namespace manifests are safe to apply before checking workload dependencies.
kubectl apply -f "$MANIFEST_DIR/namespace.yaml"

# Secrets are deliberately not committed. Refuse to deploy the workload until
# the required secret has been provisioned out-of-band.
if ! kubectl get secret api-secrets -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Required secret api-secrets is missing from namespace $NAMESPACE." >&2
    echo "Provision it securely before deploying; no database secret is stored in this repository." >&2
    exit 1
fi

# Apply the remaining manifests. Re-applying namespace.yaml is idempotent.
echo "Applying manifests from $MANIFEST_DIR..."
kubectl apply -f "$MANIFEST_DIR/" -n "$NAMESPACE"

# Wait for the API rollout and surface the final pod state.
echo "Waiting for rollout..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=300s

echo "Deployment status:"
kubectl get pods -n "$NAMESPACE" -l app=api

echo "Deployment complete."
