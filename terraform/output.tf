output "kubernetes_endpoint" {
    value = data.google_container_cluster.forseti_cluster.endpoint
}
output "ip_cidr_range" {
    value = data.google_compute_subnetwork.forseti_subnetwork.ip_cidr_range
}
output "node_pool" {
    value = data.google_container_cluster.forseti_cluster.node_pool[local.node_pool_index]
}