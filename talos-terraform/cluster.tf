resource "talos_machine_secrets" "machine_secrets" {}

resource "talos_machine_configuration_controlplane" "machineconfig_cp" {
  kubernetes_version = var.kubernetes_version

  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.endpoint}:6443"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  examples_enabled = false
  docs_enabled     = false
}

resource "talos_machine_configuration_worker" "machineconfig_worker" {
  kubernetes_version = var.kubernetes_version

  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${local.endpoint}:6443"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  examples_enabled = false
  docs_enabled     = false
}

resource "talos_client_configuration" "talosconfig" {
  cluster_name    = var.cluster_name
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets
  endpoints       = [for k, v in var.node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  talos_config          = talos_client_configuration.talosconfig.talos_config
  machine_configuration = talos_machine_configuration_controlplane.machineconfig_cp.machine_config
  for_each              = var.node_data.controlplanes
  endpoint              = each.key
  node                  = each.key
  config_patches = [
    templatefile("${path.module}/templates/cp.yaml.tmpl", {
      cluster_name = var.cluster_name
      registry     = local.registry
      endpoint     = local.endpoint
      ip_address   = each.key
      install_disk = each.value.install_disk

      kubernetes_version = var.kubernetes_version
      installer_version  = var.installer_version
      coredns_version    = var.coredns_version
    })
  ]
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  talos_config          = talos_client_configuration.talosconfig.talos_config
  machine_configuration = talos_machine_configuration_worker.machineconfig_worker.machine_config
  for_each              = var.node_data.workers
  endpoint              = each.key
  node                  = each.key
  config_patches = [
    templatefile("${path.module}/templates/worker.yaml.tmpl", {
      cluster_name = var.cluster_name
      registry     = local.registry
      endpoint     = local.endpoint
      ip_address   = each.key
      install_disk = each.value.install_disk

      kubernetes_version = var.kubernetes_version
      installer_version  = var.installer_version
    })
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  talos_config = talos_client_configuration.talosconfig.talos_config
  endpoint     = [for k, v in var.node_data.controlplanes : k][0]
  node         = [for k, v in var.node_data.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  talos_config = talos_client_configuration.talosconfig.talos_config
  endpoint     = [for k, v in var.node_data.controlplanes : k][0]
  node         = [for k, v in var.node_data.controlplanes : k][0]
}
