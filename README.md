# terraform-modules-ocp
This is a collection of terraform modules that configure OCP.

| module | function        |
|----------------|--------------|
| certs   | Configures certificates for the cluster with self-signed certificates. A root CA or intermediate certificate and key are needed |
| dyndns  | Updates DNS with entries for API and Ingress VIPs as well as cluster hosts |
| htpasswd | Configures an HTPasswd oAuth identity provider     |
| iscsi | Configures the opensource [iscsi/targetd provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/iscsi/targetd) |
| ldap | Configures an LDAP/MSAD oAuth identity provider |
| nfs | Configures the opensource [nfs ganesha provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) |
| nfs-client | Configures the opensource [nfs subdir provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) |
| wait-for | Runs openshift-install wait-for tasks to check OpenShift installation status |

As with most modules you would look at the variables.tf file to determine what the inputs are for the module. Two other inputs of note:
- The source points to where the module source is located. It can be a local directory or a git source repo.
- The depends_on variable allows you to create dependencies between resources in scenarios where one resource depends on another but there is no built in dependency through output variables. If dependencies are not needed the parameter can be removed. 

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

### Calling dyndns module
This module configures DNS if the DNS server allows dynamic updating. 

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

### Calling htpasswd module
This module configures the HTPasswd identity provider enabling a simple local login for when kubeadmin is removed.

```terraform
module "cluster_htpasswd" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//htpasswd?ref=1.1"
  depends_on = []

  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  password = "********"
  user = "ocpadmin"
}
```
#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| password                 | The password for the specified user. | string | "" |
| random_password_length   | If a password is not specified a random password will be generated using the length specified here | number | 24 |
| user                      | The user to specifiy for htpasswd | string | ocpadmin |
| cluster_dir                  | The directory where the openshift-install command was executed. Should contain the auth folder username. The password will be copied to a file here <username>-password     | string | - |

### Calling iscsi module
This module configures the iSCSI provisioner using [iscsi/targetd provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/iscsi/targetd). It expects that the iSCSI target is configured and targetd is running. The provided link has good documentation on configuring the iSCSI server.

The configuration requires the WWN of all the iSCSI initiators. It is found in the **/etc/iscsi/initiatorname.iscsi** file on each node in the cluster. This information either needs to be collected from all the nodes or it is possible to update the initiator names on all the nodes using machine configs.

```terraform

module "cluster_iscsi_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//iscsi?ref=1.1"

  depends_on = []

  cluster_id = "my_cluster_name"
  cluster_dir = format("%s/%s/installer", abspath(path.root), "my_cluster_name")

  storage_class = format("%s-block", "my_cluster_name")
  server = "192.168.0.9"
  port = "3260"
  volumegroup = "vg_targetd/thinpoollv"
  wwn = "iqn.2003-01.org.linux-iscsi.host:tgt1"
  initiators = "iqn.2003-01.org.linux-iscsi.host:master1,iqn.2003-01.org.linux-iscsi.host:master2,iqn.2003-01.org.linux-iscsi.host:master3,iqn.2003-01.org.linux-iscsi.host:worker1"

  user = "admin"
  password = "**********"
  is_default_class = "false"
}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id                   | The ID/Name of the cluster  | string | - |
| cluster_dir                  | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| fstype                 | The filesystem to format the storage with. | string | ext4 |
| storage_class   | The name of the storage class to be created | string | iscsi |
| server          | Address/hostname for iSCSI server | string | - |
| port            | Port for iSCSI server     | string | 3260 |
| user            | Username for targetd server | string | - |
| password        | Password for targetd server | string | - |
| volumegroup     | LVM volume group or logical volume thin pool to carve LUNs | string | - |
| wwn             | World wide name for iSCSI server | string | - |
| initiators      | Comma delimitetd list of WWN for the iSCSI initiators (aka worker node wwn) | string | - |
| image          | Docker image to run the provisioner in OpenShift | string | quay.io/external_storage/iscsi-controller:latest |
| is_default_class | Should created storage class be the default | string | false |


### Calling ldap module
```terraform
module "cluster_ldap" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//ldap?ref=1.1"
  depends_on = []

  cluster_id = local.instance_id
  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  ldap_server = "openldap.ocp.example.com"
  ldap_bind_dn = "cn=Manager"
  ldap_password = "********"
  ldap_type = "openldap"
  ldap_base_dn = "dc=ocp,dc=example,dc=com"
}
```

### Calling nfs module
```terraform
module "cluster_nfs_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//nfs?ref=1.1"

  depends_on = []

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", abspath(path.root), var.cluster_id)

  storage_class = "nfs"
  pvc_storage_class = "thin"
  pvc_size = "100G"
  is_default_class = "true"
}
```

### Calling nfs-client module
```terraform
locals {
  nfs_server = "192.168.0.9"
  nfs_server_path = "/repository/kubevols"
}

module "cluster_nfs_client_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//nfs-client?ref=1.1"

  depends_on = []

  cluster_id = local.instance_id
  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  storage_class = format("%s-file", local.instance_id)
  nfs_server = local.nfs_server
  nfs_server_path = local.nfs_server_path
  is_default_class = "false"
}
```

### Calling wait-for module
```terraform
module "wait_for_bootstrap" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//wait-for?ref=1.1"

  depends_on = []

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", path.root, var.cluster_id)

  what_for = "bootstrap-complete"
}

module "wait_for_install" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//wait-for?ref=1.1"

  depends_on = [module.wait_for_bootstrap]

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", path.root, var.cluster_id)

  what_for = "install-complete"
}
```