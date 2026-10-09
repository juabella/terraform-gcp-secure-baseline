variable "project_id" {
  description = "The ID of the GCP project where the VPC will be created."
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network being created."
  type        = string
  default     = "secure-vpc"
}

variable "region" {
  description = "The default region for the subnets."
  type        = string
  default     = "us-central1"
}

variable "subnets" {
  description = "List of subnet configurations. Includes secondary ranges for GKE readiness."
  type = list(object({
    subnet_name           = string
    subnet_ip             = string
    subnet_region         = optional(string)
    subnet_private_access = optional(bool, true)
    description           = optional(string, "Managed by Terraform")
    secondary_ranges = optional(list(object({
      range_name    = string
      ip_cidr_range = string
    })), [])
  }))
  default = []
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for all subnets (CIS Benchmark 3.6 compliant)."
  type        = bool
  default     = true
}

variable "delete_default_internet_gateway_routes" {
  description = "If true, deletes the default route (0.0.0.0/0) created automatically by GCP."
  type        = bool
  default     = true
}
