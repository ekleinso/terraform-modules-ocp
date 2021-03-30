variable "cluster_id" {
  type = string
  description = "Cluster identifier"
}

variable "cluster_dir" {
  type = string
  description = "Directory containing cluster configurations"
}

variable "ldap_server" {
  type = string
  description = "IP address or hostname of ldap/msad server"
}

variable "ldap_bind_dn" {
  type = string
  description = "bind DN to connect to ldap/msad will be combined with baseDN"
}

variable "ldap_password" {
  type = string
  description = "bind password to connect to ldap/msad"
}

variable "ldap_type" {
  type = string
  description = "type of ldap server openldap or msad"
}

variable "ldap_base_dn" {
  type = string
  description = "base DN for ldap/msad"
}

variable "ldap_certificate" {
  type = string
  description = "Certificate for ldap/msad server if TLS is required and using self-signed cert"
  default = ""
}

variable "msad_whitelist" {
  type = string
  description = "Whitelist file for MSAD group synchronization"
  default = ""
}

