variable "password" {
  default = ""
}

variable "random_password_length" {
  type = number
  default = 24
}

variable "user" {
  default = "ocpadmin"
}

variable "cluster_dir" {
  type = string
}

