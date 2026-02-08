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

## Getting Started

This guide will help you set up the environment needed to deploy and manage your personal VPN.

### 1. Project Setup and API Enablement

If you are starting with a new Google Cloud project, you need to enable the required APIs.

1.  **Create a new GCP Project:** If you don't have one already, create a new project in the [GCP Console](https://console.cloud.google.com/).
2.  **Enable Billing:** Make sure billing is enabled for your project.
3.  **Enable APIs:** Enable the following APIs for your project. You can do this from the [APIs & Services Dashboard](https://console.cloud.google.com/apis/dashboard).
    -   `Compute Engine API`
    -   `Cloud Billing API`
    -   `Cloud Billing Budget API`
    -   `Cloud Monitoring API`
    -   `OS Config API`
    -   `Cloud Scheduler API`
    -   `Pub/Sub API`

    You can enable them all with the following `gcloud` command:
    ```bash
    gcloud services enable \
      compute.googleapis.com \
      cloudbilling.googleapis.com \
      billingbudgets.googleapis.com \
      monitoring.googleapis.com \
      osconfig.googleapis.com \
      cloudscheduler.googleapis.com \
      pubsub.googleapis.com
    ```

### 2. GitHub Actions Authentication

The GitHub Actions workflow needs to authenticate to your GCP account to manage the infrastructure.

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
        -   `NOTIFICATION_EMAIL`: The email address to send monitoring alerts to.

### 3. Local Development Authentication

If you are developing locally within the dev container, you need to authenticate the gcloud CLI.

1.  **Login to Google Cloud:**
    Run the following command in your terminal:
    ```bash
    gcloud auth login
    ```
    This will open a browser window for you to log in to your Google account.

2.  **Set Application Default Credentials (ADC):**
    Run the following command:
    ```bash
    gcloud auth application-default login
    ```

3.  **Set the Quota Project:**
    To avoid issues with the billing API, set the quota project:
    ```bash
    gcloud auth application-default set-quota-project YOUR_GCP_PROJECT_ID
    ```
    Replace `YOUR_GCP_PROJECT_ID` with your actual GCP project ID.

### 4. Deployment

The deployment is fully automated using GitHub Actions.

1.  Push your changes to the `main` branch of your repository.
2.  The GitHub Actions workflow will automatically run `terraform apply` and deploy your VPN server.
3.  If you want to run terraform locally, you will need to provide the variables `gcp_project_id`, `notification_email`, and `gcp_billing_account_id`. You can do this by creating a `terraform.tfvars` file or by passing them as command-line arguments. For example:
    ```bash
    terraform apply -var="gcp_project_id=your-project-id" -var="notification_email=your-email" -var="gcp_billing_account_id=your-billing-id"
    ```

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
