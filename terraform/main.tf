provider "kubernetes" {
  alias            = "forseti"
  load_config_file = true
}

provider "helm" {
  version         = "~> 0.10"
  alias           = "forseti"
  service_account = var.k8s_tiller_sa_name
  namespace       = module.forseti.kubernetes-forseti-namespace
  kubernetes {
    load_config_file       = false
    host                   = "https://${data.google_container_cluster.forseti_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.forseti_cluster.master_auth.0.cluster_ca_certificate)
  }
  debug                           = true
  automount_service_account_token = true
  install_tiller                  = true
}

locals {
  node_pool_index = [for index, node_pool in data.google_container_cluster.forseti_cluster.node_pool : index if node_pool.name == var.gke_node_pool_name][0]
}

resource "kubernetes_namespace" "forseti" {
  metadata {
    name = "forseti"
  }
}

data "google_container_cluster" "forseti_cluster" {
  name     = var.gke_cluster_name
  location = var.gke_cluster_location
  project  = var.project_id
}

data "google_client_config" "default" {}

data "google_compute_subnetwork" "forseti_subnetwork" {
  name    = var.subnetwork
  region  = var.region
  project = var.project_id
}

resource "google_project_iam_member" "cluster_service_account-storage_reader" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${data.google_container_cluster.forseti_cluster.node_pool[local.node_pool_index].node_config.0.service_account}"
}

# module "forseti_on_gke" {
#   source  = "terraform-google-modules/forseti/google//modules/on_gke"
#   version = "4.1.0"
#   # insert the 7 required variables here
# }

module "forseti" {
  providers = {
    kubernetes = kubernetes.forseti
    helm       = helm.forseti
  }
  source  = "terraform-google-modules/forseti/google//modules/on_gke"
  version = "~> 5.1"

  domain     = var.domain
  org_id     = var.org_id
  project_id = var.project_id

  client_region   = var.region
  cloudsql_region = var.region

  storage_bucket_location = var.region
  bucket_cai_location     = var.region

  network_policy = data.google_container_cluster.forseti_cluster.network_policy.0.enabled

  # gsuite_admin_email      = var.gsuite_admin_email
  # sendgrid_api_key        = var.sendgrid_api_key
  # forseti_email_sender    = var.forseti_email_sender
  # forseti_email_recipient = var.forseti_email_recipient
  # cscc_violations_enabled = var.cscc_violations_enabled
  # cscc_source_id          = var.cscc_source_id

  # config_validator_enabled         = var.config_validator_enabled
  # git_sync_private_ssh_key_file    = var.git_sync_private_ssh_key_file
  # k8s_forseti_server_ingress_cidr  = data.google_compute_subnetwork.forseti_subnetwork.ip_cidr_range
  # helm_repository_url              = var.helm_repository_url
  # policy_library_repository_url    = var.policy_library_repository_url
  # policy_library_repository_branch = var.policy_library_repository_branch
  # policy_library_sync_enabled      = var.policy_library_sync_enabled
  # server_log_level                 = var.server_log_level
}
