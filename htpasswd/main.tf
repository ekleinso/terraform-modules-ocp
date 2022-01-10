locals {
  password = var.password == "" ? random_password.password.result : var.password
}

resource "random_password" "password" {
  length = var.random_password_length
  special = true
  override_special = "-"
}

resource "local_file" "password_file" {
    content  = format("%s\n", local.password)
    filename = "${var.cluster_dir}/auth/${var.user}-password"
    file_permission = 600
}

resource "local_file" "htpasswd" {
    content  = format("%s:%s\n", var.user, bcrypt(local.password,6))
    filename = "${var.cluster_dir}/auth/htpasswd"
    file_permission = 644
}

resource "null_resource" "ocp_htpasswd" {
  provisioner "local-exec" {
    command = <<EOF
set -ex


binaries/oc create secret generic ${var.user}-secret --from-file=htpasswd=${local_file.htpasswd.filename} -n openshift-config

if [[ "$(binaries/oc get oauth.config.openshift.io cluster -o jsonpath='{.spec.identityProviders}')" == "" ]]; then
  binaries/oc patch oauth.config.openshift.io cluster --type json --patch '[{"op": "add", "path": "/spec/identityProviders", "value":[{"htpasswd":{"fileData":{"name":"${var.user}-secret"}},"mappingMethod":"claim","name":"${var.user}","type":"HTPasswd"}]}]'
else
  binaries/oc patch oauth.config.openshift.io cluster --type json --patch '[{"op": "add", "path": "/spec/identityProviders/-", "value": {"htpasswd":{"fileData":{"name":"${var.user}-secret"}},"mappingMethod":"claim","name":"${var.user}","type":"HTPasswd"}}]'
fi

binaries/oc adm policy add-cluster-role-to-user cluster-admin ${var.user}

EOF

    environment = {
      KUBECONFIG  = format("%s/auth/kubeconfig", var.cluster_dir)
    }

    working_dir = var.cluster_dir
  }

  depends_on = [
    local_file.htpasswd
  ]
}

