  terraform {
    required_providers {
      scaleway = {
        source = "scaleway/scaleway"
      }
    }
    required_version = ">= 0.13"
  }
  provider "scaleway" {
#    access_key      = SCW_ACCESS_KEY
#    secret_key      = "<SCW_SECRET_KEY>"
#    project_id	    = "<SCW_DEFAULT_PROJECT_ID>"
    zone            = "fr-par-1"
    region          = "fr-par"
  }

  resource "scaleway_instance_ip" "public_ip" {}
  resource "scaleway_block_volume" "data" {
    size_in_gb = 30
    iops = 5000
  }

resource "scaleway_instance_security_group" "my-security-group" {
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = "22"
  }

  inbound_rule {
    action = "accept"
    port   = "80"
  }

  inbound_rule {
    action = "accept"
    port   = "443"
  }
}

  resource "scaleway_instance_server" "my-instance" {
    type  = "DEV1-L"
    image = "ubuntu_jammy"

    tags = ["terraform instance", "my-instance"]

    ip_id = scaleway_instance_ip.public_ip.id

    additional_volume_ids = [scaleway_block_volume.data.id]

    root_volume {
      # The local storage of a DEV1-L Instance is 80 GB, subtract 30 GB from the additional block volume, then the root volume needs to be 50 GB.
      size_in_gb = 50
    }

    security_group_id = scaleway_instance_security_group.my-security-group.id
  }
