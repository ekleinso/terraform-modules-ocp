provider "dns" {
  update {
    server        = var.dns_server
    key_name      = var.key_name
    key_algorithm = var.key_algorithm
    key_secret    = var.key_secret
  }
}

resource "dns_a_record_set" "cluster" {
  for_each = var.hostnames_ip_addresses

  zone = "${var.dns_domain}."
  name = format("%s.%s", element(split(".", each.value), 0), var.cluster_name)
  addresses = [
    each.key
  ]
  ttl = 300
}

resource "dns_ptr_record" "cluster" {
  for_each = var.hostnames_ip_addresses
  
  zone = format("%s.%s.in-addr.arpa.", element(split(".", each.key), 1), element(split(".", each.key), 0))
  name = format("%s.%s", element(split(".", each.key), 3), element(split(".", each.key), 2))
  ptr  = format("%s.", each.value)
  ttl  = 300
}

resource "dns_a_record_set" "api" {
  count = var.api_vip != "" ? 1 : 0
  zone = "${var.dns_domain}."
  name = format("api.%s", var.cluster_name)
  addresses = [
    var.api_vip
  ]
  ttl = 300
}

resource "dns_a_record_set" "api_int" {
  count = var.api_vip != "" ? 1 : 0
  zone = "${var.dns_domain}."
  name = format("api-int.%s", var.cluster_name)
  addresses = [
    var.api_vip
  ]
  ttl = 300
}

resource "dns_a_record_set" "apps" {
  count = var.ingress_vip != "" ? 1 : 0
  zone = "${var.dns_domain}."
  name = format("*.apps.%s", var.cluster_name)
  addresses = [
    var.ingress_vip
  ]
  ttl = 300
}

