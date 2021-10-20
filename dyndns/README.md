# terraform-module-ocp-dyndns
Makes use of the [Terraform DNS provider](https://registry.terraform.io/providers/hashicorp/dns/latest/docs) 
to dynamically update a DNS server with entries for an OpenShift installation

### Calling dyndns module 

```terraform
module "cluster_dns" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//dyndns?ref=1.1"

  # This is joining lists and combining the lists into a map
  hostnames_ip_addresses = zipmap(
    concat(
      var.control_ip_addresses,
      var.compute_ip_addresses,
      var.storage_ip_addresses
    ),
    concat(
      local.control_fqdns,
      local.compute_fqdns,
      local.storage_fqdns
    )
  )

  cluster_name = "my_cluster_name"
  dns_server = "192.168.0.1"
  dns_domain = "example.com"

  # These parameters all come from the DNS server
  key_name = "ns1.example.com."
  key_algorithm = "hmac-md5"
  key_secret = "qgQiMOb/hi4RDBoyibojTw=="

  api_vip = "192.168.0.200"
  ingress_vip = "192.168.0.201"
}
```
#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_name                 | The ID/Name of the cluster  | string | - |
| hostnames_ip_addresses                  | A map of hostnames and IP addresses. IP address is key and hostname is value        | map | - |
| api_vip                      | The VIP for the OpenShift API servers | string | - |
| ingress_vip                  | The VIP for the OpenShift ingress | string | - |
| dns_domain                   | The base DNS Domain name    | string | - |
| dns_server                   | DNS server to provide dynDNS updates | string | - |
| key_name                     | Name of the key for DynDNS updates | string | - |
| key_algorithm                | key algorithm for DynDNS updates | string | - |
| key_secret                   | The secret key for DynDNS updates. | string | - |
