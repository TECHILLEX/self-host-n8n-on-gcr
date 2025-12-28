# Custom Image Build Guide

## Overview

This guide explains how to build, tag, and push a custom n8n Docker image with community nodes pre-installed.

## Why Custom Image?

Community nodes must be installed at **build time** because Cloud Run uses an ephemeral filesystem. Installing nodes at runtime means they'll be lost when the container restarts.

## Prerequisites

- Docker installed
- `gcloud` CLI installed and authenticated
- Artifact Registry repository created

## Step-by-Step Build Process

### 1. Set Variables

```bash
PROJECT_ID="your-gcp-project-id"
REGION="your-gcp-region"
REPO_NAME="n8n-repo"
SERVICE_NAME="n8n"
```

### 2. Configure Docker Authentication

```bash
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet
```

### 3. Build Image Tag

```bash
IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:latest"
```

### 4. Build Docker Image

```bash
docker build --platform linux/amd64 -t "$IMAGE_TAG" .
```

### 5. Push to Artifact Registry

```bash
docker push "$IMAGE_TAG"
```

### 6. Deploy to Cloud Run

```bash
gcloud run deploy ${SERVICE_NAME} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --image=${IMAGE_TAG} \
  --no-traffic
```

The `--no-traffic` flag creates a new revision without routing traffic to it, allowing you to test before switching traffic.

## Community Nodes

### What Are Community Nodes?

Community nodes are third-party n8n integrations created by the community. They extend n8n's functionality beyond the built-in nodes.

### How They Work

1. **List nodes** in `community-nodes.txt` (one per line with version):
   ```
   n8n-example-xxx@0.1.1
   ```

2. **Installation happens during build** - the `install-community-nodes.sh` script automatically installs all listed nodes.

3. **Nodes are baked into the image** - they persist across all container restarts and deployments.

### Adding/Updating Nodes

1. Edit `community-nodes.txt`
2. Rebuild and push the image (steps 4-5 above)
3. Deploy the new image (step 6 above)

### Required Environment Variable

Ensure `N8N_COMMUNITY_NODES_ENABLED=true` is set in your Cloud Run service configuration.

## Complete Example

```bash
# Set variables
PROJECT_ID="my-project"
REGION="us-west1"
REPO_NAME="n8n-repo"
SERVICE_NAME="n8n"

# Authenticate
gcloud auth configure-docker ${REGION}-docker.pkg.dev --quiet

# Build and push
IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${SERVICE_NAME}:latest"
docker build --platform linux/amd64 -t "$IMAGE_TAG" .
docker push "$IMAGE_TAG"

# Deploy to Cloud Run
gcloud run deploy ${SERVICE_NAME} \
  --region=${REGION} \
  --project=${PROJECT_ID} \
  --image=${IMAGE_TAG} \
  --no-traffic
```

## Verification

After deployment, verify nodes are installed:

```bash
docker run --rm --entrypoint /bin/sh "$IMAGE_TAG" -c "npm list -g | grep n8n"
```

