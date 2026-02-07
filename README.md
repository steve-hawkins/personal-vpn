# Personal WireGuard VPN on GCP Free Tier

This project uses Terraform to deploy a personal WireGuard VPN server on Google Cloud Platform's free tier. It includes automated deployment via GitHub Actions, self-healing, automated maintenance, and monitoring.

## Features

- **WireGuard VPN:** A fast, modern, and secure VPN.
- **Terraform:** Infrastructure as Code for easy and repeatable deployments.
- **GCP Free Tier:** Runs on an `e2-micro` instance, which is part of the GCP free tier.
- **Self-healing:** The VM is managed by an Instance Group Manager, so it will be automatically recreated if it fails.
- **Zero-downtime Maintenance:** The use of an IGM with a rolling update strategy allows for updates with minimal downtime.
- **GitHub Actions:** Automated CI/CD for deploying infrastructure changes.
- **Dependabot:** Keeps Terraform providers up to date.
- **Monitoring & Alerting:** Monitors CPU usage and billing to prevent unexpected costs.
- **Automated Maintenance:** The VM is automatically updated with the latest security patches weekly.

## Setup

### 1. Prerequisites

- A Google Cloud Platform account with billing enabled.
- A GitHub account and a repository for this project.

### 2. GCP Authentication

The GitHub Actions workflow needs to authenticate to your GCP account.

1.  **Create a Service Account:**
    -   In the GCP Console, navigate to **IAM & Admin > Service Accounts**.
    -   Click **Create Service Account**.
    -   Give it a name (e.g., `github-actions-vpn`).
    -   Grant the following roles:
        -   `Compute Admin`
        -   `Service Account User`
        -   `Cloud Scheduler Admin`
        -   `OS Config Patch Deployment Admin`
        -   `Monitoring Admin`
        -   `Billing Account User` (for budget alerts)
        -   `Pub/Sub Publisher`
    -   Click **Done**.

2.  **Create a Service Account Key:**
    -   Find the service account you just created.
    -   Click the three dots under **Actions** and select **Manage keys**.
    -   Click **Add Key > Create new key**.
    -   Select **JSON** as the key type and click **Create**. A JSON file will be downloaded.

3.  **Add Secrets to GitHub:**
    -   In your GitHub repository, go to **Settings > Secrets and variables > Actions**.
    -   Create the following secrets:
        -   `GCP_PROJECT_ID`: Your GCP project ID.
        -   `GCP_SA_KEY`: The contents of the JSON key file you downloaded.
        -   `GCP_BILLING_ACCOUNT_ID`: Your GCP billing account ID. You can find this in the GCP Console under **Billing**.

### 3. Terraform Variables

Create a file named `terraform/terraform.tfvars` with the following content:

```hcl
gcp_project_id         = "your-gcp-project-id"
notification_email     = "your-email@example.com"
gcp_billing_account_id = "your-gcp-billing-account-id"
```

Replace the values with your actual GCP project ID, notification email, and billing account ID.

### 4. Deployment

The deployment is fully automated using GitHub Actions.

1.  Commit the `terraform.tfvars` file (or ensure the variables are set in your CI/CD environment).
2.  Push your changes to the `main` branch of your repository.
3.  The GitHub Actions workflow will automatically run `terraform apply` and deploy your VPN server.

### 5. Retrieve Client Configuration

After the first successful deployment, the WireGuard client configuration will be available in the serial console output of the VM.

1.  In the GCP Console, navigate to **Compute Engine > VM instances**.
2.  Click on the `personal-vpn-vm-xxxx` instance.
3.  Scroll down and click on **Serial port 1 (console)**.
4.  Scroll to the bottom of the log. You will find the client configuration in two formats:
    -   **QR Code:** You can scan this directly with the WireGuard mobile app.
    -   **Raw Text:** You can copy and paste this into a `.conf` file for desktop clients.

### 6. Client Setup

-   **Android/iOS:** Install the official WireGuard app from the Play Store or App Store. Use the "Create from QR code" option.
-   **Desktop (Windows/macOS/Linux):** Install the official WireGuard client for your OS. Create a new empty tunnel and paste the raw text configuration.

## Maintenance

-   **OS Updates:** The VM will be automatically updated with security patches every Sunday at 2 AM UTC.
-   **Terraform Providers:** Dependabot will automatically create pull requests to update the Terraform providers. You just need to merge them.
