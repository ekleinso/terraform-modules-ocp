// A map of hostnames and IP addresses
// hostname is key and IP address is value
variable "hostnames_ip_addresses" {
  type = map(string)
}

// OCP cluster name
variable "cluster_name" {
  type = string
}

// The OCP API VIP
variable "api_vip" {
  type = string
  default = ""
}

// The OCP Ingress VIP
variable "ingress_vip" {
  type = string
  default = ""
}

// DNS server to provide dynDNS updates
variable "dns_server" {
  type = string
}

// Base DNS domain name
variable "dns_domain" {
  type = string
}

// Name of the key for DynDNS updates
variable "key_name" {
  type = string
}

// key algorithm for DynDNS updates
variable "key_algorithm" {
  type = string
}

// The secret key for DynDNS updates
variable "key_secret" {
  type = string
}

