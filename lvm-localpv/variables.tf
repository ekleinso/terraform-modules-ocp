variable "cluster_dir" {
  type = string
  description = "Directory containing cluster configurations"
}

variable "storage_class" {
  type = string
  description = "Storage class name for the provisioner"
  default = "openebs-lvmsc"
}

variable "volgroup" {
  type = string
  description = "Volume group"
  default = "lvmvg"
}

variable "pv" {
  type = string
  description = "Physical volume"
  default = "/dev/vdb"
}

variable "is_default_class" {
  type = string
  description = "Should created storage class be the default"
  default = "false"
}
