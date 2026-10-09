# terraform-gcp-secure-baseline

[![CI](https://github.com/juabella/terraform-gcp-secure-baseline/actions/workflows/ci.yml/badge.svg)](https://github.com/juabella/terraform-gcp-secure-baseline/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Terraform module that creates a Google Cloud VPC with secure defaults: custom subnets only, Private Google Access, and VPC Flow Logs turned on by default.

This is the free starting point for a planned set of GCP modules aimed at teams that have to answer to security reviewers and auditors. See the [Roadmap](#roadmap).

## What the module does

- Creates a VPC with `auto_create_subnetworks = false`, so no subnets exist that you did not define
- Creates the subnets you list, each with Private Google Access enabled by default
- Enables VPC Flow Logs on every subnet by default (10-minute aggregation, 50% sampling, all metadata)
- Supports secondary IP ranges per subnet, for example GKE pod and service ranges
- Adds a firewall rule that allows traffic from private (RFC 1918) address ranges
- Deletes the default route to the internet that GCP creates automatically, unless you turn that off (see [Behavior notes](#behavior-notes))

## What it does not do

This module covers the network layer only. It does not manage IAM, GKE, logging sinks, encryption keys (CMEK), organization policies, or VPC Service Controls. Some of these are planned; none exist yet.

Using this module does not make your environment compliant with any standard. It is designed to support secure-by-default network configuration, and you remain responsible for your own security and compliance review.

## Requirements

| Name | Version |
| --- | --- |
| Terraform | >= 1.5.0 |
| google provider | >= 5.0.0, < 6.0.0 |

## Quick start

```hcl
module "vpc" {
  source = "github.com/juabella/terraform-gcp-secure-baseline//modules/vpc?ref=v0.1.0"

  project_id   = "my-gcp-project"
  network_name = "example-secure-vpc"
  region       = "us-central1"

  subnets = [
    {
      subnet_name = "app-subnet"
      subnet_ip   = "10.10.1.0/24"
      secondary_ranges = [
        { range_name = "pods", ip_cidr_range = "10.10.10.0/24" },
        { range_name = "services", ip_cidr_range = "10.10.20.0/24" },
      ]
    },
    {
      subnet_name = "db-subnet"
      subnet_ip   = "10.10.2.0/24"
    },
  ]
}
```

A complete runnable example is in [`examples/basic-vpc`](examples/basic-vpc). Replace the placeholder project ID with a sandbox project and run `terraform plan` before applying anything.

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `project_id` | The GCP project ID where the VPC is created. | `string` | n/a | yes |
| `network_name` | Name of the VPC network. | `string` | `"secure-vpc"` | no |
| `region` | Default region for subnets that do not set their own. | `string` | `"us-central1"` | no |
| `subnets` | List of subnet objects: `subnet_name`, `subnet_ip`, optional `subnet_region`, `subnet_private_access` (default `true`), `description`, and `secondary_ranges`. | `list(object)` | `[]` | no |
| `enable_flow_logs` | Enable VPC Flow Logs on all subnets. | `bool` | `true` | no |
| `delete_default_internet_gateway_routes` | Delete the default internet route GCP creates with a new network. | `bool` | `true` | no |

## Outputs

| Name | Description |
| --- | --- |
| `network_name` | Name of the VPC network. |
| `network_self_link` | URI of the VPC network. |
| `subnet_self_links` | Map of subnet names to their self links. |
| `subnet_names` | List of created subnet names. |

## Behavior notes

- **No default internet route.** With the default setting, the VPC has no route to the internet. Features that depend on that route, such as Cloud NAT and Private Google Access, need routes you add yourself. Check Google's documentation for the routes your setup requires, or set `delete_default_internet_gateway_routes = false` to keep GCP's default behavior.
- **Flow logs cost money.** VPC Flow Logs generate Cloud Logging volume. Set `enable_flow_logs = false` if you do not want them.
- **The internal firewall rule is intentionally simple.** It allows traffic from private address ranges. Review it and tighten it for your environment.

## Testing

GitHub Actions runs on every push and pull request:

1. `terraform fmt -check`
2. `terraform validate` on the module and the example
3. TFLint on the module and the example
4. Checkov security scan

Any Checkov checks that are skipped are listed in [`.checkov.yaml`](.checkov.yaml) with the reason. CI validates and lints the code. It does not deploy to a live GCP project, so test in your own sandbox first.

## Roadmap

Planned, not yet released, and with no dates:

- IAM baseline module
- Hardened GKE module
- Centralized logging module
- Policy checks and CI/CD templates

If you want these, or want to tell me what your team needs most, join the early-access list: [LANDING_PAGE_URL](LANDING_PAGE_URL)

## Contributing and support

Issues and pull requests are welcome. This is maintained on a best-effort basis, with no guaranteed response time.

## License

[MIT](LICENSE)
