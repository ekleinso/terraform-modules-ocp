# terraform-modules-ocp
This is a collection of terraform modules that configure OCP.

| module | function        |
|----------------|--------------|
| certs   | Configures certificates for the cluster with self-signed certificates. A root CA or intermediate certificate and ke arer neededd |
| dyndns  | Updates DNS with entries for API and Ingress VIPs as well as cluster hosts |
| htpasswd | Configures an HTPasswd oAuth identity provider     |
| iscsi | Configures the opensource [iscsi/targetd provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/iscsi/targetd) |
| ldap | Configures an LDAP/MSAD oAuth identity provider |
| nfs | Configures the opensource [nfs ganesha provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) |
| nfs-client | Configures the opensource [nfs subdir provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) |
| wait-for | Runs openshift-install wait-for tasks to check OpenShift installation status |

### Calling certs module
```terraform
module "cluster_certs" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//certs?ref=1.1"

  depends_on = []

  cluster_id = local.instance_id
  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  api_vip = local.config.platform.baremetal.apiVIP
  ingress_vip = local.config.platform.baremetal.ingressVIP

  dns_domain = local.config.baseDomain

  ca_cert_pem = "certs/ca.crt.pem"
  ca_private_key_pem = "certs/ca.key.pem"
}
```

### Calling dyndns module
```terraform
module "cluster_dns" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//dyndns?ref=1.1"

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

  cluster_name = var.cluster_id
  dns_server = var.dns["server"]
  dns_domain = var.base_domain
  key_name = var.dns["key_name"]
  key_algorithm = var.dns["key_algorithm"]
  key_secret = var.dns["key_secret"]

  api_vip = var.openshift_api_virtualip
  ingress_vip = var.openshift_ingress_virtualip
}
```

### Calling htpasswd module
```terraform
module "cluster_htpasswd" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//htpasswd?ref=1.1"
  depends_on = []

  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  password = "********"
  user = "ocpadmin"
}
```

### Calling iscsi module
```terraform
locals {
  iscsi_server = "192.168.0.9"
  iscsi_port = "3260"
  iscsi_block_pool = "vg_targetd/thinpoollv"
  iscsi_tgt_wwn = "iqn.2003-01.org.linux-iscsi.host:tgt1"
  tgtd_user = "admin"
  tgtd_password = "**********"
  iscsi_initiators = join(",", [for idx in range(length(local.config.platform.baremetal.hosts)) : format("%s:%s", local.wwn, element(split("-", local.config.platform.baremetal.hosts[idx].name), 2))])
  wwn = format("iqn.%s.%s.%s", formatdate("YYYY-MM", timestamp()), join(".", reverse(split(".", local.config.baseDomain))), local.instance_id)
}

module "cluster_iscsi_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//iscsi?ref=1.1"

  depends_on = []

  cluster_id = local.instance_id
  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  storage_class = format("%s-block", local.instance_id)
  server = local.iscsi_server
  port = local.iscsi_port
  volumegroup = local.iscsi_block_pool
  wwn = local.iscsi_tgt_wwn
  initiators = local.iscsi_initiators

  user = local.tgtd_user
  password = local.tgtd_password
  is_default_class = "false"
}

data "template_file" "worker_iscsi_config" {
  template = <<EOF
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-worker-regenerate-iscsi-initiatorname
spec:
  config:
    ignition:
      version: 3.2.0
    systemd:
      units:
      - name: coreos-regenerate-iscsi-initiatorname.service
        enabled: true
        contents: "# Regenerate /etc/iscsi/initiatorname.iscsi at boot\n[Unit]\nDocumentation=https://bugzilla.redhat.com/show_bug.cgi?id=1687722\nBefore=iscsid.service\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/sh -c 'echo \"InitiatorName=${local.wwn}:$$(hostname -s | cut -f3 -d \"-\")\" > /etc/iscsi/initiatorname.iscsi'\nRemainAfterExit=yes\n[Install]\nWantedBy=multi-user.target"
EOF
}

data "template_file" "master_iscsi_config" {
  template = <<EOF
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 99-master-regenerate-iscsi-initiatorname
spec:
  config:
    ignition:
      version: 3.2.0
    systemd:
      units:
      - name: coreos-regenerate-iscsi-initiatorname.service
        enabled: true
        contents: "# Regenerate /etc/iscsi/initiatorname.iscsi at boot\n[Unit]\nDocumentation=https://bugzilla.redhat.com/show_bug.cgi?id=1687722\nBefore=iscsid.service\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/sh -c 'echo \"InitiatorName=${local.wwn}:$$(hostname -s | cut -f3 -d \"-\")\" > /etc/iscsi/initiatorname.iscsi'\nRemainAfterExit=yes\n[Install]\nWantedBy=multi-user.target"
EOF
}

resource "local_file" "worker_iscsi_config" {
  lifecycle {
    ignore_changes = [content]
  }
  content  = data.template_file.worker_iscsi_config.rendered
  filename = format("%s/%s/cluster_configs/99_openshift-machineconfig_99-worker-regenerate-iscsi-initiatorname.yaml", path.module, local.instance_id)
  file_permission = 644
}

resource "local_file" "master_iscsi_config" {
  lifecycle {
    ignore_changes = [content]
  }
  content  = data.template_file.master_iscsi_config.rendered
  filename = format("%s/%s/cluster_configs/99_openshift-machineconfig_99-master-regenerate-iscsi-initiatorname.yaml", path.module, local.instance_id)
  file_permission = 644
}
```

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