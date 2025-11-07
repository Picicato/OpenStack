terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.43.0"
    }
  }
}

provider "openstack" {
  auth_url         = var.auth_url
  region           = var.region
  tenant_name      = var.project_name
  user_name        = var.username
  password         = var.password
  user_domain_name = var.user_domain_name
}

#resource "openstack_compute_keypair_v2" "gitlab_key" {
#  name       = "gitlab_key"
#  public_key = file(var.ssh_public_key)
#}

resource "openstack_compute_instance_v2" "gitlab_instance" {
  name        = "gitlab-instance"
  image_name  = var.image_name
  flavor_name = var.flavor_name
  #key_pair    = openstack_compute_keypair_v2.gitlab_key.name

  network {
    name = var.network_name
  }

  security_groups = ["default"]

  user_data = file("cloud-init.yml")

  metadata = {
    Name = "GitLab Server"
  }
}

output "gitlab_instance_ip" {
  value = openstack_compute_instance_v2.gitlab_instance.access_ip_v4
}