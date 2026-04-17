#!/bin/bash
# Kubernetes deployment script for production

set -euo pipefail

NAMESPACE="${1:-production}"
DEPLOYMENT_NAME="api-deployment"

echo "🚀 Deploying to $NAMESPACE..."

# Get current context
kubectl config current-context

# Check namespace exists
if ! kubectl get namespace "$NAMESPACE" &>/dev/null; then
    echo "Creating namespace $NAMESPACE..."
    kubectl create namespace "$NAMESPACE"
fi

# Apply manifests
echo "Applying manifests..."
kubectl apply -f "kubernetes/$NAMESPACE/" -n "$NAMESPACE"

# Wait for rollout
echo "Waiting for rollout..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=300s

# Show status
echo "Deployment status:"
kubectl get pods -n "$NAMESPACE" -l app=api

echo "✅ Deployment complete!"
