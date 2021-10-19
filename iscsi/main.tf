locals {
  project = "${var.cluster_id}-storage"
}

data "template_file" "k8s_iscsi_yaml" {
  template = file("${path.module}/templates/iscsi.tpl")
  vars = {
    server = var.server
    port = var.port
    username = base64encode(var.user)
    password = base64encode(var.password)
    volumegroup = var.volumegroup
    wwn = var.wwn
    fstype = var.fstype
    initiators = var.initiators
    provisioner_image = var.image
    cluster_name = var.cluster_id
    storage_class = var.storage_class
    is_default_class = var.is_default_class
    project = local.project
    image = var.image
  }
}

#
resource "local_file" "k8s_iscsi_yaml" {
    lifecycle {
       ignore_changes = [content]
    }
    content  = data.template_file.k8s_iscsi_yaml.rendered
    filename = format("%s/storage/k8s_iscsi.yaml", var.cluster_dir)
    file_permission = 644
}

resource "null_resource" "ocp_iscsi" {
  provisioner "local-exec" {
    command = <<EOF
set -ex

CURRENT_DEFAULT=`binaries/oc get sc | grep default | awk '{print $1}'`
if [[ "${var.is_default_class}" == "true" && -n "$CURRENT_DEFAULT" ]]; then
  binaries/oc annotate sc/$CURRENT_DEFAULT storageclass.kubernetes.io/is-default-class-
fi

binaries/oc apply -f ${local_file.k8s_iscsi_yaml.filename}

EOF

    environment = {
      KUBECONFIG  = format("%s/auth/kubeconfig", var.cluster_dir)
    }

    working_dir = var.cluster_dir
  }

  depends_on = [
    local_file.k8s_iscsi_yaml
  ]
}

