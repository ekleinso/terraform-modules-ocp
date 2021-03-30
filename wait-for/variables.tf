// OCP cluster name
variable "cluster_id" {
  type = string
}

// OCP cluster config directory
variable "cluster_dir" {
  type = string
}

// What to wait for
variable "what_for" {
  type = string
}

// log level (e.g. "debug | info | warn | error") (default "info")
variable "log_level" {
  type = string
  default = "info"
}

