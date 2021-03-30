variable "cluster_id" {
  type = string
  description = "Cluster identifier"
}

variable "cluster_dir" {
  type = string
  description = "Directory containing cluster configurations"
}

variable "storage_class" {
  type = string
  description = "Storage class name for the provisioner"
  default = "nfs-client"
}

variable "nfs_server" {
  type = string
  description = "Address/hostname for NFS server"
}

variable "nfs_server_path" {
  type = string
  description = "NFS Server path"
}

variable "nfs_server_username" {
  type = string
  description = "User for remote NFS access"
}

variable "nfs_ssh_key" {
  type = string
  description = "User for remote NFS access"
  default = "~/.ssh/id_rsa"
}

variable "image" {
  type = string
  description = "Docker image to run the server"
  default = "quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11"
}

variable "is_default_class" {
  type = string
  description = "Should created storage class be the default"
  default = "false"
}
