output "network_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.main.name
}

output "network_self_link" {
  description = "The URI of the VPC network."
  value       = google_compute_network.main.self_link
}

output "subnet_self_links" {
  description = "A map of subnet names to their self links."
  value = {
    for name, subnet in google_compute_subnetwork.subnets : name => subnet.self_link
  }
}

output "subnet_names" {
  description = "A list of created subnet names."
  value       = [for subnet in google_compute_subnetwork.subnets : subnet.name]
}
