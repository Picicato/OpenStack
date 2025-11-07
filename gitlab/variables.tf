# OpenStack provider configuration
variable "auth_url" {
  description = "The authentication URL for OpenStack"
  type        = string
}

variable "region" {
  description = "value"
  type        = string
}

variable "project_name" {
  description = "The OpenStack project name (tenant name)"
  type        = string
}

variable "username" {
  description = "value"
  type        = string
}

variable "password" {
  description = "value"
  type        = string
  sensitive   = true
}

variable "user_domain_name" {
  description = "value"
  type = string
}

# SSH Key Pair
variable "ssh_public_key" {
  description = "Path to the SSH public key file"
  type        = string
}
# GitLab Instance Configuration
variable "image_name" {
  description = "The name of the image to use for the GitLab instance"
  type        = string
}

variable "flavor_name" {
  description = "The flavor name for the GitLab instance"
  type        = string
}

variable "vm_name" {
  description = "value"
  type        = string
}

variable "network_name" {
  description = "The name of the network to attach the GitLab instance to"
  type        = string

}