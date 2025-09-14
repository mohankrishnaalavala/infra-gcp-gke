# FraudGuard Infrastructure

This repository contains Terraform infrastructure-as-code for the FraudGuard fraud detection system. It provisions a GKE Autopilot cluster, Artifact Registry, Workload Identity Federation for GitHub Actions, Secret Manager, and optional budget alerts.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ GitHub Actions (CI/CD)                                      │
│ • Workload Identity Federation                              │
│ • Service Accounts: ci-builder, ci-deployer                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ Google Cloud Platform                                       │
│ • GKE Autopilot Cluster                                     │
│ • Artifact Registry (Docker)                                │
│ • Secret Manager                                            │
│ • Budget Alerts (optional)                                  │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

Before running Terraform, ensure you have:

1. **Google Cloud Project**: Created with billing enabled
2. **APIs Enabled**: The Terraform will enable required APIs automatically
3. **Local Tools**:
   - [Terraform](https://www.terraform.io/downloads) >= 1.0
   - [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/)

4. **Authentication**:
   ```bash
   gcloud auth application-default login
   gcloud config set project fraudguard-hackathon
   ```

## Quick Start

### 1. Configure Variables

Copy the example configuration and update with your values:

```bash
cd envs/hackathon
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# Required variables
project_id = "fraudguard-hackathon"
region     = "us-central1"
cluster_name = "fraudguard-auto"
ar_repo_id = "fraudguard"
github_owner = "mohankrishnaalavala"
repos_needing_wif = ["fraudguard-boa", "infra-gcp-gke"]
default_branches = ["main", "develop"]

# Optional: Budget configuration
# billing_account_id = "XXXXXX-XXXXXX-XXXXXX"
# budget_amount = 100
# budget_notification_emails = ["your-email@example.com"]
```

### 2. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration (first time only - manual apply required)
terraform apply
```

### 3. Post-Deployment Setup

After successful deployment, run these commands:

```bash
# Get cluster credentials
gcloud container clusters get-credentials fraudguard-auto --region us-central1 --project fraudguard-hackathon

# Create cluster admin binding (optional, for initial setup)
kubectl create clusterrolebinding bootstrap-admin \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value account)"
```

### 4. Add Secrets

Create secret versions in Secret Manager:

```bash
# Add Gemini API key
gcloud secrets versions add gemini-api-key --data-file=- <<< "your-gemini-api-key-here"

# Add configuration (create config.json first)
echo '{"environment": "hackathon", "debug": true}' > config.json
gcloud secrets versions add fraudguard-config --data-file=config.json
rm config.json
```

## Modules

### GKE Autopilot (`modules/gke-autopilot`)
- Creates a GKE Autopilot cluster with Workload Identity enabled
- Configured with private nodes, VPC-native networking
- Includes security posture, binary authorization, and monitoring

### Artifact Registry (`modules/artifact-registry`)
- Docker repository for container images
- Cleanup policies for cost optimization
- Located in `us` region for global access

### IAM Workload Identity Federation (`modules/iam-wif-github`)
- Enables keyless authentication from GitHub Actions
- Creates service accounts: `ci-builder` and `ci-deployer`
- Restricts access to specific repositories and branches

### Secret Manager (`modules/secret-manager`)
- Creates placeholder secrets: `gemini-api-key`, `fraudguard-config`
- Configured with automatic replication
- IAM bindings for GKE access

### Budgets (`modules/budgets`)
- Optional budget alerts for cost control
- Configurable thresholds and notification emails
- Only created if `billing_account_id` is provided

## GitHub Actions Integration

After infrastructure deployment, configure GitHub Actions with these repository variables:

```bash
# Get the output values
terraform output

# Set in GitHub repository settings > Secrets and variables > Actions > Variables:
WIF_PROVIDER=//iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-actions/providers/github-oidc
WIF_SERVICE_ACCOUNT_BUILDER=ci-builder@fraudguard-hackathon.iam.gserviceaccount.com
WIF_SERVICE_ACCOUNT_DEPLOYER=ci-deployer@fraudguard-hackathon.iam.gserviceaccount.com
ARTIFACT_REGISTRY_URL=us-docker.pkg.dev/fraudguard-hackathon/fraudguard
GKE_CLUSTER=fraudguard-auto
GKE_LOCATION=us-central1
PROJECT_ID=fraudguard-hackathon
```

### Example GitHub Actions Usage

```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: ${{ vars.WIF_PROVIDER }}
    service_account: ${{ vars.WIF_SERVICE_ACCOUNT_BUILDER }}

- name: Setup gcloud CLI
  uses: google-github-actions/setup-gcloud@v2

- name: Configure Docker for Artifact Registry
  run: gcloud auth configure-docker us-docker.pkg.dev
```

## OIDC Subject Conditions

The Workload Identity Federation is configured to allow access from:

- Repository: `mohankrishnaalavala/fraudguard-boa` or `mohankrishnaalavala/infra-gcp-gke`
- Branches: `main` or `develop`
- Subject format: `repo:OWNER/REPO:ref:refs/heads/BRANCH`

Example valid subjects:
- `repo:mohankrishnaalavala/fraudguard-boa:ref:refs/heads/main`
- `repo:mohankrishnaalavala/infra-gcp-gke:ref:refs/heads/develop`

## Cost Optimization

- **GKE Autopilot**: Pay only for running pods, automatic scaling
- **Artifact Registry**: Cleanup policies remove old images
- **Budget Alerts**: Monitor spending with configurable thresholds
- **Regional Resources**: Most resources in `us-central1` to minimize egress

## Security Features

- **Workload Identity**: Keyless authentication, no service account keys
- **Private GKE Cluster**: Nodes have private IPs
- **Least Privilege**: Service accounts have minimal required permissions
- **Secret Manager**: Encrypted secret storage with IAM controls
- **Network Security**: VPC-native networking with security policies

## Troubleshooting

### Common Issues

1. **API Not Enabled**: Terraform enables APIs automatically, but may take a few minutes
2. **Billing Account**: Budget creation requires a valid billing account ID
3. **Permissions**: Ensure your user has `Editor` or `Owner` role on the project
4. **Quota**: Check GKE and Compute Engine quotas in your region

### Useful Commands

```bash
# Check cluster status
gcloud container clusters describe fraudguard-auto --region us-central1

# List secrets
gcloud secrets list

# Check Workload Identity setup
gcloud iam workload-identity-pools list --location=global

# View budget
gcloud billing budgets list --billing-account=BILLING_ACCOUNT_ID
```

## Cleanup

To destroy all resources:

```bash
cd envs/hackathon
terraform destroy
```

**Warning**: This will delete the GKE cluster and all applications running on it.

## Support

For issues with this infrastructure:
1. Check the [Terraform documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
2. Review Google Cloud [GKE Autopilot documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
3. Check [Workload Identity Federation setup](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines)