# Hub-Spoke Jenkins Pipeline Setup Guide

This guide details how to set up and use the two Jenkins pipelines for AMI creation and instance lifecycle management within an AWS Hub-Spoke architecture.

## Prerequisites

1.  **Jenkins Plugins**:
    *   Pipeline
    *   Email Extension (for notifications)
    *   SSH Build Agents
    *   AWS Steps (optional but recommended)
2.  **Tooling on Spoke Worker**:
    *   AWS CLI
    *   Packer
    *   Java (OpenJDK 11 or 17)
3.  **Credentials**:
    *   AWS Credentials configured on the Jenkins worker or via Jenkins credentials.
    *   SSH Private Key for the Spoke instance stored in Jenkins.

## Pipeline 1: AMI Creation (`Jenkinsfile.ami_creation`)

This pipeline builds a custom AMI with Nginx installed.

### Setup Instructions:
1.  Create a new **Pipeline** job in Jenkins named `AMI-Creation-Build`.
2.  Configure the job to pull from this repository.
3.  Set the script path to `Jenkinsfile.ami_creation`.
4.  Ensure the `spoke-linux` label is assigned to your Spoke Worker node.

### What it does:
1.  Generates a temporary AWS Key Pair.
2.  Runs Packer to launch a builder VM, install Nginx via `install_nginx.sh`, and create an AMI.
3.  Stores the generated keys in **AWS Secrets Manager**.
4.  Sends an email with the new AMI ID.

---

## Pipeline 2: Instance Spinup (`Jenkinsfile.instance_spinup`)

This pipeline manages the lifecycle of your production instances.

### Setup Instructions:
1.  Create a new **Pipeline** job in Jenkins named `multi-cloud-Instance_HubSpoke Spinup`.
2.  Configure the job to pull from this repository.
3.  Set the script path to `Jenkinsfile.instance_spinup`.

### Parameters:
*   **ACTION**: Choose `START` to launch a new instance or `STOP` to stop an existing one.
*   **AMI_ID**: (Optional for START) Provide a specific AMI ID. If left blank, it finds the latest AMI created by the build pipeline.
*   **INSTANCE_ID**: (Required for STOP) The ID of the instance you wish to halt.

### What it does:
*   **START**: Creates/updates the `production-web-sg` Security Group (Ports 22 & 80), launches a t2.micro instance, waits for it to be ready, and emails the Public IP.
*   **STOP**: Gracefully stops the specified instance and sends a confirmation email.

---

## Architecture Reminder (Hub-Spoke)

*   **Hub Account**: Jenkins Controller.
*   **Spoke Account**: Worker Node and Production Instances.
*   **Connectivity**: VPC Peering with route tables pointing to each other's CIDR blocks.
*   **Security**: Spoke Worker SG allows SSH only from the Hub VPC CIDR.
