job "unifi" {
  datacenters = ["dc1"]
  type = "service"

  group "mongodb" {
    network {
      mode = "bridge"
    }

    service {
      name = "mongodb"
      port = "27017"

      connect{
        sidecar_service {}
      }
    }

    volume "mongo" {
      type      = "host"
      read_only = false
      source    = "mongo"
    }

    task "mongo" {
      driver = "docker"

      config {
        image = "mongo:3.6"
      }

      volume_mount {
        volume      = "mongo"
        destination = "/data"
        read_only   = false
      }
    }
  }

  group "unifi-controller" {
    network {
      mode  = "bridge"

      port "device" {
        static = 8080
        to = 8080
      }

      port "https" {
        static = 8443
        to = 8443
      }

      port "stun" {
        static = 3478
        to = 3478
      }
    }

    service {
      name = "unifi"
      port = "https"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "mongodb"
              local_bind_port = 8808
            }
          }
        }
      }
    }

    volume "unifi" {
      type      = "host"
      read_only = false
      source    = "unifi"
    }

    task "controller" {
      driver = "docker"

      config {
        image = "jacobalberty/unifi:stable-6"
      }

      env {
          DB_URI = "mongodb://${NOMAD_UPSTREAM_ADDR_mongodb}/unifi"
          DB_NAME = "unifi"
          STATDB_URI = "mongodb://${NOMAD_UPSTREAM_ADDR_mongodb}/unifi_stat"
      }

      volume_mount {
        volume      = "unifi"
        destination = "/unifi"
        read_only   = false
      }
    }
  }
}
