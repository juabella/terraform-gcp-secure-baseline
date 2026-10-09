provider "google" {
  project = "your-test-project-id"
  region  = "us-central1"
}

module "secure_vpc" {
  source = "../../modules/vpc"

  project_id   = "your-test-project-id"
  network_name = "example-secure-vpc"
  region       = "us-central1"

  subnets = [
    {
      subnet_name           = "app-subnet"
      subnet_ip             = "10.10.1.0/24"
      subnet_private_access = true
      secondary_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.10.10.0/24"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.10.20.0/24"
        }
      ]
    },
    {
      subnet_name           = "db-subnet"
      subnet_ip             = "10.10.2.0/24"
      subnet_private_access = true
    }
  ]
}

output "vpc_name" {
  value = module.secure_vpc.network_name
}
