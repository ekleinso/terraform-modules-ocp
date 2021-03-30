locals {
  oauth_cert = "ldap-ca-crt"
}

data "template_file" "k8s_oauth_yaml" {
  template = var.ldap_type == "msad" ? file("${path.module}/templates/k8s_oauth_msad.tpl") : file("${path.module}/templates/k8s_oauth.tpl")
  vars = {
    ldap_host = var.ldap_certificate != "" ? "ldaps://${var.ldap_server}:636" : "ldap://${var.ldap_server}:389"
    bind_dn = var.ldap_bind_dn
    base_dn = var.ldap_base_dn
    cluster_name = var.cluster_id
    insecure = var.ldap_certificate != "" ? false : true
    certificate = var.ldap_certificate != "" ? local.oauth_cert : ""
    ldap_type = var.ldap_type
  }
}

data "template_file" "k8s_ldap_sync_yaml" {
  template = var.ldap_type == "msad" ? file("${path.module}/templates/k8s_msad_sync_config.tpl") : file("${path.module}/templates/k8s_rfc2307_config.tpl")
  vars = {
    ldap_host = var.ldap_certificate != "" ? "ldaps://${var.ldap_server}:636" : "ldap://${var.ldap_server}:389"
    bind_dn = var.ldap_bind_dn
    base_dn = var.ldap_base_dn
    cluster_name = var.cluster_id
    insecure = var.ldap_certificate != "" ? false : true
    certificate = var.ldap_certificate
    ldap_type = var.ldap_type
    bind_password = var.ldap_password
  }
}

#
resource "local_file" "k8s_oauth_yaml" {
    content  = data.template_file.k8s_oauth_yaml.rendered
    filename = format("%s/ldap/k8s_oauth.yaml", var.cluster_dir)
    file_permission = 644
}

resource "local_file" "k8s_ldap_sync_yaml" {
    content  = data.template_file.k8s_ldap_sync_yaml.rendered
    filename = format("%s/ldap/k8s_ldap_sync.yaml", var.cluster_dir)
    file_permission = 644
}

resource "null_resource" "ocp_ldap" {
  provisioner "local-exec" {
    command = <<EOF
set -ex

binaries/oc -n openshift-config create secret generic ldap-bind-password-${var.cluster_id} --from-literal=bindPassword=${var.ldap_password}
if [ -f "${var.ldap_certificate}" ]
then
   binaries/oc -n openshift-config create configmap ${local.oauth_cert} --from-file=ca.crt=${var.ldap_certificate}
fi
binaries/oc replace -f ${local_file.k8s_oauth_yaml.filename}
if [ "${var.ldap_type}" == "openldap" ]
then
   binaries/oc adm groups sync --sync-config=${local_file.k8s_ldap_sync_yaml.filename} --confirm
else
   binaries/oc adm groups sync --sync-config=${local_file.k8s_ldap_sync_yaml.filename} --whitelist=${var.msad_whitelist} --confirm
fi
binaries/oc adm policy add-cluster-role-to-group cluster-admin ${var.cluster_id}-Admins

EOF

    environment = {
      KUBECONFIG  = format("%s/auth/kubeconfig", var.cluster_dir)
    }

    working_dir = var.cluster_dir
  }

  depends_on = [
    local_file.k8s_oauth_yaml,
    local_file.k8s_ldap_sync_yaml
  ]
}

