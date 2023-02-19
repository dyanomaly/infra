variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "homelab"
}

variable "kubernetes_version" {
  description = "Kubernetes release version used for container images"
  type        = string
  default     = "v1.26.1"
}

variable "installer_version" {
  description = "Talos installer version"
  type        = string
  default     = "v1.3.4"
}

variable "coredns_version" {
  description = "CoreDNS image version"
  type        = string
  default     = "1.10.0"
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "172.16.73.40" = {
        install_disk = "/dev/sda"
        hostname     = "kctrlplane40"
      },
      "172.16.73.41" = {
        install_disk = "/dev/sda"
        hostname     = "kctrlplane41"
      },
      "172.16.73.42" = {
        install_disk = "/dev/sda"
        hostname     = "kctrlplane42"
      }
    }
    workers = {
      "172.16.73.50" = {
        install_disk = "/dev/sda"
        hostname     = "kworker50"
      },
      "172.16.73.51" = {
        install_disk = "/dev/sda"
        hostname     = "kworker51"
      },
      "172.16.73.52" = {
        install_disk = "/dev/sda"
        hostname     = "kworker52"
      }
    }
  }
}
