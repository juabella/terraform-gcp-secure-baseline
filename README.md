# terraform-gcp-secure-baseline

[![CI/CD](https://github.com/yourusername/terraform-gcp-secure-baseline/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/terraform-gcp-secure-baseline/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-≥1.5.0-623CE4.svg)](https://www.terraform.io)
[![Checkov](https://img.shields.io/badge/Checkov-Passing-007EC6.svg)](https://www.checkov.io)

Production-ready, security-hardened Terraform modules for Google Cloud Platform. Built by a Senior Cloud Architect with 15+ years of enterprise infrastructure experience. 

This open-core repository provides the foundational **VPC and IAM baseline**. For advanced modules (Hardened GKE, Centralized Logging, CIS Benchmark enforcement, and multi-environment CI/CD pipelines), check out the **[Pro Library](https://your-landing-page.com)**.

## 🛡️ Security & Compliance Mapping
This module is designed to align with industry security standards out of the box:

| Control Area | CIS GCP Benchmark v3.0.0 | Description |
| :--- | :---: | :--- |
| **Network Isolation** | 3.1, 3.2 | VPC configured with private Google access; no default internet gateways. |
| **IAM Least Privilege** | 1.1, 1.4 | Custom roles enforced; no primitive Owner/Editor roles granted. |
| **Encryption** | 4.1 | CMEK (Customer-Managed Encryption Keys) ready structure. |
| **Logging** | 6.1, 6.2 | VPC Flow Logs and Admin Activity logs enabled by default. |

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.5.0
- GCP Service Account with `roles/compute.networkAdmin` and `roles/iam.securityAdmin`
- Authentication configured (e.g., `gcloud auth application-default login`)

### Usage Example

```hcl
module "secure_vpc" {
  source  = "github.com/yourusername/terraform-gcp-secure-baseline//modules/vpc"
  version = "1.0.0"

  project_id  = "my-gcp-project"
  network_name = "prod-secure-vpc"
  region      = "us-central1"

  # Security defaults (can be overridden, but not recommended)
  enable_private_google_access = true
  enable_vpc_flow_logs         = true
  subnet_names                 = ["app-subnet", "db-subnet"]
  subnet_ip_cidr_ranges        = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "iam_baseline" {
  source  = "github.com/yourusername/terraform-gcp-secure-baseline//modules/iam"
  version = "1.0.0"

  project_id = "my-gcp-project"
  
  # Enforce least privilege
  disable_default_service_accounts = true
}
