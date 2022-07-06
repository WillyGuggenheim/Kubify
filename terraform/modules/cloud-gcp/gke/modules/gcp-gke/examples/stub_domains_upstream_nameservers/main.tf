

locals {
  cluster_type = "domains-nameservers"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                 = "../../"
  project_id             = var.project_id
  name                   = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region                 = var.region
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = var.ip_range_pods
  ip_range_services      = var.ip_range_services
  create_service_account = false
  service_account        = var.compute_engine_service_account

  configure_ip_masq = true

  stub_domains = {
    "example.com" = [
      "10.254.154.11",
      "10.254.154.12",
    ]
    "example.net" = [
      "10.254.154.11",
      "10.254.154.12",
    ]
  }

  upstream_nameservers = ["8.8.8.8", "8.8.4.4"]
}
