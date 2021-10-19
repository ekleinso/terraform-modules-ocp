variable "cluster_id" {
  type = string
  description = "Cluster identifier"
}

variable "cluster_dir" {
  type = string
  description = "Directory containing cluster configurations"
}

variable "fstype" {
  type = string
  description = "FileSystem type to format the volumes"
  default = "ext4"
}

variable "storage_class" {
  type = string
  description = "Storage class name for the provisioner"
  default = "iscsi"
}

variable "server" {
  type = string
  description = "Address/hostname for iSCSI server"
}

variable "port" {
  type = string
  description = "Port for iSCSI server"
  default = "3260"
}

variable "user" {
  type = string
  description = "Username for targetd server"
}

variable "password" {
  type = string
  description = "Password for targetd server"
}

variable "volumegroup" {
  type = string
  description = "Volume group or thin storage pool for iSCSI"
}

variable "wwn" {
  type = string
  description = "World wide name for iSCSI server"
}

variable "initiators" {
  type = string
  description = "Comma delimitetd list of WWN for the iSCSI initiators (aka worker node wwn)"
}

variable "image" {
  type = string
  description = "Docker image to run the server"
  default = "quay.io/external_storage/iscsi-controller:latest"
}

variable "is_default_class" {
  type = string
  description = "Should created storage class be the default"
  default = "false"
}

