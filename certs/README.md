### Calling certs module
In the first sample here we are invoking the certs module that configures certificates for the OpenShift ingress and API. 

```terraform
module "cluster_certs" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//certs?ref=1.1"

  depends_on = [null_resource.create_cluster]

  cluster_id = "my_cluster_name"
  cluster_dir = format("%s/%s/installer", abspath(path.root), "my_cluster_name")

  api_vip = "192.168.0.200"
  ingress_vip = "192.168.0.201"

  dns_domain = "example.com"

  ca_cert_pem = "/tmp/certs/ca.crt.pem"
  ca_private_key_pem = "/tmp/certs/ca.key.pem"
}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id                   | The ID/Name of the cluster  | string | - |
| cluster_dir                  | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| api_vip                      | The VIP for the OpenShift API servers | string | - |
| ingress_vip                  | The VIP for the OpenShift ingress | string | - |
| dns_domain                   | The base DNS Domain name    | string | - |
| ca_cert_chain                | Location of the user provided root CA certificate chain in the repo | string | - |
| ca_cert_pem                  | Location of the user provided root CA certificate in the repo | string | - |
| ca_private_key_pem           | Location of the user provided root CA certificate key in the repo | string | - |
| private_key_algorithm        | The name of the algorithm to use for private keys. Must be one of: RSA or ECDSA. | string | RSA |
| private_key_ecdsa_curve      | he name of the elliptic curve to use. Should only be used if var.private_key_algorithm is ECDSA. Must be one of P224, P256, P384 or P521. | string | P256 |
| private_key_rsa_bits        | The size of the generated RSA key in bits. Should only be used if var.private_key_algorithm is RSA. | string | 4096 |
| allowed_uses                | ist of keywords from RFC5280 describing a use that is permitted for the issued certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses. | list | "key_encipherment", "digital_signature" |
| validity_period_hours       | The number of hours after initial issuing that the certificate will become invalid. | string | 17520 |
