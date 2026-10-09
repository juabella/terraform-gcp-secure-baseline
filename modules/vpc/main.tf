locals {
  subnets = {
    for idx, subnet in var.subnets : subnet.subnet_name => {
      subnet_name           = subnet.subnet_name
      subnet_ip             = subnet.subnet_ip
      subnet_region         = coalesce(subnet.subnet_region, var.region)
      subnet_private_access = subnet.subnet_private_access
      description           = subnet.description
      secondary_ranges      = subnet.secondary_ranges
    }
  }
}

resource "google_compute_network" "main" {
  name                            = var.network_name
  project                         = var.project_id
  auto_create_subnetworks         = false
  delete_default_routes_on_create = var.delete_default_internet_gateway_routes
  routing_mode                    = "REGIONAL"
}

resource "google_compute_subnetwork" "subnets" {
  for_each = local.subnets

  name                     = each.value.subnet_name
  project                  = var.project_id
  network                  = google_compute_network.main.name
  region                   = each.value.subnet_region
  ip_cidr_range            = each.value.subnet_ip
  private_ip_google_access = each.value.subnet_private_access
  description              = each.value.description

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.main.name

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

  allow {
    protocol = "all"
  }

  priority = 65534
}
