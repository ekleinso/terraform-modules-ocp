locals {
  project = "${var.cluster_id}-storage"
}

data "template_file" "k8s_storage_yaml" {
  template = file("${path.module}/templates/nfs-client.tpl")
  vars = {
    nfs_server = var.nfs_server
    nfs_server_path = var.nfs_server_path
    provisioner_image = var.image
    cluster_name = var.cluster_id
    storage_class = var.storage_class
    is_default_class = var.is_default_class
    project = local.project
    nfs_server_username = var.nfs_server_username
  }
}

#
resource "local_file" "k8s_storage_yaml" {
    content  = data.template_file.k8s_storage_yaml.rendered
    filename = format("%s/storage/k8s_nfs_client.yaml", var.cluster_dir)
    file_permission = 644
}

resource "null_resource" "config_nfs" {

  triggers = {
    type = "ssh"
    user = var.nfs_server_username
    server = var.nfs_server
    share = var.nfs_server_path
    cluster_name = var.cluster_id
    private_key = file(var.nfs_ssh_key)
  }

  lifecycle {
    ignore_changes = [triggers["type"], triggers["user"], triggers["server"], triggers["cluster_name"], triggers["share"], triggers["private_key"]]
  }

  connection {
    type     = self.triggers.type
    user     = self.triggers.user
    private_key = self.triggers.private_key
    host     = self.triggers.server
    agent    = "false"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${self.triggers.share}/${self.triggers.cluster_name}"
    ]
  }

  provisioner "remote-exec" {
    when   = destroy
    inline = [
      "rm -rf ${self.triggers.share}/${self.triggers.cluster_name}"
    ]
  }

}

resource "null_resource" "ocp_nfs_client" {
  provisioner "local-exec" {
    command = <<EOF
set -ex

CURRENT_DEFAULT=`binaries/oc get sc | grep default | awk '{print $1}'`
if [[ "${var.is_default_class}" == "true" && -n "$CURRENT_DEFAULT" ]]; then
  binaries/oc annotate sc/$CURRENT_DEFAULT storageclass.kubernetes.io/is-default-class-
fi

binaries/oc apply -f ${local_file.k8s_storage_yaml.filename}
binaries/oc project ${local.project}
binaries/oc adm policy add-scc-to-user ${var.cluster_id}-hostmount-anyuid -z nfs-client-provisioner

EOF

    environment = {
      KUBECONFIG  = format("%s/auth/kubeconfig", var.cluster_dir)
    }

    working_dir = var.cluster_dir
  }

  depends_on = [
    local_file.k8s_storage_yaml
  ]
}

