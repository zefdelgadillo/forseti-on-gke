variable "gsuite_admin_email" {

}

variable "domain" {

}

variable "project_id" {

}

variable "org_id" {

}

variable "gke_cluster_name" {

}

variable "gke_node_pool_name" {
  description = "The name of the GKE node-pool where Forseti is being deployed"
  default     = "forseti-node-pool"
}

variable "gke_cluster_location" {

}

variable "subnetwork" {

}

variable "region" {

}

variable "helm_repository_url" {
  description = "The Helm repository containing the 'forseti-security' Helm charts"
  default     = "https://forseti-security-charts.storage.googleapis.com/release/"
}

variable "k8s_tiller_sa_name" {
  default     = "tiller"
}
